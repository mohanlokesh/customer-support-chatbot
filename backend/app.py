import os
from datetime import datetime, timedelta
from flask import Flask, jsonify, request
from flask_cors import CORS
from flask_jwt_extended import JWTManager, create_access_token, jwt_required, get_jwt_identity
from dotenv import load_dotenv
import bcrypt
from loguru import logger
import sys
from sqlalchemy import or_
import requests
import random

# Import database components
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from database.config import SessionLocal
from database.models import User, Conversation, Message, Order, OrderItem, Product, Cart, CartItem
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

# JWT callback handlers
@jwt.user_identity_loader
def user_identity_lookup(user):
    """
    Function that takes whatever is passed in as the identity
    when creating JWTs and converts it to a JSON serializable format.
    """
    return str(user)

@jwt.user_lookup_loader
def user_lookup_callback(_jwt_header, jwt_data):
    """
    Function that is called whenever a protected endpoint is accessed.
    It takes the JWT data and returns the corresponding user object.
    """
    user_id = jwt_data["sub"]
    
    # Handle both string IDs (from Rasa) and numeric IDs (from frontend)
    try:
        # Try to convert to integer for database lookup
        user_id_int = int(user_id)
        
        db = SessionLocal()
        try:
            user = db.query(User).filter(User.id == user_id_int).first()
            db.close()
            return user
        except:
            db.close()
            return None
    except ValueError:
        # If it's not a valid integer, it might be a custom token from Rasa
        # For Rasa actions, we'll just return the ID as is
        return user_id

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

@app.route("/api/health/rasa", methods=["GET"])
def rasa_health_check():
    """
    Check if Rasa server is healthy
    """
    rasa_url = os.getenv("RASA_URL", "http://localhost:5005")
    try:
        response = requests.get(f"{rasa_url}/health", timeout=2)
        if response.status_code == 200:
            return jsonify({"status": "ok", "message": "Rasa server is available"}), 200
        else:
            return jsonify({"status": "error", "message": f"Rasa returned status code {response.status_code}"}), 200
    except requests.exceptions.RequestException as e:
        logger.warning(f"Rasa health check failed: {str(e)}")
        return jsonify({"status": "error", "message": "Rasa server is not available"}), 200

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
    # Get the user identity from the JWT
    user_id = get_jwt_identity()
    
    # Convert to integer if possible (coming from frontend)
    try:
        user_id = int(user_id)
    except ValueError:
        # If not a valid integer, assume it's from Rasa actions
        # For demo purposes, we'll use a mock user ID
        user_id = 1  # Use a demo user ID
    
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
    # Get the user identity from the JWT
    user_id = get_jwt_identity()
    
    # Convert to integer if possible (coming from frontend)
    try:
        user_id = int(user_id)
    except ValueError:
        # If not a valid integer, assume it's from Rasa actions
        # For demo purposes, we'll use a mock user ID
        user_id = 1  # Use a demo user ID
    
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
    # Get the user identity from the JWT
    user_id = get_jwt_identity()
    
    # Convert to integer if possible (coming from frontend)
    try:
        user_id = int(user_id)
    except ValueError:
        # If not a valid integer, assume it's from Rasa actions
        # For demo purposes, we'll use a mock user ID
        user_id = 1  # Use a demo user ID
    
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
    # Get the user identity from the JWT
    user_id = get_jwt_identity()
    
    # Convert to integer if possible (coming from frontend)
    try:
        user_id = int(user_id)
    except ValueError:
        # If not a valid integer, assume it's from Rasa actions
        # For demo purposes, we'll use a mock user ID
        user_id = 1  # Use a demo user ID
    
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
    # Get the user identity from the JWT
    user_id = get_jwt_identity()
    
    # Convert to integer if possible (coming from frontend)
    try:
        user_id = int(user_id)
    except ValueError:
        # If not a valid integer, assume it's from Rasa actions
        # For demo purposes, we'll use a mock user ID
        user_id = 1  # Use a demo user ID
    
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
    # Get the user identity from the JWT
    user_id = get_jwt_identity()
    
    # Convert to integer if possible (coming from frontend)
    try:
        user_id = int(user_id)
    except ValueError:
        # If not a valid integer, assume it's from Rasa actions
        # For demo purposes, we'll use a mock user ID
        user_id = 1  # Use a demo user ID
    
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

