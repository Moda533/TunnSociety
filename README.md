# TunSociety (Local Dev)

Stack:
- ASP.NET Core (.NET 8)
- Angular
- MySQL via Laragon (local)
- Ollama-backed local moderation (`deepseek-r1`) with local heuristic fallback

## Backend (API)
```
cd backend/TunSociety.Api
dotnet restore
dotnet run
```

Edit `backend/TunSociety.Api/appsettings.json` if your Laragon MySQL credentials differ.
Make sure Ollama is running locally on `http://localhost:11434` with the `deepseek-r1` model pulled.
The backend uses Ollama first and falls back to local heuristic scoring if the local AI call fails.

## Frontend (Angular)
```
cd frontend/tun-society
npm install
npm start
```

The Angular dev server proxies `/api` to `http://localhost:5000`.
