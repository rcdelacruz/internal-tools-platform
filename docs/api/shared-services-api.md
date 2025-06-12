# Shared Services API Reference

> Complete API reference for the Internal Tools Platform shared services

## 🎯 Overview

The Shared Services API provides centralized functionality for authentication, user management, notifications, file handling, and audit logging. All services follow REST conventions and return consistent JSON responses.

**Base URL:** `http://localhost:3001` (development) | `https://api.company.com` (production)

**API Version:** `v1`

**Documentation:** Available at `/api` endpoint (Swagger UI)

## 🔐 Authentication

All API endpoints require authentication unless otherwise specified. The API supports two authentication methods:

### JWT Bearer Token (User Authentication)
```http
Authorization: Bearer <jwt_token>
X-Org-ID: <organization_id>
```

### API Key (Service-to-Service)
```http
X-API-Key: <api_key>
X-Org-ID: <organization_id>
```

## 📊 Response Format

All API responses follow a consistent format:

### Success Response
```json
{
  "data": {},
  "status": "success",
  "message": "Operation completed successfully",
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 100,
    "pages": 5,
    "hasNext": true,
    "hasPrev": false
  }
}
```

### Error Response
```json
{
  "status": "error",
  "message": "Error description",
  "code": "ERROR_CODE",
  "errors": [
    {
      "field": "email",
      "message": "Invalid email format"
    }
  ],
  "timestamp": "2025-06-12T14:00:00Z",
  "path": "/api/v1/users"
}
```

## 🔑 Authentication Service

### Login
```http
POST /api/v1/auth/login
Content-Type: application/json

{
  "email": "user@company.com",
  "password": "password",
  "orgId": "org_123"
}
```

**Response:**
```json
{
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": "user_123",
      "email": "user@company.com",
      "name": "John Doe",
      "department": "Engineering",
      "permissions": ["users:read", "resources:create"]
    },
    "expiresIn": 900
  },
  "status": "success"
}
```

### Verify Token
```http
POST /api/v1/auth/verify
Authorization: Bearer <token>
X-Org-ID: <org_id>
```

**Response:**
```json
{
  "data": {
    "userId": "user_123",
    "orgId": "org_123",
    "email": "user@company.com",
    "permissions": ["users:read", "resources:create"],
    "sessionId": "session_123"
  },
  "status": "success"
}
```

### Refresh Token
```http
POST /api/v1/auth/refresh
Content-Type: application/json

{
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "orgId": "org_123"
}
```

### Logout
```http
POST /api/v1/auth/logout
Authorization: Bearer <token>
X-Org-ID: <org_id>
```

### Change Password
```http
PUT /api/v1/auth/password
Authorization: Bearer <token>
X-Org-ID: <org_id>
Content-Type: application/json

{
  "currentPassword": "old_password",
  "newPassword": "new_password"
}
```

## 👥 User Management Service

### List Users
```http
GET /api/v1/users?page=1&limit=20&search=john&department=Engineering
Authorization: Bearer <token>
X-Org-ID: <org_id>
```

**Query Parameters:**
- `page` (integer): Page number (default: 1)
- `limit` (integer): Items per page (default: 20, max: 100)
- `search` (string): Search in name and email
- `department` (string): Filter by department
- `active` (boolean): Filter by active status
- `sort` (string): Sort field and direction (e.g., "name:asc", "createdAt:desc")

**Response:**
```json
{
  "data": [
    {
      "id": "user_123",
      "email": "john@company.com",
      "name": "John Doe",
      "department": "Engineering",
      "active": true,
      "permissions": ["users:read"],
      "createdAt": "2025-01-01T00:00:00Z",
      "updatedAt": "2025-06-12T14:00:00Z"
    }
  ],
  "status": "success",
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 50,
    "pages": 3,
    "hasNext": true,
    "hasPrev": false
  }
}
```

### Get User
```http
GET /api/v1/users/{userId}
Authorization: Bearer <token>
X-Org-ID: <org_id>
```

### Get Current User
```http
GET /api/v1/users/me
Authorization: Bearer <token>
X-Org-ID: <org_id>
```

### Create User
```http
POST /api/v1/users
Authorization: Bearer <token>
X-Org-ID: <org_id>
Content-Type: application/json

{
  "email": "new@company.com",
  "name": "New User",
  "department": "Marketing",
  "permissions": ["users:read"]
}
```

### Update User
```http
PUT /api/v1/users/{userId}
Authorization: Bearer <token>
X-Org-ID: <org_id>
Content-Type: application/json

{
  "name": "Updated Name",
  "department": "Sales",
  "active": true,
  "permissions": ["users:read", "resources:create"]
}
```

### Delete User
```http
DELETE /api/v1/users/{userId}
Authorization: Bearer <token>
X-Org-ID: <org_id>
```