# Add a new endpoint specifically for the Rasa action server to get order status
@app.route("/api/orders/<string:order_number>/status", methods=["GET"])
@jwt_required()
def get_order_status(order_number):
    """
    Get the status of a specific order (used by Rasa action server)
    """
    # Get the user identity from the JWT
    user_id = get_jwt_identity()
    
    # Convert to integer if possible (coming from frontend)
    try:
        user_id = int(user_id)
    except ValueError:
        # If not a valid integer, assume it's from Rasa actions
        # For demo purposes, we'll use a mock user ID
        user_id = 1  # Use a demo user ID
    
    db = SessionLocal()
    try:
        order = db.query(Order).filter(
            Order.order_number == order_number,
            Order.user_id == user_id
        ).first()
        
        if not order:
            return jsonify({"error": "Order not found"}), 404
        
        return jsonify({
            "order_number": order.order_number,
            "status": order.status.value,
            "ordered_at": order.ordered_at.isoformat(),
            "estimated_delivery": order.estimated_delivery.isoformat() if order.estimated_delivery else None
        }), 200
        
    except Exception as e:
        logger.error(f"Error retrieving order status: {str(e)}")
        return jsonify({"error": "Failed to retrieve order status"}), 500
    finally:
        db.close()

# Add a new endpoint for canceling orders
@app.route("/api/orders/<string:order_number>/cancel", methods=["POST"])
@jwt_required()
def cancel_order(order_number):
    """
    Cancel a specific order
    """
    # Get the user identity from the JWT
    user_id = get_jwt_identity()
    
    # Convert to integer if possible (coming from frontend)
    try:
        user_id = int(user_id)
    except ValueError:
        # If not a valid integer, assume it's from Rasa actions
        # For demo purposes, we'll use a mock user ID
        user_id = 1  # Use a demo user ID
    
    db = SessionLocal()
    try:
        # Check if order exists and belongs to user
        order = db.query(Order).filter(
            Order.order_number == order_number,
            Order.user_id == user_id
        ).first()
        
        if not order:
            return jsonify({"error": "Order not found"}), 404
        
        # Check if order can be cancelled
        if order.status.value in ["delivered", "cancelled"]:
            return jsonify({"error": f"Order cannot be cancelled because it is already {order.status.value}"}), 400
        
        if order.status.value == "shipped":
            return jsonify({"error": "Order cannot be cancelled because it has already been shipped. Please initiate a return instead."}), 400
        
        # Update order status to cancelled
        from database.models import OrderStatus
        order.status = OrderStatus.CANCELLED
        db.commit()
        
        return jsonify({
            "message": f"Order {order_number} has been successfully cancelled",
            "order_number": order.order_number,
            "status": order.status.value
        }), 200
        
    except Exception as e:
        db.rollback()
        logger.error(f"Error cancelling order: {str(e)}")
        return jsonify({"error": "Failed to cancel order"}), 500
    finally:
        db.close()

# Add a new endpoint for password reset
@app.route("/api/auth/reset-password", methods=["POST"])
@jwt_required(optional=True)
def reset_password():
    """
    Reset user password and send temporary password
    This endpoint allows both authenticated and unauthenticated requests
    """
    data = request.get_json()
    
    if not data.get("email"):
        return jsonify({"error": "Email is required"}), 400
    
    email = data.get("email")
    temp_password = data.get("temp_password")  # In a real app, this would be generated server-side
    
    if not temp_password:
        # Generate a temporary password if not provided
        chars = string.ascii_letters + string.digits
        temp_password = ''.join(random.choice(chars) for _ in range(12))
    
    db = SessionLocal()
    try:
        # Find user by email
        user = db.query(User).filter(User.email == email).first()
        
        if not user:
            return jsonify({"error": "User not found with that email address"}), 404
        
        # Hash the temporary password
        hashed_password = bcrypt.hashpw(temp_password.encode("utf-8"), bcrypt.gensalt()).decode("utf-8")
        
        # Update user's password
        user.password_hash = hashed_password
        db.commit()
        
        # In a real application, send an email with the temporary password
        # For demo purposes, we'll just return success
        
        return jsonify({
            "message": "Password has been reset successfully. Check your email for the temporary password.",
            # Don't include the temporary password in the response in a real app
            # We're including it here for demonstration purposes only
            "temp_password": temp_password
        }), 200
        
    except Exception as e:
        db.rollback()
        logger.error(f"Error resetting password: {str(e)}")
        return jsonify({"error": "Failed to reset password"}), 500
    finally:
        db.close()

# Add a new endpoint for generating orders for users
@app.route("/api/orders/generate", methods=["POST"])
@jwt_required()
def generate_orders_api():
    """
    Generate test orders via API
    """
    # Implementation details here...

