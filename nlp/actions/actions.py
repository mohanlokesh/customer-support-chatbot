import json
import logging
import os
import requests
from typing import Any, Dict, List, Text
from datetime import datetime, timedelta
import jwt
import string
import random
from dotenv import load_dotenv

from rasa_sdk import Action, Tracker
from rasa_sdk.executor import CollectingDispatcher
from rasa_sdk.events import SlotSet, FollowupAction

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

                # Add status information
                status = order_data.get("status")
                msg += f"\nOrder status: {status}"
                
                dispatcher.utter_message(text=msg)

                # If order is pending or processing, suggest cancellation
                if status in ["pending", "processing"]:
                    dispatcher.utter_message(text="Would you like to cancel this order? You can say 'cancel this order' if you want to.")
                
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

class ActionCancelOrder(Action):
    """
    Action to cancel a specific order.
    """
    def name(self) -> Text:
        return "action_cancel_order"

    def run(self,
            dispatcher: CollectingDispatcher,
            tracker: Tracker,
            domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
        
        # Get the order number from the slot or extract it from latest message
        order_number = tracker.get_slot("order_number")
        
        # If no order number in slot, check if it's in the latest message via entity extraction
        if not order_number:
            for entity in tracker.latest_message.get('entities', []):
                if entity['entity'] == 'order_number':
                    order_number = entity['value']
                    break
        
        # Check if text like "ORD-12345" appears in the message
        if not order_number:
            message_text = tracker.latest_message.get('text', '').upper()
            import re
            order_matches = re.findall(r'ORD[-\s]?\d+', message_text)
            if order_matches:
                order_number = order_matches[0].replace(' ', '')
        
        if not order_number:
            dispatcher.utter_message(text="I'll need your order number to cancel it. Could you please provide it?")
            return []
        
        # Get confirmation from the user
        confirm_cancel = tracker.get_slot("confirm_cancel")
        
        if not confirm_cancel or confirm_cancel.lower() != "confirmed":
            dispatcher.utter_message(text=f"Are you sure you want to cancel order #{order_number}? This action cannot be undone.")
            dispatcher.utter_message(text="Please reply with 'Yes' to confirm or 'No' to keep the order.")
            
            # Save the order number in slot for use in the confirmation handler
            return [SlotSet("order_number", order_number), SlotSet("confirm_cancel", "asked")]
        
        # Note: The rest of the cancellation logic is now in the ActionHandleCancelConfirmation class
        # to properly handle the user's confirmation
        
        return [SlotSet("order_number", order_number)]

class ActionHandleCancelConfirmation(Action):
    """
    Action to handle confirmation of order cancellation.
    """
    def name(self) -> Text:
        return "action_handle_cancel_confirmation"

    def run(self,
            dispatcher: CollectingDispatcher,
            tracker: Tracker,
            domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
        
        # Get the user's confirmation response
        intent = tracker.latest_message.get('intent', {}).get('name', '')
        user_message = tracker.latest_message.get('text', '').lower()
        
        # Get the order number from the slots
        order_number = tracker.get_slot("order_number")
        if not order_number:
            dispatcher.utter_message(text="I don't have an order number to cancel. Please start over and provide your order number.")
            return [SlotSet("confirm_cancel", None)]
        
        # Check if the user confirmed the cancellation
        confirmation_phrases = ["yes", "confirm", "sure", "cancel", "proceed", "ok", "okay", "go ahead", "yep", "yeah", "do it", "please cancel", "i want to cancel", "that's right", "correct", "absolutely", "definitely", "please proceed", "i confirm"]
        is_confirmed = False
        
        # Check for affirm intent or common confirmation phrases
        if intent == 'affirm' or any(phrase in user_message for phrase in confirmation_phrases):
            is_confirmed = True
        
        if not is_confirmed:
            dispatcher.utter_message(text=f"I'll keep your order #{order_number} active. No changes have been made.")
            return [SlotSet("confirm_cancel", None)]
        
        try:
            # Get user ID from sender ID
            user_id = tracker.sender_id
            
            # Generate a valid JWT token for the backend
            token = get_auth_token(user_id)
            
            if not token:
                dispatcher.utter_message(text="I'm having trouble with authentication. Please try again later.")
                return [SlotSet("confirm_cancel", None)]
            
            # Create authorization header with the token
            headers = {
                "Authorization": f"Bearer {token}",
                "Content-Type": "application/json"
            }
            
            # Call backend API to cancel the order
            response = requests.post(
                f"{BACKEND_URL}/api/orders/{order_number}/cancel",
                headers=headers
            )
            
            if response.status_code == 200:
                dispatcher.utter_message(text=f"✅ I've successfully cancelled your order #{order_number}.")
                dispatcher.utter_message(text="If you made this cancellation by mistake, please contact our customer support immediately.")
                
                return [SlotSet("order_number", None), SlotSet("confirm_cancel", None)]
                
            elif response.status_code == 404:
                dispatcher.utter_message(text=f"I couldn't find an order with number {order_number}. "
                                       "Please check the number and try again.")
                return [SlotSet("order_number", None), SlotSet("confirm_cancel", None)]
            
            elif response.status_code == 400:
                try:
                    error_data = response.json()
                    error_message = error_data.get("error", "The order cannot be cancelled at this time.")
                    dispatcher.utter_message(text=f"I'm sorry, but {error_message}")
                except:
                    dispatcher.utter_message(text="I'm sorry, but the order cannot be cancelled at this time.")
                
                return [SlotSet("confirm_cancel", None)]
                
            else:
                logger.error(f"Error from backend API: {response.text}")
                dispatcher.utter_message(text="I'm having trouble connecting to our order system. "
                                      "Please try again later or contact customer support.")
                return [SlotSet("confirm_cancel", None)]
                
        except requests.RequestException as e:
            logger.error(f"Error connecting to backend: {str(e)}")
            dispatcher.utter_message(text="I'm having trouble connecting to our order system. "
                                  "Please try again later or contact customer support.")
            return [SlotSet("confirm_cancel", None)]
        except Exception as e:
            logger.error(f"Unexpected error in action_handle_cancel_confirmation: {str(e)}")
            dispatcher.utter_message(text="Sorry, something went wrong while trying to cancel your order. "
                                  "Please try again later or contact customer support.")
            return [SlotSet("confirm_cancel", None)]

def generate_temp_password():
    """Generate a random temporary password."""
    chars = string.ascii_letters + string.digits
    return ''.join(random.choice(chars) for _ in range(12))

class ActionResetPassword(Action):
    """
    Action to handle password reset.
    """
    def name(self) -> Text:
        return "action_reset_password"

    def run(self,
            dispatcher: CollectingDispatcher,
            tracker: Tracker,
            domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
        
        # Check if we have the email
        email = tracker.get_slot("email")
        
        if not email:
            dispatcher.utter_message(text="I'll need your email address to reset your password. What email should I use?")
            return []
        
        # Generate a temporary password
        temp_password = generate_temp_password()
        
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
                "Authorization": f"Bearer {token}",
                "Content-Type": "application/json"
            }
            
            # Call backend API to reset password
            data = {
                "email": email,
                "temp_password": temp_password
            }
            
            response = requests.post(
                f"{BACKEND_URL}/api/auth/reset-password",
                headers=headers,
                json=data
            )
            
            if response.status_code == 200:
                dispatcher.utter_message(text=f"I've reset your password. A temporary password has been sent to {email}.")
                dispatcher.utter_message(text="Please check your email and use the temporary password to log in. You'll be prompted to create a new password after login.")
                
                # In a real app, you would not reveal the password in the chat for security reasons
                # This is only for demonstration purposes
                dispatcher.utter_message(text=f"For demo purposes, your temporary password is: {temp_password}")
                
                return [SlotSet("email", None)]
                
            elif response.status_code == 404:
                dispatcher.utter_message(text=f"I couldn't find an account with the email address {email}. "
                                         "Please check the email and try again.")
                return [SlotSet("email", None)]
                
            else:
                logger.error(f"Error from backend API: {response.text}")
                dispatcher.utter_message(text="I'm having trouble processing your password reset request. "
                                        "Please try again later or contact customer support.")
                return [SlotSet("email", None)]
                
        except requests.RequestException as e:
            logger.error(f"Error connecting to backend: {str(e)}")
            dispatcher.utter_message(text="I'm having trouble connecting to our systems. "
                                    "Please try again later or contact customer support.")
            return [SlotSet("email", None)]
        except Exception as e:
            logger.error(f"Unexpected error in action_reset_password: {str(e)}")
            dispatcher.utter_message(text="Sorry, something went wrong while trying to reset your password. "
                                    "Please try again later or use the 'Forgot Password' option on the login page.")
            return [SlotSet("email", None)] 