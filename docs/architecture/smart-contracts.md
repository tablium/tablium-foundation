# Smart Contract Design

## Overview

The Tablium smart contract system is designed to manage player transfers between hosted wallets and external wallets, with built-in security features, limits, and compliance checks.

## Core Contracts

### 1. TabliumWallet Contract
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TabliumWallet is ReentrancyGuard, Pausable, AccessControl {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    bytes32 public constant PLAYER_ROLE = keccak256("PLAYER_ROLE");

    struct Wallet {
        address owner;
        uint256 balance;
        uint256 availableLimit;
        uint256 totalLimit;
        uint256 dailyTransferAmount;
        uint256 monthlyTransferAmount;
        uint256 lastTransferTimestamp;
        bool isActive;
    }

    struct TransferRequest {
        address from;
        address to;
        uint256 amount;
        uint256 timestamp;
        bool executed;
        bytes32 signature;
    }

    mapping(address => Wallet) public wallets;
    mapping(bytes32 => TransferRequest) public transferRequests;
    mapping(address => mapping(address => bool)) public whitelistedAddresses;
    
    uint256 public constant MIN_TRANSFER_AMOUNT = 0.01 ether;
    uint256 public constant MAX_DAILY_TRANSFER = 100 ether;
    uint256 public constant MAX_MONTHLY_TRANSFER = 1000 ether;
    uint256 public constant TRANSFER_COOLDOWN = 1 hours;
    uint256 public constant REQUEST_EXPIRY = 24 hours;

    event WalletCreated(address indexed owner);
    event TransferRequested(bytes32 indexed requestId, address from, address to, uint256 amount);
    event TransferExecuted(bytes32 indexed requestId, address from, address to, uint256 amount);
    event TransferRejected(bytes32 indexed requestId, address from, address to, uint256 amount);
    event AddressWhitelisted(address indexed owner, address indexed whitelistedAddress);
    event AddressRemovedFromWhitelist(address indexed owner, address indexed removedAddress);
    event LimitsUpdated(address indexed owner, uint256 newDailyLimit, uint256 newMonthlyLimit);

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function createWallet() external whenNotPaused {
        require(wallets[msg.sender].owner == address(0), "Wallet already exists");
        wallets[msg.sender] = Wallet({
            owner: msg.sender,
            balance: 0,
            availableLimit: MAX_DAILY_TRANSFER,
            totalLimit: MAX_MONTHLY_TRANSFER,
            dailyTransferAmount: 0,
            monthlyTransferAmount: 0,
            lastTransferTimestamp: block.timestamp,
            isActive: true
        });
        _setupRole(PLAYER_ROLE, msg.sender);
        emit WalletCreated(msg.sender);
    }

    function requestTransfer(
        address to,
        uint256 amount,
        bytes32 signature
    ) external whenNotPaused nonReentrant {
        require(wallets[msg.sender].isActive, "Wallet is not active");
        require(amount >= MIN_TRANSFER_AMOUNT, "Amount below minimum");
        require(
            wallets[msg.sender].dailyTransferAmount + amount <= MAX_DAILY_TRANSFER,
            "Daily limit exceeded"
        );
        require(
            wallets[msg.sender].monthlyTransferAmount + amount <= MAX_MONTHLY_TRANSFER,
            "Monthly limit exceeded"
        );

        bytes32 requestId = keccak256(abi.encodePacked(msg.sender, to, amount, block.timestamp));
        transferRequests[requestId] = TransferRequest({
            from: msg.sender,
            to: to,
            amount: amount,
            timestamp: block.timestamp,
            executed: false,
            signature: signature
        });

        emit TransferRequested(requestId, msg.sender, to, amount);
    }

    function executeTransfer(bytes32 requestId) external whenNotPaused nonReentrant {
        TransferRequest storage request = transferRequests[requestId];
        require(!request.executed, "Transfer already executed");
        require(block.timestamp <= request.timestamp + REQUEST_EXPIRY, "Request expired");
        require(
            hasRole(OPERATOR_ROLE, msg.sender) || 
            request.from == msg.sender,
            "Not authorized"
        );

        Wallet storage fromWallet = wallets[request.from];
        require(fromWallet.isActive, "Wallet is not active");
        require(fromWallet.balance >= request.amount, "Insufficient balance");

        fromWallet.balance -= request.amount;
        fromWallet.dailyTransferAmount += request.amount;
        fromWallet.monthlyTransferAmount += request.amount;
        fromWallet.lastTransferTimestamp = block.timestamp;

        (bool success, ) = request.to.call{value: request.amount}("");
        require(success, "Transfer failed");

        request.executed = true;
        emit TransferExecuted(requestId, request.from, request.to, request.amount);
    }

    function rejectTransfer(bytes32 requestId) external whenNotPaused {
        TransferRequest storage request = transferRequests[requestId];
        require(!request.executed, "Transfer already executed");
        require(
            hasRole(OPERATOR_ROLE, msg.sender) || 
            request.from == msg.sender,
            "Not authorized"
        );

        request.executed = true;
        emit TransferRejected(requestId, request.from, request.to, request.amount);
    }

    function whitelistAddress(address to) external whenNotPaused {
        require(wallets[msg.sender].isActive, "Wallet is not active");
        whitelistedAddresses[msg.sender][to] = true;
        emit AddressWhitelisted(msg.sender, to);
    }

    function removeFromWhitelist(address to) external whenNotPaused {
        require(wallets[msg.sender].isActive, "Wallet is not active");
        whitelistedAddresses[msg.sender][to] = false;
        emit AddressRemovedFromWhitelist(msg.sender, to);
    }

    function updateLimits(uint256 newDailyLimit, uint256 newMonthlyLimit) 
        external 
        whenNotPaused 
        onlyRole(ADMIN_ROLE) 
    {
        require(newDailyLimit <= MAX_DAILY_TRANSFER, "Daily limit too high");
        require(newMonthlyLimit <= MAX_MONTHLY_TRANSFER, "Monthly limit too high");
        
        wallets[msg.sender].availableLimit = newDailyLimit;
        wallets[msg.sender].totalLimit = newMonthlyLimit;
        
        emit LimitsUpdated(msg.sender, newDailyLimit, newMonthlyLimit);
    }

    function deposit() external payable whenNotPaused {
        require(msg.value > 0, "Amount must be greater than 0");
        wallets[msg.sender].balance += msg.value;
    }

    function withdraw(uint256 amount) external whenNotPaused nonReentrant {
        require(wallets[msg.sender].isActive, "Wallet is not active");
        require(amount <= wallets[msg.sender].balance, "Insufficient balance");
        require(
            block.timestamp >= wallets[msg.sender].lastTransferTimestamp + TRANSFER_COOLDOWN,
            "Transfer cooldown active"
        );

        wallets[msg.sender].balance -= amount;
        wallets[msg.sender].lastTransferTimestamp = block.timestamp;

        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Withdrawal failed");
    }

    function pause() external onlyRole(ADMIN_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(ADMIN_ROLE) {
        _unpause();
    }
}
```

### 2. TabliumToken Contract (Optional ERC20 Token)
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract TabliumToken is ERC20, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

    constructor() ERC20("Tablium Token", "TAB") {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function mint(address to, uint256 amount) external onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external onlyRole(BURNER_ROLE) {
        _burn(from, amount);
    }
}
```

## Key Features

### 1. Security
- ReentrancyGuard to prevent reentrancy attacks
- Pausable for emergency stops
- AccessControl for role-based permissions
- Signature verification for transfers
- Whitelist system for trusted addresses

### 2. Transfer Limits
- Daily transfer limits
- Monthly transfer limits
- Minimum transfer amount
- Transfer cooldown period
- Request expiry time

### 3. Wallet Management
- Wallet creation and activation
- Balance tracking
- Limit management
- Transfer history
- Whitelist management

### 4. Compliance
- Transfer request system
- Operator approval system
- Transaction tracking
- Limit enforcement
- Activity monitoring

## Integration Points

### 1. Backend Integration
```go
type WalletService interface {
    CreateWallet(ctx context.Context, playerID string) (*Wallet, error)
    GetBalance(ctx context.Context, walletID string) (float64, error)
    RequestTransfer(ctx context.Context, fromID, toAddress string, amount float64) (string, error)
    ExecuteTransfer(ctx context.Context, requestID string) error
    RejectTransfer(ctx context.Context, requestID string) error
    UpdateLimits(ctx context.Context, walletID string, daily, monthly float64) error
    WhitelistAddress(ctx context.Context, walletID, address string) error
    RemoveFromWhitelist(ctx context.Context, walletID, address string) error
}
```

### 2. Event Handling
```go
type WalletEvent struct {
    Type      string    `json:"type"`
    WalletID  string    `json:"walletId"`
    Amount    float64   `json:"amount"`
    From      string    `json:"from"`
    To        string    `json:"to"`
    Timestamp time.Time `json:"timestamp"`
    TxHash    string    `json:"txHash"`
}

type EventHandler interface {
    HandleWalletCreated(event WalletEvent) error
    HandleTransferRequested(event WalletEvent) error
    HandleTransferExecuted(event WalletEvent) error
    HandleTransferRejected(event WalletEvent) error
    HandleLimitsUpdated(event WalletEvent) error
}
```

## Deployment Considerations

### 1. Network Selection
- Mainnet for production
- Testnet for testing
- Private network for development

### 2. Gas Optimization
- Batch transactions
- Optimize storage usage
- Minimize state changes
- Use events for off-chain tracking

### 3. Security Measures
- Multi-signature deployment
- Timelock for admin functions
- Rate limiting
- Emergency pause functionality

### 4. Monitoring
- Contract events
- Transaction monitoring
- Gas usage tracking
- Error detection

## Testing Strategy

### 1. Unit Tests
- Contract functions
- Access control
- Limit enforcement
- Event emission

### 2. Integration Tests
- Backend integration
- Event handling
- Transaction processing
- Error scenarios

### 3. Security Tests
- Reentrancy attacks
- Access control bypass
- Integer overflow
- Signature verification

### 4. Performance Tests
- Gas optimization
- Transaction throughput
- State changes
- Event processing 