# Product related endpoints
@app.route("/api/products", methods=["GET"])
def get_products():
    """
    Get all products with optional filtering
    """
    # Get query parameters for filtering
    category = request.args.get("category")
    search = request.args.get("search")
    
    db = SessionLocal()
    try:
        # Build the query
        query = db.query(Product)
        
        # Apply filtering
        if category:
            query = query.filter(Product.category == category)
        
        if search:
            # Case-insensitive search in name and description
            search_term = f"%{search}%"
            query = query.filter(
                or_(
                    Product.name.ilike(search_term),
                    Product.description.ilike(search_term)
                )
            )
        
        # Execute the query
        products = query.all()
        
        # Convert to JSON
        result = []
        for product in products:
            result.append({
                "id": product.id,
                "name": product.name,
                "description": product.description,
                "price": product.price,
                "stock_quantity": product.stock_quantity,
                "image_url": product.image_url,
                "category": product.category
            })
        
        return jsonify({"products": result}), 200
        
    except Exception as e:
        logger.error(f"Error retrieving products: {str(e)}")
        return jsonify({"error": "Failed to retrieve products"}), 500
    finally:
        db.close()

@app.route("/api/products/<int:product_id>", methods=["GET"])
def get_product(product_id):
    """
    Get details for a specific product
    """
    db = SessionLocal()
    try:
        product = db.query(Product).filter(Product.id == product_id).first()
        
        if not product:
            return jsonify({"error": "Product not found"}), 404
        
        result = {
            "id": product.id,
            "name": product.name,
            "description": product.description,
            "price": product.price,
            "stock_quantity": product.stock_quantity,
            "image_url": product.image_url,
            "category": product.category
        }
        
        return jsonify(result), 200
        
    except Exception as e:
        logger.error(f"Error retrieving product: {str(e)}")
        return jsonify({"error": "Failed to retrieve product"}), 500
    finally:
        db.close()

@app.route("/api/products/categories", methods=["GET"])
def get_categories():
    """
    Get all unique product categories
    """
    db = SessionLocal()
    try:
        # Get distinct categories
        categories = db.query(Product.category).distinct().all()
        
        # Extract category names
        result = [category[0] for category in categories if category[0]]
        
        return jsonify({"categories": result}), 200
        
    except Exception as e:
        logger.error(f"Error retrieving categories: {str(e)}")
        return jsonify({"error": "Failed to retrieve categories"}), 500
    finally:
        db.close()

# Cart related endpoints
@app.route("/api/cart", methods=["GET"])
@jwt_required()
def get_cart():
    """
    Get the current user's cart
    """
    # Get the user identity from the JWT
    user_id = get_jwt_identity()
    
    # Convert to integer if possible
    try:
        user_id = int(user_id)
    except ValueError:
        # Use a demo user ID if not a valid integer
        user_id = 1
    
    db = SessionLocal()
    try:
        # Get the user's cart
        cart = db.query(Cart).filter(Cart.user_id == user_id).first()
        
        # If cart doesn't exist, create it
        if not cart:
            cart = Cart(user_id=user_id)
            db.add(cart)
            db.commit()
        
        # Get cart items with product details
        cart_items = db.query(CartItem, Product).join(
            Product, CartItem.product_id == Product.id
        ).filter(CartItem.cart_id == cart.id).all()
        
        # Calculate total
        total = sum(item[0].quantity * item[1].price for item in cart_items)
        
        # Format response
        items = []
        for cart_item, product in cart_items:
            items.append({
                "cart_item_id": cart_item.id,
                "product_id": product.id,
                "name": product.name,
                "price": product.price,
                "quantity": cart_item.quantity,
                "subtotal": cart_item.quantity * product.price,
                "image_url": product.image_url
            })
        
        return jsonify({
            "cart_id": cart.id,
            "items": items,
            "total": total,
            "item_count": len(items)
        }), 200
        
    except Exception as e:
        db.rollback()
        logger.error(f"Error retrieving cart: {str(e)}")
        return jsonify({"error": "Failed to retrieve cart"}), 500
    finally:
        db.close()

