import os
from datetime import timedelta
from flask import Flask, jsonify, request
from flask_cors import CORS
from flask_jwt_extended import JWTManager, create_access_token, jwt_required, get_jwt_identity
from dotenv import load_dotenv
import bcrypt
from loguru import logger
import sys

# Import database components
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from database.config import SessionLocal
from database.models import User, Conversation, Message, Order, OrderItem
from backend.chatbot_api import chatbot_bp

# Load environment variables
load_dotenv()

# Create Flask app
app = Flask(__name__)
CORS(app)

# Configure JWT
app.config["JWT_SECRET_KEY"] = os.getenv("JWT_SECRET_KEY", "super-secret-key-change-in-production")
app.config["JWT_ACCESS_TOKEN_EXPIRES"] = timedelta(hours=1)
jwt = JWTManager(app)

# Configure logging
logger.add("logs/backend.log", rotation="500 MB", level="INFO")

# Register blueprints
app.register_blueprint(chatbot_bp)

@app.route("/api/health", methods=["GET"])
def health_check():
    """
    Health check endpoint
    """
    return jsonify({"status": "ok", "message": "Backend service is running"}), 200

@app.route("/api/auth/register", methods=["POST"])
def register():
    """
    Register a new user
    """
    data = request.get_json()
    
    # Validate required fields
    required_fields = ["username", "email", "password"]
    for field in required_fields:
        if field not in data:
            return jsonify({"error": f"Missing required field: {field}"}), 400
    
    # Check if user already exists
    db = SessionLocal()
    try:
        existing_user = db.query(User).filter(
            (User.username == data["username"]) | (User.email == data["email"])
        ).first()
        
        if existing_user:
            return jsonify({"error": "Username or email already exists"}), 409
        
        # Hash password
        hashed_password = bcrypt.hashpw(data["password"].encode("utf-8"), bcrypt.gensalt()).decode("utf-8")
        
        # Create new user
        new_user = User(
            username=data["username"],
            email=data["email"],
            password_hash=hashed_password,
            is_active=True
        )
        
        db.add(new_user)
        db.commit()
        
        # Create access token - Convert ID to string
        access_token = create_access_token(identity=str(new_user.id))
        
        return jsonify({
            "message": "User registered successfully",
            "access_token": access_token,
            "user": {
                "id": new_user.id,
                "username": new_user.username,
                "email": new_user.email
            }
        }), 201
        
    except Exception as e:
        db.rollback()
        logger.error(f"Error registering user: {str(e)}")
        return jsonify({"error": "Failed to register user"}), 500
    finally:
        db.close()

@app.route("/api/auth/login", methods=["POST"])
def login():
    """
    Authenticate user and return JWT token
    """
    data = request.get_json()
    
    # Validate required fields
    if not data.get("username") or not data.get("password"):
        return jsonify({"error": "Username and password are required"}), 400
    
    db = SessionLocal()
    try:
        # Find user by username
        user = db.query(User).filter(User.username == data["username"]).first()
        
        if not user or not bcrypt.checkpw(data["password"].encode("utf-8"), user.password_hash.encode("utf-8")):
            return jsonify({"error": "Invalid username or password"}), 401
        
        # Update last login timestamp
        from datetime import datetime
        user.last_login = datetime.utcnow()
        db.commit()
        
        # Create access token - Convert ID to string
        access_token = create_access_token(identity=str(user.id))
        
        return jsonify({
            "message": "Login successful",
            "access_token": access_token,
            "user": {
                "id": user.id,
                "username": user.username,
                "email": user.email
            }
        }), 200
        
    except Exception as e:
        db.rollback()
        logger.error(f"Error logging in user: {str(e)}")
        return jsonify({"error": "Failed to authenticate user"}), 500
    finally:
        db.close()

@app.route("/api/conversations", methods=["GET"])
@jwt_required()
def get_conversations():
    """
    Get all conversations for the current user
    """
    # Convert string user_id back to integer
    user_id = int(get_jwt_identity())
    
    db = SessionLocal()
    try:
        conversations = db.query(Conversation).filter(Conversation.user_id == user_id).all()
        
        result = []
        for conv in conversations:
            # Get the last message for preview
            last_message = db.query(Message).filter(
                Message.conversation_id == conv.id
            ).order_by(Message.timestamp.desc()).first()
            
            result.append({
                "id": conv.id,
                "start_time": conv.start_time.isoformat() if conv.start_time else None,
                "end_time": conv.end_time.isoformat() if conv.end_time else None,
                "duration": conv.duration,
                "last_message": last_message.content if last_message else None,
                "last_message_time": last_message.timestamp.isoformat() if last_message else None
            })
        
        return jsonify(result), 200
        
    except Exception as e:
        logger.error(f"Error retrieving conversations: {str(e)}")
        return jsonify({"error": "Failed to retrieve conversations"}), 500
    finally:
        db.close()

@app.route("/api/conversations", methods=["POST"])
@jwt_required()
def create_conversation():
    """
    Create a new conversation
    """
    # Convert string user_id back to integer
    user_id = int(get_jwt_identity())
    
    db = SessionLocal()
    try:
        new_conversation = Conversation(user_id=user_id)
        db.add(new_conversation)
        db.commit()
        
        return jsonify({
            "message": "Conversation created successfully",
            "conversation_id": new_conversation.id,
            "start_time": new_conversation.start_time.isoformat()
        }), 201
        
    except Exception as e:
        db.rollback()
        logger.error(f"Error creating conversation: {str(e)}")
        return jsonify({"error": "Failed to create conversation"}), 500
    finally:
        db.close()

