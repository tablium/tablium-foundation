# Tournament Smart Contracts

## 1. Tournament Contract

### 1.1 Core Contract
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract TabliumTournament is AccessControl, ReentrancyGuard, Pausable {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    bytes32 public constant PLAYER_ROLE = keccak256("PLAYER_ROLE");

    struct Tournament {
        uint256 id;
        string name;
        uint256 startTime;
        uint256 endTime;
        uint256 buyIn;
        uint256 prizePool;
        uint256 maxPlayers;
        uint256 currentPlayers;
        uint256 rakePercentage;
        bool isActive;
        bool isCompleted;
        address[] players;
        mapping(address => bool) isRegistered;
    }

    struct PlayerSubscription {
        uint256 tournamentId;
        uint256 buyInAmount;
        uint256 timestamp;
        bool isActive;
    }

    mapping(uint256 => Tournament) public tournaments;
    mapping(address => PlayerSubscription[]) public playerSubscriptions;
    mapping(address => uint256) public playerLimits;
    uint256 public tournamentCount;

    event TournamentCreated(uint256 indexed tournamentId, string name, uint256 startTime, uint256 endTime, uint256 buyIn, uint256 maxPlayers);
    event PlayerRegistered(uint256 indexed tournamentId, address indexed player);
    event TournamentCompleted(uint256 indexed tournamentId, address[] winners, uint256[] prizes);
    event PlayerLimitUpdated(address indexed player, uint256 newLimit);
    event RakeCollected(uint256 indexed tournamentId, uint256 amount);

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function createTournament(
        string memory name,
        uint256 startTime,
        uint256 endTime,
        uint256 buyIn,
        uint256 maxPlayers,
        uint256 rakePercentage
    ) external onlyRole(ADMIN_ROLE) returns (uint256) {
        require(startTime > block.timestamp, "Start time must be in the future");
        require(endTime > startTime, "End time must be after start time");
        require(maxPlayers > 0, "Max players must be greater than 0");
        require(rakePercentage <= 100, "Rake percentage must be <= 100");

        uint256 tournamentId = tournamentCount++;
        Tournament storage tournament = tournaments[tournamentId];
        
        tournament.id = tournamentId;
        tournament.name = name;
        tournament.startTime = startTime;
        tournament.endTime = endTime;
        tournament.buyIn = buyIn;
        tournament.maxPlayers = maxPlayers;
        tournament.rakePercentage = rakePercentage;
        tournament.isActive = true;

        emit TournamentCreated(tournamentId, name, startTime, endTime, buyIn, maxPlayers);
        return tournamentId;
    }

    function registerForTournament(uint256 tournamentId) external nonReentrant whenNotPaused {
        Tournament storage tournament = tournaments[tournamentId];
        require(tournament.isActive, "Tournament is not active");
        require(!tournament.isCompleted, "Tournament is completed");
        require(tournament.currentPlayers < tournament.maxPlayers, "Tournament is full");
        require(!tournament.isRegistered[msg.sender], "Player already registered");
        require(block.timestamp < tournament.startTime, "Registration period ended");

        // Check player limit
        require(playerLimits[msg.sender] >= tournament.buyIn, "Insufficient player limit");

        // Deduct from player limit
        playerLimits[msg.sender] -= tournament.buyIn;

        // Register player
        tournament.players.push(msg.sender);
        tournament.isRegistered[msg.sender] = true;
        tournament.currentPlayers++;

        // Record subscription
        playerSubscriptions[msg.sender].push(PlayerSubscription({
            tournamentId: tournamentId,
            buyInAmount: tournament.buyIn,
            timestamp: block.timestamp,
            isActive: true
        }));

        emit PlayerRegistered(tournamentId, msg.sender);
    }

    function completeTournament(
        uint256 tournamentId,
        address[] memory winners,
        uint256[] memory prizes
    ) external onlyRole(OPERATOR_ROLE) {
        Tournament storage tournament = tournaments[tournamentId];
        require(tournament.isActive, "Tournament is not active");
        require(!tournament.isCompleted, "Tournament already completed");
        require(block.timestamp >= tournament.endTime, "Tournament not ended");
        require(winners.length == prizes.length, "Winners and prizes length mismatch");

        // Calculate total prize pool
        uint256 totalPrizePool = tournament.buyIn * tournament.currentPlayers;
        uint256 rakeAmount = (totalPrizePool * tournament.rakePercentage) / 100;
        uint256 remainingPrizePool = totalPrizePool - rakeAmount;

        // Verify prize distribution
        uint256 totalPrizes;
        for (uint256 i = 0; i < prizes.length; i++) {
            totalPrizes += prizes[i];
        }
        require(totalPrizes == remainingPrizePool, "Invalid prize distribution");

        // Distribute prizes
        for (uint256 i = 0; i < winners.length; i++) {
            require(tournament.isRegistered[winners[i]], "Winner not registered");
            // Transfer prize to winner
            // Implementation depends on your token contract
        }

        tournament.isActive = false;
        tournament.isCompleted = true;
        tournament.prizePool = remainingPrizePool;

        emit TournamentCompleted(tournamentId, winners, prizes);
        emit RakeCollected(tournamentId, rakeAmount);
    }

    function updatePlayerLimit(address player, uint256 newLimit) external onlyRole(ADMIN_ROLE) {
        playerLimits[player] = newLimit;
        emit PlayerLimitUpdated(player, newLimit);
    }

    function getTournamentDetails(uint256 tournamentId) external view returns (
        string memory name,
        uint256 startTime,
        uint256 endTime,
        uint256 buyIn,
        uint256 prizePool,
        uint256 maxPlayers,
        uint256 currentPlayers,
        uint256 rakePercentage,
        bool isActive,
        bool isCompleted
    ) {
        Tournament storage tournament = tournaments[tournamentId];
        return (
            tournament.name,
            tournament.startTime,
            tournament.endTime,
            tournament.buyIn,
            tournament.prizePool,
            tournament.maxPlayers,
            tournament.currentPlayers,
            tournament.rakePercentage,
            tournament.isActive,
            tournament.isCompleted
        );
    }

    function getPlayerSubscriptions(address player) external view returns (PlayerSubscription[] memory) {
        return playerSubscriptions[player];
    }
}
```

## 2. Rake Distribution Contract

### 2.1 Core Contract
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract TabliumRakeDistribution is AccessControl, ReentrancyGuard {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

    struct RakeDistribution {
        uint256 tournamentId;
        uint256 totalRake;
        uint256 distributedRake;
        bool isDistributed;
        mapping(address => uint256) playerShares;
    }

    struct PlayerTier {
        uint256 tierLevel;
        uint256 sharePercentage;
        uint256 minimumStake;
    }

    mapping(uint256 => RakeDistribution) public rakeDistributions;
    mapping(address => PlayerTier) public playerTiers;
    address public tournamentContract;

    event RakeDistributionCreated(uint256 indexed tournamentId, uint256 totalRake);
    event RakeDistributed(uint256 indexed tournamentId, uint256 amount);
    event PlayerTierUpdated(address indexed player, uint256 tierLevel, uint256 sharePercentage);

    constructor(address _tournamentContract) {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        tournamentContract = _tournamentContract;
    }

    function createRakeDistribution(uint256 tournamentId, uint256 totalRake) external onlyRole(OPERATOR_ROLE) {
        require(!rakeDistributions[tournamentId].isDistributed, "Rake already distributed");
        
        RakeDistribution storage distribution = rakeDistributions[tournamentId];
        distribution.tournamentId = tournamentId;
        distribution.totalRake = totalRake;
        distribution.isDistributed = false;

        emit RakeDistributionCreated(tournamentId, totalRake);
    }

    function calculatePlayerShares(uint256 tournamentId) external onlyRole(OPERATOR_ROLE) {
        RakeDistribution storage distribution = rakeDistributions[tournamentId];
        require(!distribution.isDistributed, "Rake already distributed");

        // Get tournament players from tournament contract
        address[] memory players = ITabliumTournament(tournamentContract).getTournamentPlayers(tournamentId);
        
        // Calculate shares based on player tiers
        for (uint256 i = 0; i < players.length; i++) {
            PlayerTier storage tier = playerTiers[players[i]];
            uint256 share = (distribution.totalRake * tier.sharePercentage) / 100;
            distribution.playerShares[players[i]] = share;
        }

        distribution.isDistributed = true;
    }

    function distributeRake(uint256 tournamentId) external nonReentrant onlyRole(OPERATOR_ROLE) {
        RakeDistribution storage distribution = rakeDistributions[tournamentId];
        require(distribution.isDistributed, "Shares not calculated");
        require(distribution.distributedRake == 0, "Rake already distributed");

        // Distribute rake to players based on their shares
        for (uint256 i = 0; i < distribution.playerShares.length; i++) {
            address player = distribution.playerShares[i].player;
            uint256 share = distribution.playerShares[i].amount;
            
            if (share > 0) {
                // Transfer share to player
                // Implementation depends on your token contract
                distribution.distributedRake += share;
            }
        }

        emit RakeDistributed(tournamentId, distribution.distributedRake);
    }

    function updatePlayerTier(
        address player,
        uint256 tierLevel,
        uint256 sharePercentage,
        uint256 minimumStake
    ) external onlyRole(ADMIN_ROLE) {
        require(sharePercentage <= 100, "Share percentage must be <= 100");

        playerTiers[player] = PlayerTier({
            tierLevel: tierLevel,
            sharePercentage: sharePercentage,
            minimumStake: minimumStake
        });

        emit PlayerTierUpdated(player, tierLevel, sharePercentage);
    }

    function getPlayerShare(uint256 tournamentId, address player) external view returns (uint256) {
        return rakeDistributions[tournamentId].playerShares[player];
    }

    function getPlayerTier(address player) external view returns (
        uint256 tierLevel,
        uint256 sharePercentage,
        uint256 minimumStake
    ) {
        PlayerTier storage tier = playerTiers[player];
        return (tier.tierLevel, tier.sharePercentage, tier.minimumStake);
    }
}
```

