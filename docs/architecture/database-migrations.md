# Database Migrations

This document outlines the database migration strategy for all services within the Tablium platform.

## Overview

Each service with a database dependency maintains its own migrations in a structured format. Migrations are versioned, sequential, and designed to be idempotent when possible.

## Migration Tools by Language

### TypeScript Services (Auth, User, Integration)
- **Tool**: TypeORM Migrations
- **Location**: `src/database/migrations/`
- **Naming Convention**: `YYYYMMDDHHMMSS-migration-name.ts`
- **Commands**:
  - Generate: `npm run migration:generate -- -n MigrationName`
  - Run: `npm run migration:run`
  - Revert: `npm run migration:revert`

### Go Services (API Gateway, Game State, Realtime)
- **Tool**: golang-migrate
- **Location**: `db/migrations/`
- **Naming Convention**: `YYYYMMDDHHMMSS_migration_name.up.sql` and `YYYYMMDDHHMMSS_migration_name.down.sql`
- **Commands**:
  - Create: `migrate create -ext sql -dir db/migrations -seq migration_name`
  - Up: `migrate -database ${DATABASE_URL} -path db/migrations up`
  - Down: `migrate -database ${DATABASE_URL} -path db/migrations down`

### Rust Services (Wallet)
- **Tool**: Diesel
- **Location**: `migrations/`
- **Naming Convention**: `YYYYMMDDHHMMSS_migration_name/up.sql` and `YYYYMMDDHHMMSS_migration_name/down.sql`
- **Commands**:
  - Create: `diesel migration generate migration_name`
  - Run: `diesel migration run`
  - Revert: `diesel migration revert`

### Python Services (AI Engine)
- **Tool**: Alembic
- **Location**: `alembic/versions/`
- **Naming Convention**: `<hash>_migration_name.py`
- **Commands**:
  - Create: `alembic revision --autogenerate -m "migration_name"`
  - Run: `alembic upgrade head`
  - Revert: `alembic downgrade -1`

## Initial Migrations

Each service repository contains baseline migrations establishing the initial schema:

1. **Auth Service**: User authentication tables, roles, permissions
2. **User Service**: User profiles, achievements, statistics
3. **Wallet Service**: Wallets, transactions, balances
4. **Game State Service**: Game records, moves, results
5. **AI Engine**: Training data, models, predictions

## Docker Integration

Migrations run automatically when containers start up using wait-for scripts to ensure database availability before attempting migrations.

## Best Practices

1. **Never modify existing migrations** - Create new migrations instead
2. **Version control all migrations** - All migration files must be in the repository
3. **Test migrations** - Both up and down migrations should be tested
4. **Keep migrations small** - Smaller, focused migrations are easier to review and less error-prone
5. **Include descriptive comments** - Document the purpose of each migration
6. **Backup before migrating** - Always backup production databases before migration

## Example Migration Files

Example TypeORM migration:
```typescript
import { MigrationInterface, QueryRunner, Table } from "typeorm";

export class CreateUsersTable1615213456789 implements MigrationInterface {
    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.createTable(
            new Table({
                name: "users",
                columns: [
                    {
                        name: "id",
                        type: "uuid",
                        isPrimary: true,
                        generationStrategy: "uuid",
                        default: "uuid_generate_v4()"
                    },
                    {
                        name: "email",
                        type: "varchar",
                        isUnique: true
                    },
                    {
                        name: "password_hash",
                        type: "varchar"
                    },
                    {
                        name: "created_at",
                        type: "timestamp",
                        default: "now()"
                    },
                    {
                        name: "updated_at",
                        type: "timestamp",
                        default: "now()"
                    }
                ]
            }),
            true
        );
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.dropTable("users");
    }
}
```

Example golang-migrate migration:
```sql
-- Up migration
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE game_states (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    game_id UUID NOT NULL,
    state JSONB NOT NULL,
    turn_number INTEGER NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(game_id, turn_number)
);

CREATE INDEX idx_game_states_game_id ON game_states(game_id);

-- Down migration
DROP TABLE IF EXISTS game_states;
```

Example Diesel migration:
```sql
-- Up migration
CREATE TABLE wallets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    balance DECIMAL(20, 8) NOT NULL DEFAULT 0,
    wallet_type VARCHAR(50) NOT NULL,
    address VARCHAR(255) NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, wallet_type)
);

CREATE INDEX idx_wallets_user_id ON wallets(user_id);

-- Down migration
DROP TABLE IF EXISTS wallets;
``` 