@app.route("/api/conversations/<int:conversation_id>/messages", methods=["GET"])
@jwt_required()
def get_messages(conversation_id):
    """
    Get all messages for a specific conversation
    """
    # Convert string user_id back to integer
    user_id = int(get_jwt_identity())
    
    db = SessionLocal()
    try:
        # Check if conversation belongs to user
        conversation = db.query(Conversation).filter(
            Conversation.id == conversation_id,
            Conversation.user_id == user_id
        ).first()
        
        if not conversation:
            return jsonify({"error": "Conversation not found"}), 404
        
        messages = db.query(Message).filter(
            Message.conversation_id == conversation_id
        ).order_by(Message.timestamp.asc()).all()
        
        result = []
        for msg in messages:
            result.append({
                "id": msg.id,
                "is_user": msg.is_user,
                "content": msg.content,
                "timestamp": msg.timestamp.isoformat()
            })
        
        return jsonify(result), 200
        
    except Exception as e:
        logger.error(f"Error retrieving messages: {str(e)}")
        return jsonify({"error": "Failed to retrieve messages"}), 500
    finally:
        db.close()

@app.route("/api/conversations/<int:conversation_id>/messages", methods=["POST"])
@jwt_required()
def create_message(conversation_id):
    """
    Create a new message in a conversation
    """
    # Convert string user_id back to integer
    user_id = int(get_jwt_identity())
    data = request.get_json()
    
    if not data.get("content"):
        return jsonify({"error": "Message content is required"}), 400
    
    db = SessionLocal()
    try:
        # Check if conversation belongs to user
        conversation = db.query(Conversation).filter(
            Conversation.id == conversation_id,
            Conversation.user_id == user_id
        ).first()
        
        if not conversation:
            return jsonify({"error": "Conversation not found"}), 404
        
        # Create user message
        new_message = Message(
            conversation_id=conversation_id,
            is_user=True,
            content=data["content"]
        )
        db.add(new_message)
        db.commit()
        
        # Return the created message
        return jsonify({
            "id": new_message.id,
            "is_user": new_message.is_user,
            "content": new_message.content,
            "timestamp": new_message.timestamp.isoformat()
        }), 201
        
    except Exception as e:
        db.rollback()
        logger.error(f"Error creating message: {str(e)}")
        return jsonify({"error": "Failed to create message"}), 500
    finally:
        db.close()

@app.route("/api/orders", methods=["GET"])
@jwt_required()
def get_orders():
    """
    Get all orders for the current user
    """
    # Convert string user_id back to integer
    user_id = int(get_jwt_identity())
    
    db = SessionLocal()
    try:
        orders = db.query(Order).filter(Order.user_id == user_id).all()
        
        result = []
        for order in orders:
            result.append({
                "id": order.id,
                "order_number": order.order_number,
                "total_amount": order.total_amount,
                "status": order.status.value,
                "ordered_at": order.ordered_at.isoformat(),
                "estimated_delivery": order.estimated_delivery.isoformat() if order.estimated_delivery else None,
                "delivered_at": order.delivered_at.isoformat() if order.delivered_at else None,
                "tracking_number": order.tracking_number
            })
        
        return jsonify(result), 200
        
    except Exception as e:
        logger.error(f"Error retrieving orders: {str(e)}")
        return jsonify({"error": "Failed to retrieve orders"}), 500
    finally:
        db.close()

@app.route("/api/orders/<string:order_number>", methods=["GET"])
@jwt_required()
def get_order_details(order_number):
    """
    Get details for a specific order
    """
    # Convert string user_id back to integer
    user_id = int(get_jwt_identity())
    
    db = SessionLocal()
    try:
        order = db.query(Order).filter(
            Order.order_number == order_number,
            Order.user_id == user_id
        ).first()
        
        if not order:
            return jsonify({"error": "Order not found"}), 404
        
        # Get order items
        order_items = db.query(OrderItem).filter(OrderItem.order_id == order.id).all()
        
        items = []
        for item in order_items:
            items.append({
                "id": item.id,
                "product_name": item.product_name,
                "quantity": item.quantity,
                "price": item.price,
                "total": item.quantity * item.price
            })
        
        result = {
            "id": order.id,
            "order_number": order.order_number,
            "total_amount": order.total_amount,
            "status": order.status.value,
            "ordered_at": order.ordered_at.isoformat(),
            "estimated_delivery": order.estimated_delivery.isoformat() if order.estimated_delivery else None,
            "delivered_at": order.delivered_at.isoformat() if order.delivered_at else None,
            "shipping_address": order.shipping_address,
            "tracking_number": order.tracking_number,
            "items": items
        }
        
        return jsonify(result), 200
        
    except Exception as e:
        logger.error(f"Error retrieving order details: {str(e)}")
        return jsonify({"error": "Failed to retrieve order details"}), 500
    finally:
        db.close()

if __name__ == "__main__":
    port = int(os.getenv("BACKEND_PORT", 5000))
    app.run(host="0.0.0.0", port=port, debug=True) 