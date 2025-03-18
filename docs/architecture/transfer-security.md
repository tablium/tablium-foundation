# Transfer Security and Verification

## 1. Rule Evaluation Logic

### 1.1 Rule Engine
```go
type RuleEngine struct {
    Rules       []ReviewRule
    Conditions  map[string]ConditionEvaluator
    Actions     map[string]ActionExecutor
}

type ConditionEvaluator interface {
    Evaluate(ctx context.Context, request *TransferRequest) (bool, error)
}

type ActionExecutor interface {
    Execute(ctx context.Context, request *TransferRequest) error
}

func (e *RuleEngine) EvaluateRequest(ctx context.Context, request *TransferRequest) (*ReviewResult, error) {
    // Sort rules by priority
    sort.Slice(e.Rules, func(i, j int) bool {
        return e.Rules[i].Priority > e.Rules[j].Priority
    })

    // Evaluate each rule
    for _, rule := range e.Rules {
        if !rule.IsEnabled {
            continue
        }

        // Parse and evaluate conditions
        conditions := strings.Split(rule.Condition, "&&")
        allConditionsMet := true

        for _, condition := range conditions {
            condition = strings.TrimSpace(condition)
            evaluator, exists := e.Conditions[condition]
            if !exists {
                return nil, fmt.Errorf("unknown condition: %s", condition)
            }

            met, err := evaluator.Evaluate(ctx, request)
            if err != nil {
                return nil, fmt.Errorf("failed to evaluate condition: %w", err)
            }

            if !met {
                allConditionsMet = false
                break
            }
        }

        if allConditionsMet {
            // Execute action
            executor, exists := e.Actions[rule.Action]
            if !exists {
                return nil, fmt.Errorf("unknown action: %s", rule.Action)
            }

            if err := executor.Execute(ctx, request); err != nil {
                return nil, fmt.Errorf("failed to execute action: %w", err)
            }

            return &ReviewResult{
                Status: rule.Action,
                RuleID: rule.ID,
            }, nil
        }
    }

    return &ReviewResult{
        Status: "PENDING_MANUAL_REVIEW",
    }, nil
}
```

### 1.2 Condition Evaluators
```go
// Amount condition
type AmountCondition struct {
    MaxAmount float64
    MinAmount float64
}

func (c *AmountCondition) Evaluate(ctx context.Context, request *TransferRequest) (bool, error) {
    return request.Amount >= c.MinAmount && request.Amount <= c.MaxAmount, nil
}

// Whitelist condition
type WhitelistCondition struct {
    Service *WalletService
}

func (c *WhitelistCondition) Evaluate(ctx context.Context, request *TransferRequest) (bool, error) {
    return c.Service.IsAddressWhitelisted(ctx, request.FromWalletID, request.ToAddress)
}

// Risk score condition
type RiskScoreCondition struct {
    MaxRiskScore float64
    Service      *RiskService
}

func (c *RiskScoreCondition) Evaluate(ctx context.Context, request *TransferRequest) (bool, error) {
    score, err := c.Service.GetRiskScore(ctx, request.FromWalletID)
    if err != nil {
        return false, err
    }
    return score <= c.MaxRiskScore, nil
}
```

## 2. Alert Threshold Configuration

### 2.1 Alert Configuration
```go
type AlertThresholds struct {
    ErrorRate struct {
        Warning  float64 `json:"warning"`
        Critical float64 `json:"critical"`
    } `json:"errorRate"`
    ResponseTime struct {
        Warning  time.Duration `json:"warning"`
        Critical time.Duration `json:"critical"`
    } `json:"responseTime"`
    Volume struct {
        Warning  float64 `json:"warning"`
        Critical float64 `json:"critical"`
    } `json:"volume"`
    RiskScore struct {
        Warning  float64 `json:"warning"`
        Critical float64 `json:"critical"`
    } `json:"riskScore"`
}

type AlertConfig struct {
    Thresholds     AlertThresholds `json:"thresholds"`
    CheckInterval  time.Duration   `json:"checkInterval"`
    NotificationChannels []string   `json:"notificationChannels"`
    EscalationLevels     []string   `json:"escalationLevels"`
}

func (s *WalletService) ConfigureAlerts(ctx context.Context, config *AlertConfig) error {
    // Validate thresholds
    if err := s.ValidateAlertThresholds(config.Thresholds); err != nil {
        return fmt.Errorf("invalid alert thresholds: %w", err)
    }

    // Update configuration
    s.alertConfig = config

    // Start monitoring
    go s.MonitorAndAlert(ctx, config)

    return nil
}
```

