# Backend Architecture

## Overview
The Tablium API backend is a distributed system with a microservices architecture focused on player experience, club management, tournament operations, and lobby management. The system is designed to be scalable, reliable, and maintainable.

## Core Services

### 1. Player Service
Purpose: Manages player profiles, experience, and level progression
Key Features:
- Player registration and authentication
- Experience point tracking
- Level progression system
- Player statistics and achievements
- Player preferences and settings

Dependencies:
- PostgreSQL (player data)
- Redis (caching)
- RabbitMQ (events)

### 2. Club Service
Purpose: Handles club creation and management for Pro players
Key Features:
- Club creation and management
- Member management
- Club benefits and perks
- Club tournament management
- Club statistics and analytics

Dependencies:
- PostgreSQL (club data)
- Redis (caching)
- RabbitMQ (events)

### 3. Rakeback Service
Purpose: Manages rakeback calculations and distributions
Key Features:
- Rakeback calculation
- Distribution scheduling
- Player tier management
- Transaction history
- Compliance reporting

Dependencies:
- PostgreSQL (transaction data)
- Redis (caching)
- RabbitMQ (events)

### 4. Event Service
Purpose: Manages tournament events and operations
Key Features:
- Tournament creation and management
- Registration handling
- Prize pool management
- Winner tracking
- Event scheduling

Dependencies:
- PostgreSQL (event data)
- Redis (caching)
- RabbitMQ (events)

### 5. Lobby Service
Purpose: Manages game lobbies and player matching
Key Features:
- Lobby creation and management
- Player matching system
- Real-time state management
- Game type support (Cash, Tournament, SNG)
- Lobby analytics and monitoring

Dependencies:
- PostgreSQL (lobby data)
- Redis (real-time state)
- RabbitMQ (events)
- WebSocket (real-time updates)

### 6. Wallet Service
Purpose: Manages player wallets and blockchain interactions
Key Features:
- Hosted wallet management
- External wallet integration
- Transfer limits
- Transaction history
- Balance management

Dependencies:
- PostgreSQL (wallet data)
- Redis (caching)
- RabbitMQ (events)
- Ethereum node

### 7. Blockchain Service
Purpose: Handles blockchain interactions and smart contracts
Key Features:
- Smart contract management
- Transaction processing
- Gas optimization
- Network monitoring
- Security validations

Dependencies:
- Ethereum node
- Web3 client
- Smart contracts
- Transaction queue

## Data Models

### Player
```go
type Player struct {
    ID            string    `json:"id"`
    Username      string    `json:"username"`
    Email         string    `json:"email"`
    Level         int       `json:"level"`
    Experience    int64     `json:"experience"`
    CreatedAt     time.Time `json:"createdAt"`
    UpdatedAt     time.Time `json:"updatedAt"`
    Preferences   Preferences `json:"preferences"`
}
```

### PlayerLevel
```go
type PlayerLevel struct {
    Level         int       `json:"level"`
    RequiredXP    int64     `json:"requiredXP"`
    Benefits      []string  `json:"benefits"`
    RakebackRate  float64   `json:"rakebackRate"`
}
```

### Club
```go
type Club struct {
    ID            string    `json:"id"`
    Name          string    `json:"name"`
    OwnerID       string    `json:"ownerId"`
    CreatedAt     time.Time `json:"createdAt"`
    UpdatedAt     time.Time `json:"updatedAt"`
    Members       []Member  `json:"members"`
    Benefits      []string  `json:"benefits"`
}
```

### ClubTournament
```go
type ClubTournament struct {
    ID            string    `json:"id"`
    ClubID        string    `json:"clubId"`
    Name          string    `json:"name"`
    StartTime     time.Time `json:"startTime"`
    EndTime       time.Time `json:"endTime"`
    BuyIn         float64   `json:"buyIn"`
    PrizePool     float64   `json:"prizePool"`
    Status        string    `json:"status"`
    MaxTables     int       `json:"maxTables"`
    PlayersPerTable int     `json:"playersPerTable"`
    BlindLevels   []BlindLevel `json:"blindLevels"`
    PayoutStructure []PayoutTier `json:"payoutStructure"`
    CreatedAt     time.Time `json:"createdAt"`
    UpdatedAt     time.Time `json:"updatedAt"`
}

type BlindLevel struct {
    Level         int       `json:"level"`
    SmallBlind    float64   `json:"smallBlind"`
    BigBlind      float64   `json:"bigBlind"`
    Ante          float64   `json:"ante"`
    Duration      int       `json:"duration"` // in minutes
}

type PayoutTier struct {
    Position      int       `json:"position"`
    Percentage    float64   `json:"percentage"`
    Amount        float64   `json:"amount"`
}
```

