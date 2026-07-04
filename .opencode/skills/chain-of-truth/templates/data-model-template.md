# Data Model: [Product/Application Name]

**Document:** SoT-6 | **Derived From:** SoT-4 (User Flows) — NOT directly from SRS | **Status:** Draft | **Last Updated:** [Date]

> **Critical:** This model is derived from User Flows (how data is created/read/updated/validated in real business processes), not from the SRS. Data is shaped by process needs, not the reverse.

## 1. Overview

[One paragraph: what this data model covers and which User Flows it supports. Reference the core business objects from the SRS that the User Flows exercised.]

## 2. Class Diagram

```mermaid
classDiagram
  class [Entity] {
    +[type] [attribute]
    +[type] [attribute]
  }
  class [Entity] {
    +[type] [attribute]
  }
  [Entity] "1" --> "*" [Entity] : [relationship label]
  [Entity] "1" --> "*" [Entity] : [relationship label]
```

## 3. Entity Descriptions

### ENT-001: [Entity Name]
*Purpose:* [What this entity represents in the business process]

| Attribute | Type | Constraint | Description |
|-----------|------|------------|-------------|
| id | [UUID / bigint] | PK, NOT NULL | Unique identifier |
| [attribute] | [type] | [UNIQUE / NOT NULL / CHECK] | [Description] |
| created_at | timestamp | NOT NULL, default now() | Creation time |
| updated_at | timestamp | | Last modification time |

### ENT-002: [Entity Name]
*Purpose:* [What this entity represents]

| Attribute | Type | Constraint | Description |
|-----------|------|------------|-------------|
| id | [type] | PK | Unique identifier |
| [attribute] | [type] | [FK → Entity.field] | [Description] |

## 4. Relationships

| Relationship | Type | Cardinality | Description |
|--------------|------|-------------|-------------|
| [Entity A] → [Entity B] | One-to-Many | 1:N | [e.g., One cashier creates many transactions] |
| [Entity A] → [Entity B] | One-to-Many | 1:N | [e.g., One transaction has many detail lines] |
| [Entity A] → [Entity B] | One-to-One | 1:1 | [Description] |
| [Entity A] ↔ [Entity B] | Many-to-Many | M:N | [Description — usually via junction table] |

## 5. Business Rules

### [Domain] Rules
- [e.g., Product name must be unique]
- [e.g., price and stock_quantity must be >= 0]
- [e.g., out-of-stock products cannot be added to cart]

### [Domain] Rules
- [e.g., quantity must be an integer > 0]
- [e.g., total = sum of subtotals]
- [e.g., change = amount_paid − total]
- [e.g., stock reduced only after transaction completes]
- [e.g., quantity < 1 removes item from cart]

### State / Lifecycle Transitions
| Entity | From State | To State | Trigger |
|--------|-----------|----------|---------|
| [Entity] | [e.g., Pending] | [e.g., Paid] | [e.g., Payment confirmed] |
| [Entity] | [e.g., Paid] | [e.g., Cancelled] | [e.g., Void action] |

### Data Retention
- [Entity]: [retention period + archive/delete policy]
- [Entity]: [retention period]

## 6. Indexes

| Table | Index | Columns | Purpose |
|-------|-------|---------|---------|
| [table] | idx_[name] | [columns] | [e.g., Speed up search by name] |
| [table] | idx_[name] | [columns] | [e.g., Filter by date range] |

## 7. SQL DDL

> Replace with your target database. Shown in PostgreSQL.

```sql
CREATE TABLE [entity] (
  id           [type] PRIMARY KEY DEFAULT [gen],
  [column]     [type] [constraints],
  -- ponytail: add CHECK constraints at the DB for rules the app also enforces;
  -- belt-and-suspenders, drop the app-side duplicate only if a measured reason appears.
  CONSTRAINT [chk_name] CHECK ([condition]),
  UNIQUE ([columns])
);

CREATE TABLE [entity] (
  id              [type] PRIMARY KEY,
  [fk_column]     [type] NOT NULL REFERENCES [parent](id),
  [column]        [type] [constraints],
  CONSTRAINT [chk_name] CHECK ([condition])
);

CREATE INDEX idx_[name] ON [table] ([columns]);
```

## 8. Validation Rules Summary

| Field | Rule | Enforced At |
|-------|------|-------------|
| [entity.field] | [e.g., required, email format] | [API + DB] |
| [entity.field] | [e.g., >= 0] | [DB CHECK + API] |
| [entity.field] | [e.g., unique] | [DB UNIQUE + API] |

## 9. Traceability

| Entity | Source (User Flow) | SRS Reference | Feature |
|--------|-------------------|---------------|---------|
| [Entity] | docs/user_flows/uc-[id]-[name].md | docs/srs.md#F00[X] | F00[X] |
| [Entity] | docs/user_flows/uc-[id]-[name].md | docs/srs.md#F00[X] | F00[X] |