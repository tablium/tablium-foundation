# Backend Services Documentation

## Game History Service

### Core Components
```go
type GameHistoryService struct {
    db            *sql.DB
    redis         *redis.Client
    eventBus      *rabbitmq.Client
    gameService   *GameService
}

type GameHistory struct {
    ID            string    `json:"id"`
    GameType      string    `json:"gameType"` // "CASH", "TOURNAMENT"
    StartTime     time.Time `json:"startTime"`
    EndTime       time.Time `json:"endTime"`
    BuyIn         float64   `json:"buyIn"`
    CashOut       float64   `json:"cashOut"`
    Profit        float64   `json:"profit"`
    Hands         int       `json:"hands"`
    VPIP          float64   `json:"vpip"`
    PFR           float64   `json:"pfr"`
    AFQ           float64   `json:"afq"`
    Players       []GameHistoryPlayer `json:"players"`
    Actions       []GameHistoryAction `json:"actions"`
}

type GameHistoryPlayer struct {
    ID            string    `json:"id"`
    Username      string    `json:"username"`
    Position      int       `json:"position"`
    Stack         float64   `json:"stack"`
    Profit        float64   `json:"profit"`
    Hands         int       `json:"hands"`
    VPIP          float64   `json:"vpip"`
    PFR           float64   `json:"pfr"`
    AFQ           float64   `json:"afq"`
}

type GameHistoryAction struct {
    Type          string    `json:"type"` // "BET", "CALL", "RAISE", "FOLD", "CHECK"
    PlayerID      string    `json:"playerId"`
    Amount        float64   `json:"amount,omitempty"`
    Timestamp     time.Time `json:"timestamp"`
}
```

### Database Schema
```sql
CREATE TABLE game_history (
    id VARCHAR(36) PRIMARY KEY,
    game_type VARCHAR(50) NOT NULL,
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL,
    buy_in DECIMAL(10,2) NOT NULL,
    cash_out DECIMAL(10,2) NOT NULL,
    profit DECIMAL(10,2) NOT NULL,
    hands INTEGER NOT NULL,
    vpip DECIMAL(5,2) NOT NULL,
    pfr DECIMAL(5,2) NOT NULL,
    afq DECIMAL(5,2) NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);

CREATE TABLE game_history_players (
    history_id VARCHAR(36) REFERENCES game_history(id),
    player_id VARCHAR(36) REFERENCES players(id),
    position INTEGER NOT NULL,
    stack DECIMAL(10,2) NOT NULL,
    profit DECIMAL(10,2) NOT NULL,
    hands INTEGER NOT NULL,
    vpip DECIMAL(5,2) NOT NULL,
    pfr DECIMAL(5,2) NOT NULL,
    afq DECIMAL(5,2) NOT NULL,
    PRIMARY KEY (history_id, player_id)
);

CREATE TABLE game_history_actions (
    id VARCHAR(36) PRIMARY KEY,
    history_id VARCHAR(36) REFERENCES game_history(id),
    player_id VARCHAR(36) REFERENCES players(id),
    action_type VARCHAR(50) NOT NULL,
    amount DECIMAL(10,2),
    timestamp TIMESTAMP NOT NULL
);
```

### API Endpoints
```
GET    /api/v1/game-history
GET    /api/v1/game-history/:id
GET    /api/v1/game-history/player/:playerId
GET    /api/v1/game-history/export
POST   /api/v1/game-history/replay
```

## Movement History Service

