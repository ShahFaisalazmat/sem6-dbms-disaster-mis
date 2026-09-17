-- 1. Incident Statistics
SELECT Location, DisasterType, SeverityLevel, COUNT(*) AS IncidentCount
FROM Incident
GROUP BY Location, DisasterType, SeverityLevel;

-- 2. Resource Utilization
SELECT r.ResourceName,
       SUM(d.QuantityDispatched) AS TotalDispatched,
       ISNULL(SUM(c.QuantityConsumed), 0) AS TotalConsumed
FROM Dispatch d
JOIN AllocationDetail a ON d.AllocationID = a.AllocationID
JOIN Resource r ON a.ResourceID = r.ResourceID
LEFT JOIN ConsumptionRecord c ON d.DispatchID = c.DispatchID
GROUP BY r.ResourceName;

-- 3. Response Time (requires TeamAssignment data)
SELECT TOP 5
    i.IncidentID,
    i.TimeReported,
    ta.AssignedTime,
    DATEDIFF(MINUTE, i.TimeReported, ta.AssignedTime) AS ResponseMinutes
FROM Incident i
JOIN TeamAssignment ta ON i.IncidentID = ta.IncidentID
WHERE ta.AssignedTime IS NOT NULL;

-- 4. Financial Summary
SELECT TransactionType, SUM(Amount) AS TotalAmount, COUNT(*) AS TransactionCount
FROM [Transaction]
WHERE Status = 'Completed'
GROUP BY TransactionType;

-- 5. Approval Workflow
SELECT r.RequestID, r.RequestType, r.Status AS RequestStatus,
       a.Status AS ApprovalStatus, a.Comments, a.Timestamp AS ApprovalDate
FROM Request r
LEFT JOIN Approval a ON r.RequestID = a.RequestID
ORDER BY r.CreatedAt DESC;

USE DisasterMIS;
GO

-- 1. Add FieldOfficer role (if not exists)
IF NOT EXISTS (SELECT 1 FROM Role WHERE RoleName = 'FieldOfficer')
BEGIN
    INSERT INTO Role (RoleName) VALUES ('FieldOfficer');
    PRINT 'FieldOfficer role added.';
END
ELSE
BEGIN
    PRINT 'FieldOfficer role already exists.';
END
GO

-- 2. Verify RoleID for FieldOfficer
DECLARE @FieldRoleID INT;
SELECT @FieldRoleID = RoleID FROM Role WHERE RoleName = 'FieldOfficer';
PRINT 'FieldOfficer RoleID: ' + CAST(@FieldRoleID AS VARCHAR);
GO

-- 3. Add FieldOfficer user (if not exists)
IF NOT EXISTS (SELECT 1 FROM [User] WHERE Email = 'field@disaster.com')
BEGIN
    INSERT INTO [User] (Name, Email, PasswordHash, RoleID, Status)
    VALUES ('Field Officer', 'field@disaster.com', 'field123', 
            (SELECT RoleID FROM Role WHERE RoleName = 'FieldOfficer'), 'Active');
    PRINT 'FieldOfficer user added.';
END
ELSE
BEGIN
    PRINT 'FieldOfficer user already exists.';
END
GO

-- 4. Verify all users
SELECT u.UserID, u.Name, u.Email, u.PasswordHash, r.RoleName, u.Status
FROM [User] u
INNER JOIN Role r ON u.RoleID = r.RoleID
ORDER BY r.RoleName, u.UserID;
GO