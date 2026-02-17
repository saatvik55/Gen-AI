# Learning Agent Backend

FastAPI backend for topics, summaries, quizzes, and strength tracking.

## Setup

### Prerequisites
- Python 3.9+
- PostgreSQL (optional, for production use)

### Installation

1. **Activate the virtual environment:**
   ```bash
   source .venv/bin/activate  # On macOS/Linux
   # or
   .venv\Scripts\activate  # On Windows
   ```

2. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

3. **Configure environment variables:**
   - Copy `.env.example` to `.env`
   - Update `DATABASE_URL` if needed

### Running the Server

```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

Or with the venv activated:
```bash
.venv/bin/uvicorn app.main:app --reload
```

### API Documentation

Once the server is running, visit:
- **Swagger UI:** http://localhost:8000/docs
- **ReDoc:** http://localhost:8000/redoc
- **Health Check:** http://localhost:8000/health

## API Endpoints

### Topics
- `GET /topics/` - List all topics
- `POST /topics/` - Create a new topic

### Health
- `GET /health` - Health check endpoint

## Project Structure

```
backend/
├── .venv/                   # Virtual environment
├── app/
│   ├── __init__.py          # Package initialization
│   ├── main.py              # FastAPI application
│   ├── database.py          # Database configuration
│   ├── models.py            # SQLAlchemy models
│   ├── schemas.py           # Pydantic schemas
│   └── router_topics.py     # Topics routes
├── .env                     # Environment variables (not in git)
├── .env.example             # Environment template
├── .gitignore              # Git ignore rules
├── requirements.txt         # Python dependencies
└── README.md               # This file
```

## Dependencies

- **FastAPI 0.115.0** - Modern web framework
- **Uvicorn 0.30.0** - ASGI server
- **SQLAlchemy 2.0.36** - ORM
- **Psycopg 3.1.18** - PostgreSQL adapter
- **Pydantic 2.9.0** - Data validation
- **Python-dotenv 1.0.1** - Environment management
- **HTTPX 0.27.2** - HTTP client

## Development

The server runs with auto-reload enabled in development mode. Any changes to Python files will automatically restart the server.
