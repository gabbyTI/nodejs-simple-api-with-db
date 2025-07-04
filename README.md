# Node.js Simple API with PostgreSQL

A simple REST API built with Node.js, Express, and PostgreSQL (via Prisma ORM). This project is designed for practicing DevOps, SRE, and cloud infrastructure skills. It includes user and message management, health checks, and a basic web UI.

## Features
- RESTful API for users and messages
- PostgreSQL database with Prisma ORM
- Express.js server with logging (Pino)
- Health check endpoint
- Static web dashboard (HTML/JS)
- Graceful shutdown and error handling
- Docker and Docker Compose support
- Environment variable configuration
- Ready for cloud deployment

## Endpoints
- `GET /health` — Health check
- `GET /users` — List users
- `POST /users` — Create user
- `GET /users/:id` — Get user by ID
- `DELETE /users/:id` — Delete user
- `GET /messages` — List messages
- `POST /messages` — Create message
- `GET /messages/:id` — Get message by ID
- `DELETE /messages/:id` — Delete message

## Getting Started

### Prerequisites
- Node.js (v18+ recommended)
- PostgreSQL database
- npm

### Setup
1. **Clone the repository:**
   ```bash
   git clone <repo-url>
   cd nodejs-simpleapi-with-db
   ```
2. **Install dependencies:**
   ```bash
   npm install
   ```
3. **Configure environment variables:**
   - Copy `.env` and update `DATABASE_URL` for your PostgreSQL instance.
4. **Run database migrations:**
   ```bash
   npm run db:migrate
   ```
5. **(Optional) Seed the database:**
   ```bash
   npm run db:seed
   ```
6. **Start the development server:**
   ```bash
   npm run dev
   ```
   The app will be available at http://localhost:3000

### Running Tests
```bash
npm test
```

### Build and Run in Production
```bash
npm run build
npm start
```

### Docker Usage
Build and run the app in Docker:
```bash
docker build -t simpleapi .
docker run --env-file .env -p 3000:3000 simpleapi
```

Or use Docker Compose (add your service config to `docker-compose.yml`):
```bash
docker-compose up --build
```

## Project Structure
```
├── src/
│   ├── index.ts         # Entry point
│   ├── server.ts        # Express app and server logic
│   ├── lib/
│   │   ├── prisma.ts    # Prisma client
│   │   └── logger.ts    # Centralized logger
│   ├── routes/          # API route handlers
│   └── public/          # Static HTML dashboard
├── prisma/              # Prisma schema and migrations
├── tests/               # Integration and helper tests
├── Dockerfile           # Docker build config
├── .env                 # Environment variables
├── package.json         # NPM scripts and dependencies
└── README.md            # Project documentation
```

## Logging
- Uses [Pino](https://getpino.io/) for structured logging.
- Logs requests, errors, and important events.

## License
MIT