@app.route("/api/cart/items", methods=["POST"])
@jwt_required()
def add_to_cart():
    """
    Add an item to the cart
    """
    # Get the user identity from the JWT
    user_id = get_jwt_identity()
    
    # Convert to integer if possible
    try:
        user_id = int(user_id)
    except ValueError:
        # Use a demo user ID if not a valid integer
        user_id = 1
    
    data = request.get_json()
    
    # Validate required fields
    if not data.get("product_id") or not data.get("quantity"):
        return jsonify({"error": "Product ID and quantity are required"}), 400
    
    product_id = data["product_id"]
    quantity = int(data["quantity"])
    
    # Ensure quantity is positive
    if quantity <= 0:
        return jsonify({"error": "Quantity must be positive"}), 400
    
    db = SessionLocal()
    try:
        # Check if product exists and has enough stock
        product = db.query(Product).filter(Product.id == product_id).first()
        
        if not product:
            return jsonify({"error": "Product not found"}), 404
        
        if product.stock_quantity < quantity:
            return jsonify({"error": "Not enough stock available"}), 400
        
        # Get or create the user's cart
        cart = db.query(Cart).filter(Cart.user_id == user_id).first()
        
        if not cart:
            cart = Cart(user_id=user_id)
            db.add(cart)
            db.flush()
        
        # Check if the product is already in the cart
        cart_item = db.query(CartItem).filter(
            CartItem.cart_id == cart.id,
            CartItem.product_id == product_id
        ).first()
        
        if cart_item:
            # Update existing cart item
            cart_item.quantity += quantity
        else:
            # Create new cart item
            cart_item = CartItem(
                cart_id=cart.id,
                product_id=product_id,
                quantity=quantity
            )
            db.add(cart_item)
        
        # Update cart timestamp
        cart.updated_at = datetime.utcnow()
        
        db.commit()
        
        # Return updated cart
        return get_cart()
        
    except Exception as e:
        db.rollback()
        logger.error(f"Error adding to cart: {str(e)}")
        return jsonify({"error": "Failed to add item to cart"}), 500
    finally:
        db.close()

@app.route("/api/cart/items/<int:cart_item_id>", methods=["PUT"])
@jwt_required()
def update_cart_item(cart_item_id):
    """
    Update a cart item quantity
    """
    # Get the user identity from the JWT
    user_id = get_jwt_identity()
    
    # Convert to integer if possible
    try:
        user_id = int(user_id)
    except ValueError:
        # Use a demo user ID if not a valid integer
        user_id = 1
    
    data = request.get_json()
    
    # Validate required fields
    if "quantity" not in data:
        return jsonify({"error": "Quantity is required"}), 400
    
    quantity = int(data["quantity"])
    
    db = SessionLocal()
    try:
        # Get the user's cart
        cart = db.query(Cart).filter(Cart.user_id == user_id).first()
        
        if not cart:
            return jsonify({"error": "Cart not found"}), 404
        
        # Get the cart item
        cart_item = db.query(CartItem).filter(
            CartItem.id == cart_item_id,
            CartItem.cart_id == cart.id
        ).first()
        
        if not cart_item:
            return jsonify({"error": "Cart item not found"}), 404
        
        # Check product stock
        product = db.query(Product).filter(Product.id == cart_item.product_id).first()
        
        if quantity > 0:
            if product.stock_quantity < quantity:
                return jsonify({"error": "Not enough stock available"}), 400
            
            # Update quantity
            cart_item.quantity = quantity
            
            # Update cart timestamp
            cart.updated_at = datetime.utcnow()
            
            db.commit()
        else:
            # If quantity is 0 or negative, remove the item
            db.delete(cart_item)
            
            # Update cart timestamp
            cart.updated_at = datetime.utcnow()
            
            db.commit()
        
        # Return updated cart
        return get_cart()
        
    except Exception as e:
        db.rollback()
        logger.error(f"Error updating cart item: {str(e)}")
        return jsonify({"error": "Failed to update cart item"}), 500
    finally:
        db.close()

@app.route("/api/cart/items/<int:cart_item_id>", methods=["DELETE"])
@jwt_required()
def remove_from_cart(cart_item_id):
    """
    Remove an item from the cart
    """
    # Get the user identity from the JWT
    user_id = get_jwt_identity()
    
    # Convert to integer if possible
    try:
        user_id = int(user_id)
    except ValueError:
        # Use a demo user ID if not a valid integer
        user_id = 1
    
    db = SessionLocal()
    try:
        # Get the user's cart
        cart = db.query(Cart).filter(Cart.user_id == user_id).first()
        
        if not cart:
            return jsonify({"error": "Cart not found"}), 404
        
        # Get the cart item
        cart_item = db.query(CartItem).filter(
            CartItem.id == cart_item_id,
            CartItem.cart_id == cart.id
        ).first()
        
        if not cart_item:
            return jsonify({"error": "Cart item not found"}), 404
        
        # Remove the item
        db.delete(cart_item)
        
        # Update cart timestamp
        cart.updated_at = datetime.utcnow()
        
        db.commit()
        
        # Return updated cart
        return get_cart()
        
    except Exception as e:
        db.rollback()
        logger.error(f"Error removing cart item: {str(e)}")
        return jsonify({"error": "Failed to remove cart item"}), 500
    finally:
        db.close()

