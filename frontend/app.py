import os
import json
import requests
import time
import datetime
from typing import List, Dict, Any
import streamlit as st
from streamlit_chat import message
from dotenv import load_dotenv
import extra_streamlit_components as stx

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

# Initialize all session state variables first
if "messages" not in st.session_state:
    st.session_state.messages = []

if "conversation_id" not in st.session_state:
    st.session_state.conversation_id = None

if "user_id" not in st.session_state:
    st.session_state.user_id = None

if "token" not in st.session_state:
    st.session_state.token = None

if "username" not in st.session_state:
    st.session_state.username = None

if "cart" not in st.session_state:
    st.session_state.cart = {"items": [], "total": 0, "item_count": 0}

if "active_tab" not in st.session_state:
    st.session_state.active_tab = "Products"

if "products" not in st.session_state:
    st.session_state.products = []

if "categories" not in st.session_state:
    st.session_state.categories = []

if "selected_category" not in st.session_state:
    st.session_state.selected_category = "All"

if "search_query" not in st.session_state:
    st.session_state.search_query = ""

# Get cookie manager instance
cookie_manager = stx.CookieManager()

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
    elif method == "PUT":
        headers["Content-Type"] = "application/json"
        response = requests.put(f"{BACKEND_URL}{endpoint}", headers=headers, json=data)
    elif method == "DELETE":
        response = requests.delete(f"{BACKEND_URL}{endpoint}", headers=headers)
    else:
        raise ValueError(f"Unsupported method: {method}")
    
    if response.status_code >= 400:
        st.error(f"API Error: {response.status_code} - {response.text}")
        return {"error": response.text}
    
    return response.json()

def validate_token(token):
    """
    Validate the token and retrieve user information.
    Returns True if token is valid, False otherwise.
    """
    if not token:
        return False
    
    # Make a request to a protected endpoint to validate the token
    response = make_api_request("/api/conversations", method="GET", token=token)
    if "error" in response:
        return False
    
    # Get user info from backend
    try:
        # We can extract the user ID from JWT payload, but for security it's better to ask the backend
        # This would require a new endpoint in a real app, but for now let's assume the conversations endpoint works
        return True
    except Exception as e:
        st.error(f"Error validating token: {str(e)}")
        return False

# Try to load token from cookie
token = cookie_manager.get(cookie="auth_token")
if token and validate_token(token):
    st.session_state.token = token
    # Get username from cookie
    username = cookie_manager.get(cookie="username")
    if username:
        st.session_state.username = username
    user_id = cookie_manager.get(cookie="user_id")
    if user_id:
        st.session_state.user_id = user_id
elif token:
    # Token is invalid, clear it
    cookie_manager.delete(cookie="auth_token")
    cookie_manager.delete(cookie="username")
    cookie_manager.delete(cookie="user_id")

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
    
    # Store token and user info in cookies
    expires = datetime.datetime.now() + datetime.timedelta(hours=1)
    cookie_manager.set(cookie="auth_token", val=response["access_token"], expires_at=expires, key="login_token")
    cookie_manager.set(cookie="username", val=response["user"]["username"], expires_at=expires, key="login_username")
    cookie_manager.set(cookie="user_id", val=str(response["user"]["id"]), expires_at=expires, key="login_user_id")
    
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
    
    # Store token and user info in cookies
    expires = datetime.datetime.now() + datetime.timedelta(hours=1)
    cookie_manager.set(cookie="auth_token", val=response["access_token"], expires_at=expires, key="register_token")
    cookie_manager.set(cookie="username", val=response["user"]["username"], expires_at=expires, key="register_username")
    cookie_manager.set(cookie="user_id", val=str(response["user"]["id"]), expires_at=expires, key="register_user_id")
    
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
    
    # Handle case where response is already a list of orders
    if isinstance(response, list):
        return response
    
    # Handle case where response is a dictionary with an "orders" key
    return response.get("orders", [])

