import logging
from sqlalchemy.exc import SQLAlchemyError
from database.config import init_db, SessionLocal
from database.models import User, Company, SupportData, OrderStatus
import bcrypt

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

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