## 3. Integration Points

### 3.1 Tournament Subscription Flow
1. Player initiates tournament registration
2. System checks player's available limit
3. If sufficient limit:
   - Deducts buy-in amount from player's limit
   - Registers player in tournament
   - Records subscription
4. If insufficient limit:
   - Rejects registration
   - Notifies player

### 3.2 Rake Collection and Distribution
1. Tournament completion:
   - Calculates total prize pool
   - Deducts rake percentage
   - Records rake amount
2. Rake distribution:
   - Calculates player shares based on tiers
   - Distributes rake to eligible players
   - Updates player balances

### 3.3 Player Limit Management
1. Player limit updates:
   - Admin can update player limits
   - System tracks limit usage
   - Prevents over-subscription
2. Limit restoration:
   - Unused limits returned after tournament
   - Failed tournament refunds
   - Cancellation handling

## 4. Security Considerations

### 4.1 Access Control
- Role-based access for admin and operators
- Player registration validation
- Tournament state management
- Rake distribution controls

### 4.2 Transaction Safety
- Reentrancy protection
- State consistency checks
- Atomic operations
- Error handling

### 4.3 Limit Management
- Limit validation before registration
- Atomic limit updates
- Limit restoration on failures
- Limit history tracking

## 5. Monitoring and Events

### 5.1 Key Events
- Tournament creation and updates
- Player registration
- Tournament completion
- Rake collection and distribution
- Player limit updates
- Tier changes

### 5.2 Monitoring Points
- Tournament participation rates
- Rake collection efficiency
- Player limit utilization
- Distribution accuracy
- Contract performance

## 6. Testing Strategy

### 6.1 Unit Tests
- Tournament creation and management
- Player registration and limits
- Rake calculation and distribution
- Tier management
- Access control

### 6.2 Integration Tests
- Tournament subscription flow
- Rake collection process
- Limit management
- Distribution accuracy
- Error scenarios

### 6.3 Security Tests
- Access control validation
- Reentrancy protection
- State consistency
- Limit management
- Edge cases 