def get_products(category: str = None, search: str = None) -> List[Dict]:
    """
    Get list of products with optional filtering.
    """
    endpoint = "/api/products"
    params = []
    
    if category and category != "All":
        params.append(f"category={category}")
    
    if search:
        params.append(f"search={search}")
    
    if params:
        endpoint += "?" + "&".join(params)
    
    response = make_api_request(endpoint, method="GET")
    
    if "error" in response:
        return []
    
    return response.get("products", [])

def get_product_categories() -> List[str]:
    """
    Get list of product categories.
    """
    response = make_api_request("/api/products/categories", method="GET")
    
    if "error" in response:
        return []
    
    return response.get("categories", [])

def get_cart() -> Dict:
    """
    Get the current user's cart.
    """
    if not st.session_state.token:
        return {"items": [], "total": 0, "item_count": 0}
    
    response = make_api_request(
        "/api/cart",
        method="GET",
        token=st.session_state.token
    )
    
    if "error" in response:
        return {"items": [], "total": 0, "item_count": 0}
    
    # Update session state
    st.session_state.cart = {
        "items": response.get("items", []),
        "total": response.get("total", 0),
        "item_count": response.get("item_count", 0)
    }
    
    return st.session_state.cart

def add_to_cart(product_id: int, quantity: int = 1) -> bool:
    """
    Add a product to the cart.
    """
    if not st.session_state.token:
        st.error("Please log in to add items to your cart")
        return False
    
    response = make_api_request(
        "/api/cart/items",
        method="POST",
        data={"product_id": product_id, "quantity": quantity},
        token=st.session_state.token
    )
    
    if "error" in response:
        return False
    
    # Update session state
    st.session_state.cart = {
        "items": response.get("items", []),
        "total": response.get("total", 0),
        "item_count": response.get("item_count", 0)
    }
    
    return True

def update_cart_item(cart_item_id: int, quantity: int) -> bool:
    """
    Update the quantity of an item in the cart.
    """
    if not st.session_state.token:
        return False
    
    response = make_api_request(
        f"/api/cart/items/{cart_item_id}",
        method="PUT",
        data={"quantity": quantity},
        token=st.session_state.token
    )
    
    if "error" in response:
        return False
    
    # Update session state
    st.session_state.cart = {
        "items": response.get("items", []),
        "total": response.get("total", 0),
        "item_count": response.get("item_count", 0)
    }
    
    return True

def remove_from_cart(cart_item_id: int) -> bool:
    """
    Remove an item from the cart.
    """
    if not st.session_state.token:
        return False
    
    response = make_api_request(
        f"/api/cart/items/{cart_item_id}",
        method="DELETE",
        token=st.session_state.token
    )
    
    if "error" in response:
        return False
    
    # Update session state
    st.session_state.cart = {
        "items": response.get("items", []),
        "total": response.get("total", 0),
        "item_count": response.get("item_count", 0)
    }
    
    return True

def clear_cart() -> bool:
    """
    Clear all items from the cart.
    """
    if not st.session_state.token:
        return False
    
    response = make_api_request(
        "/api/cart/clear",
        method="POST",
        token=st.session_state.token
    )
    
    if "error" in response:
        return False
    
    # Update session state
    st.session_state.cart = {
        "items": [],
        "total": 0,
        "item_count": 0
    }
    
    return True

def checkout(shipping_address: str) -> Dict:
    """
    Checkout the cart and create an order.
    """
    if not st.session_state.token:
        return {"error": "Please log in to checkout"}
    
    response = make_api_request(
        "/api/cart/checkout",
        method="POST",
        data={"shipping_address": shipping_address},
        token=st.session_state.token
    )
    
    if "error" in response:
        return response
    
    # Clear the cart in session state
    st.session_state.cart = {
        "items": [],
        "total": 0,
        "item_count": 0
    }
    
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

