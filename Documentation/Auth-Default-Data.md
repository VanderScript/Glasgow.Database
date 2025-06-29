# Auth Default Data

[[Home]] > [[Database.Auth Schema]] > Auth Default Data

## Overview
The auth schema includes essential default data that establishes the basic security framework for the application. This includes access levels, basic roles, and system users.

## Access Level Map
The `auth.access_level_map` table is initialized with standard permission levels:

| Level | Description | Usage |
|-------|------------|-------|
| 0     | None       | No access to the feature/resource |
| 1     | View       | Read-only access |
| 2     | Edit       | Can modify existing records |
| 3     | Delete     | Can remove records |
| 4     | SuperUser  | Full system access |

## Default Roles
The `auth.roles` table is populated with basic role definitions:

| Role      | Purpose |
|-----------|---------|
| NONE      | Default role for unauthenticated access |
| VIEWONLY  | Read-only access to authorized resources |
| EDITONLY  | Edit access to authorized resources |
| ADMIN     | Administrative access |
| SUPERUSER | Complete system access |

Note: Role IDs are automatically assigned using IDENTITY.

## System Users
The `auth.users` table includes pre-defined system users with specific GUIDs:

### NONE User
- **User ID:** `00000000-0000-0000-0000-000000000001`
- **Username:** `NONE`
- **Purpose:** Represents anonymous or unauthenticated access
- **Usage:** Used for operations that don't require authentication

### SYSTEM User
- **User ID:** `00000000-0000-0000-0000-000000000002`
- **Username:** `SYSTEM`
- **Purpose:** Represents system-level operations
- **Usage:** Used for automated processes and system maintenance

Note: System users are created with placeholder password values and should not be used for interactive login.

## Usage Guidelines

### Access Level Assignment
1. Use the appropriate access level when defining new features
2. Consider the principle of least privilege
3. Document any custom access level requirements

### Role Management
1. New roles should be added through proper change management
2. Custom roles should follow the naming convention
3. Document role purposes and permissions

### System Users
1. Do not modify or delete system user accounts
2. Do not use system accounts for regular user access
3. Maintain the reserved GUID pattern for any new system accounts

## Security Considerations

### Password Management
- System user passwords are placeholders
- Regular users require proper password hashing
- Use the provided stored procedures for user management

### Role Assignment
- Start with least privilege
- Document business justification for elevated roles
- Regularly audit role assignments

### Access Levels
- Use standard levels when possible
- Document any custom access level requirements
- Consider security implications of new access levels

## Related Pages
- [[Auth Schema]] - Schema structure and tables
- [[Database Conventions]] - Naming and design standards
- [[Core Default Data]] - Core schema default data 