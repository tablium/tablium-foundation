# Technical Architecture

## System Overview

The Tablium API is built using a microservices architecture with the following key components:

1. API Gateway
2. Service Layer
   - Player Service
   - Club Service
   - Rakeback Service
   - Event Service
   - Lobby Service
   - Wallet Service
   - Blockchain Service
3. Data Layer
4. Message Queue
5. Cache Layer
6. Monitoring & Logging

## Component Details

### 1. API Gateway

#### Purpose
- Request routing and load balancing
- Authentication and authorization
- Rate limiting
- Request/response transformation
- API documentation

#### Implementation
- Kong Gateway
- JWT authentication
- Rate limiting middleware
- Request validation
- Response caching

### 2. Service Layer

#### Player Service
- Player profile management
- Experience and level system
- Player statistics
- Player preferences

#### Club Service
- Club management
- Member management
- Club benefits
- Club tournaments

#### Rakeback Service
- Rakeback calculations
- Distribution management
- Player tier management
- Transaction tracking

#### Event Service
- Tournament management
- Registration handling
- Prize pool management
- Winner tracking

#### Lobby Service
- Lobby management
- Player matching
- Real-time state management
- Game type support
- Lobby analytics

#### Wallet Service
- Wallet management
- Transfer processing
- Balance tracking
- Limit management

#### Blockchain Service
- Smart contract interactions
- Transaction processing
- Gas optimization
- Network monitoring

### 3. Data Layer

#### Primary Database
- PostgreSQL
- Data persistence
- Transaction management
- Data relationships

#### Cache Layer
- Redis
- Session management
- Real-time state
- Performance optimization

### 4. Message Queue

#### Implementation
- RabbitMQ
- Event publishing
- Service communication
- Async processing

#### Event Types
- Player events
- Club events
- Tournament events
- Lobby events
- Wallet events
- Blockchain events

### 5. Real-time Communication

#### WebSocket Server
- Real-time updates
- Lobby state management
- Player interactions
- Game state updates

#### Implementation
- Gorilla WebSocket
- Connection management
- Event broadcasting
- State synchronization

### 6. Monitoring & Logging

#### Metrics Collection
- Prometheus
- Service metrics
- Performance metrics
- Business metrics

#### Logging
- ELK Stack
- Structured logging
- Log aggregation
- Log analysis

#### Alerting
- AlertManager
- Error alerts
- Performance alerts
- Business alerts

## Data Flow

### 1. Player Flow
```
Client -> API Gateway -> Player Service -> Database
                     -> Cache Layer
                     -> Message Queue
```

### 2. Club Flow
```
Client -> API Gateway -> Club Service -> Database
                     -> Cache Layer
                     -> Message Queue
```

### 3. Tournament Flow
```
Client -> API Gateway -> Event Service -> Database
                     -> Cache Layer
                     -> Message Queue
                     -> WebSocket (Real-time updates)

# Multi-table specific flow
Event Service -> Table Manager -> Table Service
             -> Player Manager -> Player Service
             -> Hand Manager -> Hand Service
             -> Break Manager -> Break Service
             -> Prize Pool Manager -> Prize Service
```

### Tournament Components

#### Table Manager
- Table creation and management
- Player seating
- Table balancing
- Table merging
- Break coordination

#### Player Manager
- Player registration
- Player transfers between tables
- Player elimination
- Player statistics
- Player actions

#### Hand Manager
- Hand dealing
- Action processing
- Pot management
- Winner determination
- Hand history

#### Break Manager
- Break scheduling
- Break coordination across tables
- Level progression
- Blind level management

#### Prize Pool Manager
- Prize pool calculation
- Payout structure management
- Winner determination
- Prize distribution

### 4. Lobby Flow
```
Client -> WebSocket -> Lobby Service -> Redis
                   -> Database
                   -> Message Queue
```

### 5. Wallet Flow
```
Client -> API Gateway -> Wallet Service -> Database
                     -> Blockchain Service
                     -> Message Queue
```

## Deployment Architecture

### 1. Infrastructure
- Kubernetes cluster
- Container orchestration
- Service mesh
- Load balancing

### 2. Database
- Primary/Replica setup
- Connection pooling
- Backup strategy
- Failover handling

### 3. Cache
- Redis cluster
- Cache invalidation
- Data persistence
- High availability

### 4. Message Queue
- RabbitMQ cluster
- Queue management
- Message persistence
- Load balancing

### 5. Monitoring
- Prometheus cluster
- Grafana dashboards
- Alert management
- Log aggregation

## Scaling Strategy

### 1. Horizontal Scaling
- Service replication
- Load distribution
- State management
- Cache synchronization

### 2. Vertical Scaling
- Resource allocation
- Performance optimization
- Database tuning
- Cache optimization

### 3. Database Scaling
- Read replicas
- Connection pooling
- Query optimization
- Index management

## Security Measures

### 1. Authentication
- JWT tokens
- Session management
- Rate limiting
- IP whitelisting

### 2. Authorization
- Role-based access
- Resource permissions
- API key management
- Service authentication

### 3. Data Protection
- Encryption at rest
- Encryption in transit
- Data masking
- Audit logging

## Disaster Recovery

### 1. Backup Strategy
- Database backups
- Configuration backups
- State backups
- Recovery testing

### 2. Failover
- Service failover
- Database failover
- Cache failover
- Queue failover

### 3. Recovery
- Data recovery
- Service recovery
- State recovery
- Validation

## Performance Optimization

### 1. Caching
- Response caching
- Data caching
- Session caching
- State caching

### 2. Database
- Query optimization
- Index management
- Connection pooling
- Query caching

### 3. Service
- Resource optimization
- Request batching
- Async processing
- Load balancing

## Development Workflow

### 1. Version Control
- Git workflow
- Branch management
- Code review
- CI/CD pipeline

### 2. Testing
- Unit testing
- Integration testing
- Performance testing
- Security testing

### 3. Deployment
- Environment management
- Release management
- Rollback strategy
- Monitoring

## Maintenance

### 1. Monitoring
- Service health
- Performance metrics
- Error tracking
- Usage analytics

### 2. Updates
- Dependency updates
- Security patches
- Feature updates
- Configuration updates

### 3. Optimization
- Performance tuning
- Resource optimization
- Cost optimization
- Capacity planning 