CREATE DATABASE DisasterMIS;
GO

USE DisasterMIS;
GO
CREATE TABLE Role (
    RoleID INT PRIMARY KEY IDENTITY(1,1),
    RoleName NVARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE [User] (
    UserID INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100) NOT NULL,
    Email NVARCHAR(100) UNIQUE NOT NULL,
    PasswordHash NVARCHAR(255) NOT NULL,
    RoleID INT NOT NULL,
    Status NVARCHAR(20) DEFAULT 'Active',
    FOREIGN KEY (RoleID) REFERENCES Role(RoleID)
);

CREATE TABLE Permission (
    PermissionID INT PRIMARY KEY IDENTITY(1,1),
    PermissionName NVARCHAR(100) NOT NULL
);

CREATE TABLE RolePermission (
    RoleID INT,
    PermissionID INT,
    PRIMARY KEY (RoleID, PermissionID),
    FOREIGN KEY (RoleID) REFERENCES Role(RoleID),
    FOREIGN KEY (PermissionID) REFERENCES Permission(PermissionID)
);

CREATE TABLE Request (
    RequestID INT PRIMARY KEY IDENTITY(1,1),
    RequestType NVARCHAR(50),
    CreatedBy INT,
    Status NVARCHAR(20) DEFAULT 'Pending',
    CreatedAt DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (CreatedBy) REFERENCES [User](UserID)
);

CREATE TABLE Approval (
    ApprovalID INT PRIMARY KEY IDENTITY(1,1),
    RequestID INT,
    ApprovedBy INT,
    Status NVARCHAR(20),
    Comments NVARCHAR(255),
    Timestamp DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (RequestID) REFERENCES Request(RequestID),
    FOREIGN KEY (ApprovedBy) REFERENCES [User](UserID)
);

CREATE TABLE Citizen (
    CitizenID INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100),
    Phone NVARCHAR(20),
    Email NVARCHAR(100),
    Address NVARCHAR(255)
);

CREATE TABLE Incident (
    IncidentID INT PRIMARY KEY IDENTITY(1,1),
    Location NVARCHAR(100),
    Latitude DECIMAL(9,6),
    Longitude DECIMAL(9,6),
    DisasterType NVARCHAR(50),
    SeverityLevel NVARCHAR(20),
    PriorityLevel INT,
    TimeReported DATETIME,
    Status NVARCHAR(20),
    ReporterID INT NULL,
    ReporterContact NVARCHAR(50),
    FOREIGN KEY (ReporterID) REFERENCES Citizen(CitizenID)
);

CREATE TABLE IncidentStatusLog (
    LogID INT PRIMARY KEY IDENTITY(1,1),
    IncidentID INT,
    Status NVARCHAR(50),
    Timestamp DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (IncidentID) REFERENCES Incident(IncidentID)
);

CREATE TABLE RescueTeam (
    TeamID INT PRIMARY KEY IDENTITY(1,1),
    TeamType NVARCHAR(50),
    CurrentLatitude DECIMAL(9,6),
    CurrentLongitude DECIMAL(9,6),
    AvailabilityStatus NVARCHAR(20),
    Capacity INT
);

CREATE TABLE TeamAssignment (
    AssignmentID INT PRIMARY KEY IDENTITY(1,1),
    TeamID INT,
    IncidentID INT,
    RequestID INT,
    AssignedTime DATETIME,
    CompletionTime DATETIME,
    Status NVARCHAR(20),
    Priority INT,
    AssignedBy INT,
    FOREIGN KEY (TeamID) REFERENCES RescueTeam(TeamID),
    FOREIGN KEY (IncidentID) REFERENCES Incident(IncidentID),
    FOREIGN KEY (RequestID) REFERENCES Request(RequestID),
    FOREIGN KEY (AssignedBy) REFERENCES [User](UserID)
);
CREATE TABLE Warehouse (
    WarehouseID INT PRIMARY KEY IDENTITY(1,1),
    Location NVARCHAR(100),
    Latitude DECIMAL(9,6),
    Longitude DECIMAL(9,6),
    ManagerID INT,
    FOREIGN KEY (ManagerID) REFERENCES [User](UserID)
);

