# Smart Disaster Response Management Information System (MIS)

**Semester 6 — Database Management Systems (DBMS) Project**
Department of Software Engineering, FAST – National University of Computer & Emerging Sciences

## Project Overview

The Smart Disaster Response MIS is a centralized platform for coordinating the response to natural and urban disasters — floods, earthquakes, fires, and similar emergencies. It's built to handle high-volume, real-time incident reports coming in from multiple sources and to coordinate the people, resources, and money needed to respond to them.

The system is implemented as an **ASP.NET Core MVC** web application backed by a **SQL Server** database, designed and normalized from the ground up (UNF → 1NF → 2NF → 3NF/BCNF) to support enterprise-level reliability, ACID-compliant transactions, and role-based access control.

### Key Objectives
- Rapid, coordinated incident response
- Optimal allocation and tracking of critical resources
- Secure, auditable financial tracking (donations, expenses, procurement)
- Role-based access so each stakeholder only sees and does what's relevant to them
- Approval-based workflows for critical operations
- Full audit logging for compliance and traceability

## Stakeholders / User Roles

| Role | Responsibility |
|---|---|
| **Administrator** | System configuration, user and role management |
| **Emergency Operator** | Receives and prioritizes incoming incident reports |
| **Field Officer** | Oversees on-ground rescue operations, updates statuses |
| **Warehouse Manager** | Manages resource inventory and allocation |
| **Finance Officer** | Handles financial transactions and reporting |

Access is enforced through Role-Based Access Control (RBAC), so each role only interacts with the data and operations relevant to it.

## System Modules

1. **Emergency Management** — capture and prioritize incident reports (location, disaster type, severity, time reported)
2. **Rescue Team Management** — team availability, dynamic assignment by proximity/severity, status tracking
3. **Resource Management** — full lifecycle tracking: allocation → dispatch → consumption, warehouse-wise inventory
4. **Hospital Coordination** — bed availability, patient assignment, load balancing across hospitals
5. **Financial Management** — donations, expenses, procurement, categorized transactions with audit trails
6. **User & Security (RBAC)** — role and permission management
7. **Approval Workflow** — generic request/approval pipeline (pending → approved/rejected) for critical operations
8. **Audit & Monitoring** — logs of user activity, data changes, and approval decisions
9. **Notification & Alert System** — alerting relevant stakeholders on key events
10. **System Transaction Logging** — supports ACID-compliant operation tracking

## Key Features

- High-volume, concurrent transaction handling (incident reports, allocations)
- ACID-compliant secure transactions
- Role-based access control
- Approval-based workflows for sensitive operations
- Real-time-style tracking and updates
- Database-level automation via triggers for business-rule enforcement

## Database Design

The schema was designed through a full requirements-to-implementation pipeline:

1. **System scope & stakeholder analysis**
2. **Entity identification** across all modules (User/RBAC, Request/Approval, Emergency, Rescue Teams, Resources, Hospitals, Finance, Audit, Notifications, Transaction Logging)
3. **ERD design**, capturing one-to-many, many-to-many, and one-to-one relationships between entities
4. **Normalization** from UNF through 1NF, 2NF (removing partial dependencies), 3NF (removing transitive dependencies), and BCNF for selected tables

### Core Tables
`Role`, `User`, `Permission`, `RolePermission`, `Request`, `Approval`, `Citizen`, `Incident`, `IncidentStatusLog`, `RescueTeam`, `TeamAssignment`, `Warehouse`, `Resource`, `Inventory`, `ResourceRequest`, `AllocationDetail`, `Dispatch`, `ConsumptionRecord`, `Hospital`, `BedAvailability`, `Patient`, `EscalationRule`, `DisasterBudget`, `Transaction`, `Donation`, `Expense`, `Procurement`, `AuditLog`, `Notification`, `SystemTransactionLog`

### Notable Relationships
- `User` → `Role` (many-to-one), `Role` → `Permission` via `RolePermission` (junction table)
- `Incident` reported by `Citizen`; `TeamAssignment` links `RescueTeam`, `Incident`, and `Request`
- `Inventory` is a composite-key table linking `Warehouse` and `Resource`
- Resource lifecycle: `AllocationDetail` → `Dispatch` → `ConsumptionRecord`
- `BedAvailability` extends `Hospital` (1:1); `Patient` references both `Incident` and `Hospital`
- `EscalationRule` self-references `Hospital`
- `Transaction` is extended by `Donation`, `Expense`, and `Procurement`; `DisasterBudget` ties to `Incident`
- `AuditLog` and `Notification` both reference `User`

### Reporting
`MIS_Reports.sql` includes analytical queries covering:
- Incident counts by location, disaster type, and severity
- Resource utilization (dispatched vs. consumed vs. unused/lost)
- Average and fastest incident response times
- Financial summaries by transaction type
- Approval workflow status tracking
- Low-inventory alerts against threshold levels

## Tech Stack

- **Backend:** ASP.NET Core MVC (C#)
- **Database:** Microsoft SQL Server
- **Frontend:** Razor Views (MVC), wwwroot static assets
- **Session Management:** ASP.NET Core distributed memory cache + session middleware

## Project Structure

```
DisasterMIS_Frontend/
├── Controllers/     # MVC controllers
├── Models/          # Data models
├── Views/           # Razor views
├── Helpers/         # Utility/helper classes
├── wwwroot/         # Static assets (CSS, JS, images)
├── Properties/      # Launch settings
├── appsettings.json
├── appsettings.Development.json
├── Program.cs       # App entry point & middleware pipeline
├── Disater.sql      # Database schema (DDL)
├── operation.sql    # Sample operational queries & seed data
├── MIS_Reports.sql  # Analytical/reporting queries
└── DisasterMIS_Frontend.csproj
```

## Setup & Running

**Prerequisites:**
- .NET SDK (matching the project's target framework)
- SQL Server (local instance or Docker container)
- Visual Studio or VS Code with C# extension

**Steps:**
1. Restore the database:
   ```sql
   -- Run Disater.sql in SQL Server Management Studio to create the schema
   -- Then run operation.sql for seed data / sample records
   ```
2. Update the connection string in `appsettings.json` to point to your SQL Server instance.
3. Restore and run the project:
   ```bash
   dotnet restore
   dotnet run
   ```
4. Navigate to `https://localhost:{port}` in your browser.

## Scope Boundaries

**In scope:** database design & implementation, transaction handling and concurrency control, role-based access and security, workflow automation, reporting and analytics.

**Out of scope:** integration with external government/third-party APIs, real-time GPS tracking via external services, native mobile app development (web-based only), hardware-level disaster monitoring systems.

## Team

Shah Faisal - 23i-0058
Akbar Hussain - 23i-3094
Shah Faisal - 23i-3095

## Course

- **Course:** Database Management Systems — Semester 6
- **Department:** Software Engineering
- **Institution:** FAST – National University of Computer & Emerging Sciences
