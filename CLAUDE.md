# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Menu-Stocker is a restaurant menu inventory management application. It's a monorepo with a Rails 8.0 API backend and a Next.js 15 frontend, configured for Japanese locale (Tokyo timezone).

## Development Commands

### Docker (Recommended)
```bash
docker-compose up          # Start all services (API on 3000, PostgreSQL on 5432, frontend on 3000)
docker-compose down        # Stop all services
```

### Backend (Rails API)
```bash
cd backend
bundle install
rails db:create db:migrate
rails s -b 0.0.0.0         # Start server on port 3000

# Linting & Security
bin/rubocop                # Ruby linting (uses rubocop-rails-omakase)
bin/brakeman --no-pager    # Security vulnerability scanning
```

### Frontend (Next.js)
```bash
cd frontend
yarn install
yarn dev                   # Start dev server with Turbopack

yarn build                 # Production build
yarn lint                  # ESLint
```

## Architecture

### Backend (`/backend`)
- **Rails 8.0 API-only mode** - No view rendering, pure JSON API
- **Ruby 3.4.1**
- **PostgreSQL 16** database
- `ApplicationController < ActionController::API` - All controllers inherit from API base
- CORS configuration in `config/initializers/cors.rb` (currently disabled, needs configuration for frontend communication)

### Frontend (`/frontend`)
- **Next.js 15** with App Router (React Server Components)
- **React 19**, **TypeScript 5** (strict mode)
- **Tailwind CSS** for styling
- Path alias: `@/*` maps to project root

### Service Communication
Docker services communicate via named network:
- `api` - Rails backend
- `psql` - PostgreSQL database
- `client` - Next.js frontend

## CI/CD

GitHub Actions (`.github/workflows/ci.yml`) runs on PRs and pushes to `main`:
1. **Brakeman** - Rails security scanning
2. **RuboCop** - Ruby code style linting
