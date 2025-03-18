# Tablium Frontend Features

## UI/UX Guidelines for Specific Features

### Game Table Interface
```typescript
interface GameTableStyles {
  // Table Layout
  tableSize: {
    width: '800px',
    height: '600px',
    borderRadius: '50%',
    backgroundColor: colors.grey[800],
    border: `2px solid ${colors.grey[700]}`
  },
  
  // Player Positions
  playerPositions: {
    positions: {
      bottom: { top: '85%', left: '50%' },
      bottomRight: { top: '70%', left: '85%' },
      right: { top: '50%', left: '85%' },
      topRight: { top: '30%', left: '85%' },
      top: { top: '15%', left: '50%' },
      topLeft: { top: '30%', left: '15%' },
      left: { top: '50%', left: '15%' },
      bottomLeft: { top: '70%', left: '15%' }
    },
    playerCard: {
      width: '120px',
      height: '160px',
      borderRadius: '8px',
      backgroundColor: colors.grey[900],
      boxShadow: '0 4px 6px rgba(0, 0, 0, 0.1)'
    }
  },

  // Action Buttons
  actionButtons: {
    container: {
      position: 'absolute',
      bottom: '20px',
      left: '50%',
      transform: 'translateX(-50%)',
      display: 'flex',
      gap: spacing.md
    },
    button: {
      padding: `${spacing.sm} ${spacing.lg}`,
      borderRadius: '4px',
      fontSize: typography.fontSize.base,
      fontWeight: typography.fontWeight.medium,
      transition: `all ${animations.duration.normal} ${animations.easing.easeInOut}`
    }
  },

  // Pot Display
  potDisplay: {
    container: {
      position: 'absolute',
      top: '50%',
      left: '50%',
      transform: 'translate(-50%, -50%)',
      backgroundColor: colors.grey[900],
      padding: spacing.md,
      borderRadius: '4px',
      boxShadow: '0 2px 4px rgba(0, 0, 0, 0.2)'
    },
    amount: {
      fontSize: typography.fontSize['2xl'],
      fontWeight: typography.fontWeight.bold,
      color: colors.primary.main
    }
  }
}
```

### Tournament Lobby Interface
```typescript
interface TournamentLobbyStyles {
  // Tournament List
  listContainer: {
    display: 'grid',
    gridTemplateColumns: 'repeat(auto-fill, minmax(300px, 1fr))',
    gap: spacing.lg,
    padding: spacing.lg
  },
  
  // Tournament Card
  card: {
    container: {
      backgroundColor: colors.grey[800],
      borderRadius: '8px',
      padding: spacing.lg,
      transition: `transform ${animations.duration.normal} ${animations.easing.easeInOut}`,
      '&:hover': {
        transform: 'translateY(-4px)'
      }
    },
    header: {
      display: 'flex',
      justifyContent: 'space-between',
      alignItems: 'center',
      marginBottom: spacing.md
    },
    title: {
      fontSize: typography.fontSize.xl,
      fontWeight: typography.fontWeight.semibold
    },
    status: {
      padding: `${spacing.xs} ${spacing.sm}`,
      borderRadius: '4px',
      fontSize: typography.fontSize.sm
    }
  },

  // Filters
  filters: {
    container: {
      position: 'sticky',
      top: 0,
      backgroundColor: colors.grey[900],
      padding: spacing.md,
      borderBottom: `1px solid ${colors.grey[700]}`
    },
    group: {
      display: 'flex',
      gap: spacing.md,
      alignItems: 'center'
    }
  }
}
```

## Additional State Management Patterns

### Chat System State
```typescript
interface ChatState {
  messages: ChatMessage[];
  activeChats: Record<string, ChatRoom>;
  unreadCounts: Record<string, number>;
  typingStatus: Record<string, boolean>;
  settings: ChatSettings;
  loading: boolean;
  error: string | null;
}

interface ChatMessage {
  id: string;
  senderId: string;
  content: string;
  timestamp: number;
  type: 'text' | 'system' | 'action';
  metadata?: {
    action?: GameAction;
    system?: SystemMessage;
    attachments?: Attachment[];
  };
}

interface ChatRoom {
  id: string;
  type: 'table' | 'tournament' | 'private';
  participants: string[];
  lastMessage?: ChatMessage;
  isMuted: boolean;
  settings: ChatRoomSettings;
}

interface ChatSettings {
  soundEnabled: boolean;
  notificationsEnabled: boolean;
  autoScroll: boolean;
  messageRetention: number;
  language: string;
  emojiEnabled: boolean;
  profanityFilter: boolean;
}

interface ChatRoomSettings {
  isMuted: boolean;
  notifications: boolean;
  pinned: boolean;
  readReceipts: boolean;
}

const chatActions = {
  sendMessage: createAsyncThunk(
    'chat/sendMessage',
    async (message: Omit<ChatMessage, 'id' | 'timestamp'>, { rejectWithValue }) => {
      try {
        const response = await api.sendChatMessage(message);
        return response.data;
      } catch (error) {
        return rejectWithValue(error.response.data);
      }
    }
  ),
  
  markAsRead: createAsyncThunk(
    'chat/markAsRead',
    async (chatId: string, { rejectWithValue }) => {
      try {
        const response = await api.markChatAsRead(chatId);
        return response.data;
      } catch (error) {
        return rejectWithValue(error.response.data);
      }
    }
  ),
  
  updateSettings: createAsyncThunk(
    'chat/updateSettings',
    async (settings: Partial<ChatSettings>, { rejectWithValue }) => {
      try {
        const response = await api.updateChatSettings(settings);
        return response.data;
      } catch (error) {
        return rejectWithValue(error.response.data);
      }
    }
  ),
  
  updateRoomSettings: createAsyncThunk(
    'chat/updateRoomSettings',
    async ({ chatId, settings }: { chatId: string; settings: Partial<ChatRoomSettings> }, { rejectWithValue }) => {
      try {
        const response = await api.updateChatRoomSettings(chatId, settings);
        return response.data;
      } catch (error) {
        return rejectWithValue(error.response.data);
      }
    }
  )
};

const chatReducer = createReducer(initialState, (builder) => {
  builder
    .addCase(chatActions.sendMessage.fulfilled, (state, action) => {
      const { chatId, message } = action.payload;
      state.messages.push(message);
      state.activeChats[chatId].lastMessage = message;
      state.unreadCounts[chatId] = (state.unreadCounts[chatId] || 0) + 1;
    })
    .addCase(chatActions.markAsRead.fulfilled, (state, action) => {
      const { chatId } = action.payload;
      state.unreadCounts[chatId] = 0;
    })
    .addCase(chatActions.updateSettings.fulfilled, (state, action) => {
      state.settings = { ...state.settings, ...action.payload };
    })
    .addCase(chatActions.updateRoomSettings.fulfilled, (state, action) => {
      const { chatId, settings } = action.payload;
      state.activeChats[chatId].settings = {
        ...state.activeChats[chatId].settings,
        ...settings
      };
    });
});
```