### User Permissions
```http
GET /api/v1/users/{userId}/permissions
Authorization: Bearer <token>
X-Org-ID: <org_id>
```

```http
PUT /api/v1/users/{userId}/permissions
Authorization: Bearer <token>
X-Org-ID: <org_id>
Content-Type: application/json

{
  "permissions": ["users:read", "users:create", "resources:read"]
}
```

## 📧 Notification Service

### Send Notification
```http
POST /api/v1/notifications/send
Authorization: Bearer <token>
X-Org-ID: <org_id>
Content-Type: application/json

{
  "type": "email",
  "recipients": ["user1@company.com", "user2@company.com"],
  "subject": "Welcome to the platform",
  "template": "welcome_email",
  "data": {
    "userName": "John Doe",
    "loginUrl": "https://platform.company.com/login"
  },
  "priority": "normal"
}
```

**Notification Types:**
- `email` - Email notification
- `in_app` - In-app notification
- `slack` - Slack message
- `sms` - SMS message (future)

**Priority Levels:**
- `urgent` - Immediate delivery
- `high` - High priority
- `normal` - Normal priority (default)
- `low` - Low priority

### List Notifications
```http
GET /api/v1/notifications?userId=user_123&type=email&read=false
Authorization: Bearer <token>
X-Org-ID: <org_id>
```

### Mark as Read
```http
PUT /api/v1/notifications/{notificationId}/read
Authorization: Bearer <token>
X-Org-ID: <org_id>
```

### Notification Templates
```http
GET /api/v1/notifications/templates
Authorization: Bearer <token>
X-Org-ID: <org_id>
```

```http
POST /api/v1/notifications/templates
Authorization: Bearer <token>
X-Org-ID: <org_id>
Content-Type: application/json

{
  "name": "welcome_email",
  "type": "email",
  "subject": "Welcome {{userName}}!",
  "content": "Hello {{userName}}, welcome to our platform...",
  "variables": ["userName", "loginUrl"]
}
```

## 📁 File Management Service

### Upload File
```http
POST /api/v1/files/upload
Authorization: Bearer <token>
X-Org-ID: <org_id>
Content-Type: multipart/form-data

file: <binary_data>
context: "profile_pictures"
metadata: {"alt": "User avatar"}
```

**Response:**
```json
{
  "data": {
    "id": "file_123",
    "filename": "avatar.jpg",
    "originalName": "user-avatar.jpg",
    "mimeType": "image/jpeg",
    "sizeBytes": 52480,
    "url": "https://cdn.company.com/files/avatar.jpg",
    "metadata": {
      "alt": "User avatar"
    }
  },
  "status": "success"
}
```

### Get File
```http
GET /api/v1/files/{fileId}
Authorization: Bearer <token>
X-Org-ID: <org_id>
```

### Download File
```http
GET /api/v1/files/{fileId}/download
Authorization: Bearer <token>
X-Org-ID: <org_id>
```

### List Files
```http
GET /api/v1/files?context=profile_pictures&mimeType=image/*
Authorization: Bearer <token>
X-Org-ID: <org_id>
```

### Delete File
```http
DELETE /api/v1/files/{fileId}
Authorization: Bearer <token>
X-Org-ID: <org_id>
```

### Update File Metadata
```http
PUT /api/v1/files/{fileId}/metadata
Authorization: Bearer <token>
X-Org-ID: <org_id>
Content-Type: application/json

{
  "metadata": {
    "alt": "Updated alt text",
    "category": "profile"
  }
}
```

## 📊 Audit Service

### Log Activity
```http
POST /api/v1/audit/log
Authorization: Bearer <token>
X-Org-ID: <org_id>
Content-Type: application/json

{
  "appName": "resource-management",
  "action": "resource.created",
  "resourceType": "resource",
  "resourceId": "resource_123",
  "metadata": {
    "resourceName": "Conference Room A",
    "location": "Building 1"
  }
}
```

### Get Audit Logs
```http
GET /api/v1/audit/logs?appName=resource-management&action=resource.created&startDate=2025-06-01&endDate=2025-06-12
Authorization: Bearer <token>
X-Org-ID: <org_id>
```

**Query Parameters:**
- `appName` (string): Filter by application name
- `action` (string): Filter by action type
- `resourceType` (string): Filter by resource type
- `resourceId` (string): Filter by specific resource
- `userId` (string): Filter by user
- `startDate` (string): Start date (ISO format)
- `endDate` (string): End date (ISO format)
- `page` (integer): Page number
- `limit` (integer): Items per page

### Export Audit Logs
```http
GET /api/v1/audit/export?format=csv&startDate=2025-06-01&endDate=2025-06-12
Authorization: Bearer <token>
X-Org-ID: <org_id>
```

**Formats:**
- `csv` - CSV file
- `json` - JSON file
- `xlsx` - Excel file