CREATE TABLE Resource (
    ResourceID INT PRIMARY KEY IDENTITY(1,1),
    ResourceName NVARCHAR(100),
    ResourceType NVARCHAR(50)
);

CREATE TABLE Inventory (
    WarehouseID INT,
    ResourceID INT,
    Quantity INT,
    ThresholdLevel INT,
    PRIMARY KEY (WarehouseID, ResourceID),
    FOREIGN KEY (WarehouseID) REFERENCES Warehouse(WarehouseID),
    FOREIGN KEY (ResourceID) REFERENCES Resource(ResourceID)
);

CREATE TABLE ResourceRequest (
    RequestID INT PRIMARY KEY,
    IncidentID INT,
    RequestedBy INT,
    TotalRequiredQuantity INT,
    UrgencyLevel NVARCHAR(20),
    FOREIGN KEY (RequestID) REFERENCES Request(RequestID),
    FOREIGN KEY (IncidentID) REFERENCES Incident(IncidentID),
    FOREIGN KEY (RequestedBy) REFERENCES [User](UserID)
);

CREATE TABLE AllocationDetail (
    AllocationID INT PRIMARY KEY IDENTITY(1,1),
    RequestID INT,
    ResourceID INT,
    QuantityAllocated INT,
    AllocationDate DATETIME,
    Status NVARCHAR(20),
    FOREIGN KEY (RequestID) REFERENCES ResourceRequest(RequestID),
    FOREIGN KEY (ResourceID) REFERENCES Resource(ResourceID)
);

CREATE TABLE Dispatch (
    DispatchID INT PRIMARY KEY IDENTITY(1,1),
    AllocationID INT,
    WarehouseID INT,
    QuantityDispatched INT,
    DispatchTime DATETIME,
    DeliveredTime DATETIME,
    DeliveryStatus NVARCHAR(20),
    RecipientConfirmed BIT,
    FOREIGN KEY (AllocationID) REFERENCES AllocationDetail(AllocationID),
    FOREIGN KEY (WarehouseID) REFERENCES Warehouse(WarehouseID)
);

CREATE TABLE ConsumptionRecord (
    ConsumptionID INT PRIMARY KEY IDENTITY(1,1),
    DispatchID INT,
    QuantityConsumed INT,
    ConsumptionTime DATETIME,
    IncidentID INT,
    FOREIGN KEY (DispatchID) REFERENCES Dispatch(DispatchID),
    FOREIGN KEY (IncidentID) REFERENCES Incident(IncidentID)
);
CREATE TABLE Hospital (
    HospitalID INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100),
    Location NVARCHAR(100),
    Latitude DECIMAL(9,6),
    Longitude DECIMAL(9,6)
);

CREATE TABLE BedAvailability (
    HospitalID INT PRIMARY KEY,
    TotalBeds INT,
    AvailableBeds INT,
    LastUpdated DATETIME,
    FOREIGN KEY (HospitalID) REFERENCES Hospital(HospitalID)
);

CREATE TABLE Patient (
    PatientID INT PRIMARY KEY IDENTITY(1,1),
    IncidentID INT,
    HospitalID INT,
    Status NVARCHAR(20),
    AdmissionTime DATETIME,
    DischargeTime DATETIME,
    FOREIGN KEY (IncidentID) REFERENCES Incident(IncidentID),
    FOREIGN KEY (HospitalID) REFERENCES Hospital(HospitalID)
);

CREATE TABLE EscalationRule (
    RuleID INT PRIMARY KEY IDENTITY(1,1),
    HospitalID INT,
    ThresholdAvailableBeds INT,
    EscalationTargetHospitalID INT,
    PriorityLevel INT,
    FOREIGN KEY (HospitalID) REFERENCES Hospital(HospitalID),
    FOREIGN KEY (EscalationTargetHospitalID) REFERENCES Hospital(HospitalID)
);
CREATE TABLE DisasterBudget (
    BudgetID INT PRIMARY KEY IDENTITY(1,1),
    IncidentID INT,
    AllocatedAmount DECIMAL(12,2),
    SpentAmount DECIMAL(12,2),
    RemainingAmount DECIMAL(12,2),
    LastUpdated DATETIME,
    FOREIGN KEY (IncidentID) REFERENCES Incident(IncidentID)
);