### Achievement System State
```typescript
interface AchievementState {
  achievements: Achievement[];
  unlockedAchievements: Record<string, AchievementProgress>;
  loading: boolean;
  error: string | null;
}

interface Achievement {
  id: string;
  title: string;
  description: string;
  category: 'game' | 'tournament' | 'social' | 'special';
  requirements: AchievementRequirement[];
  rewards: AchievementReward[];
  rarity: 'common' | 'rare' | 'epic' | 'legendary';
}

interface AchievementProgress {
  achievementId: string;
  progress: number;
  isUnlocked: boolean;
  unlockedAt?: number;
}

interface AchievementRequirement {
  type: string;
  value: number;
  current: number;
}

interface AchievementReward {
  type: 'chips' | 'tickets' | 'badge' | 'title';
  value: number | string;
}

const achievementActions = {
  fetchAchievements: createAsyncThunk(
    'achievement/fetchAchievements',
    async (_, { rejectWithValue }) => {
      try {
        const response = await api.getAchievements();
        return response.data;
      } catch (error) {
        return rejectWithValue(error.response.data);
      }
    }
  ),
  
  updateProgress: createAsyncThunk(
    'achievement/updateProgress',
    async (progress: AchievementProgress, { rejectWithValue }) => {
      try {
        const response = await api.updateAchievementProgress(progress);
        return response.data;
      } catch (error) {
        return rejectWithValue(error.response.data);
      }
    }
  )
};
```

## Authentication and Authorization

### Authentication Flow
```typescript
interface AuthFlow {
  // Login Flow
  login: {
    steps: [
      {
        name: 'initial',
        component: LoginForm,
        validation: {
          email: 'required|email',
          password: 'required|min:8'
        }
      },
      {
        name: '2fa',
        component: TwoFactorAuth,
        condition: (user) => user.has2FA
      }
    ]
  },

  // Registration Flow
  registration: {
    steps: [
      {
        name: 'basic',
        component: BasicInfoForm,
        validation: {
          username: 'required|min:3|max:50',
          email: 'required|email',
          password: 'required|min:8'
        }
      },
      {
        name: 'verification',
        component: EmailVerification,
        condition: (data) => data.email
      },
      {
        name: 'kyc',
        component: KYCForm,
        condition: (data) => data.requiresKYC
      }
    ]
  }
}
```

### Route Guards
```typescript
interface RouteGuard {
  // Authentication Guard
  authGuard: {
    check: (state: RootState) => boolean;
    redirect: '/login';
    message: 'Please log in to access this page';
  },

  // Role Guard
  roleGuard: {
    roles: string[];
    check: (state: RootState) => boolean;
    redirect: '/unauthorized';
    message: 'You do not have permission to access this page';
  },

  // KYC Guard
  kycGuard: {
    check: (state: RootState) => boolean;
    redirect: '/kyc-required';
    message: 'KYC verification is required to access this feature';
  },

  // Maintenance Guard
  maintenanceGuard: {
    check: (state: RootState) => boolean;
    redirect: '/maintenance';
    message: 'The system is currently under maintenance';
  }
}

// Route Guard Implementation
const withGuard = (Component: React.ComponentType, guard: RouteGuard) => {
  return (props: any) => {
    const state = useAppSelector((state) => state);
    const navigate = useNavigate();

    useEffect(() => {
      if (!guard.check(state)) {
        navigate(guard.redirect, { 
          state: { message: guard.message }
        });
      }
    }, [state, navigate]);

    return guard.check(state) ? <Component {...props} /> : null;
  };
};

// Usage Example
const ProtectedRoute = withGuard(DashboardPage, {
  ...authGuard,
  ...roleGuard,
  roles: ['admin', 'moderator']
});
```

