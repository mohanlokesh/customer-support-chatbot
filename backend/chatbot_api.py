import os
import json
import requests
from flask import Blueprint, jsonify, request
from flask_jwt_extended import jwt_required, get_jwt_identity
from sqlalchemy import or_
from loguru import logger
import sys

# Import database components
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from database.config import SessionLocal
from database.models import Conversation, Message, Order, OrderItem, SupportData

# Create blueprint
chatbot_bp = Blueprint('chatbot', __name__)

# Rasa API configuration
RASA_URL = os.getenv("RASA_URL", "http://localhost:5005")

@chatbot_bp.route("/api/chat", methods=["POST"])
@jwt_required()
def chat():
    """
    Process a chat message and get a response from Rasa
    """
    # Convert string user_id back to integer
    user_id = int(get_jwt_identity())
    data = request.get_json()
    
    if not data.get("message") or not data.get("conversation_id"):
        return jsonify({"error": "Message and conversation_id are required"}), 400
    
    message_text = data["message"]
    conversation_id = data["conversation_id"]
    
    db = SessionLocal()
    try:
        # Check if conversation belongs to user
        conversation = db.query(Conversation).filter(
            Conversation.id == conversation_id,
            Conversation.user_id == user_id
        ).first()
        
        if not conversation:
            return jsonify({"error": "Conversation not found"}), 404
        
        # Save user message
        user_message = Message(
            conversation_id=conversation_id,
            is_user=True,
            content=message_text
        )
        db.add(user_message)
        db.commit()
        
        # Send message to Rasa
        try:
            rasa_payload = {
                "sender": str(user_id),
                "message": message_text
            }
            rasa_response = requests.post(
                f"{RASA_URL}/webhooks/rest/webhook",
                json=rasa_payload
            )
            
            if rasa_response.status_code != 200:
                logger.error(f"Rasa API error: {rasa_response.text}")
                
                # Fallback response if Rasa is unavailable
                bot_message = Message(
                    conversation_id=conversation_id,
                    is_user=False,
                    content="I'm sorry, I'm having trouble processing your request right now. Please try again later."
                )
                db.add(bot_message)
                db.commit()
                
                return jsonify({
                    "response": "I'm sorry, I'm having trouble processing your request right now. Please try again later."
                }), 200
            
            # Process Rasa response
            rasa_data = rasa_response.json()
            
            if not rasa_data:
                # If Rasa doesn't understand, try to find a similar question
                similar_data = find_similar_question(message_text)
                
                if similar_data:
                    bot_response = similar_data.answer
                else:
                    bot_response = "I'm sorry, I don't understand your question. Could you please rephrase it?"
            else:
                # Use the first response from Rasa
                bot_response = rasa_data[0].get("text", "I'm processing your request.")
            
            # Save bot response
            bot_message = Message(
                conversation_id=conversation_id,
                is_user=False,
                content=bot_response
            )
            db.add(bot_message)
            db.commit()
            
            return jsonify({
                "response": bot_response
            }), 200
            
        except requests.RequestException as e:
            logger.error(f"Error connecting to Rasa: {str(e)}")
            
            # Fallback response
            bot_message = Message(
                conversation_id=conversation_id,
                is_user=False,
                content="I'm sorry, I'm having trouble connecting to my backend systems right now. Please try again later."
            )
            db.add(bot_message)
            db.commit()
            
            return jsonify({
                "response": "I'm sorry, I'm having trouble connecting to my backend systems right now. Please try again later."
            }), 200
            
    except Exception as e:
        db.rollback()
        logger.error(f"Error processing chat: {str(e)}")
        return jsonify({"error": "Failed to process chat message"}), 500
    finally:
        db.close()

@chatbot_bp.route("/api/orders/<string:order_number>/status", methods=["GET"])
@jwt_required()
def get_order_status(order_number):
    """
    Get the status of a specific order (used by Rasa action server)
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

def find_similar_question(user_question, threshold=0.5):
    """
    Find a similar question in the support database
    This is a simple keyword matching, in a real app this would use
    more sophisticated NLP like embedding similarity
    """
    db = SessionLocal()
    try:
        # Convert question to lowercase and split into keywords
        keywords = user_question.lower().split()
        
        # Simple approach: search for questions that contain any of the keywords
        support_data = db.query(SupportData).filter(
            or_(*[SupportData.question.ilike(f"%{keyword}%") for keyword in keywords])
        ).all()
        
        # Return the first match if any, in a real app you would rank them by relevance
        return support_data[0] if support_data else None
        
    except Exception as e:
        logger.error(f"Error finding similar question: {str(e)}")
        return None
    finally:
        db.close()

# Register blueprint in app.py by adding:
# from backend.chatbot_api import chatbot_bp
# app.register_blueprint(chatbot_bp) 