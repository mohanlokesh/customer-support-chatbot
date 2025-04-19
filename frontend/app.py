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
    page_icon="��",
    layout="wide",
    initial_sidebar_state="expanded"
)

# Custom CSS for a cleaner, more modern UI
st.markdown("""
<style>
    /* Main container styling */
    .main .block-container {
        padding-top: 1rem;
        padding-bottom: 1rem;
    }
    
    /* Sidebar styling */
    .sidebar .sidebar-content {
        background-color: #f8f9fa;
    }
    
    /* Header styling */
    h1, h2, h3 {
        font-weight: 600;
        margin-bottom: 1rem;
    }
    
    /* Card-like containers */
    .product-card, .cart-item, .order-card {
        background-color: white;
        border-radius: 10px;
        padding: 1.5rem;
        margin-bottom: 1rem;
        box-shadow: 0 1px 3px rgba(0,0,0,0.12), 0 1px 2px rgba(0,0,0,0.24);
    }
    
    /* Button styling */
    .stButton button {
        border-radius: 5px;
        font-weight: 500;
    }
    
    /* Primary button styling */
    .stButton.primary button {
        background-color: #4CAF50;
        color: white;
    }
    
    /* Smaller padding for widgets */
    .stTextInput, .stNumberInput, .stSelectbox {
        padding-bottom: 0.5rem;
    }
    
    /* Divider styling */
    hr {
        margin: 1.5rem 0;
    }
    
    /* Hide hamburger menu and footer */
    #MainMenu {visibility: hidden;}
    footer {visibility: hidden;}
    
    /* Alert message styling */
    .stAlert {
        border-radius: 5px;
    }
</style>
""", unsafe_allow_html=True)

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

if "current_page" not in st.session_state:
    st.session_state.current_page = "Products"

if "products" not in st.session_state:
    st.session_state.products = []

if "categories" not in st.session_state:
    st.session_state.categories = []

if "selected_category" not in st.session_state:
    st.session_state.selected_category = "All"

if "search_query" not in st.session_state:
    st.session_state.search_query = ""

if "sidebar_expanded" not in st.session_state:
    st.session_state.sidebar_expanded = True

# Get cookie manager instance
cookie_manager = stx.CookieManager()

# Add Rasa availability check function
def check_rasa_availability():
    """Check if Rasa server is available"""
    try:
        # Instead of directly connecting to Rasa, use our backend as a proxy
        response = make_api_request("/api/health/rasa", method="GET")
        return "status" in response and response["status"] == "ok"
    except Exception:
        # Try direct connection if the proxy fails
        try:
            response = requests.get("http://localhost:5005/health", timeout=2)
            return response.status_code == 200
        except requests.exceptions.RequestException:
            return False

# Rasa availability status in session state
if "rasa_available" not in st.session_state:
    st.session_state.rasa_available = check_rasa_availability()
    st.session_state.last_rasa_check = time.time()

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
    try:
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
            # If we get an error, check if Rasa might be down
            st.session_state.rasa_available = check_rasa_availability()
            
            if not st.session_state.rasa_available:
                return "I'm having trouble connecting to my AI brain. Please try again in a moment."
            else:
                return "I'm having trouble processing your request. Please try again."
        
        # Mark Rasa as available since we got a successful response
        st.session_state.rasa_available = True
        
        return response["response"]
    except Exception as e:
        # Check Rasa availability on any exception
        st.session_state.rasa_available = check_rasa_availability()
        return "I'm having trouble processing your request. Please try again."

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
    st.markdown("<h1 style='text-align: center;'>🤖 AI Customer Support Chatbot</h1>", unsafe_allow_html=True)
    
    # Center the login form
    col1, col2, col3 = st.columns([1, 2, 1])
    
    with col2:
        st.markdown("""
            <div style="background-color: white; padding: 2rem; border-radius: 10px; box-shadow: 0 1px 3px rgba(0,0,0,0.12), 0 1px 2px rgba(0,0,0,0.24);">
            <h2 style="text-align: center; margin-bottom: 2rem;">Welcome</h2>
        """, unsafe_allow_html=True)
        
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
        
        st.markdown("</div>", unsafe_allow_html=True)

def display_product_list():
    """
    Display product listings with filtering options.
    """
    st.markdown("<h1>Products</h1>", unsafe_allow_html=True)
    
    # Get categories for filter if not already loaded
    if not st.session_state.categories:
        st.session_state.categories = ["All"] + get_product_categories()
    
    # Create filter section
    st.markdown("<h3>Filters</h3>", unsafe_allow_html=True)
    
    col1, col2, col3 = st.columns([2, 2, 1])
    
    with col1:
        # Category filter
        category = st.selectbox(
            "Category",
            st.session_state.categories,
            index=st.session_state.categories.index(st.session_state.selected_category)
        )
    
    with col2:
        # Search filter
        search = st.text_input("Search", value=st.session_state.search_query)
    
    with col3:
        # Apply filters button
        st.markdown("<br>", unsafe_allow_html=True)  # Add some spacing
        if st.button("Apply Filters", use_container_width=True):
            st.session_state.selected_category = category
            st.session_state.search_query = search
            # Get filtered products
            st.session_state.products = get_products(
                category=category if category != "All" else None,
                search=search if search else None
            )
    
    st.markdown("<hr>", unsafe_allow_html=True)
    
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
                    st.markdown(f"""
                    <div class="product-card">
                        <h3>{product["name"]}</h3>
                        <p style="font-size: 1.2rem; font-weight: bold; color: #4CAF50;">${product['price']:.2f}</p>
                    </div>
                    """, unsafe_allow_html=True)
                    
                    # Display product image if available
                    if product.get("image_url"):
                        st.image(product["image_url"], use_container_width=True)
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
                        add_btn = st.button("Add to Cart", key=f"add_{product['id']}", use_container_width=True)
                        if add_btn:
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

