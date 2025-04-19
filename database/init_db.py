import logging
from sqlalchemy.exc import SQLAlchemyError
from database.config import init_db, SessionLocal
from database.models import User, Company, SupportData, OrderStatus
import bcrypt
import sys
import os
import random
from datetime import datetime, timedelta
from dotenv import load_dotenv
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Add parent directory to path for imports
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from database.config import engine
from database.models import Base, Conversation, Message, Order, OrderItem, Product, Cart

# Load environment variables
load_dotenv()

# Create tables
Base.metadata.create_all(engine)

# Create a session
Session = sessionmaker(bind=engine)
session = Session()

def create_initial_data():
    """
    Populate the database with initial data needed for the application.
    """
    db = SessionLocal()
    try:
        # Check if we already have data
        if db.query(User).first():
            logger.info("Database already contains data. Skipping initialization.")
            return

        logger.info("Creating initial data...")

        # Create admin user
        hashed_password = bcrypt.hashpw("admin123".encode("utf-8"), bcrypt.gensalt()).decode("utf-8")
        admin_user = User(
            username="admin",
            email="admin@example.com",
            password_hash=hashed_password,
            is_active=True
        )
        db.add(admin_user)

        # Create test user
        hashed_password = bcrypt.hashpw("test123".encode("utf-8"), bcrypt.gensalt()).decode("utf-8")
        test_user = User(
            username="testuser",
            email="test@example.com",
            password_hash=hashed_password,
            is_active=True
        )
        db.add(test_user)
        db.flush()  # Generate IDs for users

        # Create company
        company = Company(
            name="AI Chat Support Inc.",
            description="Leading provider of AI-powered chatbot solutions",
            contact_email="support@aichatsupport.com",
            contact_phone="1-800-CHATBOT",
            website="https://aichatsupport.example.com"
        )
        db.add(company)
        db.flush()  # Generate ID for company

        # Add support data
        support_data = [
            SupportData(
                company_id=company.id,
                question="How do I track my order?",
                answer="You can track your order by logging into your account and viewing the 'Orders' section. Alternatively, you can use the tracking number sent to your email.",
                category="orders"
            ),
            SupportData(
                company_id=company.id,
                question="What is your return policy?",
                answer="Our return policy allows returns within 30 days of purchase. Items must be in original condition with tags attached. Please contact customer support to initiate a return.",
                category="returns"
            ),
            SupportData(
                company_id=company.id,
                question="How long does shipping take?",
                answer="Standard shipping typically takes 3-5 business days. Express shipping is available for 1-2 business day delivery.",
                category="shipping"
            ),
            SupportData(
                company_id=company.id,
                question="Do you ship internationally?",
                answer="Yes, we ship to most countries worldwide. International shipping typically takes 7-14 business days.",
                category="shipping"
            ),
            SupportData(
                company_id=company.id,
                question="How can I change my password?",
                answer="You can change your password by going to 'Account Settings' and selecting 'Change Password'.",
                category="account"
            ),
            SupportData(
                company_id=company.id,
                question="What payment methods do you accept?",
                answer="We accept all major credit cards, PayPal, and Apple Pay.",
                category="payment"
            )
        ]
        db.add_all(support_data)

        # Commit the changes
        db.commit()
        logger.info("Initial data created successfully")

    except SQLAlchemyError as e:
        db.rollback()
        logger.error(f"Error creating initial data: {str(e)}")
    finally:
        db.close()

if __name__ == "__main__":
    logger.info("Initializing database...")
    init_db()
    logger.info("Database initialized")
    
    logger.info("Creating initial data...")
    create_initial_data()
    logger.info("Setup complete!")