### Session Management
```typescript
interface SessionManager {
  // Session Configuration
  config: {
    tokenExpiry: '24h',
    refreshTokenExpiry: '7d',
    autoRefreshThreshold: '1h'
  },

  // Token Management
  tokens: {
    access: string | null;
    refresh: string | null;
    expiresAt: number | null;
  },

  // Session Actions
  actions: {
    refresh: createAsyncThunk(
      'session/refresh',
      async (_, { rejectWithValue }) => {
        try {
          const response = await api.refreshToken();
          return response.data;
        } catch (error) {
          return rejectWithValue(error.response.data);
        }
      }
    ),
    
    logout: createAsyncThunk(
      'session/logout',
      async (_, { rejectWithValue }) => {
        try {
          await api.logout();
          return null;
        } catch (error) {
          return rejectWithValue(error.response.data);
        }
      }
    )
  },

  // Session Middleware
  middleware: createListenerMiddleware({
    onStart: (listenerApi) => {
      listenerApi.dispatch(sessionActions.startAutoRefresh());
    },
    onStop: (listenerApi) => {
      listenerApi.dispatch(sessionActions.stopAutoRefresh());
    }
  })
}
```

### Additional Authentication Flows
```typescript
interface ExtendedAuthFlow {
  // Password Reset Flow
  passwordReset: {
    steps: [
      {
        name: 'request',
        component: PasswordResetRequest,
        validation: {
          email: 'required|email'
        }
      },
      {
        name: 'verify',
        component: ResetTokenVerification,
        validation: {
          token: 'required|length:6'
        }
      },
      {
        name: 'newPassword',
        component: NewPasswordForm,
        validation: {
          password: 'required|min:8|regex:/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/',
          confirmPassword: 'required|same:password'
        }
      }
    ]
  },

  // Account Recovery Flow
  accountRecovery: {
    steps: [
      {
        name: 'identity',
        component: IdentityVerification,
        validation: {
          username: 'required|min:3',
          email: 'required|email'
        }
      },
      {
        name: 'verification',
        component: RecoveryVerification,
        options: [
          {
            type: 'email',
            component: EmailVerification
          },
          {
            type: 'phone',
            component: SMSVerification
          },
          {
            type: 'security',
            component: SecurityQuestions
          }
        ]
      },
      {
        name: 'reset',
        component: AccountReset,
        validation: {
          newPassword: 'required|min:8',
          confirmPassword: 'required|same:newPassword'
        }
      }
    ]
  },

  // Two-Factor Authentication Setup
  twoFactorSetup: {
    steps: [
      {
        name: 'choose',
        component: TwoFactorMethodSelection,
        options: [
          {
            type: 'authenticator',
            component: AuthenticatorSetup
          },
          {
            type: 'sms',
            component: SMSSetup
          }
        ]
      },
      {
        name: 'verify',
        component: TwoFactorVerification,
        validation: {
          code: 'required|length:6'
        }
      },
      {
        name: 'backup',
        component: BackupCodes,
        generate: true
      }
    ]
  }
}
```

### Wallet Interface Guidelines
```typescript
interface WalletInterfaceStyles {
  // Main Wallet Container
  container: {
    backgroundColor: colors.grey[900],
    borderRadius: '12px',
    padding: spacing.xl,
    boxShadow: '0 4px 6px rgba(0, 0, 0, 0.1)'
  },

  // Balance Display
  balance: {
    container: {
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      marginBottom: spacing.xl
    },
    amount: {
      fontSize: typography.fontSize['4xl'],
      fontWeight: typography.fontWeight.bold,
      color: colors.primary.main,
      marginBottom: spacing.sm
    },
    label: {
      fontSize: typography.fontSize.sm,
      color: colors.grey[400]
    }
  },

  // Transaction List
  transactions: {
    container: {
      maxHeight: '400px',
      overflowY: 'auto'
    },
    item: {
      display: 'flex',
      justifyContent: 'space-between',
      alignItems: 'center',
      padding: spacing.md,
      borderBottom: `1px solid ${colors.grey[800]}`,
      transition: `background-color ${animations.duration.fast} ${animations.easing.easeInOut}`,
      '&:hover': {
        backgroundColor: colors.grey[800]
      }
    },
    type: {
      display: 'flex',
      alignItems: 'center',
      gap: spacing.sm
    },
    amount: {
      fontWeight: typography.fontWeight.medium
    }
  },

  // Action Buttons
  actions: {
    container: {
      display: 'grid',
      gridTemplateColumns: 'repeat(auto-fit, minmax(150px, 1fr))',
      gap: spacing.md,
      marginTop: spacing.xl
    },
    button: {
      padding: spacing.md,
      borderRadius: '8px',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      gap: spacing.sm,
      transition: `all ${animations.duration.normal} ${animations.easing.easeInOut}`
    }
  }
}
```

