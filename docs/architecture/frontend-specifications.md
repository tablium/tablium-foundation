# Tablium Frontend Specifications

## UI/UX Guidelines

### Color System
```typescript
const colors = {
  primary: {
    main: '#1E88E5',
    light: '#64B5F6',
    dark: '#1565C0',
    contrast: '#FFFFFF'
  },
  secondary: {
    main: '#FF4081',
    light: '#FF80AB',
    dark: '#C60055',
    contrast: '#FFFFFF'
  },
  success: {
    main: '#4CAF50',
    light: '#81C784',
    dark: '#388E3C',
    contrast: '#FFFFFF'
  },
  warning: {
    main: '#FFC107',
    light: '#FFD54F',
    dark: '#FFA000',
    contrast: '#000000'
  },
  error: {
    main: '#F44336',
    light: '#E57373',
    dark: '#D32F2F',
    contrast: '#FFFFFF'
  },
  grey: {
    50: '#FAFAFA',
    100: '#F5F5F5',
    200: '#EEEEEE',
    300: '#E0E0E0',
    400: '#BDBDBD',
    500: '#9E9E9E',
    600: '#757575',
    700: '#616161',
    800: '#424242',
    900: '#212121'
  }
}
```

### Typography
```typescript
const typography = {
  fontFamily: {
    primary: '"Inter", "Roboto", "Helvetica", "Arial", sans-serif',
    mono: '"Roboto Mono", monospace'
  },
  fontSize: {
    xs: '0.75rem',
    sm: '0.875rem',
    base: '1rem',
    lg: '1.125rem',
    xl: '1.25rem',
    '2xl': '1.5rem',
    '3xl': '1.875rem',
    '4xl': '2.25rem'
  },
  fontWeight: {
    light: 300,
    regular: 400,
    medium: 500,
    semibold: 600,
    bold: 700
  }
}
```

### Spacing System
```typescript
const spacing = {
  xs: '0.25rem',
  sm: '0.5rem',
  md: '1rem',
  lg: '1.5rem',
  xl: '2rem',
  '2xl': '3rem',
  '3xl': '4rem'
}
```

### Breakpoints
```typescript
const breakpoints = {
  xs: '320px',
  sm: '640px',
  md: '768px',
  lg: '1024px',
  xl: '1280px',
  '2xl': '1536px'
}
```

### Animation Durations
```typescript
const animations = {
  duration: {
    fast: '150ms',
    normal: '250ms',
    slow: '350ms',
    slower: '500ms'
  },
  easing: {
    easeInOut: 'cubic-bezier(0.4, 0, 0.2, 1)',
    easeOut: 'cubic-bezier(0.0, 0, 0.2, 1)',
    easeIn: 'cubic-bezier(0.4, 0, 1, 1)'
  }
}
```

## Component Specifications

### Game Table Component
```typescript
interface GameTableProps {
  tableId: string;
  maxPlayers: number;
  currentPlayers: Player[];
  blinds: {
    small: number;
    big: number;
    ante: number;
  };
  pot: number;
  communityCards: Card[];
  currentBet: number;
  activePlayer: string;
  onAction: (action: GameAction) => void;
}

interface Player {
  id: string;
  name: string;
  stack: number;
  position: number;
  cards?: Card[];
  isActive: boolean;
  lastAction?: GameAction;
}

interface Card {
  suit: 'hearts' | 'diamonds' | 'clubs' | 'spades';
  value: string;
  isVisible: boolean;
}

interface GameAction {
  type: 'fold' | 'check' | 'call' | 'raise' | 'all-in';
  amount?: number;
  playerId: string;
  timestamp: number;
}
```

### Tournament Lobby Component
```typescript
interface TournamentLobbyProps {
  tournaments: Tournament[];
  filters: TournamentFilters;
  onFilterChange: (filters: TournamentFilters) => void;
  onRegister: (tournamentId: string) => void;
  onUnregister: (tournamentId: string) => void;
}

interface Tournament {
  id: string;
  name: string;
  type: 'SNG' | 'MTT' | 'SATELLITE';
  startTime: Date;
  buyIn: number;
  prizePool: number;
  maxPlayers: number;
  currentPlayers: number;
  blindLevels: BlindLevel[];
  status: 'REGISTERING' | 'STARTING' | 'RUNNING' | 'COMPLETED';
}

interface BlindLevel {
  level: number;
  smallBlind: number;
  bigBlind: number;
  ante: number;
  duration: string;
}
```

## Routing Structure

### Admin System Routes
```typescript
const adminRoutes = {
  dashboard: {
    path: '/',
    component: DashboardPage,
    children: {
      overview: '/overview',
      analytics: '/analytics',
      alerts: '/alerts'
    }
  },
  tournaments: {
    path: '/tournaments',
    component: TournamentsPage,
    children: {
      list: '/list',
      create: '/create',
      edit: '/:id/edit',
      details: '/:id'
    }
  },
  players: {
    path: '/players',
    component: PlayersPage,
    children: {
      list: '/list',
      profile: '/:id',
      transactions: '/:id/transactions',
      kyc: '/:id/kyc'
    }
  },
  settings: {
    path: '/settings',
    component: SettingsPage,
    children: {
      general: '/general',
      security: '/security',
      integrations: '/integrations'
    }
  }
}
```