### TournamentTable
```go
type TournamentTable struct {
    ID            string    `json:"id"`
    TournamentID  string    `json:"tournamentId"`
    TableNumber   int       `json:"tableNumber"`
    Status        string    `json:"status"` // "ACTIVE", "BREAK", "CLOSED"
    CurrentLevel  int       `json:"currentLevel"`
    CurrentHand   int       `json:"currentHand"`
    Players       []TablePlayer `json:"players"`
    CreatedAt     time.Time `json:"createdAt"`
    UpdatedAt     time.Time `json:"updatedAt"`
}

type TablePlayer struct {
    PlayerID      string    `json:"playerId"`
    SeatNumber    int       `json:"seatNumber"`
    Stack         float64   `json:"stack"`
    Status        string    `json:"status"` // "ACTIVE", "ALL_IN", "ELIMINATED"
    LastAction    string    `json:"lastAction"`
    Position      string    `json:"position"` // "BB", "SB", "UTG", etc.
}
```

### TournamentHand
```go
type TournamentHand struct {
    ID            string    `json:"id"`
    TableID       string    `json:"tableId"`
    HandNumber    int       `json:"handNumber"`
    Level         int       `json:"level"`
    Pot           float64   `json:"pot"`
    Board         []string  `json:"board"`
    Actions       []HandAction `json:"actions"`
    Winners       []Winner  `json:"winners"`
    CreatedAt     time.Time `json:"createdAt"`
    UpdatedAt     time.Time `json:"updatedAt"`
}

type HandAction struct {
    PlayerID      string    `json:"playerId"`
    Action        string    `json:"action"` // "FOLD", "CHECK", "CALL", "RAISE", "ALL_IN"
    Amount        float64   `json:"amount"`
    Timestamp     time.Time `json:"timestamp"`
}

type Winner struct {
    PlayerID      string    `json:"playerId"`
    Amount        float64   `json:"amount"`
    Hand          []string  `json:"hand"`
}
```

### Lobby
```go
type Lobby struct {
    ID            string    `json:"id"`
    Name          string    `json:"name"`
    Type          string    `json:"type"`
    MinStake      float64   `json:"minStake"`
    MaxStake      float64   `json:"maxStake"`
    MaxPlayers    int       `json:"maxPlayers"`
    CurrentPlayers int      `json:"currentPlayers"`
    Status        string    `json:"status"`
    CreatedAt     time.Time `json:"createdAt"`
    UpdatedAt     time.Time `json:"updatedAt"`
    Settings      LobbySettings `json:"settings"`
}
```

### Wallet
```go
type Wallet struct {
    ID            string    `json:"id"`
    PlayerID      string    `json:"playerId"`
    Balance       float64   `json:"balance"`
    DailyLimit    float64   `json:"dailyLimit"`
    MonthlyLimit  float64   `json:"monthlyLimit"`
    CreatedAt     time.Time `json:"createdAt"`
    UpdatedAt     time.Time `json:"updatedAt"`
}
```

## Database Schema

### Players Table
```sql
CREATE TABLE players (
    id VARCHAR(36) PRIMARY KEY,
    username VARCHAR(255) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    level INTEGER NOT NULL DEFAULT 1,
    experience BIGINT NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    preferences JSONB NOT NULL DEFAULT '{}'
);
```

### Clubs Table
```sql
CREATE TABLE clubs (
    id VARCHAR(36) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    owner_id VARCHAR(36) NOT NULL REFERENCES players(id),
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    benefits JSONB NOT NULL DEFAULT '[]'
);
```

### Club Tournaments Table
```sql
CREATE TABLE club_tournaments (
    id VARCHAR(36) PRIMARY KEY,
    club_id VARCHAR(36) NOT NULL REFERENCES clubs(id),
    name VARCHAR(255) NOT NULL,
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL,
    buy_in DECIMAL(10,2) NOT NULL,
    prize_pool DECIMAL(10,2) NOT NULL DEFAULT 0,
    status VARCHAR(50) NOT NULL,
    max_tables INTEGER NOT NULL DEFAULT 1,
    players_per_table INTEGER NOT NULL DEFAULT 9,
    blind_levels JSONB NOT NULL,
    payout_structure JSONB NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);
```

