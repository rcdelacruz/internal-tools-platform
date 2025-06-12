# Internal Tools Platform

> A comprehensive platform for building internal organizational tools with shared services and self-contained Next.js applications.

## 🎯 Overview

This platform provides a robust foundation for building internal tools with shared services architecture. It's designed for fast developer onboarding, consistent patterns, and scalable deployment.

### Key Features

- **Shared Services**: NestJS-based microservices for authentication, user management, notifications, file handling, and audit logging
- **Self-Contained Apps**: Next.js full-stack applications that can operate independently
- **Developer Experience**: One-command setup, consistent patterns, comprehensive documentation
- **Future-Ready**: API-first design, packageable services, SDK-ready architecture
- **Platform Agnostic**: Deploy anywhere with Docker containers

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Next.js App   │    │   Next.js App   │    │   Next.js App   │
│   (Resource     │    │   (Skills       │    │   (Knowledge    │
│   Management)   │    │   Assessment)   │    │   Base)         │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────────┐
                    │   NestJS Shared     │
                    │   Services          │
                    │   - Auth            │
                    │   - Users           │
                    │   - Notifications   │
                    │   - Files           │
                    │   - Audit           │
                    └─────────────────────┘
                                 │
                    ┌─────────────────────┐
                    │   Data Layer        │
                    │   - PostgreSQL      │
                    │   - Redis           │
                    │   - File Storage    │
                    └─────────────────────┘
```

## 🚀 Quick Start

### Prerequisites

- Node.js 18+ and npm
- Docker and Docker Compose
- Git

### Development Setup

```bash
# Clone the repository
git clone https://github.com/rcdelacruz/internal-tools-platform.git
cd internal-tools-platform

# One-command setup
npm run setup:dev

# This will:
# 1. Install all dependencies
# 2. Start Docker services (PostgreSQL, Redis)
# 3. Run database migrations
# 4. Start all services in development mode
# 5. Open browser to local dashboard
```

### Available Services

After setup, the following services will be available:

- **Shared Services API**: http://localhost:3001
- **Resource Management App**: http://localhost:3002
- **API Documentation**: http://localhost:3001/api
- **Database Admin**: http://localhost:5050 (pgAdmin)
- **Redis Admin**: http://localhost:8081 (RedisInsight)

## 📁 Project Structure

```
internal-tools-platform/
├── packages/                     # Shared packages
│   ├── shared-types/            # TypeScript definitions
│   ├── shared-client/           # API client library
│   ├── shared-ui/               # Common UI components
│   └── shared-config/           # Configuration utilities
├── services/
│   └── shared-services/         # NestJS backend services
├── apps/
│   ├── resource-management/     # Resource management app
│   ├── skills-assessment/       # Skills assessment app (future)
│   └── knowledge-base/          # Knowledge base app (future)
├── infrastructure/              # Docker and deployment configs
├── docs/                        # Comprehensive documentation
├── scripts/                     # Development and deployment scripts
└── tools/                       # Development tools and utilities
```

## 📚 Documentation

### For Developers

- [Getting Started Guide](docs/getting-started.md) - Complete onboarding guide
- [Development Workflow](docs/development-workflow.md) - Day-to-day development practices
- [Creating New Apps](docs/creating-new-apps.md) - Template-based app creation
- [Shared Services API](docs/api/shared-services-api.md) - Complete API reference
- [Database Schema](docs/database-schema.md) - Data model documentation

### For Architecture

- [Architecture Overview](docs/architecture/overview.md) - System design and patterns
- [ADRs (Architecture Decision Records)](docs/ADRs/) - Decision history and rationale
- [Deployment Guide](docs/deployment/) - Multi-platform deployment instructions
- [Security Guidelines](docs/security.md) - Security best practices

### For Operations

- [Monitoring Setup](docs/operations/monitoring.md) - Observability and monitoring
- [Backup & Recovery](docs/operations/backup-recovery.md) - Data protection strategies
- [Troubleshooting](docs/operations/troubleshooting.md) - Common issues and solutions

## 🛠️ Available Commands

```bash
# Development
npm run dev                      # Start all services in development mode
npm run dev:shared              # Start only shared services
npm run dev:resource            # Start only resource management app

# Building
npm run build                   # Build all packages and applications
npm run build:shared            # Build shared services
npm run build:apps              # Build all applications

# Testing
npm run test                    # Run all tests
npm run test:unit               # Run unit tests only
npm run test:integration        # Run integration tests only
npm run test:e2e                # Run end-to-end tests

# Utilities
npm run setup:dev               # Complete development setup
npm run create:app <name>       # Create new Next.js application
npm run db:migrate              # Run database migrations
npm run db:seed                 # Seed database with sample data
npm run lint                    # Lint all code
npm run format                  # Format all code

# Deployment
npm run deploy:staging          # Deploy to staging environment
npm run deploy:production       # Deploy to production environment
```

## 🔧 Technology Stack

### Backend (Shared Services)
- **Framework**: NestJS with TypeScript
- **Database**: PostgreSQL with Prisma ORM
- **Cache**: Redis
- **Authentication**: JWT with refresh tokens
- **API Documentation**: OpenAPI/Swagger
- **Testing**: Jest with supertest

### Frontend (Applications)
- **Framework**: Next.js 14+ with App Router
- **Language**: TypeScript
- **Styling**: Tailwind CSS
- **UI Components**: Radix UI + Custom components
- **State Management**: Zustand
- **Forms**: React Hook Form with Zod validation
- **Testing**: Vitest + Testing Library

### Infrastructure
- **Containerization**: Docker and Docker Compose
- **Process Management**: PM2
- **Reverse Proxy**: Nginx
- **Monitoring**: Prometheus + Grafana
- **Logging**: Winston + ELK Stack

## 🤝 Contributing

1. Read the [Development Workflow](docs/development-workflow.md)
2. Check the [Coding Standards](docs/coding-standards.md)
3. Create a feature branch
4. Make your changes with tests
5. Submit a pull request

## 📄 License

This project is proprietary and intended for internal use only.

## 🆘 Support

- **Documentation**: Check the [docs/](docs/) directory
- **Issues**: Create an issue in this repository
- **Questions**: Reach out to the platform team

---

**Built with ❤️ for efficient internal tool development**