CREATE TABLE [Transaction] (
    TransactionID INT PRIMARY KEY IDENTITY(1,1),
    IncidentID INT,
    TransactionType NVARCHAR(50),
    Amount DECIMAL(12,2),
    TransactionDate DATETIME,
    Description NVARCHAR(255),
    ReferenceNumber NVARCHAR(100),
    Status NVARCHAR(20),
    FOREIGN KEY (IncidentID) REFERENCES Incident(IncidentID)
);

CREATE TABLE Donation (
    DonationID INT PRIMARY KEY IDENTITY(1,1),
    TransactionID INT,
    DonorName NVARCHAR(100),
    DonorType NVARCHAR(50),
    FOREIGN KEY (TransactionID) REFERENCES [Transaction](TransactionID)
);

CREATE TABLE Expense (
    ExpenseID INT PRIMARY KEY IDENTITY(1,1),
    TransactionID INT,
    RequestID INT,
    Purpose NVARCHAR(255),
    FOREIGN KEY (TransactionID) REFERENCES [Transaction](TransactionID),
    FOREIGN KEY (RequestID) REFERENCES Request(RequestID)
);

CREATE TABLE Procurement (
    ProcurementID INT PRIMARY KEY IDENTITY(1,1),
    TransactionID INT,
    SupplierName NVARCHAR(100),
    FOREIGN KEY (TransactionID) REFERENCES [Transaction](TransactionID)
);
CREATE TABLE AuditLog (
    LogID INT PRIMARY KEY IDENTITY(1,1),
    UserID INT,
    ActionType NVARCHAR(20),
    TableName NVARCHAR(50),
    RecordID INT,
    OldValue NVARCHAR(MAX),
    NewValue NVARCHAR(MAX),
    Timestamp DATETIME DEFAULT GETDATE(),
    IPAddress NVARCHAR(50),
    FOREIGN KEY (UserID) REFERENCES [User](UserID)
);

CREATE TABLE Notification (
    NotificationID INT PRIMARY KEY IDENTITY(1,1),
    UserID INT,
    Type NVARCHAR(50),
    Message NVARCHAR(255),
    IsRead BIT DEFAULT 0,
    CreatedAt DATETIME DEFAULT GETDATE(),
    RelatedEntityType NVARCHAR(50),
    RelatedRecordID INT,
    FOREIGN KEY (UserID) REFERENCES [User](UserID)
);

CREATE TABLE SystemTransactionLog (
    SysTransactionID INT PRIMARY KEY IDENTITY(1,1),
    OperationType NVARCHAR(50),
    StartTime DATETIME,
    EndTime DATETIME,
    Status NVARCHAR(20)
);



-- ============================================================
-- Transaction 1: Allocate Resources and Update Inventory
-- Demonstrates: Atomicity, Consistency, Isolation, Durability
-- ============================================================
GO
CREATE OR ALTER PROCEDURE usp_AllocateResources
    @RequestID INT,
    @ResourceID INT,
    @QuantityAllocated INT,
    @WarehouseID INT,
    @AllocatedBy INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @CurrentStock INT;
    DECLARE @AllocationID INT;
    DECLARE @ErrorMessage NVARCHAR(4000);
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- 1. Check available stock
        SELECT @CurrentStock = Quantity 
        FROM Inventory 
        WHERE WarehouseID = @WarehouseID AND ResourceID = @ResourceID;
        
        IF @CurrentStock IS NULL
            THROW 50001, 'Resource not found in this warehouse.', 1;
        
        IF @CurrentStock < @QuantityAllocated
            THROW 50002, 'Insufficient stock in warehouse.', 1;
        
        -- 2. Create allocation record
        INSERT INTO AllocationDetail (RequestID, ResourceID, QuantityAllocated, AllocationDate, Status)
        VALUES (@RequestID, @ResourceID, @QuantityAllocated, GETDATE(), 'Pending');
        
        SET @AllocationID = SCOPE_IDENTITY();
        
        -- 3. Update inventory (deduct stock)
        UPDATE Inventory 
        SET Quantity = Quantity - @QuantityAllocated
        WHERE WarehouseID = @WarehouseID AND ResourceID = @ResourceID;
        
        -- 4. (Optional) Update ResourceRequest status if fully allocated
        -- (You can add logic here)
        
        COMMIT TRANSACTION;
        
        SELECT 'Success' AS Status, @AllocationID AS AllocationID;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        SET @ErrorMessage = ERROR_MESSAGE();
        SELECT 'Failed' AS Status, @ErrorMessage AS ErrorMessage;
    END CATCH