### Tournament Tables Table
```sql
CREATE TABLE tournament_tables (
    id VARCHAR(36) PRIMARY KEY,
    tournament_id VARCHAR(36) NOT NULL REFERENCES club_tournaments(id),
    table_number INTEGER NOT NULL,
    status VARCHAR(50) NOT NULL,
    current_level INTEGER NOT NULL DEFAULT 1,
    current_hand INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    UNIQUE(tournament_id, table_number)
);
```

### Table Players Table
```sql
CREATE TABLE table_players (
    id VARCHAR(36) PRIMARY KEY,
    table_id VARCHAR(36) NOT NULL REFERENCES tournament_tables(id),
    player_id VARCHAR(36) NOT NULL REFERENCES players(id),
    seat_number INTEGER NOT NULL,
    stack DECIMAL(10,2) NOT NULL,
    status VARCHAR(50) NOT NULL,
    last_action VARCHAR(50),
    position VARCHAR(10),
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    UNIQUE(table_id, seat_number)
);
```

### Tournament Hands Table
```sql
CREATE TABLE tournament_hands (
    id VARCHAR(36) PRIMARY KEY,
    table_id VARCHAR(36) NOT NULL REFERENCES tournament_tables(id),
    hand_number INTEGER NOT NULL,
    level INTEGER NOT NULL,
    pot DECIMAL(10,2) NOT NULL DEFAULT 0,
    board JSONB NOT NULL DEFAULT '[]',
    actions JSONB NOT NULL DEFAULT '[]',
    winners JSONB NOT NULL DEFAULT '[]',
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    UNIQUE(table_id, hand_number)
);
```

### Lobbies Table
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
```

### Wallets Table
```sql
CREATE TABLE wallets (
    id VARCHAR(36) PRIMARY KEY,
    player_id VARCHAR(36) NOT NULL REFERENCES players(id),
    balance DECIMAL(10,2) NOT NULL DEFAULT 0,
    daily_limit DECIMAL(10,2) NOT NULL,
    monthly_limit DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);
```

## API Endpoints

### Player Endpoints
```
POST   /api/v1/players/register
POST   /api/v1/players/login
GET    /api/v1/players/:id
PUT    /api/v1/players/:id
GET    /api/v1/players/:id/experience
GET    /api/v1/players/:id/level
```

### Club Endpoints
```
POST   /api/v1/clubs
GET    /api/v1/clubs/:id
PUT    /api/v1/clubs/:id
POST   /api/v1/clubs/:id/members
DELETE /api/v1/clubs/:id/members/:memberId
POST   /api/v1/clubs/:id/tournaments
GET    /api/v1/clubs/:id/tournaments
```

### Tournament Endpoints
```
POST   /api/v1/tournaments
GET    /api/v1/tournaments/:id
POST   /api/v1/tournaments/:id/register
GET    /api/v1/tournaments/:id/players
POST   /api/v1/tournaments/:id/complete

# New endpoints for multi-table support
GET    /api/v1/tournaments/:id/tables
GET    /api/v1/tournaments/:id/tables/:tableId
POST   /api/v1/tournaments/:id/tables/:tableId/start
POST   /api/v1/tournaments/:id/tables/:tableId/end
GET    /api/v1/tournaments/:id/tables/:tableId/hands
POST   /api/v1/tournaments/:id/tables/:tableId/players
DELETE /api/v1/tournaments/:id/tables/:tableId/players/:playerId
POST   /api/v1/tournaments/:id/tables/:tableId/actions
```

### Lobby Endpoints
```
POST   /api/v1/lobbies
GET    /api/v1/lobbies/:id
POST   /api/v1/lobbies/:id/join
POST   /api/v1/lobbies/:id/leave
GET    /api/v1/lobbies
PATCH  /api/v1/lobbies/:id/settings
```

### Wallet Endpoints
```
POST   /api/v1/wallets
GET    /api/v1/wallets/:id
POST   /api/v1/wallets/:id/transfer
GET    /api/v1/wallets/:id/transactions
POST   /api/v1/wallets/:id/external
```

## Security

### Authentication
- JWT-based authentication
- Role-based access control
- Session management
- Rate limiting

### Authorization
- Resource-based permissions
- Role-based access control
- API key management
- IP whitelisting

### Data Protection
- Encryption at rest
- Encryption in transit
- Data masking
- Audit logging

## Monitoring and Logging

### Metrics Collection
- Service health metrics
- Performance metrics
- Business metrics
- Error rates

### Logging Strategy
- Structured logging
- Log levels
- Log aggregation
- Log retention

### Alerting
- Error rate alerts
- Performance alerts
- Business metric alerts
- Security alerts 