def display_cart():
    """
    Display the user's shopping cart.
    """
    st.markdown("<h1>Shopping Cart</h1>", unsafe_allow_html=True)
    
    # Get current cart
    cart = get_cart()
    
    if not cart["items"]:
        st.info("Your cart is empty. Add some products!")
        return
    
    # Display cart items
    for item in cart["items"]:
        st.markdown(f"""
        <div class="cart-item">
            <h3>{item["name"]}</h3>
        </div>
        """, unsafe_allow_html=True)
        
        col1, col2, col3 = st.columns([3, 2, 1])
        
        with col1:
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
    
    # Display cart total and checkout form
    st.markdown("""
    <div class="cart-item" style="margin-top: 2rem;">
        <h3>Order Summary</h3>
    </div>
    """, unsafe_allow_html=True)
    
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
    st.markdown("<h1>Order History</h1>", unsafe_allow_html=True)
    
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
        
        st.markdown(f"""
        <div class="order-card">
            <h3>Order #{formatted_order_number}</h3>
            <p style="background-color: #e7f3fe; color: #0c63e4; display: inline-block; padding: 0.3rem 0.6rem; border-radius: 4px;">{order['status'].capitalize()}</p>
        </div>
        """, unsafe_allow_html=True)
        
        with st.expander("View Details"):
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
    st.markdown("<h1>AI Customer Support Assistant</h1>", unsafe_allow_html=True)
    
    # Create a custom chat container
    st.markdown("""
    <div style="background-color: white; border-radius: 10px; padding: 1rem; box-shadow: 0 1px 3px rgba(0,0,0,0.12), 0 1px 2px rgba(0,0,0,0.24);">
    """, unsafe_allow_html=True)
    
    # Start new conversation button
    if st.button("New Conversation", key="new_chat_button"):
        st.session_state.conversation_id = create_conversation()
        st.session_state.messages = []
        st.rerun()
    
    # Display chat messages
    chat_container = st.container()
    with chat_container:
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
    
    st.markdown("</div>", unsafe_allow_html=True)

def display_account():
    """
    Display user account information.
    """
    st.markdown("<h1>Account Information</h1>", unsafe_allow_html=True)
    
    # Create a card for user info
    st.markdown(f"""
    <div class="order-card">
        <h3>Profile</h3>
        <p><strong>Username:</strong> {st.session_state.username}</p>
    </div>
    """, unsafe_allow_html=True)
    
    # Logout button
    if st.button("Logout", use_container_width=True):
        # Clear session state
        for key in list(st.session_state.keys()):
            del st.session_state[key]
        
        # Delete cookies with unique keys
        cookie_manager.delete(cookie="auth_token", key="logout_token")
        cookie_manager.delete(cookie="username", key="logout_username")
        cookie_manager.delete(cookie="user_id", key="logout_user_id")
        
        st.rerun()

def main():
    """
    Main app function with side menu navigation.
    """
    # Show login form if not authenticated
    if not st.session_state.token:
        display_login_form()
        return
    
    # Get initial cart data when logged in
    if st.session_state.cart["items"] == [] and st.session_state.token:
        st.session_state.cart = get_cart()
    
    # Side menu navigation
    with st.sidebar:
        st.markdown("<h2 style='text-align: center;'>E-Shop with AI</h2>", unsafe_allow_html=True)
        
        # User info in sidebar
        st.markdown(f"""
        <div style="text-align: center; margin-bottom: 2rem;">
            <p>Welcome, <b>{st.session_state.username}</b>!</p>
            <p>🛒 {st.session_state.cart['item_count']} items (${st.session_state.cart['total']:.2f})</p>
        </div>
        """, unsafe_allow_html=True)
        
        # Navigation menu
        st.markdown("<h3>Navigation</h3>", unsafe_allow_html=True)
        
        menu_options = {
            "Products": "🛍️ Products",
            "Cart": "🛒 Cart",
            "Orders": "📦 Orders",
            "Chat": "💬 AI Assistant",
            "Account": "👤 My Account"
        }
        
        for page, label in menu_options.items():
            if st.button(label, key=f"menu_{page}", use_container_width=True, 
                        help=f"Go to {page} page",
                        disabled=(st.session_state.current_page == page)):
                st.session_state.current_page = page
                st.rerun()
        
        # Add a separator
        st.markdown("<hr>", unsafe_allow_html=True)
        
        # Filter section (only for products page)
        if st.session_state.current_page == "Products":
            st.markdown("<h3>Quick Filters</h3>", unsafe_allow_html=True)
            
            # Get categories if not already loaded
            if not st.session_state.categories:
                st.session_state.categories = ["All"] + get_product_categories()
            
            # Category buttons
            for category in st.session_state.categories:
                if st.button(category, key=f"cat_{category}",
                           use_container_width=True,
                           disabled=(st.session_state.selected_category == category)):
                    st.session_state.selected_category = category
                    st.session_state.products = get_products(
                        category=category if category != "All" else None,
                        search=st.session_state.search_query if st.session_state.search_query else None
                    )
                    st.rerun()
    
    # Main content area - show the appropriate content for the selected page
    if st.session_state.current_page == "Products":
        display_product_list()
    elif st.session_state.current_page == "Cart":
        display_cart()
    elif st.session_state.current_page == "Orders":
        display_orders()
    elif st.session_state.current_page == "Chat":
        display_chat_interface()
    elif st.session_state.current_page == "Account":
        display_account()

if __name__ == "__main__":
    main() 