### Core Components
```go
type MovementHistoryService struct {
    db            *sql.DB
    redis         *redis.Client
    eventBus      *rabbitmq.Client
    walletService *WalletService
}

type MovementHistory struct {
    ID            string    `json:"id"`
    PlayerID      string    `json:"playerId"`
    GameType      string    `json:"gameType"` // "CASH", "TOURNAMENT", "SIT_N_GO", "SPIN_N_GO", "BATTLE_ROYALE"
    MovementType  string    `json:"movementType"` // "BUY_IN", "CASH_OUT", "REBUY", "ADD_ON", "RAKE", "BONUS"
    Amount        float64   `json:"amount"`
    Currency      string    `json:"currency"`
    Status        string    `json:"status"` // "PENDING", "COMPLETED", "FAILED", "CANCELLED"
    GameID        string    `json:"gameId,omitempty"`
    TableID       string    `json:"tableId,omitempty"`
    TournamentID  string    `json:"tournamentId,omitempty"`
    Metadata      map[string]interface{} `json:"metadata,omitempty"`
    CreatedAt     time.Time `json:"createdAt"`
    UpdatedAt     time.Time `json:"updatedAt"`
}

type MovementSummary struct {
    PlayerID      string    `json:"playerId"`
    GameType      string    `json:"gameType"`
    TotalBuyIn    float64   `json:"totalBuyIn"`
    TotalCashOut  float64   `json:"totalCashOut"`
    TotalRebuys   float64   `json:"totalRebuys"`
    TotalAddOns   float64   `json:"totalAddOns"`
    TotalRake     float64   `json:"totalRake"`
    TotalBonus    float64   `json:"totalBonus"`
    NetProfit     float64   `json:"netProfit"`
    LastMovement  time.Time `json:"lastMovement"`
}

type MovementFilter struct {
    StartDate     time.Time `json:"startDate,omitempty"`
    EndDate       time.Time `json:"endDate,omitempty"`
    GameTypes     []string  `json:"gameTypes,omitempty"`
    MovementTypes []string  `json:"movementTypes,omitempty"`
    Status        []string  `json:"status,omitempty"`
    MinAmount     float64   `json:"minAmount,omitempty"`
    MaxAmount     float64   `json:"maxAmount,omitempty"`
}
```

### Database Schema
```sql
CREATE TABLE movement_history (
    id VARCHAR(36) PRIMARY KEY,
    player_id VARCHAR(36) REFERENCES players(id),
    game_type VARCHAR(50) NOT NULL,
    movement_type VARCHAR(50) NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    currency VARCHAR(3) NOT NULL,
    status VARCHAR(50) NOT NULL,
    game_id VARCHAR(36),
    table_id VARCHAR(36),
    tournament_id VARCHAR(36),
    metadata JSONB,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);

CREATE TABLE movement_summaries (
    player_id VARCHAR(36) REFERENCES players(id),
    game_type VARCHAR(50) NOT NULL,
    total_buy_in DECIMAL(10,2) NOT NULL DEFAULT 0,
    total_cash_out DECIMAL(10,2) NOT NULL DEFAULT 0,
    total_rebuys DECIMAL(10,2) NOT NULL DEFAULT 0,
    total_add_ons DECIMAL(10,2) NOT NULL DEFAULT 0,
    total_rake DECIMAL(10,2) NOT NULL DEFAULT 0,
    total_bonus DECIMAL(10,2) NOT NULL DEFAULT 0,
    net_profit DECIMAL(10,2) NOT NULL DEFAULT 0,
    last_movement TIMESTAMP NOT NULL,
    PRIMARY KEY (player_id, game_type)
);

CREATE TABLE movement_audit_log (
    id VARCHAR(36) PRIMARY KEY,
    movement_id VARCHAR(36) REFERENCES movement_history(id),
    action VARCHAR(50) NOT NULL,
    actor_id VARCHAR(36) REFERENCES players(id),
    old_status VARCHAR(50),
    new_status VARCHAR(50),
    reason TEXT,
    created_at TIMESTAMP NOT NULL
);
```

### API Endpoints
```
GET    /api/v1/movements
GET    /api/v1/movements/:id
GET    /api/v1/movements/player/:playerId
GET    /api/v1/movements/summary
GET    /api/v1/movements/export
POST   /api/v1/movements/buy-in
POST   /api/v1/movements/cash-out
POST   /api/v1/movements/rebuy
POST   /api/v1/movements/add-on
PUT    /api/v1/movements/:id/status
GET    /api/v1/movements/audit/:id
```

### Game Types Support
The Movement History Service supports the following game types:

1. Cash Games
- Regular cash game buy-ins and cash-outs
- Rebuys and add-ons
- Rake tracking
- Session-based movement tracking

2. Tournaments
- Tournament buy-ins
- Prize pool distributions
- Rebuys and add-ons
- Satellite tournament entries
- Tournament-specific bonuses

3. Sit & Go
- Single table tournament buy-ins
- Prize pool distributions
- Rebuys (if allowed)
- Jackpot contributions

4. Spin & Go
- Buy-ins
- Prize pool distributions
- Multiplier tracking
- Jackpot contributions

5. Battle Royale
- Buy-ins
- Prize pool distributions
- Knockout bounties
- Progressive bounty tracking