# Check if we already have users
user_count = session.query(User).count()
if user_count == 0:
    print("Initializing database with sample data...")
    
    # Create demo users
    demo_users = [
        {
            "username": "demo_user",
            "email": "demo@example.com",
            "password": "password123"
        },
        {
            "username": "john_doe",
            "email": "john@example.com",
            "password": "password123"
        },
        {
            "username": "jane_smith",
            "email": "jane@example.com",
            "password": "password123"
        }
    ]
    
    for user_data in demo_users:
        hashed_password = bcrypt.hashpw(user_data["password"].encode("utf-8"), bcrypt.gensalt()).decode("utf-8")
        user = User(
            username=user_data["username"],
            email=user_data["email"],
            password_hash=hashed_password,
            created_at=datetime.utcnow(),
            last_login=datetime.utcnow(),
            is_active=True
        )
        session.add(user)
    
    # Create a company
    company = Company(
        name="E-Shop Inc.",
        description="A demo e-commerce company selling a variety of products",
        contact_email="support@eshop.com",
        contact_phone="555-123-4567",
        website="https://www.eshop-demo.com"
    )
    session.add(company)
    session.flush()  # Flush to get company ID
    
    # Create some support data (FAQ)
    support_data = [
        {
            "question": "How long does shipping take?",
            "answer": "Standard shipping usually takes 3-5 business days. Express shipping is available for 1-2 business day delivery.",
            "category": "shipping"
        },
        {
            "question": "What is your return policy?",
            "answer": "We accept returns within 30 days of purchase. Items must be in original condition with tags attached.",
            "category": "returns"
        },
        {
            "question": "Do you ship internationally?",
            "answer": "Yes, we ship to most countries worldwide. International shipping typically takes 7-14 business days.",
            "category": "shipping"
        },
        {
            "question": "How can I track my order?",
            "answer": "You can track your order by entering your order number in the 'Track Order' section of our website or by asking me to check the status for you.",
            "category": "orders"
        },
        {
            "question": "What payment methods do you accept?",
            "answer": "We accept all major credit cards, PayPal, and Apple Pay.",
            "category": "payment"
        }
    ]
    
    for data in support_data:
        faq = SupportData(
            company_id=company.id,
            question=data["question"],
            answer=data["answer"],
            category=data["category"],
            created_at=datetime.utcnow(),
            updated_at=datetime.utcnow()
        )
        session.add(faq)

    # Create sample products
    sample_products = [
        {
            "name": "Wireless Headphones",
            "description": "Premium noise-cancelling wireless headphones with 20-hour battery life",
            "price": 129.99,
            "stock_quantity": 50,
            "image_url": "https://example.com/images/headphones.jpg",
            "category": "Electronics"
        },
        {
            "name": "Smartphone Case",
            "description": "Durable protective case for the latest smartphones",
            "price": 24.99,
            "stock_quantity": 200,
            "image_url": "https://example.com/images/phone_case.jpg",
            "category": "Accessories"
        },
        {
            "name": "Fitness Tracker",
            "description": "Water-resistant fitness tracker with heart rate monitoring",
            "price": 89.99,
            "stock_quantity": 75,
            "image_url": "https://example.com/images/fitness_tracker.jpg",
            "category": "Electronics"
        },
        {
            "name": "Laptop Backpack",
            "description": "Ergonomic backpack with padded compartments for laptops up to 15 inches",
            "price": 59.99,
            "stock_quantity": 100,
            "image_url": "https://example.com/images/backpack.jpg",
            "category": "Accessories"
        },
        {
            "name": "Wireless Charger",
            "description": "Fast wireless charging pad compatible with all Qi-enabled devices",
            "price": 34.99,
            "stock_quantity": 150,
            "image_url": "https://example.com/images/wireless_charger.jpg",
            "category": "Electronics"
        },
        {
            "name": "Bluetooth Speaker",
            "description": "Portable waterproof Bluetooth speaker with 12-hour playtime",
            "price": 79.99,
            "stock_quantity": 60,
            "image_url": "https://example.com/images/bluetooth_speaker.jpg",
            "category": "Electronics"
        },
        {
            "name": "Smartwatch",
            "description": "Advanced smartwatch with fitness tracking and notifications",
            "price": 199.99,
            "stock_quantity": 40,
            "image_url": "https://example.com/images/smartwatch.jpg",
            "category": "Electronics"
        },
        {
            "name": "USB-C Hub",
            "description": "7-in-1 USB-C hub with HDMI, USB 3.0, and SD card reader",
            "price": 45.99,
            "stock_quantity": 80,
            "image_url": "https://example.com/images/usb_hub.jpg",
            "category": "Accessories"
        }
    ]
    
    for product_data in sample_products:
        product = Product(
            company_id=company.id,
            name=product_data["name"],
            description=product_data["description"],
            price=product_data["price"],
            stock_quantity=product_data["stock_quantity"],
            image_url=product_data["image_url"],
            category=product_data["category"],
            created_at=datetime.utcnow(),
            updated_at=datetime.utcnow()
        )
        session.add(product)
    
    # Create sample orders
    users = session.query(User).all()
    
    for user in users:
        # Create between 0 and 3 orders for each user
        for _ in range(random.randint(0, 3)):
            order_date = datetime.utcnow() - timedelta(days=random.randint(1, 30))
            
            # Generate a random order number
            order_number = 'ORD-' + ''.join(random.choices('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', k=8))
            
            # Pick a random status with bias towards "delivered"
            statuses = ["pending", "processing", "shipped", "delivered", "cancelled", "backordered"]
            weights = [0.1, 0.15, 0.2, 0.4, 0.05, 0.1]  # Higher weight for "delivered"
            status = random.choices(statuses, weights=weights, k=1)[0]
            
            # Create the order
            order = Order(
                order_number=order_number,
                user_id=user.id,
                total_amount=0,  # Will calculate after adding items
                status=status,
                ordered_at=order_date,
                estimated_delivery=order_date + timedelta(days=random.randint(3, 10)),
                delivered_at=order_date + timedelta(days=random.randint(3, 7)) if status == "delivered" else None,
                shipping_address="123 Main St, Anytown, AN 12345",
                tracking_number=''.join(random.choices('0123456789', k=12)) if status in ["shipped", "delivered"] else None
            )
            session.add(order)
            session.flush()  # To get the order ID
            
            # Add between 1 and 5 items to the order
            total_amount = 0
            for _ in range(random.randint(1, 5)):
                # Get a random product from the database
                products = session.query(Product).all()
                product = random.choice(products)
                
                quantity = random.randint(1, 3)
                price = product.price
                
                item = OrderItem(
                    order_id=order.id,
                    product_name=product.name,
                    quantity=quantity,
                    price=price
                )
                session.add(item)
                
                total_amount += price * quantity
            
            # Update the order's total amount
            order.total_amount = total_amount
            
    # Create empty carts for each user
    for user in users:
        cart = Cart(
            user_id=user.id,
            created_at=datetime.utcnow(),
            updated_at=datetime.utcnow()
        )
        session.add(cart)
    
    # Commit all changes
    session.commit()
    print("Database initialized successfully!")
else:
    print("Database already contains data. Skipping initialization.")

# Close the session
session.close() 