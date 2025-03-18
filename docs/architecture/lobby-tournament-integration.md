# Lobby-Tournament Integration

## Overview
This document details the integration between the lobby system and tournament system, including transitions, state management, and real-time updates.

## Lobby to Tournament Transition

### Registration Flow
```go
type LobbyTournamentTransition struct {
    LobbyID string
    TournamentID string
    PlayerID string
    BuyIn float64
    StackSize float64
}

func (lt *LobbyTournamentTransition) HandleTransition() {
    // 1. Validate player eligibility
    if !lt.validateEligibility() {
        return
    }
    
    // 2. Process buy-in
    if !lt.processBuyIn() {
        return
    }
    
    // 3. Create tournament entry
    entry := lt.createTournamentEntry()
    
    // 4. Update lobby state
    lt.updateLobbyState()
    
    // 5. Notify relevant parties
    lt.notifyTransition()
}
```

### State Management
```go
type LobbyTournamentState struct {
    LobbyState string
    TournamentState string
    PlayerState string
    TransitionState string
}

func (lts *LobbyTournamentState) UpdateState() {
    // 1. Validate state transition
    if !lts.validateStateTransition() {
        return
    }
    
    // 2. Update state
    lts.updateState()
    
    // 3. Persist state
    lts.persistState()
    
    // 4. Notify state change
    lts.notifyStateChange()
}
```

## Real-time Communication

### WebSocket Events
```go
type LobbyTournamentEvent struct {
    Type string
    LobbyID string
    TournamentID string
    PlayerID string
    Data interface{}
    Timestamp time.Time
}

const (
    EventTypeLobbyJoin = "LOBBY_JOIN"
    EventTypeLobbyLeave = "LOBBY_LEAVE"
    EventTypeTournamentRegister = "TOURNAMENT_REGISTER"
    EventTypeTournamentUnregister = "TOURNAMENT_UNREGISTER"
    EventTypeTournamentStart = "TOURNAMENT_START"
    EventTypeTournamentEnd = "TOURNAMENT_END"
    EventTypeTableAssignment = "TABLE_ASSIGNMENT"
    EventTypePlayerElimination = "PLAYER_ELIMINATION"
)

func (lte *LobbyTournamentEvent) Process() {
    switch lte.Type {
    case EventTypeLobbyJoin:
        lte.processLobbyJoin()
    case EventTypeTournamentRegister:
        lte.processTournamentRegister()
    case EventTypeTableAssignment:
        lte.processTableAssignment()
    case EventTypePlayerElimination:
        lte.processPlayerElimination()
    }
}
```

### State Synchronization
```go
type LobbyTournamentSync struct {
    SyncInterval time.Duration
    ValidationEnabled bool
}

func (lts *LobbyTournamentSync) Synchronize() {
    // 1. Collect current states
    states := lts.collectStates()
    
    // 2. Validate states
    if lts.ValidationEnabled {
        lts.validateStates(states)
    }
    
    // 3. Resolve discrepancies
    lts.resolveDiscrepancies(states)
    
    // 4. Update systems
    lts.updateSystems(states)
}
```

## Tournament Features in Lobby

### Tournament Information
```go
type LobbyTournamentInfo struct {
    TournamentID string
    Name string
    BuyIn float64
    PrizePool float64
    StartTime time.Time
    RegisteredPlayers int
    MaxPlayers int
    Status string
    BlindLevels []BlindLevel
    PayoutStructure []PayoutTier
}

func (lti *LobbyTournamentInfo) Update() {
    // 1. Fetch tournament data
    lti.fetchTournamentData()
    
    // 2. Update lobby display
    lti.updateLobbyDisplay()
    
    // 3. Notify players
    lti.notifyPlayers()
}
```

### Player Statistics
```go
type LobbyPlayerStats struct {
    PlayerID string
    TournamentCount int
    TotalBuyIn float64
    TotalWinnings float64
    BestFinish int
    AverageFinish float64
    ROI float64
}

func (lps *LobbyPlayerStats) Update() {
    // 1. Calculate statistics
    lps.calculateStats()
    
    // 2. Update display
    lps.updateDisplay()
    
    // 3. Notify player
    lps.notifyPlayer()
}
```

## Error Handling

### Transition Errors
```go
type LobbyTournamentError struct {
    ErrorType string
    LobbyID string
    TournamentID string
    PlayerID string
    ErrorMessage string
    Timestamp time.Time
}

func (lte *LobbyTournamentError) Handle() {
    // 1. Log error
    lte.logError()
    
    // 2. Determine recovery action
    action := lte.determineRecoveryAction()
    
    // 3. Execute recovery
    lte.executeRecovery(action)
    
    // 4. Notify relevant parties
    lte.notifyError()
}
```

## Monitoring

### Integration Metrics
```go
type LobbyTournamentMetrics struct {
    TransitionSuccessRate float64
    AverageTransitionTime time.Duration
    ErrorRate float64
    PlayerRetentionRate float64
    TournamentFillRate float64
    StateSyncLatency time.Duration
}

func (ltm *LobbyTournamentMetrics) Collect() {
    // 1. Collect metrics
    ltm.collectMetrics()
    
    // 2. Calculate statistics
    ltm.calculateStatistics()
    
    // 3. Update monitoring
    ltm.updateMonitoring()
    
    // 4. Check alerts
    ltm.checkAlerts()
} 