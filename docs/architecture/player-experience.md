# Player Experience System

## Player Levels

### Level System
```go
// Player level definitions
type PlayerLevel struct {
    Level           int       `json:"level"`
    Name            string    `json:"name"`
    RequiredXP      int64     `json:"requiredXP"`
    Benefits        []Benefit `json:"benefits"`
    Icon            string    `json:"icon"`
    Color           string    `json:"color"`
    Description     string    `json:"description"`
}

// Level benefits
type Benefit struct {
    Type            string    `json:"type"` // "RAKEBACK", "BONUS", "ACCESS", "PRIORITY"
    Value           float64   `json:"value"`
    Description     string    `json:"description"`
    Conditions      []Condition `json:"conditions,omitempty"`
}

// Player experience tracking
type PlayerExperience struct {
    PlayerID        string    `json:"playerId"`
    CurrentLevel    int       `json:"currentLevel"`
    CurrentXP       int64     `json:"currentXP"`
    TotalXP         int64     `json:"totalXP"`
    LastLevelUp     time.Time `json:"lastLevelUp"`
    LevelHistory    []LevelProgress `json:"levelHistory"`
    CreatedAt       time.Time `json:"createdAt"`
    UpdatedAt       time.Time `json:"updatedAt"`
}

// Level progress tracking
type LevelProgress struct {
    Level           int       `json:"level"`
    XPAtLevel       int64     `json:"xpAtLevel"`
    AchievedAt      time.Time `json:"achievedAt"`
    GamesPlayed     int       `json:"gamesPlayed"`
    TotalEarnings   float64   `json:"totalEarnings"`
}

// XP calculation rules
type XPRule struct {
    Action          string    `json:"action"` // "GAME_WIN", "TOURNAMENT_WIN", "DAILY_LOGIN", "ACHIEVEMENT"
    BaseXP          int64     `json:"baseXP"`
    Multiplier      float64   `json:"multiplier"`
    Conditions      []Condition `json:"conditions"`
    Cooldown        string    `json:"cooldown,omitempty"` // e.g., "24h", "7d"
}

// Example level progression
var levelProgression = []PlayerLevel{
    {
        Level: 1,
        Name: "Novice",
        RequiredXP: 0,
        Benefits: []Benefit{
            {
                Type: "RAKEBACK",
                Value: 0.05, // 5% rakeback
                Description: "Basic rakeback rate",
            },
        },
        Icon: "novice",
        Color: "#808080",
        Description: "Starting level for all players",
    },
    {
        Level: 5,
        Name: "Regular",
        RequiredXP: 1000,
        Benefits: []Benefit{
            {
                Type: "RAKEBACK",
                Value: 0.10, // 10% rakeback
                Description: "Increased rakeback rate",
            },
            {
                Type: "BONUS",
                Value: 0.05, // 5% bonus on winnings
                Description: "Winning bonus",
            },
        },
        Icon: "regular",
        Color: "#4CAF50",
        Description: "Regular player with enhanced benefits",
    },
    {
        Level: 10,
        Name: "Pro",
        RequiredXP: 5000,
        Benefits: []Benefit{
            {
                Type: "RAKEBACK",
                Value: 0.15, // 15% rakeback
                Description: "Pro rakeback rate",
            },
            {
                Type: "BONUS",
                Value: 0.10, // 10% bonus on winnings
                Description: "Pro winning bonus",
            },
            {
                Type: "ACCESS",
                Value: 1,
                Description: "Access to Pro tables",
            },
        },
        Icon: "pro",
        Color: "#2196F3",
        Description: "Professional player with premium benefits",
    },
    // Add more levels as needed
}

// XP calculation rules
var xpRules = []XPRule{
    {
        Action: "GAME_WIN",
        BaseXP: 100,
        Multiplier: 1.0,
        Conditions: []Condition{
            {
                Type: "MIN_STAKE",
                Value: 1.0,
            },
        },
    },
    {
        Action: "TOURNAMENT_WIN",
        BaseXP: 500,
        Multiplier: 1.5,
        Conditions: []Condition{
            {
                Type: "MIN_PLAYERS",
                Value: 8,
            },
        },
    },
    {
        Action: "DAILY_LOGIN",
        BaseXP: 50,
        Multiplier: 1.0,
        Cooldown: "24h",
    },
    // Add more rules as needed
}
```

