# AI-Driven Chatbot for Customer Support/E-commerce

An AI-powered chatbot system for customer support and e-commerce that understands user queries, retrieves answers from a database, and learns from interactions.

## Features

- User authentication (login/register)
- Real-time chat interface
- Natural language understanding with Rasa
- PostgreSQL database integration
- Order tracking and product lookup
- Conversation history
- Custom actions for database interaction

## Technology Stack

- **Frontend**: Streamlit 2.0+
- **Backend**: Flask 3.0+
- **NLP**: Rasa 3.6+
- **Database**: PostgreSQL
- **Python**: 3.10+

## Project Structure

```
ai-chatbot/
├── backend/          # Flask API server
├── database/         # PostgreSQL database models and config
├── frontend/         # Streamlit web interface
├── nlp/              # Rasa NLP component
│   ├── actions/      # Custom actions for Rasa
│   ├── data/         # Training data
│   └── models/       # Trained models (generated)
└── README.md         # Project documentation
```

## Setup Instructions

### Prerequisites

- Python 3.10.11
- PostgreSQL 15
- pip (Python package manager)

### Installation

1. Clone the repository:
   ```
   git clone https://github.com/yourusername/ai-chatbot.git
   cd ai-chatbot
   ```

2. Create a virtual environment:
   ```
   python -m venv venv
   # On Windows
   venv\Scripts\activate
   # On macOS/Linux
   source venv/bin/activate
   ```

3. Install dependencies:
   ```
   pip install -r requirements.txt
   ```

4. Install Spacy language model:
   ```
   python -m spacy download en_core_web_md
   ```

5. Set up the environment variables:
   ```
   cp .env.example .env
   # Edit .env with your configuration
   ```

6. Set up the database:
   ```
   # Create the PostgreSQL database
   createdb ai_chatbot
   
   # Initialize the database
   python -m database.init_db
   ```

7. Train the Rasa model:
   ```
   cd nlp
   rasa train
   ```

## Running the Application

You need to run several components separately:

1. Start the Flask backend server:
   ```
   cd backend
   python app.py
   ```

2. Start the Rasa server:
   ```
   cd nlp
   rasa run --enable-api
   ```

3. Start the Rasa actions server:
   ```
   cd nlp
   rasa run actions
   ```

4. Start the Streamlit frontend:
   ```
   cd frontend
   streamlit run app.py
   ```

The application will be accessible at: http://localhost:8501

## API Documentation

### Authentication Endpoints

- `POST /api/auth/register` - Register a new user
- `POST /api/auth/login` - Authenticate user and get JWT token

### Conversation Endpoints

- `GET /api/conversations` - Get all conversations for current user
- `POST /api/conversations` - Create a new conversation
- `GET /api/conversations/{id}/messages` - Get messages for a conversation
- `POST /api/conversations/{id}/messages` - Add a message to a conversation

### Chat Endpoint

- `POST /api/chat` - Send a message to the chatbot and get a response

### Order Endpoints

- `GET /api/orders` - Get all orders for the current user
- `GET /api/orders/{order_number}` - Get details for a specific order
- `GET /api/orders/{order_number}/status` - Get status of a specific order

## Database Schema

1. **Users**: id, username, email, password_hash, created_at, last_login, is_active

2. **Conversations**: id, user_id, start_time, end_time, duration

3. **Messages**: id, conversation_id, is_user, content, timestamp

4. **Orders**: id, order_number, user_id, total_amount, status, ordered_at, estimated_delivery, delivered_at, shipping_address, tracking_number

5. **OrderItems**: id, order_id, product_name, quantity, price

6. **Company**: id, name, description, contact_email, contact_phone, website

7. **SupportData**: id, company_id, question, answer, category, created/updated timestamps

## License

This project is licensed under the MIT License - see the LICENSE file for details. 