#!/usr/bin/env python3
"""
Script to generate new orders for users in the database.
This can be used to populate test data or create orders in bulk.
"""

import argparse
import random
import uuid
from datetime import datetime, timedelta
import logging
from typing import List, Optional
import os
import sys

# Add the project root directory to the Python path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from sqlalchemy.exc import SQLAlchemyError
from database.config import SessionLocal
from database.models import User, Order, OrderItem, OrderStatus

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)

# Sample product data for generating random order items
SAMPLE_PRODUCTS = [
    {"name": "Smart Speaker", "price": 89.99},
    {"name": "Wireless Headphones", "price": 129.99},
    {"name": "Smartphone Case", "price": 24.99},
    {"name": "USB-C Cable", "price": 12.99},
    {"name": "Power Bank", "price": 39.99},
    {"name": "Wireless Charger", "price": 29.99},
    {"name": "Bluetooth Keyboard", "price": 59.99},
    {"name": "Tablet Stand", "price": 19.99},
    {"name": "Screen Protector", "price": 9.99},
    {"name": "Laptop Sleeve", "price": 34.99},
]

def generate_order_number() -> str:
    """Generate a unique order number"""
    return f"ORD-{uuid.uuid4().hex[:8].upper()}"

def generate_tracking_number() -> str:
    """Generate a random tracking number"""
    return f"TRK{random.randint(1000000, 9999999)}"

def generate_address() -> str:
    """Generate a random shipping address"""
    street_numbers = list(range(1, 999))
    street_names = ["Main St", "Oak Ave", "Maple Dr", "Park Blvd", "Washington St"]
    cities = ["New York", "Los Angeles", "Chicago", "Houston", "Phoenix"]
    states = ["NY", "CA", "IL", "TX", "AZ"]
    zip_codes = [f"{random.randint(10000, 99999)}" for _ in range(5)]
    
    street_number = random.choice(street_numbers)
    street_name = random.choice(street_names)
    city = random.choice(cities)
    state = random.choice(states)
    zip_code = random.choice(zip_codes)
    
    return f"{street_number} {street_name}, {city}, {state} {zip_code}"

def create_order_items(db_session, order_id: int, min_items: int = 1, max_items: int = 5) -> List[OrderItem]:
    """Create a random number of order items for an order"""
    num_items = random.randint(min_items, max_items)
    order_items = []
    
    # Select random products
    selected_products = random.sample(SAMPLE_PRODUCTS, num_items)
    
    for product in selected_products:
        quantity = random.randint(1, 3)
        item = OrderItem(
            order_id=order_id,
            product_name=product["name"],
            quantity=quantity,
            price=product["price"]
        )
        db_session.add(item)
        order_items.append(item)
    
    return order_items

