-- ==================================================================
-- Seed data for AUTH schema lookup / enumeration tables
-- Author: Zachery Vanderford
-- ==================================================================

------------------------------------------------------------
-- ACCESS LEVEL MAP
------------------------------------------------------------
INSERT INTO auth.access_level_map ( level, lvl_description) VALUES
(0, 'None'),
(1, 'View'),
(2, 'Edit'),
(3, 'Delete'),
(4, 'SuperUser');
GO

------------------------------------------------------------
-- ROLES
-- Note: role_id is IDENTITY, so we don't specify it
------------------------------------------------------------
INSERT INTO auth.roles (role) VALUES
('NONE'),
('VIEWONLY'),
('EDITONLY'),
('ADMIN'),
('SUPERUSER');
GO

------------------------------------------------------------
-- SYSTEM USERS
-- These users are pre-defined with specific GUIDs to ensure consistency
-- Note: user_id has DEFAULT NEWID(), but we override for system users
------------------------------------------------------------
INSERT INTO auth.users 
    ([user_id], [username], [password_hash], [password_salt], [email], [email_verified], [is_active], [date_created_utc], [date_updated_utc]) 
VALUES
    -- NONE user - represents no user or anonymous access
    ('00000000-0000-0000-0000-000000000001', 'NONE', 
     'SystemUserNoPasswordHash', 'SystemUserNoPasswordSalt',
     NULL, 0, 1, GETUTCDATE(), GETUTCDATE()),
    -- SYSTEM user - represents system operations
    ('00000000-0000-0000-0000-000000000002', 'SYSTEM', 
     'SystemUserNoPasswordHash', 'SystemUserNoPasswordSalt',
     NULL, 0, 1, GETUTCDATE(), GETUTCDATE());
GO 