### Player System Routes
```typescript
const playerRoutes = {
  lobby: {
    path: '/',
    component: LobbyPage,
    children: {
      cashGames: '/cash-games',
      tournaments: '/tournaments',
      sitAndGo: '/sng'
    }
  },
  game: {
    path: '/game/:tableId',
    component: GamePage,
    children: {
      table: '/table',
      handHistory: '/history',
      chat: '/chat'
    }
  },
  tournament: {
    path: '/tournament/:tournamentId',
    component: TournamentPage,
    children: {
      lobby: '/lobby',
      table: '/table',
      results: '/results'
    }
  },
  wallet: {
    path: '/wallet',
    component: WalletPage,
    children: {
      balance: '/balance',
      deposit: '/deposit',
      withdraw: '/withdraw',
      transactions: '/transactions'
    }
  },
  profile: {
    path: '/profile',
    component: ProfilePage,
    children: {
      settings: '/settings',
      security: '/security',
      achievements: '/achievements'
    }
  }
}
```

## State Management Patterns

### Redux Store Structure
```typescript
interface RootState {
  auth: AuthState;
  game: GameState;
  tournament: TournamentState;
  wallet: WalletState;
  ui: UIState;
}

interface AuthState {
  user: User | null;
  token: string | null;
  isAuthenticated: boolean;
  loading: boolean;
  error: string | null;
}

interface GameState {
  activeTable: Table | null;
  players: Record<string, Player>;
  currentHand: Hand | null;
  handHistory: Hand[];
  chat: ChatMessage[];
  loading: boolean;
  error: string | null;
}

interface TournamentState {
  activeTournament: Tournament | null;
  tournaments: Tournament[];
  registrations: Record<string, TournamentRegistration>;
  results: Record<string, TournamentResult>;
  loading: boolean;
  error: string | null;
}

interface WalletState {
  balance: number;
  transactions: Transaction[];
  deposits: Deposit[];
  withdrawals: Withdrawal[];
  loading: boolean;
  error: string | null;
}

interface UIState {
  theme: 'light' | 'dark';
  sidebar: {
    isOpen: boolean;
    activeItem: string;
  };
  modals: {
    [key: string]: {
      isOpen: boolean;
      data: any;
    };
  };
  notifications: Notification[];
}
```

### Redux Actions
```typescript
// Game Actions
const gameActions = {
  joinTable: createAsyncThunk(
    'game/joinTable',
    async (tableId: string, { rejectWithValue }) => {
      try {
        const response = await api.joinTable(tableId);
        return response.data;
      } catch (error) {
        return rejectWithValue(error.response.data);
      }
    }
  ),
  
  leaveTable: createAsyncThunk(
    'game/leaveTable',
    async (tableId: string, { rejectWithValue }) => {
      try {
        const response = await api.leaveTable(tableId);
        return response.data;
      } catch (error) {
        return rejectWithValue(error.response.data);
      }
    }
  ),
  
  performAction: createAsyncThunk(
    'game/performAction',
    async (action: GameAction, { rejectWithValue }) => {
      try {
        const response = await api.performAction(action);
        return response.data;
      } catch (error) {
        return rejectWithValue(error.response.data);
      }
    }
  )
};

// Tournament Actions
const tournamentActions = {
  fetchTournaments: createAsyncThunk(
    'tournament/fetchTournaments',
    async (filters: TournamentFilters, { rejectWithValue }) => {
      try {
        const response = await api.getTournaments(filters);
        return response.data;
      } catch (error) {
        return rejectWithValue(error.response.data);
      }
    }
  ),
  
  registerTournament: createAsyncThunk(
    'tournament/register',
    async (tournamentId: string, { rejectWithValue }) => {
      try {
        const response = await api.registerTournament(tournamentId);
        return response.data;
      } catch (error) {
        return rejectWithValue(error.response.data);
      }
    }
  )
};
```

### Redux Reducers
```typescript
const gameReducer = createReducer(initialState, (builder) => {
  builder
    .addCase(gameActions.joinTable.pending, (state) => {
      state.loading = true;
      state.error = null;
    })
    .addCase(gameActions.joinTable.fulfilled, (state, action) => {
      state.loading = false;
      state.activeTable = action.payload;
    })
    .addCase(gameActions.joinTable.rejected, (state, action) => {
      state.loading = false;
      state.error = action.payload.message;
    })
    .addCase(gameActions.performAction.fulfilled, (state, action) => {
      state.currentHand = action.payload;
    });
});

const tournamentReducer = createReducer(initialState, (builder) => {
  builder
    .addCase(tournamentActions.fetchTournaments.pending, (state) => {
      state.loading = true;
      state.error = null;
    })
    .addCase(tournamentActions.fetchTournaments.fulfilled, (state, action) => {
      state.loading = false;
      state.tournaments = action.payload;
    })
    .addCase(tournamentActions.fetchTournaments.rejected, (state, action) => {
      state.loading = false;
      state.error = action.payload.message;
    });
});
```

### Custom Hooks
```typescript
// Game Hook
const useGame = (tableId: string) => {
  const dispatch = useAppDispatch();
  const { activeTable, currentHand, loading, error } = useAppSelector(
    (state) => state.game
  );

  const joinTable = useCallback(() => {
    dispatch(gameActions.joinTable(tableId));
  }, [dispatch, tableId]);

  const performAction = useCallback((action: GameAction) => {
    dispatch(gameActions.performAction(action));
  }, [dispatch]);

  return {
    activeTable,
    currentHand,
    loading,
    error,
    joinTable,
    performAction
  };
};

// Tournament Hook
const useTournament = (tournamentId: string) => {
  const dispatch = useAppDispatch();
  const { activeTournament, loading, error } = useAppSelector(
    (state) => state.tournament
  );

  const register = useCallback(() => {
    dispatch(tournamentActions.registerTournament(tournamentId));
  }, [dispatch, tournamentId]);

  return {
    activeTournament,
    loading,
    error,
    register
  };
};
``` 