@app.route("/api/cart/clear", methods=["POST"])
@jwt_required()
def clear_cart():
    """
    Clear all items from the cart
    """
    # Get the user identity from the JWT
    user_id = get_jwt_identity()
    
    # Convert to integer if possible
    try:
        user_id = int(user_id)
    except ValueError:
        # Use a demo user ID if not a valid integer
        user_id = 1
    
    db = SessionLocal()
    try:
        # Get the user's cart
        cart = db.query(Cart).filter(Cart.user_id == user_id).first()
        
        if not cart:
            return jsonify({"error": "Cart not found"}), 404
        
        # Remove all items
        db.query(CartItem).filter(CartItem.cart_id == cart.id).delete()
        
        # Update cart timestamp
        cart.updated_at = datetime.utcnow()
        
        db.commit()
        
        return jsonify({
            "message": "Cart cleared successfully",
            "cart_id": cart.id,
            "items": [],
            "total": 0,
            "item_count": 0
        }), 200
        
    except Exception as e:
        db.rollback()
        logger.error(f"Error clearing cart: {str(e)}")
        return jsonify({"error": "Failed to clear cart"}), 500
    finally:
        db.close()

@app.route("/api/cart/checkout", methods=["POST"])
@jwt_required()
def checkout():
    """
    Checkout the cart and create an order
    """
    # Get the user identity from the JWT
    user_id = get_jwt_identity()
    
    # Convert to integer if possible
    try:
        user_id = int(user_id)
    except ValueError:
        # Use a demo user ID if not a valid integer
        user_id = 1
    
    data = request.get_json()
    
    # Validate required fields
    if not data.get("shipping_address"):
        return jsonify({"error": "Shipping address is required"}), 400
    
    shipping_address = data["shipping_address"]
    
    db = SessionLocal()
    try:
        # Get the user's cart
        cart = db.query(Cart).filter(Cart.user_id == user_id).first()
        
        if not cart:
            return jsonify({"error": "Cart not found"}), 404
        
        # Get cart items with product details
        cart_items = db.query(CartItem, Product).join(
            Product, CartItem.product_id == Product.id
        ).filter(CartItem.cart_id == cart.id).all()
        
        if not cart_items:
            return jsonify({"error": "Cart is empty"}), 400
        
        # Check stock for all items
        for cart_item, product in cart_items:
            if product.stock_quantity < cart_item.quantity:
                return jsonify({
                    "error": f"Not enough stock for {product.name}. Available: {product.stock_quantity}."
                }), 400
        
        # Generate order number
        order_number = None
        while True:
            # Generate a candidate order number
            candidate = f'ORD-{random.randint(10000, 99999)}'
            
            # Check if this order number already exists
            existing_order = db.query(Order).filter(Order.order_number == candidate).first()
            if not existing_order:
                order_number = candidate
                break
        
        # Calculate total
        total = sum(item[0].quantity * item[1].price for item in cart_items)
        
        # Create order
        now = datetime.utcnow()
        order = Order(
            order_number=order_number,
            user_id=user_id,
            total_amount=total,
            status="pending",
            ordered_at=now,
            estimated_delivery=now + timedelta(days=5),
            shipping_address=shipping_address
        )
        db.add(order)
        db.flush()  # To get the order ID
        
        # Create order items and update stock
        for cart_item, product in cart_items:
            # Create order item
            order_item = OrderItem(
                order_id=order.id,
                product_name=product.name,
                quantity=cart_item.quantity,
                price=product.price
            )
            db.add(order_item)
            
            # Update product stock
            product.stock_quantity -= cart_item.quantity
        
        # Clear cart
        db.query(CartItem).filter(CartItem.cart_id == cart.id).delete()
        
        # Update cart timestamp
        cart.updated_at = now
        
        db.commit()
        
        return jsonify({
            "message": "Order placed successfully",
            "order_number": order_number,
            "total": total,
            "status": "pending",
            "estimated_delivery": (now + timedelta(days=5)).isoformat()
        }), 201
        
    except Exception as e:
        db.rollback()
        logger.error(f"Error during checkout: {str(e)}")
        return jsonify({"error": "Failed to complete checkout"}), 500
    finally:
        db.close()

if __name__ == "__main__":
    port = int(os.getenv("BACKEND_PORT", 5000))
    app.run(host="0.0.0.0", port=port, debug=True) 