-- ==================================================================
-- Seed data for AUTH schema lookup / enumeration tables
-- Author: Zachery Vanderford
-- ==================================================================

------------------------------------------------------------
-- ACCESS LEVEL MAP
------------------------------------------------------------
INSERT INTO auth.access_level_map (access_level_id, level, lvl_description) VALUES
(1, 0, 'None'),
(2, 1, 'View'),
(3, 2, 'Edit'),
(4, 3, 'Delete'),
(5, 4, 'SuperUser');
GO

------------------------------------------------------------
-- ROLES
------------------------------------------------------------
INSERT INTO auth.roles (role_id, role) VALUES
(1, 'NONE'),
(2, 'VIEWONLY'),
(3, 'EDITONLY'),
(4, 'ADMIN'),
(99, 'SUPERUSER');
GO

------------------------------------------------------------
-- SYSTEM USERS
-- These users are pre-defined with specific GUIDs to ensure consistency
------------------------------------------------------------
INSERT INTO auth.users (user_id, username, password_hash, password_salt) VALUES
-- NONE user - represents no user or anonymous access
('00000000-0000-0000-0000-000000000001', 'NONE', 
 'SystemUserNoPasswordHash', 'SystemUserNoPasswordSalt'),
-- SYSTEM user - represents system operations
('00000000-0000-0000-0000-000000000002', 'SYSTEM', 
 'SystemUserNoPasswordHash', 'SystemUserNoPasswordSalt');
GO 