def display_product_list():
    """
    Display product listings with filtering options.
    """
    st.title("Products")
    
    # Get categories for filter
    if not st.session_state.categories:
        st.session_state.categories = ["All"] + get_product_categories()
    
    # Create filter sidebar
    with st.sidebar:
        st.header("Filters")
        
        # Category filter
        category = st.selectbox(
            "Category",
            st.session_state.categories,
            index=st.session_state.categories.index(st.session_state.selected_category)
        )
        
        # Search filter
        search = st.text_input("Search", value=st.session_state.search_query)
        
        # Apply filters button
        if st.button("Apply Filters"):
            st.session_state.selected_category = category
            st.session_state.search_query = search
            # Get filtered products
            st.session_state.products = get_products(
                category=category if category != "All" else None,
                search=search if search else None
            )
    
    # Initialize products if empty
    if not st.session_state.products:
        st.session_state.products = get_products()
    
    # Display products in a grid
    col1, col2, col3 = st.columns(3)
    
    if not st.session_state.products:
        st.info("No products found matching your criteria.")
    else:
        for i, product in enumerate(st.session_state.products):
            with [col1, col2, col3][i % 3]:
                with st.container():
                    st.subheader(product["name"])
                    st.write(f"${product['price']:.2f}")
                    
                    # Display product image if available
                    if product.get("image_url"):
                        st.image(product["image_url"], use_column_width=True)
                    else:
                        st.write("🖼️ Image not available")
                    
                    st.write(product["description"])
                    
                    col_qty, col_btn = st.columns([1, 2])
                    with col_qty:
                        qty = st.number_input(
                            "Qty",
                            min_value=1,
                            max_value=product["stock_quantity"],
                            value=1,
                            key=f"qty_{product['id']}"
                        )
                    
                    with col_btn:
                        if st.button("Add to Cart", key=f"add_{product['id']}"):
                            if not st.session_state.token:
                                st.error("Please log in to add items to your cart")
                            else:
                                success = add_to_cart(product["id"], qty)
                                if success:
                                    st.success(f"Added {qty} x {product['name']} to cart!")
                                    st.rerun()
                                else:
                                    st.error("Failed to add item to cart")
                    
                    st.write(f"In stock: {product['stock_quantity']}")
                    st.divider()

def display_cart():
    """
    Display the user's shopping cart.
    """
    st.title("Shopping Cart")
    
    # Get current cart
    cart = get_cart()
    
    if not cart["items"]:
        st.info("Your cart is empty. Add some products!")
        return
    
    # Display cart items
    for item in cart["items"]:
        col1, col2, col3 = st.columns([3, 2, 1])
        
        with col1:
            st.subheader(item["name"])
            st.write(f"Price: ${item['price']:.2f}")
        
        with col2:
            qty = st.number_input(
                "Quantity",
                min_value=1,
                max_value=100,
                value=item["quantity"],
                key=f"cart_qty_{item['cart_item_id']}"
            )
            
            if qty != item["quantity"]:
                if st.button("Update", key=f"update_{item['cart_item_id']}"):
                    success = update_cart_item(item["cart_item_id"], qty)
                    if success:
                        st.success("Cart updated!")
                        st.rerun()
                    else:
                        st.error("Failed to update cart")
        
        with col3:
            st.write(f"Subtotal: ${item['subtotal']:.2f}")
            if st.button("Remove", key=f"remove_{item['cart_item_id']}"):
                success = remove_from_cart(item["cart_item_id"])
                if success:
                    st.success("Item removed!")
                    st.rerun()
                else:
                    st.error("Failed to remove item")
        
        st.divider()
    
    # Display cart total
    st.subheader(f"Total: ${cart['total']:.2f}")
    
    # Clear cart button
    if st.button("Clear Cart"):
        success = clear_cart()
        if success:
            st.success("Cart cleared!")
            st.rerun()
        else:
            st.error("Failed to clear cart")
    
    # Checkout section
    st.subheader("Checkout")
    with st.form("checkout_form"):
        shipping_address = st.text_area("Shipping Address")
        checkout_button = st.form_submit_button("Place Order")
        
        if checkout_button:
            if not shipping_address:
                st.error("Please enter your shipping address")
            else:
                with st.spinner("Processing your order..."):
                    result = checkout(shipping_address)
                
                if "error" in result:
                    st.error(result["error"])
                else:
                    # Format order number with ORD- prefix if needed
                    order_number = result['order_number']
                    if not order_number.startswith('ORD-'):
                        formatted_order_number = f"ORD-{order_number}"
                    else:
                        formatted_order_number = order_number
                        
                    st.success(f"Order placed successfully! Your order number is {formatted_order_number}.")
                    st.rerun()

