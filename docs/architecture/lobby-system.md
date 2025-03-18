# Lobby System Architecture

## 1. Core Components

### 1.1 Lobby Service
```go
type LobbyService struct {
    db            *sql.DB
    redis         *redis.Client
    eventBus      *rabbitmq.Client
    playerService *PlayerService
    gameService   *GameService
}

type Lobby struct {
    ID          string    `json:"id"`
    Name        string    `json:"name"`
    Type        string    `json:"type"` // "CASH", "TOURNAMENT", "SNG"
    MinStake    float64   `json:"minStake"`
    MaxStake    float64   `json:"maxStake"`
    MaxPlayers  int       `json:"maxPlayers"`
    CurrentPlayers int    `json:"currentPlayers"`
    Status      string    `json:"status"` // "ACTIVE", "FILLING", "IN_PROGRESS", "COMPLETED"
    CreatedAt   time.Time `json:"createdAt"`
    UpdatedAt   time.Time `json:"updatedAt"`
    Settings    LobbySettings `json:"settings"`
}

type LobbySettings struct {
    TimeBank     int     `json:"timeBank"`
    ShotClock    int     `json:"shotClock"`
    RakePercent  float64 `json:"rakePercent"`
    MinBuyIn     float64 `json:"minBuyIn"`
    MaxBuyIn     float64 `json:"maxBuyIn"`
    AllowStraddle bool   `json:"allowStraddle"`
    AllowRunItTwice bool `json:"allowRunItTwice"`
    AllowTimeBank bool   `json:"allowTimeBank"`
}
```

### 1.2 Lobby Management
```go
type LobbyManager struct {
    lobbies    map[string]*Lobby
    mutex      sync.RWMutex
    service    *LobbyService
}

func (lm *LobbyManager) CreateLobby(ctx context.Context, settings *LobbySettings) (*Lobby, error) {
    lobby := &Lobby{
        ID: uuid.New().String(),
        Name: fmt.Sprintf("Lobby-%s", uuid.New().String()[:8]),
        Status: "ACTIVE",
        CreatedAt: time.Now(),
        UpdatedAt: time.Now(),
        Settings: *settings,
    }

    // Validate settings
    if err := lm.validateSettings(settings); err != nil {
        return nil, fmt.Errorf("invalid lobby settings: %w", err)
    }

    // Store in database
    if err := lm.service.db.CreateLobby(ctx, lobby); err != nil {
        return nil, fmt.Errorf("failed to create lobby: %w", err)
    }

    // Add to memory
    lm.mutex.Lock()
    lm.lobbies[lobby.ID] = lobby
    lm.mutex.Unlock()

    // Publish event
    if err := lm.service.eventBus.Publish("lobby.created", lobby); err != nil {
        log.Printf("Failed to publish lobby created event: %v", err)
    }

    return lobby, nil
}

func (lm *LobbyManager) JoinLobby(ctx context.Context, lobbyID string, playerID string) error {
    lm.mutex.Lock()
    lobby, exists := lm.lobbies[lobbyID]
    lm.mutex.Unlock()

    if !exists {
        return fmt.Errorf("lobby not found")
    }

    // Check player eligibility
    if err := lm.checkPlayerEligibility(ctx, playerID, lobby); err != nil {
        return err
    }

    // Update lobby state
    lobby.CurrentPlayers++
    lobby.UpdatedAt = time.Now()

    // Store in database
    if err := lm.service.db.UpdateLobby(ctx, lobby); err != nil {
        return fmt.Errorf("failed to update lobby: %w", err)
    }

    // Publish event
    if err := lm.service.eventBus.Publish("lobby.player_joined", map[string]interface{}{
        "lobby_id": lobbyID,
        "player_id": playerID,
    }); err != nil {
        log.Printf("Failed to publish player joined event: %v", err)
    }

    return nil
}
```

## 2. Lobby Types

### 2.1 Cash Game Lobby
```go
type CashGameLobby struct {
    Lobby
    MinBuyIn     float64 `json:"minBuyIn"`
    MaxBuyIn     float64 `json:"maxBuyIn"`
    StraddleAllowed bool `json:"straddleAllowed"`
    RunItTwiceAllowed bool `json:"runItTwiceAllowed"`
}

func (l *CashGameLobby) ValidateBuyIn(amount float64) error {
    if amount < l.MinBuyIn {
        return fmt.Errorf("buy-in amount below minimum")
    }
    if amount > l.MaxBuyIn {
        return fmt.Errorf("buy-in amount above maximum")
    }
    return nil
}
```