### Profile Settings Interface
```typescript
interface ProfileSettingsStyles {
  // Settings Navigation
  navigation: {
    container: {
      display: 'flex',
      gap: spacing.md,
      marginBottom: spacing.xl,
      borderBottom: `1px solid ${colors.grey[800]}`,
      paddingBottom: spacing.md
    },
    item: {
      padding: `${spacing.sm} ${spacing.md}`,
      borderRadius: '4px',
      cursor: 'pointer',
      transition: `all ${animations.duration.normal} ${animations.easing.easeInOut}`,
      '&:hover': {
        backgroundColor: colors.grey[800]
      }
    }
  },

  // Profile Form
  form: {
    container: {
      maxWidth: '600px',
      margin: '0 auto'
    },
    section: {
      marginBottom: spacing.xl,
      padding: spacing.lg,
      backgroundColor: colors.grey[900],
      borderRadius: '8px'
    },
    title: {
      fontSize: typography.fontSize.lg,
      fontWeight: typography.fontWeight.semibold,
      marginBottom: spacing.md
    },
    field: {
      marginBottom: spacing.md
    },
    label: {
      display: 'block',
      marginBottom: spacing.xs,
      color: colors.grey[400]
    },
    input: {
      width: '100%',
      padding: spacing.sm,
      borderRadius: '4px',
      backgroundColor: colors.grey[800],
      border: `1px solid ${colors.grey[700]}`,
      color: colors.white
    }
  }
}
```

### Notification System State
```typescript
interface NotificationState {
  notifications: Notification[];
  unreadCount: number;
  settings: NotificationSettings;
  loading: boolean;
  error: string | null;
}

interface Notification {
  id: string;
  type: 'game' | 'tournament' | 'system' | 'achievement' | 'transaction';
  title: string;
  message: string;
  timestamp: number;
  read: boolean;
  action?: {
    type: string;
    payload: any;
  };
  metadata?: {
    priority: 'low' | 'medium' | 'high';
    category: string;
    expiresAt?: number;
  };
}

interface NotificationSettings {
  email: {
    enabled: boolean;
    types: string[];
    frequency: 'immediate' | 'daily' | 'weekly';
  };
  push: {
    enabled: boolean;
    types: string[];
    quietHours: {
      enabled: boolean;
      start: string;
      end: string;
    };
  };
  inApp: {
    enabled: boolean;
    types: string[];
    position: 'top-right' | 'bottom-right';
  };
}

const notificationActions = {
  fetchNotifications: createAsyncThunk(
    'notification/fetch',
    async (_, { rejectWithValue }) => {
      try {
        const response = await api.getNotifications();
        return response.data;
      } catch (error) {
        return rejectWithValue(error.response.data);
      }
    }
  ),
  
  markAsRead: createAsyncThunk(
    'notification/markAsRead',
    async (notificationId: string, { rejectWithValue }) => {
      try {
        const response = await api.markNotificationAsRead(notificationId);
        return response.data;
      } catch (error) {
        return rejectWithValue(error.response.data);
      }
    }
  ),
  
  updateSettings: createAsyncThunk(
    'notification/updateSettings',
    async (settings: NotificationSettings, { rejectWithValue }) => {
      try {
        const response = await api.updateNotificationSettings(settings);
        return response.data;
      } catch (error) {
        return rejectWithValue(error.response.data);
      }
    }
  )
};
```

### User Settings State
```typescript
interface UserSettingsState {
  preferences: UserPreferences;
  privacy: PrivacySettings;
  appearance: AppearanceSettings;
  notifications: NotificationSettings;
  loading: boolean;
  error: string | null;
}

interface UserPreferences {
  language: string;
  timezone: string;
  currency: string;
  dateFormat: string;
  sound: {
    enabled: boolean;
    volume: number;
    effects: string[];
  };
  chat: {
    enabled: boolean;
    language: string;
    autoTranslate: boolean;
  };
}

interface PrivacySettings {
  profileVisibility: 'public' | 'friends' | 'private';
  showOnlineStatus: boolean;
  showLastSeen: boolean;
  allowFriendRequests: boolean;
  allowMessages: boolean;
  showAchievements: boolean;
  showStatistics: boolean;
}

interface AppearanceSettings {
  theme: 'light' | 'dark' | 'system';
  fontSize: 'small' | 'medium' | 'large';
  contrast: 'normal' | 'high';
  animations: {
    enabled: boolean;
    reduced: boolean;
  };
  customColors?: {
    primary: string;
    secondary: string;
    background: string;
    text: string;
  };
}

const settingsActions = {
  fetchSettings: createAsyncThunk(
    'settings/fetch',
    async (_, { rejectWithValue }) => {
      try {
        const response = await api.getUserSettings();
        return response.data;
      } catch (error) {
        return rejectWithValue(error.response.data);
      }
    }
  ),
  
  updateSettings: createAsyncThunk(
    'settings/update',
    async (settings: Partial<UserSettingsState>, { rejectWithValue }) => {
      try {
        const response = await api.updateUserSettings(settings);
        return response.data;
      } catch (error) {
        return rejectWithValue(error.response.data);
      }
    }
  ),
  
  resetSettings: createAsyncThunk(
    'settings/reset',
    async (_, { rejectWithValue }) => {
      try {
        const response = await api.resetUserSettings();
        return response.data;
      } catch (error) {
        return rejectWithValue(error.response.data);
      }
    }
  )
};
```

