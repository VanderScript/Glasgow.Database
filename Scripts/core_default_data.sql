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
(4, 'PICKING_AREA', 'Area designated for picking items'),
(5, 'PACKING_AREA', 'Area designated for packing items'),
(6, 'QUALITY_CHECK', 'Area designated for quality checks'),
(7, 'STAGING_AREA', 'Temporary holding area before dispatch'),
(8, 'SHIPPING_AREA', 'Area designated for final shipping preparations'),
(9, 'SHIPPING_LANE', 'Lane where items are consolidated for shipping'),
(10, 'RETURN_AREA', 'Area designated for processing returns');
GO


------------------------------------------------------------
-- LPN STATE
------------------------------------------------------------
INSERT INTO core.lpn_state (lpn_state_id, state_code, description) VALUES
(1, 'CREATED', 'LPN created'),
(2, 'PLANNED', 'LPN is planned for processing'),
(3, 'AVAILABLE', 'LPN is available for use'),
(4, 'ROUTED', 'LPN has been routed to a destination'),
(5, 'WORKING', 'LPN is currently being processed'),
(6, 'WORK_COMPLETE', 'LPN processing completed'),
(7, 'ROUTED_FINAL', 'LPN has been routed to final destination'),
(8, 'COMPLETE', 'LPN processing is complete'),
(9, 'CANCELLED', 'LPN processing has been cancelled'),
(10, 'LOST', 'LPN is lost and cannot be located'),
(11, 'ARCHIVED', 'LPN has been archived and is no longer active');
GO


------------------------------------------------------------
-- STATUS CODE
------------------------------------------------------------
INSERT INTO core.status_code (status_code_id, status_code, description) VALUES
(1, 'SUCCESS', 'Operation succeeded'),
(2, 'FAILED', 'Operation failed'),
(3, 'PENDING', 'Operation pending'),
(4, 'CANCELLED', 'Operation cancelled');
GO
