# Tablium Project Overview

## Introduction

Tablium is an online platform for table and board games, starting with Dominoes as the MVP. The platform will be blockchain-based, utilizing a token system for in-game transactions. The MVP will focus on Sit'n Go format games, similar to popular poker platforms, with tournament support planned for future releases.

## MVP Features

### Core Features
1. User Authentication and Wallet Integration
   - User registration and login
   - Blockchain wallet integration
   - Token balance management
   - User statistics and history

2. Dominoes Game (Sit'n Go Format)
   - Real-time multiplayer gameplay
   - Automatic table creation when seats are filled
   - Configurable buy-in amounts
   - Blind structure (similar to poker)
   - Table balancing and merging
   - In-game chat
   - Player statistics and rankings

3. Token Economy
   - Token purchase and withdrawal
   - Buy-in system
   - Prize pool distribution
   - Transaction history
   - Rake system (platform fee)

### Technical Requirements

#### Backend (Render)
- Node.js/TypeScript API
- WebSocket server for real-time gameplay
- PostgreSQL database
- Redis for caching and session management
- Blockchain integration layer
- Table management system
- Player matching system

#### Frontend (Vercel)
- React/Next.js application
- Web3 integration
- Real-time game interface
- Responsive design
- Progressive Web App (PWA) support
- Table lobby interface
- Player statistics dashboard

## Infrastructure Planning

### Cloud Platform Comparison

#### Backend (Render)
Pros:
- Free tier available
- Easy deployment
- Built-in PostgreSQL
- Automatic HTTPS
- Good for Node.js applications

Cons:
- Limited free tier resources
- No built-in WebSocket support in free tier
- Limited scaling options

#### Frontend (Vercel)
Pros:
- Excellent for Next.js applications
- Automatic deployments
- Great performance
- Free tier available
- Built-in analytics

Cons:
- Limited server-side capabilities
- Cold starts on free tier

## Development Phases

### Phase 1: Foundation (2 weeks)
- Project setup and documentation
- Basic user authentication
- Database schema design
- Blockchain integration setup
- Table management system design

### Phase 2: Core Game Logic (3 weeks)
- Dominoes game implementation
- WebSocket server setup
- Real-time gameplay mechanics
- Basic UI implementation
- Table lobby system
- Player matching system

### Phase 3: Token Integration (2 weeks)
- Wallet integration
- Token transaction system
- Buy-in system
- Prize pool distribution
- Rake system implementation

### Phase 4: Polish and Testing (2 weeks)
- UI/UX improvements
- Performance optimization
- Security audit
- Testing and bug fixes
- Table balancing optimization

## Future Features (Post-MVP)
1. Tournament System
   - Scheduled tournaments
   - Multi-table tournaments
   - Satellite tournaments
   - Tournament lobby
   - Tournament statistics

2. Advanced Features
   - Leaderboards
   - Achievement system
   - Social features
   - Mobile app
   - More game variants

## Cost Estimation

### Monthly Costs (MVP)
- Render (Backend): $7-15/month
- Vercel (Frontend): Free tier
- Database: Included in Render
- Blockchain: Gas fees only
- Total: ~$15-20/month

## Next Steps

1. Set up development environment
2. Create initial project structure
3. Implement basic authentication
4. Develop table management system
5. Implement core game logic
6. Integrate blockchain functionality 