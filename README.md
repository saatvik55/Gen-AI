## Focused Learning Agent (Flutter + FastAPI)

This project implements your updated architecture:

- **Flutter app (web + mobile)** as the presentation layer only
- **FastAPI backend** as the brains:
  - Topic CRUD
  - AI summary + quiz generation
  - Strength scoring + decay logic
- **PostgreSQL** for long‑term topic memory
- **LLM API (OpenAI / Gemini)** is called **only from the backend**

Flutter never calls the LLM directly.

### Project layout

- `backend/` – FastAPI, SQLAlchemy, PostgreSQL, LLM calls
- `frontend/` – Flutter app (web + mobile target), Riverpod, Dio, GoRouter

### Getting started – Backend

```bash
cd backend
python -m venv .venv
source .venv/bin/activate  # on Windows: .venv\Scripts\activate
pip install -r requirements.txt
uvicorn app.main:app --reload
```

The FastAPI server will default to `http://127.0.0.1:8000`.

### Getting started – Flutter

If you don't already have a Flutter project, create one in `frontend/`:

```bash
cd frontend
flutter create .
```

Then adjust your `lib/` folder to match the structure below (or copy these files into the generated project).

