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