## Player Clubs

### Club System
```go
// Club definitions
type Club struct {
    ID              string    `json:"id"`
    Name            string    `json:"name"`
    Description     string    `json:"description"`
    Level           int       `json:"level"`
    RequiredLevel   int       `json:"requiredLevel"`
    MaxMembers      int       `json:"maxMembers"`
    Benefits        []Benefit `json:"benefits"`
    Icon            string    `json:"icon"`
    Color           string    `json:"color"`
    CreatedAt       time.Time `json:"createdAt"`
    UpdatedAt       time.Time `json:"updatedAt"`
}

// Club membership
type ClubMembership struct {
    ClubID          string    `json:"clubId"`
    PlayerID        string    `json:"playerId"`
    Role            string    `json:"role"` // "LEADER", "OFFICER", "MEMBER"
    JoinedAt        time.Time `json:"joinedAt"`
    Contribution    float64   `json:"contribution"`
    Status          string    `json:"status"` // "ACTIVE", "INACTIVE", "SUSPENDED"
    LastActive      time.Time `json:"lastActive"`
}

// Club benefits
var clubBenefits = map[int][]Benefit{
    1: { // Bronze Club
        {
            Type: "RAKEBACK",
            Value: 0.02, // Additional 2% rakeback
            Description: "Club rakeback bonus",
        },
        {
            Type: "BONUS",
            Value: 0.05, // 5% bonus on club games
            Description: "Club game bonus",
        },
    },
    2: { // Silver Club
        {
            Type: "RAKEBACK",
            Value: 0.05, // Additional 5% rakeback
            Description: "Club rakeback bonus",
        },
        {
            Type: "BONUS",
            Value: 0.10, // 10% bonus on club games
            Description: "Club game bonus",
        },
        {
            Type: "ACCESS",
            Value: 1,
            Description: "Access to club-exclusive tables",
        },
    },
    3: { // Gold Club
        {
            Type: "RAKEBACK",
            Value: 0.08, // Additional 8% rakeback
            Description: "Club rakeback bonus",
        },
        {
            Type: "BONUS",
            Value: 0.15, // 15% bonus on club games
            Description: "Club game bonus",
        },
        {
            Type: "ACCESS",
            Value: 1,
            Description: "Access to club-exclusive tables",
        },
        {
            Type: "PRIORITY",
            Value: 1,
            Description: "Priority support",
        },
    },
}

// Example clubs
var clubs = []Club{
    {
        ID: "bronze_club",
        Name: "Bronze Club",
        Description: "Entry-level club for regular players",
        Level: 1,
        RequiredLevel: 5,
        MaxMembers: 50,
        Benefits: clubBenefits[1],
        Icon: "bronze",
        Color: "#CD7F32",
    },
    {
        ID: "silver_club",
        Name: "Silver Club",
        Description: "Mid-tier club for experienced players",
        Level: 2,
        RequiredLevel: 10,
        MaxMembers: 100,
        Benefits: clubBenefits[2],
        Icon: "silver",
        Color: "#C0C0C0",
    },
    {
        ID: "gold_club",
        Name: "Gold Club",
        Description: "Elite club for professional players",
        Level: 3,
        RequiredLevel: 15,
        MaxMembers: 200,
        Benefits: clubBenefits[3],
        Icon: "gold",
        Color: "#FFD700",
    },
}
```

## Rakeback System