END
GO


-- ============================================================
-- Transaction 2: Assign Rescue Team and Update Availability
-- Demonstrates: Explicit rollback on failure
-- ============================================================
GO
CREATE OR ALTER PROCEDURE usp_AssignTeam
    @TeamID INT,
    @IncidentID INT,
    @RequestID INT,
    @Priority INT,
    @AssignedBy INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @CurrentStatus NVARCHAR(20);
    DECLARE @ErrorMessage NVARCHAR(4000);
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- 1. Check team availability
        SELECT @CurrentStatus = AvailabilityStatus 
        FROM RescueTeam 
        WHERE TeamID = @TeamID;
        
        IF @CurrentStatus != 'Available'
            THROW 50010, 'Team is not available for assignment.', 1;
        
        -- 2. Create team assignment
        INSERT INTO TeamAssignment (TeamID, IncidentID, RequestID, AssignedTime, Status, Priority, AssignedBy)
        VALUES (@TeamID, @IncidentID, @RequestID, GETDATE(), 'Assigned', @Priority, @AssignedBy);
        
        -- 3. Update team status to 'Assigned'
        UPDATE RescueTeam 
        SET AvailabilityStatus = 'Assigned'
        WHERE TeamID = @TeamID;
        
        -- 4. Update the request status to 'Approved' (if not already)
        UPDATE Request 
        SET Status = 'Approved'
        WHERE RequestID = @RequestID AND Status = 'Pending';
        
        COMMIT TRANSACTION;
        SELECT 'Assignment successful' AS Status;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        SET @ErrorMessage = ERROR_MESSAGE();
        SELECT 'Assignment failed' AS Status, @ErrorMessage AS ErrorMessage;
    END CATCH
END
GO

-- ============================================================
-- Rollback Demo: Attempt to allocate more than available stock
-- ============================================================
-- First, insert sample data for testing
INSERT INTO Warehouse (Location, Latitude, Longitude) VALUES ('Test WH', 0, 0);
INSERT INTO Resource (ResourceName, ResourceType) VALUES ('Test Food', 'Food');
INSERT INTO Inventory (WarehouseID, ResourceID, Quantity, ThresholdLevel) 
VALUES (1, 1, 100, 10);

-- This will succeed (allocate 50)
EXEC usp_AllocateResources @RequestID = 1, @ResourceID = 1, @QuantityAllocated = 50, @WarehouseID = 1, @AllocatedBy = 1;

-- This will fail and rollback (allocate 200 > 50 remaining)
EXEC usp_AllocateResources @RequestID = 2, @ResourceID = 1, @QuantityAllocated = 200, @WarehouseID = 1, @AllocatedBy = 1;

-- Check that inventory remains 50 (rollback prevented incorrect deduction)
SELECT * FROM Inventory WHERE ResourceID = 1;

--- Trigger 1: Auto‑Update Inventory After Dispatch
GO
CREATE TRIGGER trg_AfterDispatch
ON Dispatch
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE Inventory
    SET Quantity = Inventory.Quantity - ins.QuantityDispatched
    FROM Inventory
    INNER JOIN inserted ins ON Inventory.WarehouseID = ins.WarehouseID
    INNER JOIN AllocationDetail a ON ins.AllocationID = a.AllocationID
    WHERE Inventory.ResourceID = a.ResourceID;
END
GO


