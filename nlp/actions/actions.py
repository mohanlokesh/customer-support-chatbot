import json
import logging
import os
import requests
from typing import Any, Dict, List, Text
from datetime import datetime, timedelta
import jwt
from dotenv import load_dotenv

from rasa_sdk import Action, Tracker
from rasa_sdk.executor import CollectingDispatcher
from rasa_sdk.events import SlotSet

# Load environment variables
load_dotenv()

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Backend API configuration
BACKEND_URL = os.getenv("BACKEND_URL", "http://localhost:5000")
JWT_SECRET_KEY = os.getenv("JWT_SECRET_KEY", "super-secret-key-change-in-production")

def get_auth_token(user_id):
    """
    Generate a JWT token for the Rasa actions server to authenticate with the backend.
    This is a simplified version - in production, you'd use a more secure approach.
    """
    try:
        # Create a JWT token with the proper claims required by Flask-JWT-Extended
        now = datetime.utcnow()
        token_data = {
            "sub": str(user_id),  # 'sub' claim is required by Flask-JWT-Extended
            "iat": now,
            "nbf": now,
            "jti": str(now.timestamp()),
            "exp": now + timedelta(hours=1),
            "fresh": False,
            "type": "access"
        }
        
        token = jwt.encode(
            token_data,
            JWT_SECRET_KEY,
            algorithm="HS256"
        )
        return token
    except Exception as e:
        logger.error(f"Error generating JWT token: {str(e)}")
        return None

