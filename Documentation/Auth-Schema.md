# Auth Schema

[[Home]] > Database.Auth Schema

## Overview
The `auth` schema provides a comprehensive authentication and authorization system for the Glasgow database. It implements a role-based access control (RBAC) system with claims-based permissions, allowing for fine-grained access control across the application.

## Tables

### Users (`auth.users`)
Stores user account information and credentials.

| Column         | Type            | Nullable | Description                    |
|---------------|-----------------|----------|--------------------------------|
| user_id       | UNIQUEIDENTIFIER | No       | Primary key, auto-generated    |
| username      | VARCHAR(32)     | No       | Unique username                |
| password_hash | VARCHAR(244)    | No       | Hashed password               |
| password_salt | VARCHAR(244)    | No       | Salt used in password hashing |

**Constraints:**
- Primary Key on `user_id`
- Unique constraint on `username`
- Default NEWID() for `user_id`

### Roles (`auth.roles`)
Defines available roles in the system.

| Column  | Type        | Nullable | Description              |
|---------|-------------|----------|--------------------------|
| role_id | INT         | No       | Primary key, auto-increment |
| role    | VARCHAR(32) | No       | Role name               |

**Constraints:**
- Primary Key on `role_id`
- Unique constraint on `role`
- Identity specification on `role_id`

### Claims (`auth.claim_list`)
Defines available permissions (claims) in the system.

| Column     | Type        | Nullable | Description              |
|------------|-------------|----------|--------------------------|
| claim_id   | INT         | No       | Primary key, auto-increment |
| claim_name | VARCHAR(32) | Yes      | Name of the permission   |

**Constraints:**
- Primary Key on `claim_id`
- Identity specification on `claim_id`

### Role-Claim Mapping (`auth.role_claim_mapping`)
Maps roles to their assigned claims/permissions.

| Column    | Type | Nullable | Description           |
|-----------|------|----------|-----------------------|
| role_id   | INT  | No       | Reference to roles    |
| claim_id  | INT  | No       | Reference to claims   |

**Constraints:**
- Foreign Key to `auth.roles (role_id)`
- Foreign Key to `auth.claim_list (claim_id)`

### User-Role Mapping (`auth.user_role_mapping`)
Maps users to their assigned roles.

| Column   | Type            | Nullable | Description           |
|----------|-----------------|----------|-----------------------|
| user_id  | UNIQUEIDENTIFIER| No       | Reference to users    |
| role_id  | INT            | No       | Reference to roles    |

**Constraints:**
- Foreign Key to `auth.users (user_id)`
- Foreign Key to `auth.roles (role_id)`

### User Sessions (`auth.user_sessions`)
Manages active user sessions.

| Column        | Type            | Nullable | Description                |
|---------------|-----------------|----------|----------------------------|
| session_id    | UNIQUEIDENTIFIER| No       | Primary key               |
| user_id       | UNIQUEIDENTIFIER| No       | Reference to users        |
| refresh_token | VARCHAR(244)    | No       | Session refresh token     |
| expires_utc   | DATETIME        | No       | Session expiration time   |

**Constraints:**
- Primary Key on `session_id`
- Foreign Key to `auth.users (user_id)`

### Access Level Map (`auth.access_level_map`)
Defines permission levels for various operations.

| Column         | Type         | Nullable | Description              |
|---------------|--------------|----------|--------------------------|
| level         | INT          | No       | Access level value       |
| lvl_description| VARCHAR(50)  | Yes      | Level description        |

**Constraints:**
- Primary Key on `level`

## Stored Procedures

### `sp_upsert_users`
Handles user creation and updates.
- Creates new user accounts with hashed passwords
- Updates existing user information
- Validates username uniqueness

### `sp_upsert_roles`
Manages role creation and updates.
- Creates new roles
- Updates existing role information
- Maintains role uniqueness

### `sp_upsert_role_claim_mapping`
Manages role-claim associations.
- Assigns claims to roles
- Updates existing claim assignments
- Removes claim assignments

### `sp_upsert_user_role_mapping`
Manages user-role associations.
- Assigns roles to users
- Updates existing role assignments
- Removes role assignments

## Usage Examples

### User Authentication Flow
1. User provides credentials
2. System looks up user by username
3. Validates password hash
4. Creates session if valid
5. Returns session token

### Authorization Check Flow
1. System receives request with session token
2. Validates session
3. Retrieves user's roles
4. Retrieves role's claims
5. Checks against required permissions

### Role Assignment Flow
1. Admin selects user
2. Views available roles
3. Assigns roles using `sp_upsert_user_role_mapping`
4. System updates user's permissions

## Related Pages
- [[Auth Default Data]] - Default data and configuration
- [[Core Schema]] - Core system functionality
- [[Database Conventions]] - Naming and design standards 