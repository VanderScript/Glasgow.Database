# Glasgow Database

## Overview
The Glasgow Database serves as the foundation for a comprehensive warehouse management solution, consisting of both a Warehouse Control System (WCS) and a Warehouse Execution System (WES). The database is organized into three main schemas:

1. **Auth Schema** (`auth`)
   - Handles user authentication and authorization
   - Manages roles, permissions, and user sessions
   - Provides claim-based access control

2. **Core Schema** (`core`)
   - Shared functionality between WCS and WES
   - Manages transaction logging
   - Handles destinations and license plate numbers (LPNs)
   - Common status codes and types

3. **Forge Schema** (`forge`)
   - Warehouse Execution System (WES) functionality
   - Inventory management
   - Order processing
   - Location management
   - Task execution
   - Batch and wave processing

## Documentation Structure

### Schema System Guide
- [[Database.Auth System Guide]]
- [[Database.Core System Guide]]
- [[Database.Forge System Guide]]

### Schema Documentation
Detailed documentation for each schema:
- [[Database.Auth Schema]]
- [[Database.Core Schema]]
- [[Database.Forge Schema]]

### Default Data Documentation
Each schema includes default data for lookup tables and essential system configuration:
- [[Database.Auth Default Data]]
- [[Database.Core Default Data]]
- [[Database.Forge Default Data]]

## Database Design Principles
1. **Consistent Naming**
   - Tables use singular form (e.g., `user` not `users`)
   - Primary keys use `{table_name}_id` format
   - Foreign keys reference the full primary key name
   - Status columns use `{entity}_status_id` format

2. **Data Integrity**
   - Foreign key constraints enforce referential integrity
   - Default constraints provide sensible fallback values
   - Check constraints ensure data validity
   - Unique constraints prevent duplicate records

3. **Audit Trail**
   - Creation and modification timestamps on relevant tables
   - User tracking for create/modify operations
   - Comprehensive transaction logging in core schema

4. **Status Management**
   - Consistent status table structure across schemas
   - Status tables include description fields
   - Status changes are tracked in transaction log

## Getting Started
1. Review the schema-specific documentation to understand the data model
2. Check the default data documentation for initial setup requirements
3. Follow proper naming conventions when extending the database
4. Ensure new tables adhere to the established patterns for consistency

## Navigation
- [[Database.Auth Schema]] - Authentication and authorization
- [[Database.Core Schema]] - Shared functionality
- [[Database.Forge Schema]] - Warehouse execution system
- [[Database.Database Conventions]] - Naming and design standards 