### Rakeback Configuration
```go
// Rakeback configuration
type RakebackConfig struct {
    BaseRate        float64   `json:"baseRate"` // Base rakeback rate for all players
    LevelBonus      map[int]float64 `json:"levelBonus"` // Additional rakeback per level
    ClubBonus       map[int]float64 `json:"clubBonus"` // Additional rakeback per club level
    SpecialRates    []SpecialRate `json:"specialRates"` // Special rakeback rates for specific conditions
    MinimumRake     float64   `json:"minimumRake"` // Minimum rake amount to qualify for rakeback
    MaximumRake     float64   `json:"maximumRake"` // Maximum rakeback amount per hand
    PayoutSchedule  string    `json:"payoutSchedule"` // e.g., "DAILY", "WEEKLY", "MONTHLY"
}

// Special rakeback rate
type SpecialRate struct {
    Condition       Condition `json:"condition"`
    Rate            float64   `json:"rate"`
    Description     string    `json:"description"`
}

// Rakeback transaction
type RakebackTransaction struct {
    ID              string    `json:"id"`
    PlayerID        string    `json:"playerId"`
    GameID          string    `json:"gameId"`
    HandID          string    `json:"handId"`
    RakeAmount      float64   `json:"rakeAmount"`
    RakebackRate    float64   `json:"rakebackRate"`
    RakebackAmount  float64   `json:"rakebackAmount"`
    Level           int       `json:"level"`
    ClubLevel       int       `json:"clubLevel,omitempty"`
    Status          string    `json:"status"` // "PENDING", "APPROVED", "PAID"
    CreatedAt       time.Time `json:"createdAt"`
    UpdatedAt       time.Time `json:"updatedAt"`
}

// Example rakeback configuration
var defaultRakebackConfig = RakebackConfig{
    BaseRate: 0.05, // 5% base rakeback
    LevelBonus: map[int]float64{
        5: 0.05,  // +5% at level 5
        10: 0.10, // +10% at level 10
        15: 0.15, // +15% at level 15
        20: 0.20, // +20% at level 20
    },
    ClubBonus: map[int]float64{
        1: 0.02, // +2% for Bronze Club
        2: 0.05, // +5% for Silver Club
        3: 0.08, // +8% for Gold Club
    },
    SpecialRates: []SpecialRate{
        {
            Condition: Condition{
                Type: "TIME",
                Operator: "between",
                Value: []string{"00:00", "06:00"},
            },
            Rate: 0.10, // +10% rakeback during off-peak hours
            Description: "Off-peak hours bonus",
        },
        {
            Condition: Condition{
                Type: "EVENT",
                Event: "WEEKEND_TOURNAMENT",
            },
            Rate: 0.15, // +15% rakeback during weekend tournaments
            Description: "Weekend tournament bonus",
        },
    },
    MinimumRake: 0.01, // Minimum 0.01 to qualify for rakeback
    MaximumRake: 100.0, // Maximum 100 rakeback per hand
    PayoutSchedule: "WEEKLY",
}

// Rakeback service interface
type RakebackService interface {
    // Rakeback Calculation
    CalculateRakeback(ctx context.Context, playerID string, rakeAmount float64) (float64, error)
    GetPlayerRakebackRate(ctx context.Context, playerID string) (float64, error)
    
    // Rakeback Transactions
    CreateRakebackTransaction(ctx context.Context, transaction RakebackTransaction) error
    GetPlayerRakebackTransactions(ctx context.Context, playerID string) ([]RakebackTransaction, error)
    GetPendingRakeback(ctx context.Context, playerID string) (float64, error)
    
    // Rakeback Payout
    ProcessRakebackPayout(ctx context.Context, playerID string) error
    GetRakebackPayoutHistory(ctx context.Context, playerID string) ([]PayoutTransaction, error)
    
    // Rakeback Reports
    GenerateRakebackReport(ctx context.Context, playerID string, startDate, endDate time.Time) (*RakebackReport, error)
    GetRakebackStatistics(ctx context.Context, playerID string) (*RakebackStatistics, error)
}

// Rakeback report
type RakebackReport struct {
    PlayerID        string    `json:"playerId"`
    Period          string    `json:"period"`
    TotalRake       float64   `json:"totalRake"`
    TotalRakeback   float64   `json:"totalRakeback"`
    AverageRate     float64   `json:"averageRate"`
    Transactions    []RakebackTransaction `json:"transactions"`
    Statistics      RakebackStatistics `json:"statistics"`
}

// Rakeback statistics
type RakebackStatistics struct {
    DailyAverage    float64   `json:"dailyAverage"`
    WeeklyAverage   float64   `json:"weeklyAverage"`
    MonthlyAverage  float64   `json:"monthlyAverage"`
    PeakHours       []string  `json:"peakHours"`
    TopGames        []string  `json:"topGames"`
    TotalEarnings   float64   `json:"totalEarnings"`
}
```