## ⚙️ Configuration Service

### Get Organization Settings
```http
GET /api/v1/config/organization
Authorization: Bearer <token>
X-Org-ID: <org_id>
```

### Update Organization Settings
```http
PUT /api/v1/config/organization
Authorization: Bearer <token>
X-Org-ID: <org_id>
Content-Type: application/json

{
  "name": "Acme Corporation",
  "domain": "acme.com",
  "timezone": "America/New_York",
  "dateFormat": "MM/DD/YYYY",
  "theme": {
    "primaryColor": "#007bff",
    "logo": "https://cdn.company.com/logo.png"
  }
}
```

### Feature Flags
```http
GET /api/v1/config/features
Authorization: Bearer <token>
X-Org-ID: <org_id>
```

```http
PUT /api/v1/config/features
Authorization: Bearer <token>
X-Org-ID: <org_id>
Content-Type: application/json

{
  "features": {
    "enableSlackIntegration": true,
    "enableAdvancedReporting": false,
    "maxFileUploadSize": 10485760
  }
}
```

## 🛠️ System Endpoints

### Health Check
```http
GET /health
```

**Response:**
```json
{
  "status": "ok",
  "timestamp": "2025-06-12T14:00:00Z",
  "version": "1.0.0",
  "dependencies": {
    "database": "ok",
    "redis": "ok",
    "storage": "ok"
  }
}
```

### API Information
```http
GET /api/v1/info
```

### Metrics (Prometheus format)
```http
GET /metrics
```

## 🚨 Error Codes

### Authentication Errors
- `AUTH_001` - Invalid credentials
- `AUTH_002` - Token expired
- `AUTH_003` - Token malformed
- `AUTH_004` - Insufficient permissions
- `AUTH_005` - Account locked

### Validation Errors
- `VAL_001` - Required field missing
- `VAL_002` - Invalid format
- `VAL_003` - Value out of range
- `VAL_004` - Duplicate value

### Resource Errors
- `RES_001` - Resource not found
- `RES_002` - Resource already exists
- `RES_003` - Resource in use
- `RES_004` - Resource limit exceeded

### System Errors
- `SYS_001` - Internal server error
- `SYS_002` - Service unavailable
- `SYS_003` - Database error
- `SYS_004` - External service error

## 🔄 Rate Limiting

Rate limits are applied per user/API key:

- **Authenticated requests**: 1000 requests per hour
- **File uploads**: 100 uploads per hour
- **Email notifications**: 500 emails per hour
- **Login attempts**: 10 attempts per 15 minutes

Rate limit headers are included in responses:
```http
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 999
X-RateLimit-Reset: 1625097600
```

## 📱 SDK Usage Examples

### TypeScript/JavaScript
```typescript
import { SharedServicesClient } from '@shared/client';

const client = new SharedServicesClient({
  baseUrl: 'http://localhost:3001',
  orgId: 'org_123',
  accessToken: 'your_jwt_token'
});

// Authentication
const authResult = await client.login({
  email: 'user@company.com',
  password: 'password',
  orgId: 'org_123'
});

// User management
const users = await client.getUsers({ department: 'Engineering' });
const user = await client.getUser('user_123');

// Notifications
await client.sendNotification({
  type: 'email',
  recipients: ['user@company.com'],
  template: 'welcome_email',
  data: { userName: 'John' }
});

// File upload
const file = new File(['content'], 'document.txt');
const uploadResult = await client.uploadFile(file, 'documents');

// Audit logging
await client.logActivity({
  appName: 'my-app',
  action: 'document.created',
  resourceId: 'doc_123'
});
```

### Python (Future)
```python
from internal_tools_sdk import SharedServicesClient

client = SharedServicesClient(
    base_url="http://localhost:3001",
    org_id="org_123",
    access_token="your_jwt_token"
)

# User management
users = client.users.list(department="Engineering")
user = client.users.get("user_123")

# Notifications
client.notifications.send({
    "type": "email",
    "recipients": ["user@company.com"],
    "template": "welcome_email",
    "data": {"userName": "John"}
})
```

## 🧪 Testing

### Postman Collection
Import the Postman collection available at `/api/postman.json`

### API Testing
```bash
# Health check
curl http://localhost:3001/health

# Login
curl -X POST http://localhost:3001/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@company.com","password":"password","orgId":"demo-org"}'

# Get users (with auth token)
curl http://localhost:3001/api/v1/users \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "X-Org-ID: demo-org"
```

## 📚 Additional Resources

- [Authentication Guide](./authentication.md)
- [Error Handling](./error-handling.md)
- [API Examples](./examples/)
- [SDK Documentation](../guides/sdk-usage.md)
- [OpenAPI Specification](http://localhost:3001/api/json)

---

**Need help?** Check the [troubleshooting guide](../troubleshooting.md) or create an issue in the repository.