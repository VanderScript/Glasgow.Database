/*
Post-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.		
 Use SQLCMD syntax to include a file in the post-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the post-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/
-- ==================================================================
-- Seed data for CORE schema lookup / enumeration tables
-- Author: Zachery Vanderford
-- ==================================================================

------------------------------------------------------------
-- ACTION TYPE
------------------------------------------------------------
INSERT INTO core.transaction_action_type (action_type_id, action_code, description) VALUES
(1, 'CREATE',  'Record creation'),
(2, 'UPDATE',  'Record update'),
(3, 'DELETE',  'Record deletion'),
(4, 'ROUTE',  'Record routing'),
(5, 'VALIDATE',  'Record validation');
GO


------------------------------------------------------------
-- DESTINATION STATE
------------------------------------------------------------
INSERT INTO core.destination_state (destination_state_id, state_code, description) VALUES
(1, 'AVAILABLE',   'Destination is available'),
(2, 'BLOCKED',  'Destination is blocked from use'),
(3, 'FULL',   'Destination is full and cannot accept more items'),
(4, 'DISABLED-SOFTWARE', 'Destination is disabled by software and cannot be used'),
(5, 'DISABLED-HARDWARE', 'Destination is disabled by hardware and cannot be used'),
(6, 'UNDER_MAINTENANCE', 'Destination is under maintenance and cannot be used');
GO


------------------------------------------------------------
-- DESTINATION TYPE
------------------------------------------------------------
INSERT INTO core.destination_type (destination_type_id, type_code, description) VALUES
(1, 'RECEIVING_AREA', 'Area designated for receiving items'),
(2, 'STORAGE_AREA', 'Area designated for storage of items'),
(3, 'INVENTORY_AREA', 'Area designated for inventory storage'),
(4, 'PICKING_AREA',   'Area designated for picking items'),
(5, 'PACKING_AREA',   'Area designated for packing items'),
(6, 'QUALITY_CHECK',  'Area designated for quality checks'),
(7, 'STAGING_AREA',   'Temporary holding area before dispatch'),
(8, 'SHIPPING_AREA',   'Area designated for final shipping preparations'),
(9, 'SHIPPING_LANE',  'Lane where items are consolidated for shipping'),
(10, 'RETURN_AREA',    'Area designated for processing returns');

GO


------------------------------------------------------------
-- LPN STATE
------------------------------------------------------------
INSERT INTO core.lpn_state (lpn_state_id, state_code, description) VALUES
(1, 'CREATED',     'LPN created'),
(2, 'PLANNED',     'LPN is planned for processing'),
(3, 'AVAILABLE', 'LPN is available for use'),
(4, 'ROUTED',  'LPN has been routed to a destination'),
(5, 'WORKING',  'LPN is currently being processed'),
(6, 'WORK_COMPLETE',  'LPN processing completed'),
(7, 'ROUTED_FINAL',  'LPN has been routed to final destination'),
(8, 'COMPLETE',  'LPN processing is complete'),
(9, 'CANCELLED',  'LPN processing has been cancelled'),
(10, 'LOST',  'LPN is lost and cannot be located'),
(11, 'ARCHIVED',  'LPN has been archived and is no longer active');
GO


------------------------------------------------------------
-- STATUS CODE
------------------------------------------------------------
INSERT INTO core.status_code (status_code_id, status_code, description) VALUES
(1, 'SUCCESS',   'Operation succeeded'),
(2, 'FAILED',    'Operation failed'),
(3, 'PENDING',   'Operation pending'),
(4, 'CANCELLED', 'Operation cancelled');
GO

-- ================================
-- Forge Reference Data Seed Script
-- Inserts only (no schema changes)
-- ================================

-- TRANSFER ORDER TYPES
INSERT INTO forge.transfer_order_type (transfer_order_type_id, transfer_order_type_code, description) VALUES
(1, 'CUSTOMER_GENERATED', 'Customer generated order'),
(2, 'INTERNAL_GENERATED', 'Internal generated order'),
(3, 'MANUAL_CREATED', 'Manual created order');

-- TRANSFER ORDER STATUS
INSERT INTO forge.transfer_order_status (status_id, status_code, description) VALUES
(1, 'CREATED',        'Order is created and ready'),
(2, 'OPEN',          'Order is open and pending execution'),
(3, 'ACTIVE',        'Order is active to be worked on'),
(4, 'WORKING',       'Order is being worked on'),
(5, 'COMPLETED',     'Order has been completed'),
(6, 'CANCELLED',     'Order has been cancelled'),
(7, 'FAILED',        'Order could not be completed'),
(8, 'CLOSED_INCOMPLETE', 'Order is closed and not completely fulfilled'),
(9, 'ARCHIVED',         'Order has been archived');

-- FILL METHOD
INSERT INTO forge.fill_method (fill_method_id, fill_method_code, description) VALUES
(1, 'FILL_OR_KILL', 'Must be completely fulfilled or cancelled'),
(2, 'FILL_AND_KILL','Fulfill what is available, cancel the rest'),
(3, 'PARTIAL',      'Allow partial fulfillment');
-- TASK STATES
INSERT INTO forge.task_state (task_state_id, state_code, description) VALUES
(1, 'CREATED',        'Task is created and ready'),
(2, 'PLANNED',     'Task is planned and ready'),
(3, 'ACTIVE',      'Task is active to be worked on'),
(4, 'WORKING',     'Task is being worked on'),
(5, 'SKIPPED',     'Task has been skipped'),
(6, 'COMPLETED',   'Task has been completed'),
(7, 'CANCELLED',   'Task has been cancelled'),
(8, 'FAILED',      'Task could not be completed'),
(9, 'ARCHIVED',    'Task has been archived');


-- MOVEMENT TYPES
INSERT INTO forge.movement_type (movement_type_id, movement_code, description) VALUES
(101, 'PICK', 'Pick inventory from location'),
(199, 'PICK_MANUAL', 'Pick inventory from location manual'),
(201, 'PUT', 'Put inventory into location'),
(299, 'PUT_MANUAL', 'Put inventory into location manual'),
(301, 'B2B_PICK', 'Bin to bin pick'),
(399, 'B2B_PICK_MANUAL', 'Bin to bin pick manual'),
(401, 'B2B_PUT', 'Bin to bin put'),
(499, 'B2B_PUT_MANUAL', 'Bin to bin put manual'),
(501, 'ADJUST_DOWN_COUNT', 'Inventory adjustment down'),
(502, 'ADJUST_DOWN_LOST', 'Inventory adjustment down lost'),
(503, 'ADJUST_DOWN_DAMAGED', 'Inventory adjustment down damaged'),
(599, 'ADJUST_DOWN_MANUAL', 'Inventory adjustment down manual'),
(601, 'ADJUST_UP_COUNT', 'Inventory adjustment up'),
(602, 'ADJUST_UP_FOUND', 'Inventory adjustment up found'),
(699, 'ADJUST_UP_MANUAL', 'Inventory adjustment up manual'),
(701, 'COUNT', 'Count inventory');

-- VALIDATION TYPES
INSERT INTO forge.validation_type (validation_type_id, validation_code, description) VALUES
(1, 'NONE',       'No scan required'),
(2, 'SCAN_ONCE',  'Scan one UPC per task'),
(3, 'SCAN_ALL',   'Scan all units for task');

-- BATCH STATE
INSERT INTO forge.batch_state (batch_state_id, state_code, description) VALUES
(1, 'CREATED',   'Batch has been created'),
(2, 'RELEASED',  'Batch has been released for execution'),
(3, 'ACTIVE',    'Batch is actively executing'),
(4, 'COMPLETED', 'Batch has completed execution');

-- WAVE STATE
INSERT INTO forge.wave_state (wave_state_id, state_code, description) VALUES
(1, 'CREATED',   'Wave has been created'),
(2, 'PLANNED',   'Wave is planned and ready'),
(3, 'ACTIVE',    'Wave is actively being processed'),
(4, 'RELEASED',  'Wave has been released'),
(5, 'COMPLETED', 'Wave has completed execution');

-- BATCH TYPE
INSERT INTO forge.batch_type (batch_type_id, type_code, description) VALUES
(1, 'STANDARD',     'Generic execution batch'),
(2, 'ROUTE_BASED',  'Route‑specific execution grouping');

-- INVENTORY STATUS
INSERT INTO forge.inventory_status (status_id, status_code, description) VALUES
(1, 'AVAILABLE', 'Available for allocation'),
(2, 'HOLD',      'Not available due to hold or quarantine'),
(3, 'WORKING',   'In use by a task'),
(4, 'COMPLETED', 'Completed and ready for use'),
(5, 'ARCHIVED',  'Archived and no longer in use');

-- ITEM STATUS
INSERT INTO forge.item_status (status_id, status_code, description) VALUES
(1, 'ACTIVE',   'Item is in active use'),
(2, 'INACTIVE', 'Item is not currently active'),
(3, 'BLOCKED',  'Item is blocked or restricted'),
(4, 'ARCHIVED', 'Item is archived and no longer in use');

-- LOCATION STATUS
INSERT INTO forge.storage_location_status (status_id, status_code, description) VALUES
(1, 'AVAILABLE', 'Location is available for use'),
(2, 'BLOCKED',   'Location is blocked or restricted'),
(3, 'INACTIVE',  'Location is inactive or out of service');

-- LOCATION TYPES
INSERT INTO forge.storage_location_type (location_type_id, location_type_code, description) VALUES
(1,  'NONE',      'Unspecified or generic location'),
(2,  'BUILDING',  'Entire building or facility'),
(3,  'SECTION',   'Section of a building'),
(4,  'AREA',      'Area within a section'),
(5,  'ZONE',      'Zone within an area'),
(6,  'AISLE',     'Aisle within a zone'),
(7,  'SHELF',     'Shelf within an aisle'),
(8,  'SLOT',      'Slot or sub‑shelf position'),
(9,  'CONTAINER', 'Tote, box, or other mobile storage'),
(10, 'BIN',       'Fixed bin location for inventory');

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
