# Technology Stack

This document outlines the technology stack for the Tablium platform, including language choices for different services and their justifications.

## Core Infrastructure

| Service | Language | Justification |
|---------|----------|---------------|
| **API Gateway** | Go | High performance for routing and proxying, excellent concurrency model for handling thousands of simultaneous connections, low latency, and resource efficiency |
| **Auth Service** | TypeScript | Strong typing for security-critical code, shared types with frontend, extensive OAuth and authentication libraries |
| **User Service** | TypeScript | Object-oriented design fits user domain model, shared types with frontend, rich ecosystem for validation |
| **Wallet Service** | Rust | Memory safety critical for financial operations, performance benefits for cryptographic operations, strong guarantees against common vulnerabilities |
| **DB Config** | TypeScript | Integration with TypeORM and other TypeScript services, schema sharing capabilities |

## Game Services

| Service | Language | Justification |
|---------|----------|---------------|
| **Dominoes Game Engine** | TypeScript | Complex game rules benefit from strong typing, easier to implement game variant logic, shared types with frontend |
| **Chess Game Engine** | TypeScript | Rich type system for complex chess rules, existing chess libraries in TypeScript ecosystem |
| **Draughts Game Engine** | TypeScript | Consistent with other game engines, benefits from same architectural patterns |
| **Go Game Engine** | TypeScript | Consistency with other engines, complex territory scoring benefits from strong typing |
| **Game State Service** | Go | Performance-critical state persistence, efficient binary serialization, excellent concurrency for handling many simultaneous games |
| **Realtime Service** | Go | Superior WebSocket performance, efficient memory usage for thousands of connections, low latency communication |

## Frontend

| Service | Language | Justification |
|---------|----------|---------------|
| **Game UI** | TypeScript/React | Industry standard for interactive UIs, strong typing for game state management, rich ecosystem for game visualization |

## Smart Contracts

| Service | Language | Justification |
|---------|----------|---------------|
| **Token Contract** | Solidity/Rust | Solidity for Ethereum compatibility, Rust for blockchain integration and off-chain processing |
| **Game Contract** | Solidity/Rust | Solidity for on-chain game verification, Rust for high-performance cryptographic operations |
| **Tournament Contract** | Solidity/Rust | Same pattern as other blockchain components for consistency |

## Integration & AI

| Service | Language | Justification |
|---------|----------|---------------|
| **Integration** | TypeScript | Consistent with majority of services, flexibility for various integration patterns |
| **AI Engine** | Python | Industry-leading ML/AI libraries (TensorFlow, PyTorch), excellent for rapid prototyping of game AI algorithms |

## Cross-Cutting Concerns

### Infrastructure as Code
- Terraform (HCL)
- Docker (Containerization)
- Kubernetes (Container Orchestration)

### Databases
- PostgreSQL (Primary relational database)
- Redis (Caching, realtime features)
- MongoDB (Game state history, analytics)

### Messaging
- Kafka/RabbitMQ (Event sourcing, service communication)

## Language Selection Strategy

The language selection strategy follows these principles:

1. **Performance-critical paths**: Go or Rust for services requiring maximum performance or handling many connections
2. **Blockchain integration**: Rust for secure blockchain interfacing with Solidity for smart contracts
3. **Game logic**: TypeScript for complex rule implementation and type safety
4. **AI/ML components**: Python for leveraging the rich ML ecosystem
5. **General services**: TypeScript for consistency with frontend and rich ecosystem

This multi-language approach allows us to optimize each component for its specific requirements while maintaining overall system cohesion through well-defined interfaces. 