### Leaderboard Interface Guidelines
```typescript
interface LeaderboardStyles {
  // Main Container
  container: {
    backgroundColor: colors.grey[900],
    borderRadius: '12px',
    padding: spacing.xl,
    boxShadow: '0 4px 6px rgba(0, 0, 0, 0.1)'
  },

  // Header Section
  header: {
    container: {
      display: 'flex',
      justifyContent: 'space-between',
      alignItems: 'center',
      marginBottom: spacing.xl,
      paddingBottom: spacing.md,
      borderBottom: `1px solid ${colors.grey[800]}`
    },
    title: {
      fontSize: typography.fontSize['2xl'],
      fontWeight: typography.fontWeight.bold
    },
    filters: {
      display: 'flex',
      gap: spacing.md
    }
  },

  // Leaderboard Table
  table: {
    container: {
      width: '100%',
      borderCollapse: 'collapse'
    },
    header: {
      backgroundColor: colors.grey[800],
      padding: spacing.md,
      textAlign: 'left',
      fontWeight: typography.fontWeight.semibold
    },
    row: {
      padding: spacing.md,
      borderBottom: `1px solid ${colors.grey[800]}`,
      transition: `background-color ${animations.duration.fast} ${animations.easing.easeInOut}`,
      '&:hover': {
        backgroundColor: colors.grey[800]
      }
    },
    rank: {
      width: '60px',
      textAlign: 'center',
      fontWeight: typography.fontWeight.bold
    },
    player: {
      display: 'flex',
      alignItems: 'center',
      gap: spacing.sm
    },
    score: {
      fontWeight: typography.fontWeight.medium,
      color: colors.primary.main
    }
  },

  // Pagination
  pagination: {
    container: {
      display: 'flex',
      justifyContent: 'center',
      gap: spacing.sm,
      marginTop: spacing.xl
    },
    button: {
      padding: `${spacing.sm} ${spacing.md}`,
      borderRadius: '4px',
      backgroundColor: colors.grey[800],
      '&:hover': {
        backgroundColor: colors.grey[700]
      }
    }
  }
}
```

### Statistics Dashboard Interface
```typescript
interface StatisticsDashboardStyles {
  // Main Container
  container: {
    display: 'grid',
    gridTemplateColumns: 'repeat(auto-fit, minmax(300px, 1fr))',
    gap: spacing.lg,
    padding: spacing.lg
  },

  // Stat Card
  card: {
    container: {
      backgroundColor: colors.grey[900],
      borderRadius: '8px',
      padding: spacing.lg,
      boxShadow: '0 2px 4px rgba(0, 0, 0, 0.1)'
    },
    header: {
      display: 'flex',
      justifyContent: 'space-between',
      alignItems: 'center',
      marginBottom: spacing.md
    },
    title: {
      fontSize: typography.fontSize.lg,
      fontWeight: typography.fontWeight.semibold
    },
    value: {
      fontSize: typography.fontSize['3xl'],
      fontWeight: typography.fontWeight.bold,
      color: colors.primary.main
    },
    trend: {
      display: 'flex',
      alignItems: 'center',
      gap: spacing.xs,
      fontSize: typography.fontSize.sm
    }
  },

  // Chart Container
  chart: {
    container: {
      gridColumn: '1 / -1',
      backgroundColor: colors.grey[900],
      borderRadius: '8px',
      padding: spacing.lg,
      height: '400px'
    },
    header: {
      display: 'flex',
      justifyContent: 'space-between',
      alignItems: 'center',
      marginBottom: spacing.lg
    },
    controls: {
      display: 'flex',
      gap: spacing.md
    }
  }
}
```

### Friend System State
```typescript
interface FriendSystemState {
  friends: Friend[];
  friendRequests: FriendRequest[];
  blockedUsers: string[];
  loading: boolean;
  error: string | null;
}

interface Friend {
  id: string;
  username: string;
  status: 'online' | 'offline' | 'in-game' | 'away';
  lastSeen: number;
  avatar: string;
  stats: {
    gamesPlayed: number;
    winRate: number;
    totalEarnings: number;
  };
  mutualFriends: number;
  notes?: string;
}

interface FriendRequest {
  id: string;
  senderId: string;
  senderUsername: string;
  senderAvatar: string;
  timestamp: number;
  status: 'pending' | 'accepted' | 'rejected';
  message?: string;
}

const friendActions = {
  fetchFriends: createAsyncThunk(
    'friends/fetch',
    async (_, { rejectWithValue }) => {
      try {
        const response = await api.getFriends();
        return response.data;
      } catch (error) {
        return rejectWithValue(error.response.data);
      }
    }
  ),
  
  sendFriendRequest: createAsyncThunk(
    'friends/sendRequest',
    async (userId: string, { rejectWithValue }) => {
      try {
        const response = await api.sendFriendRequest(userId);
        return response.data;
      } catch (error) {
        return rejectWithValue(error.response.data);
      }
    }
  ),
  
  respondToRequest: createAsyncThunk(
    'friends/respondToRequest',
    async ({ requestId, accept }: { requestId: string; accept: boolean }, { rejectWithValue }) => {
      try {
        const response = await api.respondToFriendRequest(requestId, accept);
        return response.data;
      } catch (error) {
        return rejectWithValue(error.response.data);
      }
    }
  ),
  
  blockUser: createAsyncThunk(
    'friends/block',
    async (userId: string, { rejectWithValue }) => {
      try {
        const response = await api.blockUser(userId);
        return response.data;
      } catch (error) {
        return rejectWithValue(error.response.data);
      }
    }
  )
};

const friendReducer = createReducer(initialState, (builder) => {
  builder
    .addCase(friendActions.fetchFriends.fulfilled, (state, action) => {
      state.friends = action.payload;
    })
    .addCase(friendActions.sendFriendRequest.fulfilled, (state, action) => {
      state.friendRequests.push(action.payload);
    })
    .addCase(friendActions.respondToRequest.fulfilled, (state, action) => {
      const { requestId, accept } = action.payload;
      const request = state.friendRequests.find(r => r.id === requestId);
      if (request) {
        if (accept) {
          state.friends.push({
            id: request.senderId,
            username: request.senderUsername,
            avatar: request.senderAvatar,
            status: 'offline',
            lastSeen: Date.now(),
            stats: { gamesPlayed: 0, winRate: 0, totalEarnings: 0 },
            mutualFriends: 0
          });
        }
        state.friendRequests = state.friendRequests.filter(r => r.id !== requestId);
      }
    });
});
```