-- Trigger 2: Auto‑Update Team Status on Assignment Completion
GO
CREATE TRIGGER trg_TeamAssignmentComplete
ON TeamAssignment
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE RescueTeam
    SET AvailabilityStatus = 'Available'
    FROM RescueTeam
    INNER JOIN inserted i ON RescueTeam.TeamID = i.TeamID
    INNER JOIN deleted d ON i.AssignmentID = d.AssignmentID
    WHERE i.Status = 'Completed' AND d.Status != 'Completed';
END
GO


---- Trigger 3: Prevent Negative Stock
GO
CREATE TRIGGER trg_PreventNegativeStock
ON Inventory
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    IF EXISTS (SELECT 1 FROM inserted WHERE Quantity < 0)
    BEGIN
        RAISERROR('Cannot set inventory quantity below zero.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
    
    UPDATE Inventory
    SET Quantity = i.Quantity,
        ThresholdLevel = i.ThresholdLevel
    FROM Inventory inv
    INNER JOIN inserted i ON inv.WarehouseID = i.WarehouseID AND inv.ResourceID = i.ResourceID;
END
GO


-- Trigger 4: Automatic Audit Logging
GO
CREATE TRIGGER trg_Audit_Incident
ON Incident
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @Action NVARCHAR(20);
    DECLARE @RecordID INT;
    DECLARE @OldVal NVARCHAR(MAX);
    DECLARE @NewVal NVARCHAR(MAX);
    
    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
        SET @Action = 'UPDATE';
    ELSE IF EXISTS (SELECT * FROM inserted)
        SET @Action = 'INSERT';
    ELSE
        SET @Action = 'DELETE';
    
    IF @Action = 'INSERT'
    BEGIN
        SELECT @RecordID = IncidentID, @NewVal = 'New record' FROM inserted;
        INSERT INTO AuditLog (UserID, ActionType, TableName, RecordID, NewValue, IPAddress)
        VALUES (0, @Action, 'Incident', @RecordID, @NewVal, '0.0.0.0');
    END
    ELSE IF @Action = 'DELETE'
    BEGIN
        SELECT @RecordID = IncidentID, @OldVal = 'Deleted record' FROM deleted;
        INSERT INTO AuditLog (UserID, ActionType, TableName, RecordID, OldValue, IPAddress)
        VALUES (0, @Action, 'Incident', @RecordID, @OldVal, '0.0.0.0');
    END
    ELSE -- UPDATE
    BEGIN
        SELECT @RecordID = IncidentID FROM inserted;
        INSERT INTO AuditLog (UserID, ActionType, TableName, RecordID, OldValue, NewValue, IPAddress)
        VALUES (0, @Action, 'Incident', @RecordID, 'Old', 'New', '0.0.0.0');
    END
END
GO



---- SQL Script to Create Indexes
-- Single-column indexes
CREATE INDEX IX_Incident_TimeReported ON Incident(TimeReported);
CREATE INDEX IX_Incident_DisasterType ON Incident(DisasterType);
CREATE INDEX IX_Incident_Location ON Incident(Location);
CREATE INDEX IX_ResourceRequest_UrgencyLevel ON ResourceRequest(UrgencyLevel);
CREATE INDEX IX_Transaction_TransactionDate ON [Transaction](TransactionDate);

-- Composite indexes
CREATE INDEX IX_Inventory_Warehouse_Resource ON Inventory(WarehouseID, ResourceID);
CREATE INDEX IX_TeamAssignment_Status_Priority ON TeamAssignment(Status, Priority);

-- Additional foreign key indexes (already in DDL, but ensure they exist)
CREATE INDEX IX_Incident_ReporterID ON Incident(ReporterID);
CREATE INDEX IX_AllocationDetail_RequestID ON AllocationDetail(RequestID);
CREATE INDEX IX_Dispatch_AllocationID ON Dispatch(AllocationID);



--  Sample Data Generation
-- Insert 50,000 incidents
-- Drop existing trigger if it exists
DROP TRIGGER IF EXISTS trg_Audit_Incident;
GO

CREATE TRIGGER trg_Audit_Incident
ON Incident
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @Action NVARCHAR(20);
    DECLARE @RecordID INT;
    
    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
        SET @Action = 'UPDATE';
    ELSE IF EXISTS (SELECT * FROM inserted)
        SET @Action = 'INSERT';
    ELSE
        SET @Action = 'DELETE';
    
    IF @Action = 'INSERT'
    BEGIN
        SELECT @RecordID = IncidentID FROM inserted;
        INSERT INTO AuditLog (UserID, ActionType, TableName, RecordID, NewValue, IPAddress)
        VALUES (NULL, @Action, 'Incident', @RecordID, 'New record', '0.0.0.0');
    END
    ELSE IF @Action = 'DELETE'
    BEGIN
        SELECT @RecordID = IncidentID FROM deleted;
        INSERT INTO AuditLog (UserID, ActionType, TableName, RecordID, OldValue, IPAddress)
        VALUES (NULL, @Action, 'Incident', @RecordID, 'Deleted record', '0.0.0.0');
    END
    ELSE -- UPDATE
    BEGIN
        SELECT @RecordID = IncidentID FROM inserted;
        INSERT INTO AuditLog (UserID, ActionType, TableName, RecordID, OldValue, NewValue, IPAddress)
        VALUES (NULL, @Action, 'Incident', @RecordID, 'Old', 'New', '0.0.0.0');
    END
END
GO

-- Query 1: Retrieve all incidents of a specific disaster type within a date range
SELECT IncidentID, Location, DisasterType, SeverityLevel, TimeReported
FROM Incident
WHERE DisasterType = 'Flood'
  AND TimeReported BETWEEN '2025-01-01' AND '2025-12-31';


  -- Query 2: Find pending resource requests with urgency level 'High', sorted by request date
  SELECT rr.RequestID, rr.TotalRequiredQuantity, r.CreatedAt
FROM ResourceRequest rr
JOIN Request r ON rr.RequestID = r.RequestID
WHERE rr.UrgencyLevel = 'High' AND r.Status = 'Pending'
ORDER BY r.CreatedAt DESC;


-- Query 3: Report total donations grouped by month for a specific year
SELECT YEAR(TransactionDate) AS Yr, MONTH(TransactionDate) AS Mo, SUM(Amount) AS TotalDonations
FROM [Transaction]
WHERE TransactionType = 'Donation' AND Status = 'Completed'
  AND TransactionDate BETWEEN '2025-01-01' AND '2025-12-31'
GROUP BY YEAR(TransactionDate), MONTH(TransactionDate)
ORDER BY Yr, Mo;



-- Test View: FieldOfficerView
CREATE VIEW FieldOfficerView AS
SELECT i.IncidentID, i.Location, i.DisasterType, i.SeverityLevel, i.Status AS IncidentStatus,
       rt.TeamID, rt.TeamType, rt.AvailabilityStatus,
       ta.Status AS AssignmentStatus, ta.AssignedTime,
       rr.TotalRequiredQuantity, rr.UrgencyLevel
FROM Incident i
LEFT JOIN TeamAssignment ta ON i.IncidentID = ta.IncidentID
LEFT JOIN RescueTeam rt ON ta.TeamID = rt.TeamID
LEFT JOIN ResourceRequest rr ON i.IncidentID = rr.IncidentID;

SELECT IncidentID, Location, DisasterType, TeamType, UrgencyLevel
FROM FieldOfficerView
WHERE DisasterType = 'Fire' AND UrgencyLevel = 'High';






USE DisasterMIS;
GO

-- 1. First, insert roles (if not already present)
INSERT INTO Role (RoleName) VALUES 
    ('Administrator'),
    ('EmergencyOperator'),
    ('WarehouseManager'),
    ('FinanceOfficer');
GO

-- 2. Verify roles were inserted
SELECT * FROM Role;
GO

-- 3. Now insert test users with valid RoleIDs (1,2,3,4 as per above order)
-- Administrator (RoleID = 1)
INSERT INTO [User] (Name, Email, PasswordHash, RoleID, Status)
VALUES ('Admin User', 'admin@disaster.com', 'admin123', 1, 'Active');

-- EmergencyOperator (RoleID = 2)
INSERT INTO [User] (Name, Email, PasswordHash, RoleID, Status)
VALUES ('Operator User', 'operator@disaster.com', 'operator123', 2, 'Active');

-- WarehouseManager (RoleID = 3)
INSERT INTO [User] (Name, Email, PasswordHash, RoleID, Status)
VALUES ('Warehouse Manager', 'warehouse@disaster.com', 'warehouse123', 3, 'Active');

-- FinanceOfficer (RoleID = 4)
INSERT INTO [User] (Name, Email, PasswordHash, RoleID, Status)
VALUES ('Finance Officer', 'finance@disaster.com', 'finance123', 4, 'Active');
GO

-- 4. Verify users
SELECT u.UserID, u.Name, u.Email, r.RoleName, u.Status
FROM [User] u
INNER JOIN Role r ON u.RoleID = r.RoleID;
GO






USE DisasterMIS;
GO

-- View 1: Finance Officer View
CREATE OR ALTER VIEW FinanceOfficerView
AS
SELECT 
    t.TransactionID,
    t.IncidentID,
    i.DisasterType,
    i.Location AS IncidentLocation,
    t.TransactionType,
    t.Amount,
    t.TransactionDate,
    t.Description,
    t.ReferenceNumber,
    t.Status AS TransactionStatus,
    d.DonorName,
    d.DonorType,
    e.Purpose AS ExpensePurpose,
    p.SupplierName
FROM [Transaction] t
LEFT JOIN Incident i ON t.IncidentID = i.IncidentID
LEFT JOIN Donation d ON t.TransactionID = d.TransactionID
LEFT JOIN Expense e ON t.TransactionID = e.TransactionID
LEFT JOIN Procurement p ON t.TransactionID = p.TransactionID;
GO

-- View 2: Field Officer View (for incidents and teams)
CREATE OR ALTER VIEW FieldOfficerView
AS
SELECT 
    i.IncidentID,
    i.Location,
    i.DisasterType,
    i.SeverityLevel,
    i.Status AS IncidentStatus,
    rt.TeamID,
    rt.TeamType,
    rt.AvailabilityStatus,
    ta.Status AS AssignmentStatus,
    ta.AssignedTime,
    rr.TotalRequiredQuantity,
    rr.UrgencyLevel
FROM Incident i
LEFT JOIN TeamAssignment ta ON i.IncidentID = ta.IncidentID
LEFT JOIN RescueTeam rt ON ta.TeamID = rt.TeamID
LEFT JOIN ResourceRequest rr ON i.IncidentID = rr.IncidentID;
GO

-- View 3: Warehouse Manager View (Inventory with low stock alert)
CREATE OR ALTER VIEW WarehouseManagerView
AS
SELECT 
    w.WarehouseID,
    w.Location AS WarehouseLocation,
    r.ResourceName,
    r.ResourceType,
    i.Quantity,
    i.ThresholdLevel,
    CASE WHEN i.Quantity <= i.ThresholdLevel THEN 'LOW STOCK' ELSE 'OK' END AS StockStatus
FROM Inventory i
JOIN Warehouse w ON i.WarehouseID = w.WarehouseID
JOIN Resource r ON i.ResourceID = r.ResourceID;
GO

-- View 4: Administrator Dashboard (System summary)
CREATE OR ALTER VIEW AdminDashboard
AS
SELECT 
    (SELECT COUNT(*) FROM Incident) AS TotalIncidents,
    (SELECT COUNT(*) FROM Incident WHERE Status NOT IN ('Resolved', 'Closed')) AS ActiveIncidents,
    (SELECT COUNT(*) FROM RescueTeam WHERE AvailabilityStatus = 'Available') AS AvailableTeams,
    (SELECT COUNT(*) FROM ResourceRequest rr INNER JOIN Request r ON rr.RequestID = r.RequestID WHERE r.Status = 'Pending') AS PendingRequests,
    ISNULL((SELECT SUM(Amount) FROM [Transaction] WHERE TransactionType = 'Donation' AND Status = 'Completed'), 0) AS TotalDonations,
    ISNULL((SELECT SUM(Amount) FROM [Transaction] WHERE TransactionType = 'Expense' AND Status = 'Completed'), 0) AS TotalExpenses;
GO



USE DisasterMIS;
GO

-- 1. Insert a Citizen (for reporting incidents)
INSERT INTO Citizen (Name, Phone, Email, Address)
VALUES ('John Doe', '03001234567', 'john@example.com', '123 Main St');
GO

-- 2. Insert Incidents (so dashboard shows >0)
INSERT INTO Incident (Location, Latitude, Longitude, DisasterType, SeverityLevel, PriorityLevel, TimeReported, Status, ReporterContact)
VALUES 
    ('Downtown', 40.7128, -74.0060, 'Flood', 'High', 1, GETDATE(), 'Reported', 'Caller: 911'),
    ('Northside', 34.0522, -118.2437, 'Earthquake', 'Critical', 2, GETDATE(), 'Assigned', 'Anonymous'),
    ('East End', 41.8781, -87.6298, 'Fire', 'Medium', 3, GETDATE(), 'Resolved', 'Citizen: Jane');
GO

-- 3. Insert Rescue Teams
INSERT INTO RescueTeam (TeamType, CurrentLatitude, CurrentLongitude, AvailabilityStatus, Capacity)
VALUES 
    ('Medical', 40.7128, -74.0060, 'Available', 10),
    ('Fire', 34.0522, -118.2437, 'Assigned', 8),
    ('Rescue', 41.8781, -87.6298, 'Available', 12);
GO

-- 4. Insert Warehouses, Resources, Inventory
INSERT INTO Warehouse (Location, Latitude, Longitude, ManagerID)
VALUES ('Downtown Warehouse', 40.7128, -74.0060, NULL),
       ('Northside Depot', 34.0522, -118.2437, NULL);
GO

INSERT INTO Resource (ResourceName, ResourceType)
VALUES ('Food Pack', 'Food'), ('Water Bottle', 'Water'), ('Medicine Kit', 'Medicine'), ('Tent', 'Shelter');
GO

-- Inventory: Warehouse 1 has some stock
INSERT INTO Inventory (WarehouseID, ResourceID, Quantity, ThresholdLevel)
VALUES 
    (1, 1, 500, 100),
    (1, 2, 1000, 200),
    (1, 3, 50, 20),
    (2, 1, 200, 50);
GO

-- 5. Insert a Request (Resource) so that Pending Requests appear
INSERT INTO Request (RequestType, CreatedBy, Status, CreatedAt)
VALUES ('Resource', 1, 'Pending', GETDATE());   -- Assuming UserID 1 exists from earlier
DECLARE @ReqID INT = SCOPE_IDENTITY();
INSERT INTO ResourceRequest (RequestID, IncidentID, RequestedBy, TotalRequiredQuantity, UrgencyLevel)
VALUES (@ReqID, 1, 1, 100, 'High');
GO

-- 6. Insert Financial Transactions (Donations and Expenses)
INSERT INTO [Transaction] (IncidentID, TransactionType, Amount, TransactionDate, Description, Status)
VALUES 
    (1, 'Donation', 5000.00, GETDATE(), 'Corporate donation', 'Completed'),
    (2, 'Expense', 1200.00, GETDATE(), 'Food procurement', 'Completed'),
    (3, 'Donation', 800.00, GETDATE(), 'Individual donor', 'Pending');
GO

-- Add donor details for the first transaction (TransactionID will depend on order; adjust if needed)
-- For simplicity, assume TransactionID 1 and 2 exist:
INSERT INTO Donation (TransactionID, DonorName, DonorType)
VALUES (1, 'Big Corp', 'Organization');
INSERT INTO Expense (TransactionID, RequestID, Purpose)
VALUES (2, NULL, 'Purchase of supplies');
GO

-- 7. Add a Team Assignment (so Assignment view shows something)
INSERT INTO TeamAssignment (TeamID, IncidentID, RequestID, AssignedTime, Status, Priority, AssignedBy)
VALUES (1, 1, @ReqID, GETDATE(), 'Assigned', 1, 1);
GO