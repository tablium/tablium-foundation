# Tablium Platform Foundation

This repository serves as the foundation and central documentation hub for the Tablium platform. It contains architectural decisions, technical specifications, project planning, and implementation guidelines for all Tablium services.

## Repository Structure

```
tablium-foundation/
├── docs/
│   ├── architecture/        # Technical architecture and specifications
│   └── project-plan/        # Project phases and planning documents
├── scripts/                 # Utility scripts for platform management
└── README.md               # This file
```

## Documentation Overview

### Architecture Documentation

- **Core Architecture**
  - [Technical Architecture](docs/architecture/technical-architecture.md)
  - [Backend Architecture](docs/architecture/backend-architecture.md)
  - [Frontend Architecture](docs/architecture/frontend.md)
  - [Service Communication](docs/architecture/service-communication.md)

- **Game Systems**
  - [Game Engines Strategy](docs/architecture/game-engines-strategy.md)
  - [Tournament System](docs/architecture/table-tournament-system.md)
  - [Lobby System](docs/architecture/lobby-system.md)
  - [Real-time Communication](docs/architecture/real-time-communication.md)

- **Security & Anti-Cheat**
  - [Anti-Cheat System](docs/architecture/anti-cheat.md)
  - [Enhanced Anti-Cheat](docs/architecture/enhanced-anti-cheat.md)
  - [Anti-Cheat Integration](docs/architecture/anti-cheat-integration.md)
  - [Anti-Cheat Error Handling](docs/architecture/anti-cheat-error-handling.md)

- **Blockchain Integration**
  - [Smart Contracts](docs/architecture/smart-contracts.md)
  - [Tournament Contracts](docs/architecture/tournament-contracts.md)
  - [Transfer Security](docs/architecture/transfer-security.md)
  - [Transfer Automation](docs/architecture/transfer-automation.md)
  - [Transfer Flow](docs/architecture/transfer-flow.md)

- **Development Standards**
  - [Error Handling Standards](docs/architecture/error-handling-standards.md)
  - [Database Migrations](docs/architecture/database-migrations.md)
  - [Technology Stack](docs/architecture/technology-stack.md)

### Project Planning

- [Project Overview](docs/project-plan/README.md)
- [Sprint Planning](docs/project-plan/sprint-planning.md)
- [Task Tracking](docs/project-plan/task-tracking.md)

#### Development Phases
1. [Backend Development](docs/project-plan/phase1-backend.md)
2. [Smart Contracts Development](docs/project-plan/phase2-smart-contracts.md)
3. [Frontend Development](docs/project-plan/phase3-frontend.md)
4. [Integration Phase](docs/project-plan/phase4-integration.md)

## Platform Components

The Tablium platform consists of the following main components:

### Core Services
- [API Gateway](https://github.com/tablium/tablium-api-gateway)
- [Auth Service](https://github.com/tablium/tablium-auth-service)
- [User Service](https://github.com/tablium/tablium-user-service)
- [Wallet Service](https://github.com/tablium/tablium-wallet-service)
- [Database Configuration](https://github.com/tablium/tablium-db-config)

### Game Services
- [Game State Service](https://github.com/tablium/tablium-game-state)
- [Realtime Service](https://github.com/tablium/tablium-realtime)
- [Game Engines](https://github.com/tablium/tablium-game-engines)
- [Tournament Service](https://github.com/tablium/tablium-tournament-service)
- [Matchmaking Service](https://github.com/tablium/tablium-matchmaking-service)
- [Leaderboard Service](https://github.com/tablium/tablium-leaderboard-service)
- [Replay Service](https://github.com/tablium/tablium-replay-service)

### Blockchain Services
- [Token Contract](https://github.com/tablium/tablium-token-contract)
- [Game Contract](https://github.com/tablium/tablium-game-contract)
- [Tournament Contract](https://github.com/tablium/tablium-tournament-contract)

### Support Services
- [Analytics Service](https://github.com/tablium/tablium-analytics-service)
- [Notification Service](https://github.com/tablium/tablium-notification-service)
- [AI Engine](https://github.com/tablium/tablium-ai-engine)

### Frontend
- [Frontend Application](https://github.com/tablium/tablium-frontend)

### Infrastructure
- [Kubernetes Configuration](https://github.com/tablium/tablium-k8s)
- [Terraform Infrastructure](https://github.com/tablium/tablium-terraform)
- [CI/CD Pipeline](https://github.com/tablium/tablium-ci-cd)
- [Monitoring Stack](https://github.com/tablium/tablium-monitoring)

#### Shared Libraries
- Service Discovery
  - [Go Implementation](https://github.com/tablium/tablium-go-service-discovery)
  - [Python Implementation](https://github.com/tablium/tablium-py-service-discovery)
- Error Handling
  - [Go Implementation](https://github.com/tablium/tablium-go-errors)
  - [Python Implementation](https://github.com/tablium/tablium-py-errors)
  - [TypeScript Implementation](https://github.com/tablium/tablium-ts-errors)
  - [Rust Implementation](https://github.com/tablium/tablium-rs-errors)
  - [Solidity Implementation](https://github.com/tablium/tablium-sol-errors)
- Message Queue
  - [Go Implementation](https://github.com/tablium/tablium-go-rabbitmq)
  - [Python Implementation](https://github.com/tablium/tablium-py-rabbitmq)

## Getting Started

1. Clone this repository:
   ```bash
   git clone https://github.com/tablium/tablium-foundation.git
   ```

2. Review the [Project Overview](docs/project-plan/README.md) to understand the platform's goals and architecture.

3. Follow the development phases in the project plan:
   - [Phase 1: Backend](docs/project-plan/phase1-backend.md)
   - [Phase 2: Smart Contracts](docs/project-plan/phase2-smart-contracts.md)
   - [Phase 3: Frontend](docs/project-plan/phase3-frontend.md)
   - [Phase 4: Integration](docs/project-plan/phase4-integration.md)

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details. 