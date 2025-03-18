# Transfer Request and Approval Flow

## Overview

The transfer request and approval flow is designed to ensure secure and compliant transfers between hosted wallets and external wallets. This document outlines the complete process from request initiation to final execution.

## Flow Diagram

```
[Player] → [Backend API] → [Smart Contract] → [Operator Review] → [Execution]
   ↑            ↑              ↑                   ↑               ↑
   └────────────┴──────────────┴───────────────────┴───────────────┘
                    [Event Monitoring & Updates]
```

## Detailed Process Flow

### 1. Transfer Request Initiation
```go
// 1. Player initiates transfer request
type TransferRequest struct {
    FromWalletID    string  `json:"fromWalletId"`
    ToAddress       string  `json:"toAddress"`
    Amount          float64 `json:"amount"`
    Currency        string  `json:"currency"` // "ETH" or "TAB"
    Signature       string  `json:"signature"`
    Timestamp       int64   `json:"timestamp"`
}

// 2. Backend validation
func (s *WalletService) ValidateTransferRequest(ctx context.Context, req *TransferRequest) error {
    // Validate wallet exists and is active
    wallet, err := s.GetWallet(ctx, req.FromWalletID)
    if err != nil {
        return fmt.Errorf("invalid wallet: %w", err)
    }

    // Validate transfer limits
    if err := s.ValidateTransferLimits(ctx, wallet, req.Amount); err != nil {
        return fmt.Errorf("transfer limits exceeded: %w", err)
    }

    // Validate signature
    if err := s.ValidateSignature(ctx, req); err != nil {
        return fmt.Errorf("invalid signature: %w", err)
    }

    return nil
}

// 3. Create transfer request on blockchain
func (s *WalletService) CreateTransferRequest(ctx context.Context, req *TransferRequest) (string, error) {
    // Convert amount to wei
    amount := s.ConvertToWei(req.Amount)

    // Create request on blockchain
    tx, err := s.contract.RequestTransfer(
        req.ToAddress,
        amount,
        req.Signature,
    )
    if err != nil {
        return "", fmt.Errorf("failed to create transfer request: %w", err)
    }

    // Store request in database
    requestID := tx.Hash().Hex()
    if err := s.storeTransferRequest(ctx, requestID, req); err != nil {
        return "", fmt.Errorf("failed to store transfer request: %w", err)
    }

    return requestID, nil
}
```

### 2. Operator Review Process
```go
// 1. Operator review interface
type TransferReview struct {
    RequestID       string  `json:"requestId"`
    Status          string  `json:"status"` // "APPROVED", "REJECTED"
    Reason          string  `json:"reason,omitempty"`
    OperatorID      string  `json:"operatorId"`
    ReviewedAt      int64   `json:"reviewedAt"`
}

// 2. Review process
func (s *WalletService) ReviewTransferRequest(ctx context.Context, review *TransferReview) error {
    // Get transfer request
    request, err := s.GetTransferRequest(ctx, review.RequestID)
    if err != nil {
        return fmt.Errorf("failed to get transfer request: %w", err)
    }

    // Validate operator permissions
    if err := s.ValidateOperatorPermissions(ctx, review.OperatorID); err != nil {
        return fmt.Errorf("invalid operator permissions: %w", err)
    }

    // Update request status
    if err := s.UpdateTransferRequestStatus(ctx, review); err != nil {
        return fmt.Errorf("failed to update request status: %w", err)
    }

    // Emit review event
    if err := s.EmitTransferReviewEvent(ctx, review); err != nil {
        return fmt.Errorf("failed to emit review event: %w", err)
    }

    return nil
}
```

### 3. Transfer Execution
```go
// 1. Execute transfer
func (s *WalletService) ExecuteTransfer(ctx context.Context, requestID string) error {
    // Get transfer request
    request, err := s.GetTransferRequest(ctx, requestID)
    if err != nil {
        return fmt.Errorf("failed to get transfer request: %w", err)
    }

    // Validate request status
    if request.Status != "APPROVED" {
        return fmt.Errorf("transfer request not approved")
    }

    // Execute transfer on blockchain
    tx, err := s.contract.ExecuteTransfer(requestID)
    if err != nil {
        return fmt.Errorf("failed to execute transfer: %w", err)
    }

    // Update transfer status
    if err := s.UpdateTransferStatus(ctx, requestID, "EXECUTED", tx.Hash().Hex()); err != nil {
        return fmt.Errorf("failed to update transfer status: %w", err)
    }

    // Emit execution event
    if err := s.EmitTransferExecutedEvent(ctx, requestID, tx.Hash().Hex()); err != nil {
        return fmt.Errorf("failed to emit execution event: %w", err)
    }

    return nil
}
```

### 4. Event Monitoring
```go
// 1. Event types
type TransferEvent struct {
    Type            string    `json:"type"`
    RequestID       string    `json:"requestId"`
    FromWalletID    string    `json:"fromWalletId"`
    ToAddress       string    `json:"toAddress"`
    Amount          float64   `json:"amount"`
    Status          string    `json:"status"`
    Timestamp       int64     `json:"timestamp"`
    TxHash          string    `json:"txHash,omitempty"`
}

// 2. Event handler
func (s *WalletService) HandleTransferEvent(ctx context.Context, event *TransferEvent) error {
    switch event.Type {
    case "TRANSFER_REQUESTED":
        return s.HandleTransferRequested(ctx, event)
    case "TRANSFER_REVIEWED":
        return s.HandleTransferReviewed(ctx, event)
    case "TRANSFER_EXECUTED":
        return s.HandleTransferExecuted(ctx, event)
    case "TRANSFER_FAILED":
        return s.HandleTransferFailed(ctx, event)
    default:
        return fmt.Errorf("unknown event type: %s", event.Type)
    }
}
```

## Security Measures

### 1. Request Validation
- Signature verification
- Amount limits
- Wallet status
- Address validation
- Rate limiting

### 2. Operator Review
- Multi-operator approval
- Time-based approval window
- Audit logging
- Permission checks

### 3. Execution Security
- Transaction signing
- Gas optimization
- Nonce management
- Error handling

### 4. Monitoring
- Event tracking
- Status updates
- Error alerts
- Compliance checks

## Error Handling

### 1. Request Failures
```go
type TransferError struct {
    Code        string `json:"code"`
    Message     string `json:"message"`
    RequestID   string `json:"requestId,omitempty"`
    Timestamp   int64  `json:"timestamp"`
}

func (s *WalletService) HandleTransferError(ctx context.Context, err *TransferError) error {
    // Log error
    if err := s.LogTransferError(ctx, err); err != nil {
        return fmt.Errorf("failed to log error: %w", err)
    }

    // Update request status
    if err.RequestID != "" {
        if err := s.UpdateTransferStatus(ctx, err.RequestID, "FAILED", ""); err != nil {
            return fmt.Errorf("failed to update status: %w", err)
        }
    }

    // Notify relevant parties
    if err := s.NotifyTransferError(ctx, err); err != nil {
        return fmt.Errorf("failed to send notification: %w", err)
    }

    return nil
}
```

### 2. Recovery Procedures
- Transaction retry mechanism
- State reconciliation
- Manual intervention process
- Emergency stop procedures

## Monitoring and Alerts

### 1. Key Metrics
- Transfer request volume
- Approval time
- Success rate
- Error rate
- Gas usage

### 2. Alert Conditions
- High error rate
- Long approval times
- Failed transactions
- Suspicious patterns
- Limit breaches

### 3. Reporting
- Daily transfer reports
- Error analysis
- Performance metrics
- Compliance reports 