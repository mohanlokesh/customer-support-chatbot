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
- **Python**: 3.10.11

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
└── run.py            # Application runner script
```

## Setup Instructions

### Prerequisites

- Python 3.10.11
- PostgreSQL 15
- pip (Python package manager)

### Installation

1. Open the project folder in your terminal or command prompt

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
   createdb ai_chatbot_new
   
   # Initialize the database
   python -m database.init_db
   ```

7. Train the Rasa model:
   ```
   cd nlp
   rasa train
   ```

## Running the Application

Use the run.py script to start all components automatically:

```
python run.py
```

This will start:
1. Flask backend server
2. Rasa server
3. Rasa actions server
4. Streamlit frontend

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

- `POST /api/orders/{order_number}/cancel` - Cancel a specific order

## Order Generation

Generate test orders using the provided API endpoint or command-line tool:

```bash
# Generate 5 orders for all active users
python backend/generate_orders.py --num-orders 5
```

Available options:
- `--user-ids`: IDs of users to generate orders for (default: all active users)
- `--num-orders`: Number of orders to generate per user (default: 1)
- `--status`: Order status (default: random)
- `--min-items`: Minimum number of items per order (default: 1)
- `--max-items`: Maximum number of items per order (default: 5)
- `--days-ago`: Generate orders from this many days ago until now (default: 30)
