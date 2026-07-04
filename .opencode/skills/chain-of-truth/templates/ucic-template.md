# UCIC: [Use Case Name]

**Document:** SoT-7 | **Derived From:** SoT-4 (User Flow) + SoT-6 (Data Model) | **Status:** Draft | **Last Updated:** [Date]

## Use Case Reference

| Field | Value |
|-------|-------|
| Use Case ID | UC-[ID] |
| Name | [Use case name — matches User Flow] |
| Actor | [Actor — matches User Flow] |
| Related User Flow | docs/user_flows/uc-[id]-[name].md |

## Related Screens

*Screens or pages involved. Reference IA (SoT #2).*

| Page ID | Page Name | Role |
|---------|-----------|------|
| PAGE-[ID] | [Name] | [e.g., "Form entry", "Result display"] |

## Related Entities

*Data entities involved. Reference Data Model (SoT #6).*

| Entity | Role in This Use Case | Operations |
|--------|----------------------|------------|
| [Entity] | [e.g., "User being authenticated"] | Read |
| [Entity] | [e.g., "Session being created"] | Create |

## Sequence Diagram

```
User / Frontend        API Gateway        Backend Service        Database
     |                      |                    |                    |
     |---[user action]----->|                    |                    |
     |                      |---[HTTP request]-->|                    |
     |                      |                    |---[query]--------->|
     |                      |                    |<---[result]--------|
     |                      |                    |---[business logic]-|
     |                      |<---[HTTP response]-|                    |
     |<---[UI update]-------|                    |                    |
     |                      |                    |                    |
```

*Describe each step in the sequence:*
1. **User/Frontend:** [What the user does or what the frontend triggers]
2. **API Gateway:** [Routing, auth check, rate limiting]
3. **Backend Service:** [Business logic, validation, processing]
4. **Database:** [Queries, inserts, updates, deletes]
5. **Response:** [What comes back through each layer]

## API Contract

### Endpoint
```
[METHOD] [path]
```
Example: `POST /api/v1/auth/login`

### Authentication
- **Type:** [None / Bearer Token / API Key / Session Cookie]
- **Required Role:** [Role from SRS permissions]
- **Token Location:** [Header / Cookie / Body]

### Request Headers
| Header | Value | Required |
|--------|-------|----------|
| Content-Type | application/json | Yes |
| Authorization | Bearer {token} | [Yes/No] |

### Request Payload

```json
{
  "field_name": "type",
  "field_name": "type (required)",
  "nested_object": {
    "sub_field": "type"
  }
}
```

| Field | Type | Required | Description | Validation |
|-------|------|----------|-------------|------------|
| [field] | [string/number/boolean/object/array] | Yes/No | [What it represents] | [e.g., "email format", "min 1, max 100"] |

### Response Payload (Success)

**HTTP Status:** `200 OK`

```json
{
  "field_name": "type",
  "field_name": "type"
}
```

| Field | Type | Description |
|-------|------|-------------|
| [field] | [type] | [What it represents] |

### Status Codes

| Status | Meaning | Condition | Response Body |
|--------|---------|-----------|---------------|
| 200 | OK | [When this happens] | [Success payload] |
| 201 | Created | [When this happens] | [Created payload] |
| 400 | Bad Request | [When this happens — e.g., invalid input] | `{"error": "message", "details": [...]}` |
| 401 | Unauthorized | [When this happens — e.g., missing/invalid token] | `{"error": "Authentication required"}` |
| 403 | Forbidden | [When this happens — e.g., wrong role] | `{"error": "Insufficient permissions"}` |
| 404 | Not Found | [When this happens — e.g., resource doesn't exist] | `{"error": "Resource not found"}` |
| 409 | Conflict | [When this happens — e.g., duplicate] | `{"error": "Resource already exists"}` |
| 422 | Unprocessable Entity | [When this happens — e.g., business rule violation] | `{"error": "message", "details": [...]}` |
| 500 | Internal Server Error | [When this happens] | `{"error": "Internal server error"}` |

## Data Mapping

*How data flows from UI → Request → Domain → Response → UI.*

| UI Field / Component | Request Payload Field | Domain Entity.Field | Response Payload Field | Notes |
|----------------------|----------------------|---------------------|------------------------|-------|
| [UI element] | [request field] | [entity.field] | [response field] | [Any transformation] |
| [UI element] | [request field] | [entity.field] | [response field] | [Any transformation] |

## Validation Rules

| Field | Rule | Error Message | Error Code |
|-------|------|--------------|------------|
| [field] | [e.g., "Required", "Email format", "Min length 3"] | [User-facing error message] | [e.g., "FIELD_REQUIRED"] |
| [field] | [e.g., "Must be >= 0"] | [User-facing error message] | [e.g., "INVALID_VALUE"] |
| [field] | [e.g., "Must be unique"] | [User-facing error message] | [e.g., "DUPLICATE_VALUE"] |

## Error Handling

*For each expected error condition, define the full behavior.*

| Error Condition | HTTP Status | Response Body | Frontend Behavior |
|-----------------|-------------|---------------|-------------------|
| [e.g., "Invalid credentials"] | 401 | `{"error": "Invalid email or password"}` | Show error message below form, clear password field |
| [e.g., "Account locked"] | 423 | `{"error": "Account is locked. Contact admin."}` | Show error with contact info, disable form |
| [e.g., "Network timeout"] | N/A (client-side) | N/A | Show "Connection lost. Retrying..." toast, auto-retry 3x |
| [e.g., "Server error"] | 500 | `{"error": "Something went wrong"}` | Show generic error, log details to console |

## Traceability

| Source of Truth | Reference | Relationship |
|-----------------|-----------|--------------|
| User Flow | docs/user_flows/uc-[id]-[name].md | This UCIC implements the flow defined there |
| Data Model | docs/data_model.md#[entity] | This UCIC uses entities defined there |
| SRS | docs/srs.md#F[ID] | This UCIC satisfies the requirements defined there |