### 2.2 Alert Processing
```go
func (s *WalletService) ProcessAlert(ctx context.Context, alert *Alert) error {
    // Determine severity
    severity := s.DetermineAlertSeverity(alert)

    // Get notification channels
    channels := s.GetNotificationChannels(severity)

    // Send notifications
    for _, channel := range channels {
        if err := s.SendNotification(ctx, alert, channel); err != nil {
            log.Printf("Failed to send notification to %s: %v", channel, err)
        }
    }

    // Escalate if necessary
    if severity == "CRITICAL" {
        if err := s.EscalateAlert(ctx, alert); err != nil {
            return fmt.Errorf("failed to escalate alert: %w", err)
        }
    }

    return nil
}
```

## 3. Event Processing Pipeline

### 3.1 Event Pipeline
```go
type EventPipeline struct {
    PreProcessors  []EventProcessor
    MainProcessor  EventProcessor
    PostProcessors []EventProcessor
    ErrorHandler   EventErrorHandler
}

type EventProcessor interface {
    Process(ctx context.Context, event *TransferEvent) error
}

func (p *EventPipeline) ProcessEvent(ctx context.Context, event *TransferEvent) error {
    // Pre-processing
    for _, processor := range p.PreProcessors {
        if err := processor.Process(ctx, event); err != nil {
            return p.ErrorHandler.HandleError(ctx, event, err)
        }
    }

    // Main processing
    if err := p.MainProcessor.Process(ctx, event); err != nil {
        return p.ErrorHandler.HandleError(ctx, event, err)
    }

    // Post-processing
    for _, processor := range p.PostProcessors {
        if err := processor.Process(ctx, event); err != nil {
            return p.ErrorHandler.HandleError(ctx, event, err)
        }
    }

    return nil
}
```

### 3.2 Event Processors
```go
// Validation processor
type ValidationProcessor struct {
    Validator EventValidator
}

func (p *ValidationProcessor) Process(ctx context.Context, event *TransferEvent) error {
    return p.Validator.Validate(ctx, event)
}

// Enrichment processor
type EnrichmentProcessor struct {
    Enricher EventEnricher
}

func (p *EnrichmentProcessor) Process(ctx context.Context, event *TransferEvent) error {
    return p.Enricher.Enrich(ctx, event)
}

// Notification processor
type NotificationProcessor struct {
    Notifier EventNotifier
}

func (p *NotificationProcessor) Process(ctx context.Context, event *TransferEvent) error {
    return p.Notifier.Notify(ctx, event)
}
```

## 4. State Reconciliation Process

### 4.1 Reconciliation Service
```go
type ReconciliationService struct {
    OnChainState    StateProvider
    OffChainState   StateProvider
    DiscrepancyLog  DiscrepancyLogger
    Reconciliation  ReconciliationExecutor
}

type StateProvider interface {
    GetState(ctx context.Context, walletID string) (*WalletState, error)
}

func (s *ReconciliationService) Reconcile(ctx context.Context, walletID string) error {
    // Get states
    onChain, err := s.OnChainState.GetState(ctx, walletID)
    if err != nil {
        return fmt.Errorf("failed to get on-chain state: %w", err)
    }

    offChain, err := s.OffChainState.GetState(ctx, walletID)
    if err != nil {
        return fmt.Errorf("failed to get off-chain state: %w", err)
    }

    // Compare states
    discrepancies := s.CompareStates(onChain, offChain)
    if len(discrepancies) > 0 {
        // Log discrepancies
        if err := s.DiscrepancyLog.Log(ctx, walletID, discrepancies); err != nil {
            return fmt.Errorf("failed to log discrepancies: %w", err)
        }

        // Execute reconciliation
        if err := s.Reconciliation.Execute(ctx, walletID, discrepancies); err != nil {
            return fmt.Errorf("failed to execute reconciliation: %w", err)
        }
    }

    return nil
}
```

## 5. Transfer Confirmation System

