# Error Handling Standards

## Overview
This document establishes consistent error handling patterns and standards across all Tablium services. These standards ensure uniform error reporting, proper error categorization, and effective error recovery mechanisms.

## Error Types and Categories

### Core Error Types
```go
type TabliumError struct {
    Code        string                 `json:"code"`
    Status      int                    `json:"status"`
    Message     string                 `json:"message"`
    Details     map[string]interface{} `json:"details,omitempty"`
    Timestamp   time.Time             `json:"timestamp"`
    TraceID     string                `json:"traceId"`
    Service     string                `json:"service"`
    Severity    ErrorSeverity         `json:"severity"`
    Category    ErrorCategory         `json:"category"`
}

type ErrorSeverity int

const (
    SeverityInfo ErrorSeverity = iota
    SeverityWarning
    SeverityError
    SeverityCritical
)

type ErrorCategory int

const (
    CategoryValidation ErrorCategory = iota
    CategoryAuthentication
    CategoryAuthorization
    CategoryBusinessLogic
    CategoryInfrastructure
    CategoryExternal
    CategorySecurity
)
```

### HTTP Status Code Mapping

| Error Category | Status Code | Description |
|---------------|-------------|-------------|
| Validation | 400 | Bad Request - Invalid input data |
| Authentication | 401 | Unauthorized - Invalid or missing credentials |
| Authorization | 403 | Forbidden - Insufficient permissions |
| Business Logic | 422 | Unprocessable Entity - Business rule violation |
| Infrastructure | 500 | Internal Server Error - System-level issues |
| External | 502 | Bad Gateway - External service issues |
| Security | 403/401 | Security-related issues |

## Error Response Format

### Standard Error Response
```json
{
    "error": {
        "code": "VALIDATION_ERROR",
        "status": 400,
        "message": "Invalid input parameters",
        "details": {
            "field": "email",
            "reason": "Invalid email format"
        },
        "timestamp": "2024-03-18T12:34:56.789Z",
        "traceId": "trace-123456",
        "service": "user-service",
        "severity": "ERROR",
        "category": "VALIDATION"
    }
}
```

## Error Handling Implementation

### Service Layer Error Handling
```go
type ServiceErrorHandler struct {
    Logger    *Logger
    Metrics   *MetricsCollector
    Tracer    *Tracer
}

func (h *ServiceErrorHandler) HandleError(err error) *TabliumError {
    // 1. Convert to TabliumError if needed
    tabliumErr := h.convertToTabliumError(err)
    
    // 2. Add tracing information
    tabliumErr.TraceID = h.Tracer.GetCurrentTraceID()
    
    // 3. Log error with appropriate severity
    h.Logger.LogError(tabliumErr)
    
    // 4. Record metrics
    h.Metrics.RecordError(tabliumErr)
    
    return tabliumErr
}
```

### HTTP Handler Error Handling
```go
func (h *Handler) handleError(w http.ResponseWriter, err error) {
    // 1. Convert to TabliumError
    tabliumErr := h.serviceErrorHandler.HandleError(err)
    
    // 2. Set appropriate status code
    w.WriteHeader(tabliumErr.Status)
    
    // 3. Write error response
    json.NewEncoder(w).Encode(map[string]interface{}{
        "error": tabliumErr,
    })
}
```

## Error Recovery Strategies

### Circuit Breaking
```go
type CircuitBreaker struct {
    Threshold     int
    Timeout       time.Duration
    HalfOpenState bool
    Failures      int
    LastFailure   time.Time
}

func (cb *CircuitBreaker) Execute(operation func() error) error {
    if cb.IsOpen() {
        return ErrCircuitOpen
    }
    
    err := operation()
    if err != nil {
        cb.RecordFailure()
        return err
    }
    
    cb.RecordSuccess()
    return nil
}
```

### Retry Strategy
```go
type RetryStrategy struct {
    MaxAttempts   int
    InitialDelay  time.Duration
    MaxDelay      time.Duration
    BackoffFactor float64
}

func (rs *RetryStrategy) Execute(operation func() error) error {
    var lastErr error
    delay := rs.InitialDelay
    
    for attempt := 1; attempt <= rs.MaxAttempts; attempt++ {
        err := operation()
        if err == nil {
            return nil
        }
        
        lastErr = err
        if !rs.ShouldRetry(err) {
            return err
        }
        
        time.Sleep(delay)
        delay = time.Duration(float64(delay) * rs.BackoffFactor)
        if delay > rs.MaxDelay {
            delay = rs.MaxDelay
        }
    }
    
    return lastErr
}
```

## Error Monitoring and Alerting

### Error Metrics
```go
type ErrorMetrics struct {
    ErrorCount    *prometheus.CounterVec
    ErrorLatency  *prometheus.HistogramVec
    ErrorSeverity *prometheus.GaugeVec
}

func (m *ErrorMetrics) RecordError(err *TabliumError) {
    labels := prometheus.Labels{
        "service":  err.Service,
        "category": err.Category.String(),
        "severity": err.Severity.String(),
    }
    
    m.ErrorCount.With(labels).Inc()
    m.ErrorSeverity.With(labels).Set(float64(err.Severity))
}
```

### Alert Rules
```yaml
groups:
  - name: error_alerts
    rules:
      - alert: HighErrorRate
        expr: rate(error_count_total[5m]) > 0.1
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: High error rate detected
          description: Service {{ $labels.service }} has high error rate
          
      - alert: CriticalErrors
        expr: error_severity_total{severity="critical"} > 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: Critical errors detected
          description: Critical errors in service {{ $labels.service }}
```

## Best Practices

1. **Error Context**
   - Always include relevant context in error messages
   - Use structured logging for error details
   - Include trace IDs for request tracing

2. **Error Recovery**
   - Implement appropriate retry strategies
   - Use circuit breakers for external service calls
   - Implement graceful degradation

3. **Security**
   - Never expose sensitive information in error messages
   - Log security-related errors separately
   - Implement proper error handling for authentication/authorization failures

4. **Monitoring**
   - Track error rates and patterns
   - Set up appropriate alerts
   - Monitor error recovery success rates

5. **Documentation**
   - Document all error codes and their meanings
   - Include error handling examples in API documentation
   - Maintain a list of known error scenarios and their resolutions

## Implementation Checklist

- [ ] Implement core error types and interfaces
- [ ] Set up error logging and monitoring
- [ ] Configure error alerts and notifications
- [ ] Implement retry and circuit breaker patterns
- [ ] Add error handling middleware
- [ ] Document error codes and scenarios
- [ ] Set up error tracking and analytics
- [ ] Implement error recovery procedures
- [ ] Add error handling tests
- [ ] Review and update error handling documentation 