def display_orders():
    """
    Display order history.
    """
    st.title("Order History")
    
    orders = get_order_history()
    
    if not orders:
        st.info("You don't have any orders yet.")
        return
    
    for i, order in enumerate(orders):
        # Ensure order number has ORD- prefix
        order_number = order['order_number']
        if not order_number.startswith('ORD-'):
            formatted_order_number = f"ORD-{order_number}"
        else:
            formatted_order_number = order_number
            
        with st.expander(f"Order #{formatted_order_number} - {order['status'].capitalize()}"):
            st.write(f"Date: {order['ordered_at'][:10]}")
            st.write(f"Total: ${order['total_amount']:.2f}")
            
            if order.get("estimated_delivery"):
                st.write(f"Estimated Delivery: {order['estimated_delivery'][:10]}")
            
            if order.get("tracking_number"):
                st.write(f"Tracking Number: {order['tracking_number']}")
            
            # Items section
            st.subheader("Items")
            
            # Initialize container for items
            items_container = st.container()
            
            # Generate unique key for this order
            button_key = f"load_items_{order['order_number']}"
            session_key = f"order_items_{order['order_number']}"
            
            # Check if we have already fetched the items for this order
            if session_key not in st.session_state:
                st.session_state[session_key] = {"loaded": False, "items": []}
            
            # Button to load items
            if not st.session_state[session_key]["loaded"]:
                if st.button("View Items", key=button_key):
                    # Create a loading indicator
                    with st.spinner(f"Loading items for order #{formatted_order_number}..."):
                        # Fetch order details including items
                        order_details = make_api_request(
                            f"/api/orders/{order['order_number']}",
                            method="GET",
                            token=st.session_state.token
                        )
                        
                        if "error" not in order_details and "items" in order_details:
                            # Store items in session state
                            st.session_state[session_key]["items"] = order_details["items"]
                            st.session_state[session_key]["loaded"] = True
                        else:
                            st.session_state[session_key]["items"] = []
                            st.session_state[session_key]["loaded"] = True
                        
                        st.rerun()  # Rerun to refresh the UI
            
            # Display items if they have been loaded
            with items_container:
                if st.session_state[session_key]["loaded"]:
                    items = st.session_state[session_key]["items"]
                    if items:
                        for item in items:
                            st.write(f"• {item['quantity']} x {item['product_name']} (${item['price']:.2f} each)")
                    else:
                        st.write("No items found for this order.")
                else:
                    st.write("Click 'View Items' to see the items in this order.")