### Movement Types
1. Buy-in
- Initial buy-in for any game type
- Minimum and maximum buy-in tracking
- Currency conversion tracking

2. Cash-out
- Regular cash-out
- Tournament prize collection
- Partial cash-out support

3. Rebuy
- Cash game rebuys
- Tournament rebuys
- Rebuy period tracking

4. Add-on
- Tournament add-ons
- Add-on period tracking
- Multiple add-on support

5. Rake
- Cash game rake
- Tournament fee tracking
- Rake back calculations

6. Bonus
- Welcome bonuses
- Deposit bonuses
- Loyalty rewards
- Achievement rewards
- Tournament-specific bonuses

### Features
1. Real-time Movement Tracking
- Instant movement recording
- Status updates
- Balance synchronization

2. Movement Validation
- Amount validation
- Currency validation
- Game type specific rules
- Player status checks

3. Movement Reconciliation
- Daily reconciliation
- Discrepancy detection
- Audit trail maintenance

4. Reporting
- Player movement reports
- Game type specific reports
- Time-based reports
- Export functionality

5. Security
- Movement verification
- Fraud detection
- Suspicious activity monitoring
- Audit logging

## Chat Service

### Core Components
```go
type ChatService struct {
    db            *sql.DB
    redis         *redis.Client
    eventBus      *rabbitmq.Client
    wsManager     *websocket.Manager
}

type ChatMessage struct {
    ID            string    `json:"id"`
    RoomID        string    `json:"roomId"`
    SenderID      string    `json:"senderId"`
    Content       string    `json:"content"`
    Type          string    `json:"type"` // "TEXT", "SYSTEM", "ACTION"
    Timestamp     time.Time `json:"timestamp"`
    Metadata      map[string]interface{} `json:"metadata,omitempty"`
}

type ChatRoom struct {
    ID            string    `json:"id"`
    Type          string    `json:"type"` // "TABLE", "TOURNAMENT", "PRIVATE"
    Name          string    `json:"name"`
    Participants  []string  `json:"participants"`
    Settings      ChatRoomSettings `json:"settings"`
    CreatedAt     time.Time `json:"createdAt"`
    UpdatedAt     time.Time `json:"updatedAt"`
}

type ChatRoomSettings struct {
    IsMuted       bool      `json:"isMuted"`
    Notifications bool      `json:"notifications"`
    Pinned        bool      `json:"pinned"`
    ReadReceipts  bool      `json:"readReceipts"`
}
```

### Database Schema
```sql
CREATE TABLE chat_rooms (
    id VARCHAR(36) PRIMARY KEY,
    type VARCHAR(50) NOT NULL,
    name VARCHAR(255) NOT NULL,
    settings JSONB NOT NULL DEFAULT '{}',
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);

CREATE TABLE chat_room_participants (
    room_id VARCHAR(36) REFERENCES chat_rooms(id),
    player_id VARCHAR(36) REFERENCES players(id),
    joined_at TIMESTAMP NOT NULL,
    left_at TIMESTAMP,
    PRIMARY KEY (room_id, player_id)
);

CREATE TABLE chat_messages (
    id VARCHAR(36) PRIMARY KEY,
    room_id VARCHAR(36) REFERENCES chat_rooms(id),
    sender_id VARCHAR(36) REFERENCES players(id),
    content TEXT NOT NULL,
    type VARCHAR(50) NOT NULL,
    metadata JSONB,
    timestamp TIMESTAMP NOT NULL
);

CREATE TABLE chat_message_reads (
    message_id VARCHAR(36) REFERENCES chat_messages(id),
    player_id VARCHAR(36) REFERENCES players(id),
    read_at TIMESTAMP NOT NULL,
    PRIMARY KEY (message_id, player_id)
);
```

### API Endpoints
```
GET    /api/v1/chat/rooms
GET    /api/v1/chat/rooms/:id
POST   /api/v1/chat/rooms
POST   /api/v1/chat/rooms/:id/join
POST   /api/v1/chat/rooms/:id/leave
GET    /api/v1/chat/rooms/:id/messages
POST   /api/v1/chat/rooms/:id/messages
PUT    /api/v1/chat/rooms/:id/settings
```

## Player Settings Service

