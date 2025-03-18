# Service Communication Patterns

This document outlines the service communication patterns used within the Tablium platform.

## Overview

Tablium uses multiple communication patterns to enable efficient service-to-service interactions:

1. **Synchronous Communication**: REST APIs for direct request-response patterns
2. **Asynchronous Communication**: Event-driven architecture for decoupled operations
3. **Streaming Communication**: Real-time data flows for game state updates

## Communication Principles

- **Decoupling**: Services should be loosely coupled and independently deployable
- **Resilience**: Communication should be resilient to failures
- **Observability**: All communication should be traceable and monitored
- **Security**: All inter-service communication must be authenticated and authorized
- **Versioning**: API contracts must be versioned and backward compatible when possible

## Synchronous Communication (REST APIs)

### When to Use
- Direct request-response workflows
- CRUD operations
- Query operations
- Simple service-to-service interactions

### Implementation

All REST communication follows these standards:

1. **OpenAPI 3.0 Specification**: All REST APIs must have OpenAPI specs
2. **JWT Authentication**: Service-to-service API calls must include valid JWT tokens
3. **Standard Response Format**: All responses follow the format defined in API contracts
4. **Circuit Breaking**: APIs implement circuit breaking for fault tolerance
5. **Rate Limiting**: APIs implement rate limiting to prevent abuse
6. **Retries**: Clients implement exponential backoff retry logic

### Example

User Service accessing Wallet Service:

```typescript
// User Service Code (TypeScript)
import axios from 'axios';

class WalletServiceClient {
  private baseUrl: string;
  private authToken: string;
  
  constructor() {
    this.baseUrl = process.env.WALLET_SERVICE_URL;
    // Service-to-service token
    this.authToken = process.env.SERVICE_AUTH_TOKEN;
  }
  
  async getUserWallets(userId: string): Promise<Wallet[]> {
    try {
      const response = await axios.get(`${this.baseUrl}/users/${userId}/wallets`, {
        headers: {
          'Authorization': `Bearer ${this.authToken}`,
          'X-Request-ID': generateRequestId()
        },
        timeout: 5000 // 5 second timeout
      });
      
      return response.data.data;
    } catch (error) {
      // Handle errors with circuit breaking logic
      if (isServiceUnavailable(error)) {
        circuitBreaker.recordFailure();
      }
      throw error;
    }
  }
}
```

## Asynchronous Communication (Events)

### When to Use
- Decoupled operations that don't require immediate response
- Cross-service business processes
- Eventual consistency requirements
- Notifications and triggers

### Implementation

Asynchronous communication uses the following technologies:

1. **Event Bus**: Redis Pub/Sub for lightweight events
2. **Message Queue**: RabbitMQ for durable message delivery
3. **Event Schema**: All events follow JSON schema definitions
4. **Dead Letter Queue**: Failed messages are moved to DLQ for retry/inspection
5. **Event Sourcing**: Critical state changes are recorded as event streams

### Event Types

- **Domain Events**: Represent business events (UserRegistered, GameCompleted)
- **Integration Events**: Events that trigger cross-service workflows
- **Command Events**: Events that request an action to be performed

### Event Structure

```json
{
  "id": "evt-123456",
  "type": "user.registered",
  "version": "1.0",
  "timestamp": "2023-03-18T12:34:56.789Z",
  "producer": "auth-service",
  "data": {
    "userId": "usr-123456",
    "email": "user@example.com"
  },
  "metadata": {
    "correlationId": "corr-123456",
    "traceId": "trace-123456"
  }
}
```

### Example Producer

```typescript
// Auth Service Code (TypeScript)
import { EventBus } from '@tablium/event-bus';

class UserRegistrationService {
  private eventBus: EventBus;
  
  constructor() {
    this.eventBus = new EventBus();
  }
  
  async registerUser(userData: UserRegistrationData): Promise<User> {
    // Create user in database
    const user = await this.userRepository.create(userData);
    
    // Publish event
    await this.eventBus.publish({
      type: 'user.registered',
      version: '1.0',
      producer: 'auth-service',
      data: {
        userId: user.id,
        email: user.email
      },
      metadata: {
        correlationId: getCorrelationId(),
        traceId: getTraceId()
      }
    });
    
    return user;
  }
}
```

### Example Consumer

```typescript
// User Service Code (TypeScript)
import { EventConsumer } from '@tablium/event-bus';

class UserProfileEventHandler {
  private eventConsumer: EventConsumer;
  
  constructor() {
    this.eventConsumer = new EventConsumer();
    
    // Subscribe to events
    this.eventConsumer.subscribe('user.registered', this.handleUserRegistered.bind(this));
  }
  
  async handleUserRegistered(event: Event): Promise<void> {
    try {
      // Create user profile
      await this.userProfileRepository.create({
        userId: event.data.userId,
        email: event.data.email,
        username: generateUsername(event.data.email)
      });
      
      // Acknowledge successful processing
      await this.eventConsumer.acknowledge(event);
    } catch (error) {
      // Move to dead letter queue if processing fails
      await this.eventConsumer.deadLetter(event, error);
    }
  }
}
```

## Real-time Communication (WebSockets)

### When to Use
- Game state updates
- Chat messages
- Notifications
- Collaborative features

### Implementation

Real-time communication uses the following technologies:

1. **WebSockets**: For bidirectional communication
2. **Socket.IO**: For fallback support and room management
3. **Redis Adapter**: For scaling WebSocket connections across nodes
4. **JWT Authentication**: For authenticating WebSocket connections
5. **Message Schema**: All messages follow defined schemas

### Message Structure