def display_chat_interface():
    """
    Display the chat interface.
    """
    # Sidebar with user info and options
    with st.sidebar:
        st.title(f"Welcome, {st.session_state.username}!")
        
        # View order history
        if st.button("View Order History", key="sidebar_view_orders_button"):
            orders = get_order_history()
            if orders:
                st.subheader("Recent Orders")
                for order in orders:
                    # Ensure order number has ORD- prefix
                    order_number = order['order_number']
                    if not order_number.startswith('ORD-'):
                        formatted_order_number = f"ORD-{order_number}"
                    else:
                        formatted_order_number = order_number
                        
                    with st.expander(f"Order #{formatted_order_number} - {order['status']}"):
                        st.write(f"**Order Date:** {order['ordered_at'][:10]}")
                        st.write(f"**Total Amount:** ${order['total_amount']}")
                        if order.get('tracking_number'):
                            st.write(f"**Tracking Number:** {order['tracking_number']}")
                            
                        # Display order items with lazy loading
                        st.write("**Items:**")
                        
                        # Initialize container for items
                        chat_items_container = st.container()
                        
                        # Generate unique key for this order
                        button_key = f"chat_load_items_{order['order_number']}"
                        session_key = f"order_items_{order['order_number']}"
                        
                        # Check if we have already fetched the items for this order
                        if session_key not in st.session_state:
                            st.session_state[session_key] = {"loaded": False, "items": []}
                        
                        # Button to load items
                        if not st.session_state[session_key]["loaded"]:
                            if st.button("View Items", key=button_key):
                                # Create a loading indicator
                                with st.spinner(f"Loading items for order #{formatted_order_number}..."):
                                    # Fetch order details including items
                                    order_details = make_api_request(
                                        f"/api/orders/{order['order_number']}",
                                        method="GET",
                                        token=st.session_state.token
                                    )
                                    
                                    if "error" not in order_details and "items" in order_details:
                                        # Store items in session state
                                        st.session_state[session_key]["items"] = order_details["items"]
                                        st.session_state[session_key]["loaded"] = True
                                    else:
                                        st.session_state[session_key]["items"] = []
                                        st.session_state[session_key]["loaded"] = True
                                    
                                    st.rerun()  # Rerun to refresh the UI
                        
                        # Display items if they have been loaded
                        with chat_items_container:
                            if st.session_state[session_key]["loaded"]:
                                items = st.session_state[session_key]["items"]
                                if items:
                                    for item in items:
                                        st.write(f"• {item['quantity']} x {item['product_name']} (${item['price']:.2f} each)")
                                else:
                                    st.write("No items found for this order.")
                            else:
                                st.write("Click 'View Items' to see the items in this order.")
            else:
                st.info("No orders found")
        
        # Start new conversation
        if st.button("New Conversation"):
            st.session_state.conversation_id = create_conversation()
            st.session_state.messages = []
            st.rerun()
        
        # Logout button
        if st.button("Logout", key="sidebar_logout_button"):
            # Clear session state
            for key in list(st.session_state.keys()):
                del st.session_state[key]
            
            # Delete cookies with unique keys
            cookie_manager.delete(cookie="auth_token", key="logout_token")
            cookie_manager.delete(cookie="username", key="logout_username")
            cookie_manager.delete(cookie="user_id", key="logout_user_id")
            
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
    Main app function.
    """
    # Create a header with logo and login status
    col1, col2 = st.columns([3, 1])
    
    with col1:
        st.title("E-Shop with AI Assistant")
    
    with col2:
        if st.session_state.token:
            st.write(f"Welcome, {st.session_state.username}!")
            
            # Display cart summary
            cart = st.session_state.cart
            st.write(f"🛒 Cart: {cart['item_count']} items (${cart['total']:.2f})")
            
            if st.button("Logout", key="header_logout_button"):
                # Clear session state
                st.session_state.token = None
                st.session_state.user_id = None
                st.session_state.username = None
                st.session_state.conversation_id = None
                st.session_state.messages = []
                
                # Clear cookies
                cookie_manager.delete(cookie="auth_token")
                cookie_manager.delete(cookie="username")
                cookie_manager.delete(cookie="user_id")
                
                st.rerun()
    
    # Show login form if not authenticated
    if not st.session_state.token:
        display_login_form()
        return
    
    # Create navigation tabs
    tabs = ["Products", "Cart", "Orders", "Chat"]
    
    # Get initial cart data when logged in
    if st.session_state.cart["items"] == [] and st.session_state.token:
        st.session_state.cart = get_cart()
    
    selected_tab = st.radio("Navigation", tabs, horizontal=True, index=tabs.index(st.session_state.active_tab))
    st.session_state.active_tab = selected_tab
    
    # Show the appropriate content for the selected tab
    if selected_tab == "Products":
        display_product_list()
    elif selected_tab == "Cart":
        display_cart()
    elif selected_tab == "Orders":
        display_orders()
    elif selected_tab == "Chat":
        display_chat_interface()

if __name__ == "__main__":
    main() 