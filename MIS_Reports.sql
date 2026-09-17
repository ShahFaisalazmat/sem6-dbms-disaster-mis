SELECT 
    Location,
    DisasterType,
    SeverityLevel,
    COUNT(*) AS IncidentCount
FROM Incident
GROUP BY Location, DisasterType, SeverityLevel
ORDER BY IncidentCount DESC;



SELECT 
    r.ResourceName,
    SUM(d.QuantityDispatched) AS TotalDispatched,
    ISNULL(SUM(c.QuantityConsumed), 0) AS TotalConsumed,
    (SUM(d.QuantityDispatched) - ISNULL(SUM(c.QuantityConsumed), 0)) AS UnusedOrLost
FROM Dispatch d
JOIN AllocationDetail a ON d.AllocationID = a.AllocationID
JOIN Resource r ON a.ResourceID = r.ResourceID
LEFT JOIN ConsumptionRecord c ON d.DispatchID = c.DispatchID
GROUP BY r.ResourceName
ORDER BY TotalDispatched DESC;

SELECT 
    AVG(DATEDIFF(MINUTE, i.TimeReported, ta.AssignedTime)) AS AvgResponseMinutes
FROM Incident i
JOIN TeamAssignment ta ON i.IncidentID = ta.IncidentID
WHERE ta.AssignedTime IS NOT NULL;



SELECT TOP 10
    i.IncidentID,
    i.TimeReported,
    ta.AssignedTime,
    DATEDIFF(MINUTE, i.TimeReported, ta.AssignedTime) AS ResponseMinutes
FROM Incident i
JOIN TeamAssignment ta ON i.IncidentID = ta.IncidentID
ORDER BY ResponseMinutes ASC;

SELECT 
    TransactionType,
    SUM(Amount) AS TotalAmount,
    COUNT(*) AS TransactionCount
FROM [Transaction]
WHERE Status = 'Completed'
GROUP BY TransactionType;

SELECT 
    r.RequestID,
    r.RequestType,
    r.Status AS RequestStatus,
    a.Status AS ApprovalStatus,
    a.Comments,
    a.Timestamp AS ApprovalDate
FROM Request r
LEFT JOIN Approval a ON r.RequestID = a.RequestID
ORDER BY r.CreatedAt DESC;


SELECT 
    w.Location AS WarehouseLocation,
    r.ResourceName,
    i.Quantity,
    i.ThresholdLevel
FROM Inventory i
JOIN Warehouse w ON i.WarehouseID = w.WarehouseID
JOIN Resource r ON i.ResourceID = r.ResourceID
WHERE i.Quantity <= i.ThresholdLevel;