### Form Validation Rules
```typescript
interface FormValidationRules {
  // User Profile Validation
  profile: {
    username: {
      required: true,
      minLength: 3,
      maxLength: 50,
      pattern: /^[a-zA-Z0-9_-]+$/,
      message: 'Username must be 3-50 characters and can only contain letters, numbers, underscores, and hyphens'
    },
    email: {
      required: true,
      pattern: /^[^\s@]+@[^\s@]+\.[^\s@]+$/,
      message: 'Please enter a valid email address'
    },
    password: {
      required: true,
      minLength: 8,
      pattern: /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/,
      message: 'Password must be at least 8 characters and contain at least one uppercase letter, one lowercase letter, one number, and one special character'
    },
    avatar: {
      maxSize: 5 * 1024 * 1024, // 5MB
      types: ['image/jpeg', 'image/png', 'image/gif'],
      dimensions: {
        min: { width: 100, height: 100 },
        max: { width: 500, height: 500 }
      }
    }
  },

  // Payment Information Validation
  payment: {
    cardNumber: {
      required: true,
      pattern: /^[0-9]{16}$/,
      message: 'Please enter a valid 16-digit card number'
    },
    expiryDate: {
      required: true,
      pattern: /^(0[1-9]|1[0-2])\/([0-9]{2})$/,
      message: 'Please enter a valid expiry date (MM/YY)'
    },
    cvv: {
      required: true,
      pattern: /^[0-9]{3,4}$/,
      message: 'Please enter a valid CVV'
    },
    amount: {
      required: true,
      min: 10,
      max: 10000,
      message: 'Amount must be between $10 and $10,000'
    }
  },

  // Tournament Registration Validation
  tournament: {
    buyIn: {
      required: true,
      min: 0,
      message: 'Buy-in amount must be positive'
    },
    maxPlayers: {
      required: true,
      min: 2,
      max: 1000,
      message: 'Maximum players must be between 2 and 1000'
    },
    startTime: {
      required: true,
      min: Date.now() + 3600000, // 1 hour from now
      message: 'Tournament must start at least 1 hour from now'
    },
    blindLevels: {
      required: true,
      minItems: 1,
      maxItems: 50,
      message: 'Tournament must have between 1 and 50 blind levels'
    }
  },

  // Chat Message Validation
  chat: {
    message: {
      required: true,
      maxLength: 500,
      pattern: /^[^<>]*$/,
      message: 'Message must be less than 500 characters and cannot contain HTML tags'
    },
    recipient: {
      required: true,
      pattern: /^[a-zA-Z0-9_-]+$/,
      message: 'Invalid recipient username'
    }
  }
}

// Form Validation Implementation
const useFormValidation = (rules: FormValidationRules, formData: any) => {
  const [errors, setErrors] = useState<Record<string, string>>({});

  const validate = () => {
    const newErrors: Record<string, string> = {};

    Object.entries(rules).forEach(([field, rule]) => {
      const value = formData[field];

      if (rule.required && !value) {
        newErrors[field] = `${field} is required`;
        return;
      }

      if (rule.pattern && !rule.pattern.test(value)) {
        newErrors[field] = rule.message;
        return;
      }

      if (rule.minLength && value.length < rule.minLength) {
        newErrors[field] = rule.message || `${field} must be at least ${rule.minLength} characters`;
        return;
      }

      if (rule.maxLength && value.length > rule.maxLength) {
        newErrors[field] = rule.message || `${field} must be less than ${rule.maxLength} characters`;
        return;
      }

      if (rule.min !== undefined && value < rule.min) {
        newErrors[field] = rule.message || `${field} must be greater than ${rule.min}`;
        return;
      }

      if (rule.max !== undefined && value > rule.max) {
        newErrors[field] = rule.message || `${field} must be less than ${rule.max}`;
        return;
      }
    });

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  return { errors, validate };
};
```

