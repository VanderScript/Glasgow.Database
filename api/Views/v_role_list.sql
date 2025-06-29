CREATE VIEW [api].[v_role_list]
AS
SELECT 
    r.role_id as roleId,
    r.role as roleName,
    COUNT(DISTINCT urm.user_id) as userCount,
    COUNT(DISTINCT rcm.claim_id) as claimCount
FROM auth.roles r
LEFT JOIN auth.user_role_mapping urm ON r.role_id = urm.role_id
LEFT JOIN auth.role_claim_mapping rcm ON r.role_id = rcm.role_id
GROUP BY r.role_id, r.role; 