### 2.2 Tournament Lobby
```go
type TournamentLobby struct {
    Lobby
    StartTime    time.Time `json:"startTime"`
    BuyIn        float64   `json:"buyIn"`
    PrizePool    float64   `json:"prizePool"`
    PayoutStructure []float64 `json:"payoutStructure"`
}

func (l *TournamentLobby) ValidateRegistration(player *Player) error {
    if l.CurrentPlayers >= l.MaxPlayers {
        return fmt.Errorf("tournament is full")
    }
    if time.Now().After(l.StartTime) {
        return fmt.Errorf("tournament registration closed")
    }
    return nil
}
```

### 2.3 Sit & Go Lobby
```go
type SNG Lobby struct {
    Lobby
    BuyIn        float64   `json:"buyIn"`
    PrizePool    float64   `json:"prizePool"`
    StartWhenFull bool     `json:"startWhenFull"`
    PayoutStructure []float64 `json:"payoutStructure"`
}

func (l *SNG Lobby) CheckStartCondition() bool {
    if l.StartWhenFull {
        return l.CurrentPlayers == l.MaxPlayers
    }
    return false
}
```

## 3. Lobby Features

### 3.1 Player Matching
```go
type PlayerMatcher struct {
    service *LobbyService
}

func (pm *PlayerMatcher) FindSuitableLobby(ctx context.Context, player *Player) (*Lobby, error) {
    // Get player preferences
    preferences, err := pm.service.playerService.GetPlayerPreferences(ctx, player.ID)
    if err != nil {
        return nil, fmt.Errorf("failed to get player preferences: %w", err)
    }

    // Find matching lobbies
    lobbies, err := pm.service.db.GetActiveLobbies(ctx)
    if err != nil {
        return nil, fmt.Errorf("failed to get active lobbies: %w", err)
    }

    // Filter and sort lobbies based on preferences
    suitableLobbies := pm.filterLobbies(lobbies, preferences)
    if len(suitableLobbies) == 0 {
        return nil, fmt.Errorf("no suitable lobbies found")
    }

    // Return best match
    return pm.selectBestMatch(suitableLobbies, preferences), nil
}
```

### 3.2 Lobby State Management
```go
type LobbyStateManager struct {
    service *LobbyService
    states  map[string]*LobbyState
    mutex   sync.RWMutex
}

type LobbyState struct {
    LobbyID      string
    Status       string
    Players      map[string]*PlayerState
    GameState    *GameState
    LastUpdate   time.Time
}

func (lsm *LobbyStateManager) UpdateState(ctx context.Context, lobbyID string, update *StateUpdate) error {
    lsm.mutex.Lock()
    state, exists := lsm.states[lobbyID]
    lsm.mutex.Unlock()

    if !exists {
        return fmt.Errorf("lobby state not found")
    }

    // Apply update
    if err := lsm.applyUpdate(state, update); err != nil {
        return fmt.Errorf("failed to apply update: %w", err)
    }

    // Persist state
    if err := lsm.persistState(ctx, state); err != nil {
        return fmt.Errorf("failed to persist state: %w", err)
    }

    // Notify players
    if err := lsm.notifyPlayers(ctx, state); err != nil {
        log.Printf("Failed to notify players: %v", err)
    }

    return nil
}
```

## 4. API Endpoints

### 4.1 Lobby Management
```go
func (s *Server) setupLobbyRoutes() {
    // Create lobby
    s.router.POST("/api/v1/lobbies", s.handleCreateLobby)
    
    // Get lobby details
    s.router.GET("/api/v1/lobbies/:id", s.handleGetLobby)
    
    // Join lobby
    s.router.POST("/api/v1/lobbies/:id/join", s.handleJoinLobby)
    
    // Leave lobby
    s.router.POST("/api/v1/lobbies/:id/leave", s.handleLeaveLobby)
    
    // List available lobbies
    s.router.GET("/api/v1/lobbies", s.handleListLobbies)
    
    // Update lobby settings
    s.router.PATCH("/api/v1/lobbies/:id/settings", s.handleUpdateLobbySettings)
}
```