### 5.1 Multi-Factor Authentication
```go
type MFAConfig struct {
    Methods []string `json:"methods"` // "SMS", "EMAIL", "AUTHENTICATOR"
    RequiredMethods int `json:"requiredMethods"`
    Timeout time.Duration `json:"timeout"`
}

type MFAService struct {
    Config MFAConfig
    SMSProvider SMSProvider
    EmailProvider EmailProvider
    AuthenticatorProvider AuthenticatorProvider
}

func (s *MFAService) RequestConfirmation(ctx context.Context, transfer *TransferRequest) error {
    // Generate verification codes
    codes := make(map[string]string)
    
    for _, method := range s.Config.Methods {
        code, err := s.GenerateVerificationCode()
        if err != nil {
            return fmt.Errorf("failed to generate code: %w", err)
        }
        codes[method] = code
    }

    // Send verification codes
    for method, code := range codes {
        switch method {
        case "SMS":
            if err := s.SMSProvider.Send(ctx, transfer.PhoneNumber, code); err != nil {
                return fmt.Errorf("failed to send SMS: %w", err)
            }
        case "EMAIL":
            if err := s.EmailProvider.Send(ctx, transfer.Email, code); err != nil {
                return fmt.Errorf("failed to send email: %w", err)
            }
        case "AUTHENTICATOR":
            if err := s.AuthenticatorProvider.Generate(ctx, transfer.UserID, code); err != nil {
                return fmt.Errorf("failed to generate authenticator code: %w", err)
            }
        }
    }

    // Store verification state
    if err := s.StoreVerificationState(ctx, transfer.ID, codes); err != nil {
        return fmt.Errorf("failed to store verification state: %w", err)
    }

    return nil
}
```

### 5.2 Verification Process
```go
func (s *MFAService) VerifyConfirmation(ctx context.Context, transferID string, verifications map[string]string) error {
    // Get verification state
    state, err := s.GetVerificationState(ctx, transferID)
    if err != nil {
        return fmt.Errorf("failed to get verification state: %w", err)
    }

    // Check timeout
    if time.Since(state.CreatedAt) > s.Config.Timeout {
        return fmt.Errorf("verification timeout")
    }

    // Verify codes
    verifiedMethods := 0
    for method, code := range verifications {
        if state.Codes[method] == code {
            verifiedMethods++
        }
    }

    // Check if enough methods are verified
    if verifiedMethods < s.Config.RequiredMethods {
        return fmt.Errorf("insufficient verification methods")
    }

    // Update transfer status
    if err := s.UpdateTransferStatus(ctx, transferID, "VERIFIED"); err != nil {
        return fmt.Errorf("failed to update transfer status: %w", err)
    }

    return nil
}
```

### 5.3 Integration with Transfer Process
```go
func (s *WalletService) ProcessTransferWithConfirmation(ctx context.Context, request *TransferRequest) error {
    // Request MFA confirmation
    if err := s.mfaService.RequestConfirmation(ctx, request); err != nil {
        return fmt.Errorf("failed to request confirmation: %w", err)
    }

    // Wait for confirmation
    confirmed, err := s.WaitForConfirmation(ctx, request.ID, s.config.ConfirmationTimeout)
    if err != nil {
        return fmt.Errorf("failed to wait for confirmation: %w", err)
    }

    if !confirmed {
        return fmt.Errorf("transfer not confirmed")
    }

    // Process transfer
    return s.ProcessTransfer(ctx, request)
}
```

### 5.4 Notification Templates
```go
type NotificationTemplate struct {
    Type        string            `json:"type"`
    Subject     string            `json:"subject"`
    Body        string            `json:"body"`
    Variables   []string          `json:"variables"`
}

var TransferTemplates = map[string]NotificationTemplate{
    "SMS": {
        Type: "SMS",
        Body: "Your Tablium transfer verification code is: {{.Code}}. Valid for {{.Timeout}} minutes.",
        Variables: []string{"Code", "Timeout"},
    },
    "EMAIL": {
        Type: "EMAIL",
        Subject: "Tablium Transfer Confirmation",
        Body: `
            <h2>Transfer Confirmation</h2>
            <p>Your transfer verification code is: <strong>{{.Code}}</strong></p>
            <p>This code will expire in {{.Timeout}} minutes.</p>
            <p>If you didn't request this transfer, please contact support immediately.</p>
        `,
        Variables: []string{"Code", "Timeout"},
    },
}
``` 