class ActionCheckOrderStatus(Action):
    """
    Action to check the status of a specific order.
    """
    def name(self) -> Text:
        return "action_check_order_status"

    def run(self,
            dispatcher: CollectingDispatcher,
            tracker: Tracker,
            domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
        
        # Get the order number from the slot
        order_number = tracker.get_slot("order_number")
        
        if not order_number:
            dispatcher.utter_message(text="I'll need your order number to check the status. Could you please provide it?")
            return []
        
        try:
            # Get user ID from sender ID (requires user authentication in the backend)
            user_id = tracker.sender_id
            
            # Generate a valid JWT token for the backend
            token = get_auth_token(user_id)
            
            if not token:
                dispatcher.utter_message(text="I'm having trouble with authentication. Please try again later.")
                return []
            
            # Create authorization header with the token
            headers = {
                "Authorization": f"Bearer {token}"
            }
            
            # Call backend API to get order status
            response = requests.get(
                f"{BACKEND_URL}/api/orders/{order_number}/status",
                headers=headers
            )
            
            if response.status_code == 200:
                order_data = response.json()
                
                # Format delivery estimate
                estimated_delivery = order_data.get("estimated_delivery")
                if estimated_delivery:
                    # Convert ISO format to date object and format nicely
                    delivery_date = datetime.fromisoformat(estimated_delivery.replace("Z", "+00:00"))
                    formatted_date = delivery_date.strftime("%B %d, %Y")
                else:
                    formatted_date = "not available"
                
                # Send response based on order status
                status = order_data.get("status")
                
                if status == "pending":
                    msg = f"Your order {order_number} is pending. We're processing it now. " \
                          f"Estimated delivery: {formatted_date}."
                elif status == "processing":
                    msg = f"Your order {order_number} is being processed. " \
                          f"Estimated delivery: {formatted_date}."
                elif status == "shipped":
                    msg = f"Good news! Your order {order_number} has been shipped. " \
                          f"Estimated delivery: {formatted_date}."
                elif status == "delivered":
                    msg = f"Your order {order_number} has been delivered. " \
                          f"If you haven't received it, please contact our support team."
                elif status == "cancelled":
                    msg = f"Your order {order_number} has been cancelled. " \
                          f"If you didn't cancel it, please contact our support team."
                elif status == "backordered":
                    msg = f"Your order {order_number} is currently backordered. " \
                          f"We'll ship it as soon as it's available. " \
                          f"Estimated delivery: {formatted_date}."
                else:
                    msg = f"Your order {order_number} is in status: {status}. " \
                          f"Estimated delivery: {formatted_date}."
                
                dispatcher.utter_message(text=msg)
                
                # If the order is shipped, suggest tracking
                if status == "shipped":
                    dispatcher.utter_message(text="Would you like to track your package?")
                
                return [SlotSet("order_number", order_number)]
                
            elif response.status_code == 404:
                dispatcher.utter_message(text=f"I couldn't find an order with number {order_number}. "
                                         "Please check the number and try again.")
                return [SlotSet("order_number", None)]
                
            else:
                logger.error(f"Error from backend API: {response.text}")
                dispatcher.utter_message(text="I'm having trouble connecting to our order system. "
                                        "Please try again later or contact customer support.")
                return []
                
        except requests.RequestException as e:
            logger.error(f"Error connecting to backend: {str(e)}")
            dispatcher.utter_message(text="I'm having trouble connecting to our order system. "
                                    "Please try again later or contact customer support.")
            return []
        except Exception as e:
            logger.error(f"Unexpected error in action_check_order_status: {str(e)}")
            dispatcher.utter_message(text="Sorry, something went wrong while checking your order. "
                                    "Please try again later.")
            return []

class ActionListOrderItems(Action):
    """
    Action to list items in a specific order.
    """
    def name(self) -> Text:
        return "action_list_order_items"

    def run(self,
            dispatcher: CollectingDispatcher,
            tracker: Tracker,
            domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
        
        # Get the order number from the slot
        order_number = tracker.get_slot("order_number")
        
        if not order_number:
            dispatcher.utter_message(text="I'll need your order number to list the items. Could you please provide it?")
            return []
        
        try:
            # Get user ID from sender ID
            user_id = tracker.sender_id
            
            # Generate a valid JWT token for the backend
            token = get_auth_token(user_id)
            
            if not token:
                dispatcher.utter_message(text="I'm having trouble with authentication. Please try again later.")
                return []
            
            # Create authorization header with the token
            headers = {
                "Authorization": f"Bearer {token}"
            }
            
            # Call backend API to get order details
            response = requests.get(
                f"{BACKEND_URL}/api/orders/{order_number}",
                headers=headers
            )
            
            if response.status_code == 200:
                order_data = response.json()
                items = order_data.get("items", [])
                
                if not items:
                    dispatcher.utter_message(text=f"Your order {order_number} doesn't have any items.")
                    return [SlotSet("order_number", order_number)]
                
                # Create a message with all items
                msg = f"Here are the items in your order {order_number}:\n\n"
                
                for idx, item in enumerate(items, 1):
                    product_name = item.get("product_name", "Unknown product")
                    quantity = item.get("quantity", 0)
                    price = item.get("price", 0.0)
                    total = item.get("total", price * quantity)
                    
                    msg += f"{idx}. {product_name} - Quantity: {quantity}, Price: ${price:.2f}, Total: ${total:.2f}\n"
                
                msg += f"\nTotal order amount: ${order_data.get('total_amount', 0.0):.2f}"
                
                dispatcher.utter_message(text=msg)
                return [SlotSet("order_number", order_number)]
                
            elif response.status_code == 404:
                dispatcher.utter_message(text=f"I couldn't find an order with number {order_number}. "
                                        "Please check the number and try again.")
                return [SlotSet("order_number", None)]
                
            else:
                logger.error(f"Error from backend API: {response.text}")
                dispatcher.utter_message(text="I'm having trouble connecting to our order system. "
                                        "Please try again later or contact customer support.")
                return []
                
        except requests.RequestException as e:
            logger.error(f"Error connecting to backend: {str(e)}")
            dispatcher.utter_message(text="I'm having trouble connecting to our order system. "
                                    "Please try again later or contact customer support.")
            return []
        except Exception as e:
            logger.error(f"Unexpected error in action_list_order_items: {str(e)}")
            dispatcher.utter_message(text="Sorry, something went wrong while retrieving your order items. "
                                    "Please try again later.")
            return []

class ActionGetUserOrders(Action):
    """
    Action to get all orders for a user.
    """
    def name(self) -> Text:
        return "action_get_user_orders"

    def run(self,
            dispatcher: CollectingDispatcher,
            tracker: Tracker,
            domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
        
        try:
            # Get user ID from sender ID
            user_id = tracker.sender_id
            
            # Generate a valid JWT token for the backend
            token = get_auth_token(user_id)
            
            if not token:
                dispatcher.utter_message(text="I'm having trouble with authentication. Please try again later.")
                return []
            
            # Create authorization header with the token
            headers = {
                "Authorization": f"Bearer {token}"
            }
            
            # Call backend API to get all user orders
            response = requests.get(
                f"{BACKEND_URL}/api/orders",
                headers=headers
            )
            
            if response.status_code == 200:
                orders = response.json()
                
                if not orders:
                    dispatcher.utter_message(text="You don't have any orders yet.")
                    return []
                
                # Create a message with recent orders
                msg = "Here are your recent orders:\n\n"
                
                for idx, order in enumerate(orders[:5], 1):  # Limit to 5 most recent orders
                    order_number = order.get("order_number", "Unknown")
                    status = order.get("status", "Unknown")
                    ordered_at = order.get("ordered_at", "")
                    
                    # Format date
                    if ordered_at:
                        ordered_date = datetime.fromisoformat(ordered_at.replace("Z", "+00:00"))
                        formatted_date = ordered_date.strftime("%B %d, %Y")
                    else:
                        formatted_date = "Unknown date"
                    
                    msg += f"{idx}. Order #{order_number} - Status: {status}, Ordered on: {formatted_date}\n"
                
                if len(orders) > 5:
                    msg += f"\n... and {len(orders) - 5} more orders."
                
                msg += "\n\nYou can ask about a specific order by providing the order number."
                
                dispatcher.utter_message(text=msg)
                return []
                
            else:
                logger.error(f"Error from backend API: {response.text}")
                dispatcher.utter_message(text="I'm having trouble retrieving your orders. "
                                        "Please try again later or contact customer support.")
                return []
                
        except requests.RequestException as e:
            logger.error(f"Error connecting to backend: {str(e)}")
            dispatcher.utter_message(text="I'm having trouble connecting to our order system. "
                                    "Please try again later or contact customer support.")
            return []
        except Exception as e:
            logger.error(f"Unexpected error in action_get_user_orders: {str(e)}")
            dispatcher.utter_message(text="Sorry, something went wrong while retrieving your orders. "
                                    "Please try again later.")
            return [] 