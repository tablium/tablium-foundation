# Tablium Frontend Architecture

## Overview

The Tablium platform consists of two separate frontend applications:

1. **Tablium Admin** - Administrative interface for platform management
2. **Tablium Player** - Player interface for game participation

## Technology Stack

### Common Technologies
- **Framework**: React with TypeScript
- **State Management**: Redux Toolkit
- **Styling**: Tailwind CSS
- **UI Components**: Material-UI
- **API Client**: Axios
- **WebSocket**: Socket.IO Client
- **Testing**: Jest + React Testing Library
- **Build Tool**: Vite

### Additional Technologies
- **Admin System**:
  - React Router for navigation
  - React Query for data fetching
  - Chart.js for analytics
  - React Grid Layout for dashboards
  - React Table for data tables

- **Player System**:
  - React Router for navigation
  - React Query for data fetching
  - Canvas/WebGL for game rendering
  - Howler.js for audio
  - React DnD for drag-and-drop

## Admin System Architecture

### Core Features
1. **Authentication & Authorization**
   - Role-based access control
   - Multi-factor authentication
   - Session management

2. **Dashboard**
   - Real-time platform metrics
   - Active games/tournaments
   - Player statistics
   - Revenue analytics
   - System health monitoring

3. **Tournament Management**
   - Tournament creation/editing
   - Schedule management
   - Prize pool configuration
   - Blind level settings
   - Results processing

4. **Player Management**
   - Player profiles
   - Account status
   - Transaction history
   - KYC verification
   - Ban management

5. **Game Management**
   - Table configuration
   - Blind level settings
   - Rake settings
   - Game rules
   - Anti-cheat monitoring

6. **Financial Management**
   - Transaction monitoring
   - Rake reports
   - Payout processing
   - Financial analytics
   - Audit logs

7. **System Configuration**
   - Platform settings
   - API management
   - Integration settings
   - Notification rules
   - System logs

### Component Structure
```
src/
├── components/
│   ├── common/
│   │   ├── Header/
│   │   ├── Sidebar/
│   │   ├── Footer/
│   │   └── Loading/
│   ├── dashboard/
│   │   ├── Metrics/
│   │   ├── Charts/
│   │   └── Alerts/
│   ├── tournaments/
│   │   ├── List/
│   │   ├── Create/
│   │   └── Details/
│   ├── players/
│   │   ├── List/
│   │   ├── Profile/
│   │   └── Transactions/
│   └── settings/
│       ├── General/
│       ├── Security/
│       └── Integrations/
├── pages/
├── hooks/
├── services/
├── store/
├── utils/
└── types/
```

## Player System Architecture

### Core Features
1. **Authentication & Profile**
   - Login/Registration
   - Profile management
   - Wallet integration
   - KYC verification
   - Security settings

2. **Lobby System**
   - Game type selection
   - Table browsing
   - Buy-in options
   - Player filtering
   - Quick join

3. **Game Interface**
   - Table view
   - Player actions
   - Hand history
   - Chat system
   - Time bank
   - Sound effects

4. **Tournament Interface**
   - Tournament lobby
   - Registration
   - Blind level display
   - Prize pool info
   - Player rankings
   - Break timer

5. **Wallet & Transactions**
   - Balance display
   - Deposit/Withdrawal
   - Transaction history
   - Bonus management
   - Rakeback tracking

6. **Social Features**
   - Friends list
   - Chat system
   - Player notes
   - Achievement system
   - Leaderboards

### Component Structure
```
src/
├── components/
│   ├── common/
│   │   ├── Header/
│   │   ├── Navigation/
│   │   └── Loading/
│   ├── lobby/
│   │   ├── GameList/
│   │   ├── TableList/
│   │   └── QuickJoin/
│   ├── game/
│   │   ├── Table/
│   │   ├── Player/
│   │   ├── Actions/
│   │   └── Chat/
│   ├── tournament/
│   │   ├── Lobby/
│   │   ├── Registration/
│   │   └── Results/
│   └── wallet/
│       ├── Balance/
│       ├── Transactions/
│       └── Deposit/
├── pages/
├── hooks/
├── services/
├── store/
├── utils/
└── types/
```

## Shared Components

### Common UI Elements
1. **Buttons**
   - Primary/Secondary actions
   - Icon buttons
   - Loading states
   - Disabled states

2. **Forms**
   - Input fields
   - Select dropdowns
   - Checkboxes
   - Radio buttons
   - Form validation

3. **Tables**
   - Sortable columns
   - Pagination
   - Row selection
   - Custom cells

4. **Modals**
   - Confirmation dialogs
   - Form modals
   - Alert messages
   - Loading states

5. **Notifications**
   - Toast messages
   - Alert banners
   - Status indicators
   - Progress bars

### Shared Utilities
1. **API Client**
   - Request/Response interceptors
   - Error handling
   - Retry logic
   - Cache management

2. **State Management**
   - Redux store setup
   - Action creators
   - Reducers
   - Middleware

3. **WebSocket Client**
   - Connection management
   - Event handling
   - Reconnection logic
   - Message queuing

4. **Authentication**
   - Token management
   - Session handling
   - Permission checks
   - Role validation

## Security Considerations

1. **Data Protection**
   - HTTPS enforcement
   - XSS prevention
   - CSRF protection
   - Input sanitization

2. **Authentication**
   - JWT management
   - Refresh tokens
   - Session timeout
   - Device fingerprinting

3. **Authorization**
   - Role-based access
   - Permission checks
   - Resource protection
   - API security

4. **Monitoring**
   - Error tracking
   - Performance monitoring
   - Security logging
   - User activity tracking

## Performance Optimization

1. **Code Splitting**
   - Route-based splitting
   - Component lazy loading
   - Dynamic imports
   - Bundle optimization

2. **Caching**
   - API response caching
   - Static asset caching
   - State persistence
   - Local storage

3. **Rendering**
   - Virtual scrolling
   - Infinite loading
   - Debouncing
   - Throttling

4. **Asset Management**
   - Image optimization
   - Font loading
   - Resource preloading
   - CDN integration

## Development Workflow

1. **Version Control**
   - Feature branches
   - Pull requests
   - Code review
   - CI/CD pipeline

2. **Testing**
   - Unit tests
   - Integration tests
   - E2E tests
   - Performance tests

3. **Deployment**
   - Staging environment
   - Production deployment
   - Rollback strategy
   - Monitoring

4. **Documentation**
   - Component docs
   - API documentation
   - Style guide
   - Development guide 