```json
{
  "type": "game.move",
  "gameId": "game-123456",
  "data": {
    "playerId": "usr-123456",
    "moveData": { /* Game-specific move data */ }
  },
  "timestamp": "2023-03-18T12:34:56.789Z"
}
```

### Example Server (Realtime Service)

```typescript
// Realtime Service Code (TypeScript)
import { Server } from 'socket.io';
import { createAdapter } from '@socket.io/redis-adapter';
import { verifyToken } from './auth';

const io = new Server({
  cors: {
    origin: process.env.FRONTEND_URL,
    methods: ["GET", "POST"]
  }
});

// Redis adapter for scaling
const pubClient = createRedisClient();
const subClient = pubClient.duplicate();
io.adapter(createAdapter(pubClient, subClient));

// Authentication middleware
io.use(async (socket, next) => {
  try {
    const token = socket.handshake.auth.token;
    if (!token) {
      return next(new Error('Authentication error'));
    }
    
    const user = await verifyToken(token);
    socket.data.user = user;
    next();
  } catch (error) {
    next(new Error('Authentication error'));
  }
});

// Game namespace
const gameIo = io.of('/games');

gameIo.on('connection', (socket) => {
  const userId = socket.data.user.id;
  
  // Join game room
  socket.on('join-game', (gameId) => {
    socket.join(`game:${gameId}`);
    gameIo.to(`game:${gameId}`).emit('user-joined', {
      userId,
      timestamp: new Date().toISOString()
    });
  });
  
  // Handle game move
  socket.on('game-move', async (data) => {
    try {
      // Validate and process game move
      const result = await gameStateService.processMove(data.gameId, userId, data.move);
      
      // Broadcast updated game state
      gameIo.to(`game:${data.gameId}`).emit('game-updated', {
        gameId: data.gameId,
        state: result.state,
        lastMove: {
          playerId: userId,
          moveData: data.move
        },
        timestamp: new Date().toISOString()
      });
    } catch (error) {
      // Send error only to the sender
      socket.emit('error', {
        code: error.code || 'GAME_MOVE_ERROR',
        message: error.message
      });
    }
  });
});
```

### Example Client (Frontend)

```typescript
// Game UI Code (TypeScript)
import { io } from 'socket.io-client';

class GameSocketClient {
  private socket: any;
  
  constructor(gameId: string, authToken: string) {
    this.socket = io(`${API_BASE_URL}/games`, {
      auth: {
        token: authToken
      },
      reconnection: true,
      reconnectionAttempts: 5,
      reconnectionDelay: 1000
    });
    
    this.socket.on('connect', () => {
      console.log('Connected to game server');
      this.socket.emit('join-game', gameId);
    });
    
    this.socket.on('user-joined', (data) => {
      console.log(`User ${data.userId} joined the game`);
    });
    
    this.socket.on('game-updated', (data) => {
      // Update game state in UI
      gameStore.updateGameState(data.gameId, data.state);
    });
    
    this.socket.on('error', (error) => {
      // Handle error in UI
      notificationService.showError(error.message);
    });
  }
  
  makeMove(moveData: any): void {
    this.socket.emit('game-move', {
      gameId: this.gameId,
      move: moveData
    });
  }
  
  disconnect(): void {
    this.socket.disconnect();
  }
}
```

## Service Discovery

Tablium implements service discovery to enable dynamic service location:

1. **DNS-based discovery**: In Kubernetes using service names
2. **Configuration-based discovery**: Using environment variables for local development
3. **Health checks**: For load balancers to detect service availability

## Communication Security

All service-to-service communication implements the following security measures:

1. **TLS encryption**: For all network traffic
2. **JWT Authentication**: For service identity verification
3. **Rate limiting**: To prevent abuse of services
4. **IP allowlisting**: For production environments
5. **Payload validation**: To prevent malicious data

## Monitoring and Tracing

All service communication is monitored using:

1. **Distributed tracing**: Using OpenTelemetry for end-to-end request tracing
2. **Correlation IDs**: To track requests across service boundaries
3. **Metrics collection**: For latency, error rate, and throughput
4. **Log aggregation**: For centralized logging
5. **Alerting**: For abnormal communication patterns

## Event Schemas

Standard event schemas are maintained in a central schema registry. Example events:

### User Domain Events
- `user.registered`
- `user.profile.updated`
- `user.achievements.earned`

### Game Domain Events
- `game.created`
- `game.started`
- `game.move.made`
- `game.completed`

### Wallet Domain Events
- `wallet.created`
- `wallet.transaction.created`
- `wallet.balance.updated`

## Service Dependencies

| Service | Depends On | Communication Pattern |
|---------|------------|------------------------|
| API Gateway | Auth Service | REST |
| Auth Service | User Service | REST, Events |
| User Service | Wallet Service | REST |
| Game Engine | Game State Service | REST |
| Game State Service | User Service | REST |
| Realtime Service | Game State Service | REST, Events |
| Wallet Service | - | - |

## Communication Anti-patterns to Avoid

1. **Chatty communications**: Prefer batch operations over multiple small calls
2. **Synchronous chains**: Avoid long chains of synchronous service calls
3. **Point-to-point coupling**: Use events for loose coupling when possible
4. **Shared databases**: Services should not share databases directly
5. **Lack of versioning**: Always version your APIs
6. **No fallback strategy**: Always implement fallbacks for critical paths

## Implementation Checklist

When implementing new service communication:

1. Define the API contract or event schema first
2. Implement client and server components
3. Add authentication and authorization
4. Implement error handling and retries
5. Set up monitoring and metrics
6. Test under various failure conditions
7. Document the integration points 