### Game History Interface Guidelines
```typescript
interface GameHistoryStyles {
  // Main Container
  container: {
    backgroundColor: colors.grey[900],
    borderRadius: '12px',
    padding: spacing.xl,
    boxShadow: '0 4px 6px rgba(0, 0, 0, 0.1)'
  },

  // Filter Section
  filters: {
    container: {
      display: 'flex',
      flexWrap: 'wrap',
      gap: spacing.md,
      marginBottom: spacing.xl,
      padding: spacing.md,
      backgroundColor: colors.grey[800],
      borderRadius: '8px'
    },
    group: {
      display: 'flex',
      flexDirection: 'column',
      gap: spacing.xs
    },
    label: {
      fontSize: typography.fontSize.sm,
      color: colors.grey[400]
    }
  },

  // Game List
  gameList: {
    container: {
      display: 'flex',
      flexDirection: 'column',
      gap: spacing.md
    },
    item: {
      display: 'grid',
      gridTemplateColumns: 'auto 1fr auto',
      gap: spacing.md,
      padding: spacing.md,
      backgroundColor: colors.grey[800],
      borderRadius: '8px',
      transition: `transform ${animations.duration.fast} ${animations.easing.easeInOut}`,
      '&:hover': {
        transform: 'translateX(4px)'
      }
    },
    gameType: {
      display: 'flex',
      alignItems: 'center',
      gap: spacing.sm
    },
    details: {
      display: 'flex',
      flexDirection: 'column',
      gap: spacing.xs
    },
    result: {
      display: 'flex',
      alignItems: 'center',
      gap: spacing.sm,
      fontWeight: typography.fontWeight.medium
    }
  },

  // Replay Controls
  replay: {
    container: {
      position: 'fixed',
      bottom: 0,
      left: 0,
      right: 0,
      backgroundColor: colors.grey[900],
      padding: spacing.md,
      borderTop: `1px solid ${colors.grey[800]}`,
      display: 'flex',
      justifyContent: 'center',
      gap: spacing.md
    },
    controls: {
      display: 'flex',
      alignItems: 'center',
      gap: spacing.sm
    },
    timeline: {
      flex: 1,
      height: '4px',
      backgroundColor: colors.grey[800],
      borderRadius: '2px',
      cursor: 'pointer'
    }
  }
}
```

### Player Profile Interface Guidelines
```typescript
interface PlayerProfileStyles {
  // Header Section
  header: {
    container: {
      display: 'flex',
      gap: spacing.xl,
      padding: spacing.xl,
      backgroundColor: colors.grey[900],
      borderRadius: '12px',
      marginBottom: spacing.xl
    },
    avatar: {
      width: '120px',
      height: '120px',
      borderRadius: '50%',
      border: `4px solid ${colors.primary.main}`,
      overflow: 'hidden'
    },
    info: {
      flex: 1,
      display: 'flex',
      flexDirection: 'column',
      gap: spacing.sm
    },
    name: {
      fontSize: typography.fontSize['2xl'],
      fontWeight: typography.fontWeight.bold
    },
    status: {
      display: 'flex',
      alignItems: 'center',
      gap: spacing.sm,
      color: colors.grey[400]
    }
  },

  // Stats Grid
  stats: {
    container: {
      display: 'grid',
      gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))',
      gap: spacing.md,
      marginBottom: spacing.xl
    },
    card: {
      backgroundColor: colors.grey[900],
      borderRadius: '8px',
      padding: spacing.md,
      textAlign: 'center'
    },
    value: {
      fontSize: typography.fontSize['2xl'],
      fontWeight: typography.fontWeight.bold,
      color: colors.primary.main
    },
    label: {
      fontSize: typography.fontSize.sm,
      color: colors.grey[400]
    }
  },

  // Achievement Showcase
  achievements: {
    container: {
      display: 'grid',
      gridTemplateColumns: 'repeat(auto-fill, minmax(150px, 1fr))',
      gap: spacing.md
    },
    achievement: {
      backgroundColor: colors.grey[900],
      borderRadius: '8px',
      padding: spacing.md,
      textAlign: 'center',
      transition: `transform ${animations.duration.fast} ${animations.easing.easeInOut}`,
      '&:hover': {
        transform: 'translateY(-4px)'
      }
    },
    icon: {
      width: '64px',
      height: '64px',
      marginBottom: spacing.sm
    },
    title: {
      fontSize: typography.fontSize.sm,
      fontWeight: typography.fontWeight.medium
    }
  }
}
```

### Game History State Management
```typescript
interface GameHistoryState {
  games: GameHistory[];
  filters: GameHistoryFilters;
  selectedGame: GameHistory | null;
  loading: boolean;
  error: string | null;
}

interface GameHistory {
  id: string;
  type: 'cash' | 'tournament';
  startTime: number;
  endTime: number;
  buyIn: number;
  cashOut: number;
  profit: number;
  hands: number;
  vpip: number;
  pfr: number;
  afq: number;
  players: GameHistoryPlayer[];
  actions: GameHistoryAction[];
}

interface GameHistoryPlayer {
  id: string;
  username: string;
  position: number;
  stack: number;
  profit: number;
  hands: number;
  vpip: number;
  pfr: number;
  afq: number;
}

interface GameHistoryAction {
  type: 'bet' | 'call' | 'raise' | 'fold' | 'check';
  playerId: string;
  amount?: number;
  timestamp: number;
}

interface GameHistoryFilters {
  dateRange: {
    from: number;
    to: number;
  };
  gameTypes: ('cash' | 'tournament')[];
  minBuyIn: number;
  maxBuyIn: number;
  minHands: number;
  minProfit: number;
}

const gameHistoryActions = {
  fetchGames: createAsyncThunk(
    'gameHistory/fetch',
    async (filters: GameHistoryFilters, { rejectWithValue }) => {
      try {
        const response = await api.getGameHistory(filters);
        return response.data;
      } catch (error) {
        return rejectWithValue(error.response.data);
      }
    }
  ),
  
  selectGame: createAction<string>('gameHistory/selectGame'),
  updateFilters: createAction<GameHistoryFilters>('gameHistory/updateFilters'),
  
  exportHistory: createAsyncThunk(
    'gameHistory/export',
    async (filters: GameHistoryFilters, { rejectWithValue }) => {
      try {
        const response = await api.exportGameHistory(filters);
        return response.data;
      } catch (error) {
        return rejectWithValue(error.response.data);
      }
    }
  )
};

const gameHistoryReducer = createReducer(initialState, (builder) => {
  builder
    .addCase(gameHistoryActions.fetchGames.fulfilled, (state, action) => {
      state.games = action.payload;
    })
    .addCase(gameHistoryActions.selectGame, (state, action) => {
      state.selectedGame = state.games.find(g => g.id === action.payload) || null;
    })
    .addCase(gameHistoryActions.updateFilters, (state, action) => {
      state.filters = action.payload;
    });
});
```