### 4.2 WebSocket Events
```go
type LobbyEvents struct {
    // Lobby state changes
    LobbyCreated     string = "lobby.created"
    LobbyUpdated     string = "lobby.updated"
    LobbyDeleted     string = "lobby.deleted"
    
    // Player events
    PlayerJoined     string = "lobby.player_joined"
    PlayerLeft       string = "lobby.player_left"
    PlayerReady      string = "lobby.player_ready"
    PlayerUnready    string = "lobby.player_unready"
    
    // Game events
    GameStarting     string = "lobby.game_starting"
    GameStarted      string = "lobby.game_started"
    GameEnded        string = "lobby.game_ended"
}

func (s *Server) handleLobbyWebSocket(conn *websocket.Conn, lobbyID string) {
    // Subscribe to lobby events
    events := s.lobbyService.SubscribeToLobby(lobbyID)
    defer s.lobbyService.UnsubscribeFromLobby(lobbyID)

    // Handle incoming messages
    go func() {
        for {
            var msg Message
            if err := conn.ReadJSON(&msg); err != nil {
                log.Printf("Failed to read message: %v", err)
                break
            }

            if err := s.handleLobbyMessage(lobbyID, msg); err != nil {
                log.Printf("Failed to handle message: %v", err)
            }
        }
    }()

    // Send events to client
    for event := range events {
        if err := conn.WriteJSON(event); err != nil {
            log.Printf("Failed to write message: %v", err)
            break
        }
    }
}
```

## 5. Database Schema

### 5.1 Lobby Tables
```sql
CREATE TABLE lobbies (
    id VARCHAR(36) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    type VARCHAR(50) NOT NULL,
    min_stake DECIMAL(10,2) NOT NULL,
    max_stake DECIMAL(10,2) NOT NULL,
    max_players INTEGER NOT NULL,
    current_players INTEGER NOT NULL DEFAULT 0,
    status VARCHAR(50) NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    settings JSONB NOT NULL
);

CREATE TABLE lobby_players (
    lobby_id VARCHAR(36) REFERENCES lobbies(id),
    player_id VARCHAR(36) REFERENCES players(id),
    joined_at TIMESTAMP NOT NULL,
    left_at TIMESTAMP,
    PRIMARY KEY (lobby_id, player_id)
);

CREATE TABLE lobby_history (
    id VARCHAR(36) PRIMARY KEY,
    lobby_id VARCHAR(36) REFERENCES lobbies(id),
    event_type VARCHAR(50) NOT NULL,
    event_data JSONB NOT NULL,
    created_at TIMESTAMP NOT NULL
);
```

## 6. Monitoring and Analytics

### 6.1 Metrics
```go
type LobbyMetrics struct {
    TotalLobbies        int64
    ActiveLobbies       int64
    TotalPlayers        int64
    AverageWaitTime     time.Duration
    LobbyCreationRate   float64
    PlayerJoinRate      float64
    PlayerLeaveRate     float64
    GameStartRate       float64
}

func (s *LobbyService) CollectMetrics() *LobbyMetrics {
    return &LobbyMetrics{
        TotalLobbies:      s.getTotalLobbies(),
        ActiveLobbies:     s.getActiveLobbies(),
        TotalPlayers:      s.getTotalPlayers(),
        AverageWaitTime:   s.calculateAverageWaitTime(),
        LobbyCreationRate: s.calculateLobbyCreationRate(),
        PlayerJoinRate:    s.calculatePlayerJoinRate(),
        PlayerLeaveRate:   s.calculatePlayerLeaveRate(),
        GameStartRate:     s.calculateGameStartRate(),
    }
}
```

### 6.2 Analytics
```go
type LobbyAnalytics struct {
    PeakHours        map[int]int
    PopularStakes    map[float64]int
    PlayerRetention  map[string]float64
    LobbyUtilization map[string]float64
}

func (s *LobbyService) GenerateAnalytics(ctx context.Context, period time.Duration) (*LobbyAnalytics, error) {
    analytics := &LobbyAnalytics{
        PeakHours:        make(map[int]int),
        PopularStakes:    make(map[float64]int),
        PlayerRetention:  make(map[string]float64),
        LobbyUtilization: make(map[string]float64),
    }

    // Collect data
    if err := s.collectAnalyticsData(ctx, period, analytics); err != nil {
        return nil, fmt.Errorf("failed to collect analytics data: %w", err)
    }

    // Process data
    if err := s.processAnalyticsData(analytics); err != nil {
        return nil, fmt.Errorf("failed to process analytics data: %w", err)
    }

    return analytics, nil
}
```

## 7. Testing Strategy

### 7.1 Unit Tests
- Lobby creation and management
- Player joining and leaving
- State management
- Event handling
- Settings validation

### 7.2 Integration Tests
- Lobby-player interaction
- Game start conditions
- State persistence
- Event propagation
- WebSocket communication

### 7.3 Performance Tests
- Concurrent player connections
- State update performance
- Event handling capacity
- Database operations
- Memory usage 