### Core Components
```go
type PlayerSettingsService struct {
    db            *sql.DB
    redis         *redis.Client
    eventBus      *rabbitmq.Client
}

type PlayerSettings struct {
    PlayerID      string    `json:"playerId"`
    Preferences   Preferences `json:"preferences"`
    Privacy       PrivacySettings `json:"privacy"`
    Appearance    AppearanceSettings `json:"appearance"`
    Notifications NotificationSettings `json:"notifications"`
    GameSettings  GameSettings `json:"gameSettings"`
    UpdatedAt     time.Time `json:"updatedAt"`
}

type Preferences struct {
    Language      string    `json:"language"`
    Timezone      string    `json:"timezone"`
    Currency      string    `json:"currency"`
    DateFormat    string    `json:"dateFormat"`
    Sound         SoundSettings `json:"sound"`
    Chat          ChatSettings `json:"chat"`
}

type PrivacySettings struct {
    ProfileVisibility string    `json:"profileVisibility"` // "PUBLIC", "FRIENDS", "PRIVATE"
    ShowOnlineStatus  bool      `json:"showOnlineStatus"`
    ShowLastSeen      bool      `json:"showLastSeen"`
    AllowFriendRequests bool    `json:"allowFriendRequests"`
    AllowMessages     bool      `json:"allowMessages"`
    ShowAchievements   bool      `json:"showAchievements"`
    ShowStatistics     bool      `json:"showStatistics"`
}

type AppearanceSettings struct {
    Theme         string    `json:"theme"` // "LIGHT", "DARK", "SYSTEM"
    FontSize      string    `json:"fontSize"` // "SMALL", "MEDIUM", "LARGE"
    Contrast      string    `json:"contrast"` // "NORMAL", "HIGH"
    Animations    AnimationSettings `json:"animations"`
    CustomColors  map[string]string `json:"customColors,omitempty"`
}

type NotificationSettings struct {
    Email         EmailNotificationSettings `json:"email"`
    Push          PushNotificationSettings `json:"push"`
    InApp         InAppNotificationSettings `json:"inApp"`
}
```

### Database Schema
```sql
CREATE TABLE player_settings (
    player_id VARCHAR(36) PRIMARY KEY REFERENCES players(id),
    preferences JSONB NOT NULL DEFAULT '{}',
    privacy JSONB NOT NULL DEFAULT '{}',
    appearance JSONB NOT NULL DEFAULT '{}',
    notifications JSONB NOT NULL DEFAULT '{}',
    game_settings JSONB NOT NULL DEFAULT '{}',
    updated_at TIMESTAMP NOT NULL
);

CREATE TABLE settings_history (
    id VARCHAR(36) PRIMARY KEY,
    player_id VARCHAR(36) REFERENCES players(id),
    settings_type VARCHAR(50) NOT NULL,
    old_value JSONB,
    new_value JSONB,
    changed_at TIMESTAMP NOT NULL
);
```

### API Endpoints
```
GET    /api/v1/settings
PUT    /api/v1/settings
GET    /api/v1/settings/history
POST   /api/v1/settings/reset
```

## Achievement Service

### Core Components
```go
type AchievementService struct {
    db            *sql.DB
    redis         *redis.Client
    eventBus      *rabbitmq.Client
}

type Achievement struct {
    ID            string    `json:"id"`
    Title         string    `json:"title"`
    Description   string    `json:"description"`
    Category      string    `json:"category"` // "GAME", "TOURNAMENT", "SOCIAL", "SPECIAL"
    Requirements  []AchievementRequirement `json:"requirements"`
    Rewards       []AchievementReward `json:"rewards"`
    Rarity        string    `json:"rarity"` // "COMMON", "RARE", "EPIC", "LEGENDARY"
    Icon          string    `json:"icon"`
    CreatedAt     time.Time `json:"createdAt"`
    UpdatedAt     time.Time `json:"updatedAt"`
}

type AchievementRequirement struct {
    Type          string    `json:"type"`
    Value         int       `json:"value"`
    Current       int       `json:"current"`
}

type AchievementReward struct {
    Type          string    `json:"type"` // "CHIPS", "TICKETS", "BADGE", "TITLE"
    Value         interface{} `json:"value"`
}

type AchievementProgress struct {
    PlayerID      string    `json:"playerId"`
    AchievementID string    `json:"achievementId"`
    Progress      int       `json:"progress"`
    IsUnlocked    bool      `json:"isUnlocked"`
    UnlockedAt    time.Time `json:"unlockedAt,omitempty"`
}
```