## Integration with Existing Systems

### Player Service Enhancement
```go
// Enhanced player service interface
type EnhancedPlayerService interface {
    // Existing player operations
    CreatePlayer(ctx context.Context, player *Player) error
    UpdatePlayer(ctx context.Context, playerID string, updates map[string]interface{}) error
    GetPlayer(ctx context.Context, playerID string) (*Player, error)
    DeletePlayer(ctx context.Context, playerID string) error
    
    // Level system operations
    AddExperience(ctx context.Context, playerID string, amount int64) error
    GetPlayerLevel(ctx context.Context, playerID string) (*PlayerLevel, error)
    GetLevelProgress(ctx context.Context, playerID string) (*LevelProgress, error)
    
    // Club system operations
    JoinClub(ctx context.Context, playerID, clubID string) error
    LeaveClub(ctx context.Context, playerID, clubID string) error
    GetPlayerClubs(ctx context.Context, playerID string) ([]Club, error)
    UpdateClubRole(ctx context.Context, playerID, clubID string, role string) error
    
    // Rakeback operations
    GetRakebackRate(ctx context.Context, playerID string) (float64, error)
    GetRakebackEarnings(ctx context.Context, playerID string) (float64, error)
    ProcessRakeback(ctx context.Context, playerID string, amount float64) error
}
```

### Event Integration
```go
// New event types for player experience
const (
    EventLevelUp           = "PLAYER_LEVEL_UP"
    EventClubJoin         = "PLAYER_CLUB_JOIN"
    EventClubLeave        = "PLAYER_CLUB_LEAVE"
    EventRakebackEarned   = "PLAYER_RAKEBACK_EARNED"
    EventRakebackPaid     = "PLAYER_RAKEBACK_PAID"
)

// Event handlers
func (s *playerService) handleLevelUp(ctx context.Context, playerID string, newLevel int) error {
    // Notify player
    s.eventBus.Publish(EventLevelUp, map[string]interface{}{
        "player_id": playerID,
        "new_level": newLevel,
        "timestamp": time.Now(),
    })
    
    // Update player benefits
    return s.updatePlayerBenefits(ctx, playerID)
}

func (s *playerService) handleClubJoin(ctx context.Context, playerID, clubID string) error {
    // Notify player and club members
    s.eventBus.Publish(EventClubJoin, map[string]interface{}{
        "player_id": playerID,
        "club_id": clubID,
        "timestamp": time.Now(),
    })
    
    // Update player benefits
    return s.updatePlayerBenefits(ctx, playerID)
}

func (s *playerService) handleRakebackEarned(ctx context.Context, playerID string, amount float64) error {
    // Notify player
    s.eventBus.Publish(EventRakebackEarned, map[string]interface{}{
        "player_id": playerID,
        "amount": amount,
        "timestamp": time.Now(),
    })
    
    // Update player statistics
    return s.updatePlayerStatistics(ctx, playerID)
}
```

## Club Creation and Management

