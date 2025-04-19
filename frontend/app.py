import os
import json
import requests
import time
import datetime
from typing import List, Dict, Any
import streamlit as st
from streamlit_chat import message
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Backend API URL
BACKEND_URL = os.getenv("BACKEND_URL", "http://localhost:5000")

# Configure page
st.set_page_config(
    page_title="AI Customer Support Chatbot",
    page_icon="🤖",
    layout="wide"
)

# Initialize session state
if "messages" not in st.session_state:
    st.session_state.messages = []

if "conversation_id" not in st.session_state:
    st.session_state.conversation_id = None

if "user_id" not in st.session_state:
    st.session_state.user_id = None

if "token" not in st.session_state:
    st.session_state.token = None

def make_api_request(endpoint: str, method: str = "GET", data: Dict = None, token: str = None) -> Dict:
    """
    Make an API request to the backend.
    """
    headers = {}
    if token:
        headers["Authorization"] = f"Bearer {token}"
    
    if method == "GET":
        response = requests.get(f"{BACKEND_URL}{endpoint}", headers=headers)
    elif method == "POST":
        headers["Content-Type"] = "application/json"
        response = requests.post(f"{BACKEND_URL}{endpoint}", headers=headers, json=data)
    else:
        raise ValueError(f"Unsupported method: {method}")
    
    if response.status_code >= 400:
        st.error(f"API Error: {response.status_code} - {response.text}")
        return {"error": response.text}
    
    return response.json()

def login(username: str, password: str) -> bool:
    """
    Authenticate user with the backend.
    """
    data = {"username": username, "password": password}
    response = make_api_request("/api/auth/login", method="POST", data=data)
    
    if "error" in response:
        return False
    
    # Store user info and token in session state
    st.session_state.user_id = response["user"]["id"]
    st.session_state.token = response["access_token"]
    st.session_state.username = response["user"]["username"]
    return True

def register(username: str, email: str, password: str) -> bool:
    """
    Register a new user.
    """
    data = {"username": username, "email": email, "password": password}
    response = make_api_request("/api/auth/register", method="POST", data=data)
    
    if "error" in response:
        return False
    
    # Store user info and token in session state
    st.session_state.user_id = response["user"]["id"]
    st.session_state.token = response["access_token"]
    st.session_state.username = response["user"]["username"]
    return True

def create_conversation() -> int:
    """
    Create a new conversation.
    """
    response = make_api_request(
        "/api/conversations",
        method="POST",
        data={},
        token=st.session_state.token
    )
    
    if "error" in response:
        st.error("Failed to create conversation")
        return None
    
    return response["conversation_id"]

def get_chat_response(user_input: str) -> str:
    """
    Get a response from the chatbot.
    """
    # Ensure we have a conversation
    if not st.session_state.conversation_id:
        st.session_state.conversation_id = create_conversation()
    
    # Send message to backend
    response = make_api_request(
        "/api/chat",
        method="POST",
        data={
            "message": user_input,
            "conversation_id": st.session_state.conversation_id
        },
        token=st.session_state.token
    )
    
    if "error" in response:
        return "I'm having trouble connecting to my backend systems. Please try again later."
    
    return response["response"]

def get_order_history() -> List[Dict]:
    """
    Get order history for the current user.
    """
    response = make_api_request(
        "/api/orders",
        method="GET",
        token=st.session_state.token
    )
    
    if "error" in response:
        return []
    
    return response

def display_login_form():
    """
    Display the login form.
    """
    st.title("🤖 AI Customer Support Chatbot")
    
    # Create tabs for login and registration
    login_tab, register_tab = st.tabs(["Login", "Register"])
    
    with login_tab:
        with st.form("login_form"):
            username = st.text_input("Username")
            password = st.text_input("Password", type="password")
            submit_button = st.form_submit_button("Login")
            
            if submit_button:
                if login(username, password):
                    st.success("Login successful!")
                    st.rerun()
                else:
                    st.error("Invalid username or password")
    
    with register_tab:
        with st.form("register_form"):
            new_username = st.text_input("Username")
            new_email = st.text_input("Email")
            new_password = st.text_input("Password", type="password")
            confirm_password = st.text_input("Confirm Password", type="password")
            submit_button = st.form_submit_button("Register")
            
            if submit_button:
                if new_password != confirm_password:
                    st.error("Passwords do not match")
                elif register(new_username, new_email, new_password):
                    st.success("Registration successful!")
                    st.rerun()
                else:
                    st.error("Failed to register. Username or email may already exist.")

def display_chat_interface():
    """
    Display the chat interface.
    """
    # Sidebar with user info and options
    with st.sidebar:
        st.title(f"Welcome, {st.session_state.username}!")
        
        # View order history
        if st.button("View Order History"):
            orders = get_order_history()
            if orders:
                st.subheader("Recent Orders")
                for order in orders:
                    with st.expander(f"Order #{order['order_number']} - {order['status']}"):
                        st.write(f"**Order Date:** {order['ordered_at'][:10]}")
                        st.write(f"**Total Amount:** ${order['total_amount']}")
                        if order['tracking_number']:
                            st.write(f"**Tracking Number:** {order['tracking_number']}")
            else:
                st.info("No orders found")
        
        # Start new conversation
        if st.button("New Conversation"):
            st.session_state.conversation_id = create_conversation()
            st.session_state.messages = []
            st.rerun()
        
        # Logout button
        if st.button("Logout"):
            for key in list(st.session_state.keys()):
                del st.session_state[key]
            st.rerun()
    
    # Main chat container
    st.title("🤖 AI Customer Support Assistant")
    
    # Display chat messages
    for i, msg in enumerate(st.session_state.messages):
        if msg["is_user"]:
            message(msg["content"], is_user=True, key=f"msg_{i}")
        else:
            message(msg["content"], key=f"msg_{i}")
    
    # Chat input
    user_input = st.chat_input("Type your message here...")
    
    if user_input:
        # Add user message to chat
        st.session_state.messages.append({"content": user_input, "is_user": True})
        
        # Get bot response
        bot_response = get_chat_response(user_input)
        
        # Add bot response to chat
        st.session_state.messages.append({"content": bot_response, "is_user": False})
        
        st.rerun()

def main():
    """
    Main function to run the Streamlit app.
    """
    # Check if user is logged in
    if st.session_state.token:
        display_chat_interface()
    else:
        display_login_form()

if __name__ == "__main__":
    main() 