def generate_orders(
    user_ids: List[int] = None,
    num_orders: int = 1,
    status: Optional[str] = None,
    min_items: int = 1,
    max_items: int = 5,
    start_date: Optional[datetime] = None,
    end_date: Optional[datetime] = None
) -> List[Order]:
    """
    Generate new orders for specified users
    
    Args:
        user_ids: List[int] = None,
        num_orders: Number of orders to generate per user
        status: Specific order status (if None, randomly assigns status)
        min_items: Minimum number of items per order
        max_items: Maximum number of items per order
        start_date: Start date for order timestamps (if None, uses last 30 days)
        end_date: End date for order timestamps (if None, uses current date)
        
    Returns:
        List of created Order objects
    """
    created_orders = []
    
    # Create a session just to get the user IDs, then close it
    db = SessionLocal()
    try:
        # If no user IDs provided, get all active users
        if not user_ids:
            users = db.query(User).filter(User.is_active == True).all()
            user_ids = [user.id for user in users]
    finally:
        db.close()
    
    # If no users found, exit
    if not user_ids:
        logger.warning("No users found to generate orders for")
        return []
        
    # Define date range for orders
    if not end_date:
        end_date = datetime.utcnow()
    if not start_date:
        start_date = end_date - timedelta(days=30)
    
    logger.info(f"Generating {num_orders} order(s) for {len(user_ids)} user(s)")
    
    # Process each user with a separate DB session
    for user_id in user_ids:
        user_orders = []
        
        # Generate orders for this user
        for _ in range(num_orders):
            # Create a new session for each order to avoid transaction conflicts
            db = SessionLocal()
            
            try:
                # Generate random order date within range
                ordered_at = start_date + timedelta(
                    seconds=random.randint(0, int((end_date - start_date).total_seconds()))
                )
                
                # Set order status
                if status:
                    order_status = OrderStatus(status)
                else:
                    # Random status with weighted probability
                    statuses = list(OrderStatus)
                    weights = [0.1, 0.2, 0.3, 0.3, 0.05, 0.05]  # Adjust probabilities as needed
                    order_status = random.choices(statuses, weights=weights, k=1)[0]
                
                # Create estimate and delivery dates based on status
                estimated_delivery = ordered_at + timedelta(days=random.randint(3, 10))
                delivered_at = None
                if order_status == OrderStatus.DELIVERED:
                    delivered_at = estimated_delivery - timedelta(hours=random.randint(0, 48))
                
                # Select random products first to calculate the total amount
                num_items = random.randint(min_items, max_items)
                selected_products = random.sample(SAMPLE_PRODUCTS, num_items)
                
                # Calculate total amount before creating order
                total_amount = 0.0
                for product in selected_products:
                    quantity = random.randint(1, 3)
                    total_amount += product["price"] * quantity
                
                # Create the order
                order = Order(
                    order_number=generate_order_number(),
                    user_id=user_id,
                    status=order_status,
                    ordered_at=ordered_at,
                    estimated_delivery=estimated_delivery,
                    delivered_at=delivered_at,
                    shipping_address=generate_address(),
                    tracking_number=generate_tracking_number() if order_status != OrderStatus.PENDING else None,
                    total_amount=total_amount  # Set the calculated total amount
                )
                
                db.add(order)
                db.flush()  # Generate order ID
                
                # Create order items
                for product in selected_products:
                    quantity = random.randint(1, 3)
                    item = OrderItem(
                        order_id=order.id,
                        product_name=product["name"],
                        quantity=quantity,
                        price=product["price"]
                    )
                    db.add(item)
                
                # Commit this order
                db.commit()
                user_orders.append(order)
                created_orders.append(order)
                logger.info(f"Created order #{order.order_number} for user #{user_id}")
                
            except Exception as e:
                db.rollback()
                logger.error(f"Error generating an order for user {user_id}: {str(e)}")
                # Continue with next order
            finally:
                db.close()
    
    logger.info(f"Successfully generated {len(created_orders)} orders")
    return created_orders

def main():
    """Main function to parse arguments and generate orders"""
    parser = argparse.ArgumentParser(description="Generate orders for users in the database")
    parser.add_argument("--user-ids", type=int, nargs="+", help="IDs of users to generate orders for (default: all active users)")
    parser.add_argument("--num-orders", type=int, default=1, help="Number of orders to generate per user (default: 1)")
    parser.add_argument("--status", type=str, choices=[s.value for s in OrderStatus], help="Order status (default: random)")
    parser.add_argument("--min-items", type=int, default=1, help="Minimum number of items per order (default: 1)")
    parser.add_argument("--max-items", type=int, default=5, help="Maximum number of items per order (default: 5)")
    parser.add_argument("--days-ago", type=int, default=30, help="Generate orders from this many days ago until now (default: 30)")
    
    args = parser.parse_args()
    
    # Calculate date range based on days_ago
    end_date = datetime.utcnow()
    start_date = end_date - timedelta(days=args.days_ago)
    
    # Generate orders
    orders = generate_orders(
        user_ids=args.user_ids,
        num_orders=args.num_orders,
        status=args.status,
        min_items=args.min_items,
        max_items=args.max_items,
        start_date=start_date,
        end_date=end_date
    )
    
    # Print summary
    if orders:
        print(f"Successfully generated {len(orders)} orders")
        for i, order in enumerate(orders, 1):
            print(f"{i}. Order #{order.order_number} for User #{order.user_id}: {order.total_amount:.2f} ({order.status.value})")
    else:
        print("No orders were generated")

if __name__ == "__main__":
    main() 