### Player Profile State Management
```typescript
interface PlayerProfileState {
  profile: PlayerProfile | null;
  statistics: PlayerStatistics | null;
  achievements: Achievement[];
  recentGames: GameHistory[];
  loading: boolean;
  error: string | null;
}

interface PlayerProfile {
  id: string;
  username: string;
  displayName: string;
  avatar: string;
  status: 'online' | 'offline' | 'in-game' | 'away';
  lastSeen: number;
  joinedAt: number;
  location?: string;
  bio?: string;
  socialLinks?: {
    twitter?: string;
    facebook?: string;
    instagram?: string;
    discord?: string;
  };
}

interface PlayerStatistics {
  gamesPlayed: number;
  handsPlayed: number;
  totalProfit: number;
  winRate: number;
  vpip: number;
  pfr: number;
  afq: number;
  biggestWin: number;
  biggestLoss: number;
  averageBuyIn: number;
  favoriteGameType: 'cash' | 'tournament';
  bestFinish: {
    tournament: string;
    position: number;
    prize: number;
  };
}

const playerProfileActions = {
  fetchProfile: createAsyncThunk(
    'playerProfile/fetch',
    async (playerId: string, { rejectWithValue }) => {
      try {
        const response = await api.getPlayerProfile(playerId);
        return response.data;
      } catch (error) {
        return rejectWithValue(error.response.data);
      }
    }
  ),
  
  fetchStatistics: createAsyncThunk(
    'playerProfile/fetchStatistics',
    async (playerId: string, { rejectWithValue }) => {
      try {
        const response = await api.getPlayerStatistics(playerId);
        return response.data;
      } catch (error) {
        return rejectWithValue(error.response.data);
      }
    }
  ),
  
  fetchAchievements: createAsyncThunk(
    'playerProfile/fetchAchievements',
    async (playerId: string, { rejectWithValue }) => {
      try {
        const response = await api.getPlayerAchievements(playerId);
        return response.data;
      } catch (error) {
        return rejectWithValue(error.response.data);
      }
    }
  ),
  
  fetchRecentGames: createAsyncThunk(
    'playerProfile/fetchRecentGames',
    async (playerId: string, { rejectWithValue }) => {
      try {
        const response = await api.getPlayerRecentGames(playerId);
        return response.data;
      } catch (error) {
        return rejectWithValue(error.response.data);
      }
    }
  )
};

const playerProfileReducer = createReducer(initialState, (builder) => {
  builder
    .addCase(playerProfileActions.fetchProfile.fulfilled, (state, action) => {
      state.profile = action.payload;
    })
    .addCase(playerProfileActions.fetchStatistics.fulfilled, (state, action) => {
      state.statistics = action.payload;
    })
    .addCase(playerProfileActions.fetchAchievements.fulfilled, (state, action) => {
      state.achievements = action.payload;
    })
    .addCase(playerProfileActions.fetchRecentGames.fulfilled, (state, action) => {
      state.recentGames = action.payload;
    });
});
```

### Additional Form Validation Rules
```typescript
interface ExtendedFormValidationRules {
  // Game History Filters Validation
  gameHistoryFilters: {
    dateRange: {
      validate: (range: { from: number; to: number }) => {
        return range.from >= 0 && range.to >= range.from && range.to <= Date.now();
      },
      message: 'Invalid date range'
    },
    gameTypes: {
      validate: (types: string[]) => {
        return types.every(type => ['cash', 'tournament'].includes(type));
      },
      message: 'Invalid game type'
    },
    minBuyIn: {
      validate: (value: number) => {
        return value >= 0 && value <= 10000;
      },
      message: 'Minimum buy-in must be between $0 and $10,000'
    },
    minHands: {
      validate: (value: number) => {
        return value >= 0 && value <= 10000;
      },
      message: 'Minimum hands must be between 0 and 10,000'
    }
  },

  // Player Profile Validation
  playerProfile: {
    displayName: {
      required: true,
      minLength: 2,
      maxLength: 50,
      pattern: /^[a-zA-Z0-9\s-_]+$/,
      message: 'Display name must be 2-50 characters and can only contain letters, numbers, spaces, hyphens, and underscores'
    },
    bio: {
      maxLength: 500,
      pattern: /^[^<>]*$/,
      message: 'Bio must be less than 500 characters and cannot contain HTML tags'
    },
    location: {
      pattern: /^[a-zA-Z\s,]+$/,
      message: 'Location can only contain letters, spaces, and commas'
    },
    socialLinks: {
      validate: (links: Record<string, string>) => {
        const validPlatforms = ['twitter', 'facebook', 'instagram', 'discord'];
        return Object.keys(links).every(platform => 
          validPlatforms.includes(platform) && 
          /^https?:\/\/[^\s/$.?#].[^\s]*$/.test(links[platform])
        );
      },
      message: 'Invalid social media links'
    }
  }
}