### Database Schema
```sql
CREATE TABLE achievements (
    id VARCHAR(36) PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    category VARCHAR(50) NOT NULL,
    requirements JSONB NOT NULL,
    rewards JSONB NOT NULL,
    rarity VARCHAR(50) NOT NULL,
    icon VARCHAR(255) NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);

CREATE TABLE achievement_progress (
    player_id VARCHAR(36) REFERENCES players(id),
    achievement_id VARCHAR(36) REFERENCES achievements(id),
    progress INTEGER NOT NULL DEFAULT 0,
    is_unlocked BOOLEAN NOT NULL DEFAULT FALSE,
    unlocked_at TIMESTAMP,
    PRIMARY KEY (player_id, achievement_id)
);

CREATE TABLE achievement_rewards (
    id VARCHAR(36) PRIMARY KEY,
    player_id VARCHAR(36) REFERENCES players(id),
    achievement_id VARCHAR(36) REFERENCES achievements(id),
    reward_type VARCHAR(50) NOT NULL,
    reward_value JSONB NOT NULL,
    claimed_at TIMESTAMP NOT NULL
);
```

### API Endpoints
```
GET    /api/v1/achievements
GET    /api/v1/achievements/:id
GET    /api/v1/achievements/player/:playerId
POST   /api/v1/achievements/progress
POST   /api/v1/achievements/rewards/claim
```

## Notification Service

### Core Components
```go
type NotificationService struct {
    db            *sql.DB
    redis         *redis.Client
    eventBus      *rabbitmq.Client
    emailClient   *email.Client
    pushClient    *push.Client
}

type Notification struct {
    ID            string    `json:"id"`
    PlayerID      string    `json:"playerId"`
    Type          string    `json:"type"` // "GAME", "TOURNAMENT", "SYSTEM", "ACHIEVEMENT", "TRANSACTION"
    Title         string    `json:"title"`
    Message       string    `json:"message"`
    Read          bool      `json:"read"`
    Action        *NotificationAction `json:"action,omitempty"`
    Metadata      map[string]interface{} `json:"metadata,omitempty"`
    CreatedAt     time.Time `json:"createdAt"`
}

type NotificationAction struct {
    Type          string    `json:"type"`
    Payload       map[string]interface{} `json:"payload"`
}

type NotificationSettings struct {
    Email         EmailSettings `json:"email"`
    Push          PushSettings `json:"push"`
    InApp         InAppSettings `json:"inApp"`
}

type EmailSettings struct {
    Enabled       bool      `json:"enabled"`
    Types         []string  `json:"types"`
    Frequency     string    `json:"frequency"` // "IMMEDIATE", "DAILY", "WEEKLY"
}

type PushSettings struct {
    Enabled       bool      `json:"enabled"`
    Types         []string  `json:"types"`
    QuietHours    QuietHours `json:"quietHours"`
}

type InAppSettings struct {
    Enabled       bool      `json:"enabled"`
    Types         []string  `json:"types"`
    Position      string    `json:"position"` // "TOP_RIGHT", "BOTTOM_RIGHT"
}
```

### Database Schema
```sql
CREATE TABLE notifications (
    id VARCHAR(36) PRIMARY KEY,
    player_id VARCHAR(36) REFERENCES players(id),
    type VARCHAR(50) NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    read BOOLEAN NOT NULL DEFAULT FALSE,
    action JSONB,
    metadata JSONB,
    created_at TIMESTAMP NOT NULL
);

CREATE TABLE notification_settings (
    player_id VARCHAR(36) PRIMARY KEY REFERENCES players(id),
    email_settings JSONB NOT NULL DEFAULT '{}',
    push_settings JSONB NOT NULL DEFAULT '{}',
    in_app_settings JSONB NOT NULL DEFAULT '{}',
    updated_at TIMESTAMP NOT NULL
);

CREATE TABLE notification_delivery (
    id VARCHAR(36) PRIMARY KEY,
    notification_id VARCHAR(36) REFERENCES notifications(id),
    delivery_type VARCHAR(50) NOT NULL,
    status VARCHAR(50) NOT NULL,
    error TEXT,
    delivered_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL
);
```

### API Endpoints
```
GET    /api/v1/notifications
GET    /api/v1/notifications/unread
PUT    /api/v1/notifications/:id/read
PUT    /api/v1/notifications/settings
POST   /api/v1/notifications/test
``` 