### Club Creation
```go
// Club creation and management
type ClubCreation struct {
    ID              string    `json:"id"`
    CreatorID       string    `json:"creatorId"`
    Name            string    `json:"name"`
    Description     string    `json:"description"`
    Level           int       `json:"level"`
    MaxMembers      int       `json:"maxMembers"`
    Benefits        []Benefit `json:"benefits"`
    Icon            string    `json:"icon"`
    Color           string    `json:"color"`
    Status          string    `json:"status"` // "PENDING", "APPROVED", "REJECTED"
    CreatedAt       time.Time `json:"createdAt"`
    UpdatedAt       time.Time `json:"updatedAt"`
}

// Club tournament
type ClubTournament struct {
    ID              string    `json:"id"`
    ClubID          string    `json:"clubId"`
    Name            string    `json:"name"`
    Description     string    `json:"description"`
    StartTime       time.Time `json:"startTime"`
    EndTime         time.Time `json:"endTime"`
    BuyInAmount     float64   `json:"buyInAmount"`
    PrizePool       float64   `json:"prizePool"`
    MaxPlayers      int       `json:"maxPlayers"`
    MinPlayers      int       `json:"minPlayers"`
    Status          string    `json:"status"` // "SCHEDULED", "IN_PROGRESS", "COMPLETED", "CANCELLED"
    RegisteredPlayers []string `json:"registeredPlayers"`
    Winners         []Winner  `json:"winners,omitempty"`
    CreatedAt       time.Time `json:"createdAt"`
    UpdatedAt       time.Time `json:"updatedAt"`
}

// Club tournament winner
type Winner struct {
    PlayerID    string    `json:"playerId"`
    Position    int       `json:"position"`
    Prize       float64   `json:"prize"`
}

// Club management permissions
type ClubManagementPermissions struct {
    CanCreateClub      bool      `json:"canCreateClub"`
    CanCreateTournament bool     `json:"canCreateTournament"`
    MaxClubs           int       `json:"maxClubs"`
    MaxTournaments     int       `json:"maxTournaments"`
    MaxMembersPerClub  int       `json:"maxMembersPerClub"`
    MaxPrizePool       float64   `json:"maxPrizePool"`
    RequiredLevel      int       `json:"requiredLevel"`
}

// Club management limits for Pro players
var proClubLimits = ClubManagementPermissions{
    CanCreateClub:      true,
    CanCreateTournament: true,
    MaxClubs:           3,        // Pro players can create up to 3 clubs
    MaxTournaments:     5,        // Maximum 5 active tournaments per club
    MaxMembersPerClub:  100,      // Maximum 100 members per club
    MaxPrizePool:       10000.0,  // Maximum prize pool of 10,000
    RequiredLevel:      10,       // Requires Pro level (10)
}

// Enhanced club service interface
type EnhancedClubService interface {
    // Basic club operations
    CreateClub(ctx context.Context, creation ClubCreation) error
    UpdateClub(ctx context.Context, clubID string, updates map[string]interface{}) error
    DeleteClub(ctx context.Context, clubID string) error
    GetClub(ctx context.Context, clubID string) (*Club, error)
    ListClubs(ctx context.Context, filter ClubFilter) ([]Club, error)
    
    // Club membership operations
    JoinClub(ctx context.Context, playerID, clubID string) error
    LeaveClub(ctx context.Context, playerID, clubID string) error
    UpdateClubRole(ctx context.Context, playerID, clubID string, role string) error
    GetClubMembers(ctx context.Context, clubID string) ([]ClubMembership, error)
    
    // Club tournament operations
    CreateTournament(ctx context.Context, tournament ClubTournament) error
    UpdateTournament(ctx context.Context, tournamentID string, updates map[string]interface{}) error
    CancelTournament(ctx context.Context, tournamentID string) error
    GetTournament(ctx context.Context, tournamentID string) (*ClubTournament, error)
    ListClubTournaments(ctx context.Context, clubID string) ([]ClubTournament, error)
    
    // Tournament registration
    RegisterForTournament(ctx context.Context, playerID, tournamentID string) error
    UnregisterFromTournament(ctx context.Context, playerID, tournamentID string) error
    GetTournamentParticipants(ctx context.Context, tournamentID string) ([]string, error)
    
    // Club management validation
    ValidateClubCreation(ctx context.Context, creatorID string) error
    ValidateTournamentCreation(ctx context.Context, clubID string) error
    GetClubManagementLimits(ctx context.Context, playerID string) (*ClubManagementPermissions, error)
}

// Club filter
type ClubFilter struct {
    Level           int       `json:"level,omitempty"`
    Status          string    `json:"status,omitempty"`
    CreatedBy       string    `json:"createdBy,omitempty"`
    MinMembers      int       `json:"minMembers,omitempty"`
    MaxMembers      int       `json:"maxMembers,omitempty"`
    HasActiveTournaments bool  `json:"hasActiveTournaments,omitempty"`
}

// Example club tournament
var exampleClubTournament = ClubTournament{
    ID: "club_tournament_001",
    ClubID: "pro_club_001",
    Name: "Pro Club Championship",
    Description: "Monthly championship for Pro Club members",
    StartTime: time.Now().Add(24 * time.Hour),
    EndTime: time.Now().Add(48 * time.Hour),
    BuyInAmount: 100.0,
    PrizePool: 5000.0,
    MaxPlayers: 50,
    MinPlayers: 8,
    Status: "SCHEDULED",
    RegisteredPlayers: []string{},
}

// Event handlers for club management
func (s *clubService) handleClubCreation(ctx context.Context, creation ClubCreation) error {
    // Validate creator's permissions
    if err := s.validateClubCreation(ctx, creation.CreatorID); err != nil {
        return fmt.Errorf("invalid club creation: %w", err)
    }
    
    // Create club
    club := &Club{
        ID: creation.ID,
        Name: creation.Name,
        Description: creation.Description,
        Level: creation.Level,
        MaxMembers: creation.MaxMembers,
        Benefits: creation.Benefits,
        Icon: creation.Icon,
        Color: creation.Color,
        Status: "PENDING",
        CreatedAt: time.Now(),
        UpdatedAt: time.Now(),
    }
    
    // Store club
    if err := s.clubRepo.Create(ctx, club); err != nil {
        return fmt.Errorf("create club: %w", err)
    }
    
    // Notify administrators
    s.eventBus.Publish(EventClubCreated, map[string]interface{}{
        "club_id": club.ID,
        "creator_id": creation.CreatorID,
        "timestamp": time.Now(),
    })
    
    return nil
}

func (s *clubService) handleTournamentCreation(ctx context.Context, tournament ClubTournament) error {
    // Validate club's tournament limits
    if err := s.validateTournamentCreation(ctx, tournament.ClubID); err != nil {
        return fmt.Errorf("invalid tournament creation: %w", err)
    }
    
    // Create tournament
    if err := s.tournamentRepo.Create(ctx, &tournament); err != nil {
        return fmt.Errorf("create tournament: %w", err)
    }
    
    // Notify club members
    s.eventBus.Publish(EventClubTournamentCreated, map[string]interface{}{
        "tournament_id": tournament.ID,
        "club_id": tournament.ClubID,
        "timestamp": time.Now(),
    })
    
    return nil
}

// Validation functions
func (s *clubService) validateClubCreation(ctx context.Context, creatorID string) error {
    // Get creator's level
    player, err := s.playerRepo.Get(ctx, creatorID)
    if err != nil {
        return fmt.Errorf("get player: %w", err)
    }
    
    // Check if player is Pro level
    if player.Level < proClubLimits.RequiredLevel {
        return fmt.Errorf("player must be Pro level to create clubs")
    }
    
    // Check club creation limits
    clubs, err := s.clubRepo.GetByCreator(ctx, creatorID)
    if err != nil {
        return fmt.Errorf("get creator's clubs: %w", err)
    }
    
    if len(clubs) >= proClubLimits.MaxClubs {
        return fmt.Errorf("player has reached maximum club creation limit")
    }
    
    return nil
}

func (s *clubService) validateTournamentCreation(ctx context.Context, clubID string) error {
    // Get club's active tournaments
    tournaments, err := s.tournamentRepo.GetActiveByClub(ctx, clubID)
    if err != nil {
        return fmt.Errorf("get club tournaments: %w", err)
    }
    
    if len(tournaments) >= proClubLimits.MaxTournaments {
        return fmt.Errorf("club has reached maximum tournament limit")
    }
    
    return nil
}
``` 