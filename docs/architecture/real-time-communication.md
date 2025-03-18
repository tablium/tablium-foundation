# Real-time Communication

## Overview
This document details the real-time communication system, including WebSocket events, state synchronization, and event handling across the platform.

## WebSocket Events

### Event Types
```go
type WebSocketEvent struct {
    Type string
    Target string // "LOBBY", "TOURNAMENT", "TABLE", "PLAYER"
    ID string
    Data interface{}
    Timestamp time.Time
}

const (
    // Lobby Events
    EventTypeLobbyCreate = "LOBBY_CREATE"
    EventTypeLobbyUpdate = "LOBBY_UPDATE"
    EventTypeLobbyDelete = "LOBBY_DELETE"
    EventTypeLobbyJoin = "LOBBY_JOIN"
    EventTypeLobbyLeave = "LOBBY_LEAVE"
    
    // Tournament Events
    EventTypeTournamentCreate = "TOURNAMENT_CREATE"
    EventTypeTournamentUpdate = "TOURNAMENT_UPDATE"
    EventTypeTournamentStart = "TOURNAMENT_START"
    EventTypeTournamentEnd = "TOURNAMENT_END"
    EventTypeTournamentRegister = "TOURNAMENT_REGISTER"
    EventTypeTournamentUnregister = "TOURNAMENT_UNREGISTER"
    
    // Table Events
    EventTypeTableCreate = "TABLE_CREATE"
    EventTypeTableUpdate = "TABLE_UPDATE"
    EventTypeTableDelete = "TABLE_DELETE"
    EventTypeTableJoin = "TABLE_JOIN"
    EventTypeTableLeave = "TABLE_LEAVE"
    EventTypeTableMerge = "TABLE_MERGE"
    EventTypeTableBalance = "TABLE_BALANCE"
    
    // Player Events
    EventTypePlayerAction = "PLAYER_ACTION"
    EventTypePlayerElimination = "PLAYER_ELIMINATION"
    EventTypePlayerDisconnect = "PLAYER_DISCONNECT"
    EventTypePlayerReconnect = "PLAYER_RECONNECT"
    
    // Game Events
    EventTypeHandStart = "HAND_START"
    EventTypeHandEnd = "HAND_END"
    EventTypeDealCards = "DEAL_CARDS"
    EventTypeFlop = "FLOP"
    EventTypeTurn = "TURN"
    EventTypeRiver = "RIVER"
    EventTypeShowdown = "SHOWDOWN"
    
    // System Events
    EventTypeBreakStart = "BREAK_START"
    EventTypeBreakEnd = "BREAK_END"
    EventTypeLevelUp = "LEVEL_UP"
    EventTypeError = "ERROR"
)
```

### Event Processing
```go
type EventProcessor struct {
    Handlers map[string]EventHandler
    Validators map[string]EventValidator
}

func (ep *EventProcessor) ProcessEvent(event WebSocketEvent) {
    // 1. Validate event
    if !ep.validateEvent(event) {
        return
    }
    
    // 2. Get handler
    handler := ep.getHandler(event.Type)
    
    // 3. Process event
    handler.Handle(event)
    
    // 4. Update state
    ep.updateState(event)
    
    // 5. Broadcast if needed
    ep.broadcastEvent(event)
}
```

## State Synchronization

### State Manager
```go
type StateManager struct {
    States map[string]interface{}
    Subscribers map[string][]StateSubscriber
    SyncInterval time.Duration
}

func (sm *StateManager) Synchronize() {
    // 1. Collect current states
    states := sm.collectStates()
    
    // 2. Compare states
    differences := sm.compareStates(states)
    
    // 3. Resolve differences
    sm.resolveDifferences(differences)
    
    // 4. Update subscribers
    sm.updateSubscribers()
}

func (sm *StateManager) Subscribe(target string, subscriber StateSubscriber) {
    // 1. Validate subscription
    if !sm.validateSubscription(target, subscriber) {
        return
    }
    
    // 2. Add subscriber
    sm.addSubscriber(target, subscriber)
    
    // 3. Send initial state
    sm.sendInitialState(target, subscriber)
}
```

### State Validation
```go
type StateValidator struct {
    Rules map[string]ValidationRule
}

func (sv *StateValidator) ValidateState(state interface{}, target string) bool {
    // 1. Get validation rules
    rules := sv.getRules(target)
    
    // 2. Apply rules
    for _, rule := range rules {
        if !rule.Validate(state) {
            return false
        }
    }
    
    return true
}
```

## Connection Management

### Connection Handler
```go
type ConnectionHandler struct {
    Connections map[string]*Connection
    Timeout time.Duration
    MaxRetries int
}

func (ch *ConnectionHandler) HandleConnection(conn *Connection) {
    // 1. Validate connection
    if !ch.validateConnection(conn) {
        return
    }
    
    // 2. Register connection
    ch.registerConnection(conn)
    
    // 3. Start heartbeat
    ch.startHeartbeat(conn)
    
    // 4. Monitor connection
    ch.monitorConnection(conn)
}

func (ch *ConnectionHandler) HandleDisconnection(conn *Connection) {
    // 1. Clean up resources
    ch.cleanupResources(conn)
    
    // 2. Update state
    ch.updateState(conn)
    
    // 3. Notify relevant parties
    ch.notifyDisconnection(conn)
}
```

## Message Queue Integration

### Event Publisher
```go
type EventPublisher struct {
    Queue RabbitMQ
    RetryPolicy RetryPolicy
}

func (ep *EventPublisher) PublishEvent(event WebSocketEvent) {
    // 1. Prepare message
    message := ep.prepareMessage(event)
    
    // 2. Apply retry policy
    ep.applyRetryPolicy(message)
    
    // 3. Publish message
    ep.publishMessage(message)
    
    // 4. Handle acknowledgment
    ep.handleAcknowledgment(message)
}
```

### Event Subscriber
```go
type EventSubscriber struct {
    Queue RabbitMQ
    Handlers map[string]EventHandler
}

func (es *EventSubscriber) Subscribe() {
    // 1. Set up subscription
    es.setupSubscription()
    
    // 2. Start consuming
    es.startConsuming()
    
    // 3. Handle messages
    es.handleMessages()
}
```

## Error Handling

### Error Manager
```go
type ErrorManager struct {
    Handlers map[string]ErrorHandler
    RetryPolicy RetryPolicy
}

func (em *ErrorManager) HandleError(error Error) {
    // 1. Log error
    em.logError(error)
    
    // 2. Get handler
    handler := em.getHandler(error.Type)
    
    // 3. Apply retry policy
    if em.shouldRetry(error) {
        em.retry(error)
        return
    }
    
    // 4. Handle error
    handler.Handle(error)
    
    // 5. Notify relevant parties
    em.notifyError(error)
}
```

## Monitoring

### Communication Metrics
```go
type CommunicationMetrics struct {
    ConnectionCount int
    EventCount int
    ErrorCount int
    Latency time.Duration
    MessageSize int
    Bandwidth float64
}

func (cm *CommunicationMetrics) Collect() {
    // 1. Collect metrics
    cm.collectMetrics()
    
    // 2. Calculate statistics
    cm.calculateStatistics()
    
    // 3. Update monitoring
    cm.updateMonitoring()
    
    // 4. Check alerts
    cm.checkAlerts()
}
``` 