# API Documentation

## Overview

The Personnel Management System connects to a REST API backend for all data operations. This document describes the API endpoints, request/response formats, and error handling.

## Base Configuration

### Default Configuration

| Setting | Default Value | Environment Variable |
|---------|---------------|---------------------|
| Base URL | `http://localhost:8082` | `API_BASE_URL` |
| API Prefix | `/api` | `API_PREFIX` |
| Full API URL | `http://localhost:8082/api` | - |

### Live Documentation

- **Swagger UI**: http://localhost:8082/docs/
- **OpenAPI Spec**: http://localhost:8082/openapi.json
- **ReDoc**: http://localhost:8082/redoc/

## Authentication

Currently, the API does not require authentication. Future versions may implement:

- JWT Token authentication
- API Key authentication
- OAuth 2.0

## Common Headers

### Request Headers

```http
Content-Type: application/json
Accept: application/json
```

### Response Headers

```http
Content-Type: application/json
```

## Data Types

### UUID Format

All entity IDs use UUID v4 format:
```
"id": "550e8400-e29b-41d4-a716-446655440000"
```

### Date/Time Format

All dates and timestamps use ISO 8601 format:
```
"createdAt": "2024-01-15T10:30:00Z"
"hireDate": "2024-01-15"
```

### Decimal/Currency Format

Monetary values are represented as strings or numbers with 2 decimal places:
```
"baseSalary": 50000.00
```

---

## Departments API

### List All Departments

Retrieves all departments in the system.

**Request**
```http
GET /api/departments
```

**Response**
```json
[
    {
        "id": "550e8400-e29b-41d4-a716-446655440000",
        "name": "Engineering",
        "headEmployeeId": "660e8400-e29b-41d4-a716-446655440001"
    },
    {
        "id": "550e8400-e29b-41d4-a716-446655440002",
        "name": "Human Resources",
        "headEmployeeId": null
    }
]
```

**Status Codes**
| Code | Description |
|------|-------------|
| 200 | Success |
| 500 | Server error |

---

### Get Department by ID

Retrieves a single department by its ID.

**Request**
```http
GET /api/departments/{id}
```

**Parameters**
| Name | Type | Location | Description |
|------|------|----------|-------------|
| id | UUID | path | Department ID |

**Response**
```json
{
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "name": "Engineering",
    "headEmployeeId": "660e8400-e29b-41d4-a716-446655440001"
}
```

**Status Codes**
| Code | Description |
|------|-------------|
| 200 | Success |
| 404 | Department not found |
| 500 | Server error |

---

### Create Department

Creates a new department.

**Request**
```http
POST /api/departments
Content-Type: application/json

{
    "name": "Marketing",
    "headEmployeeId": "660e8400-e29b-41d4-a716-446655440001"
}
```

**Request Body**
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| name | string | Yes | Department name (1-100 chars) |
| headEmployeeId | UUID | No | ID of department head employee |

**Response**
```json
{
    "id": "550e8400-e29b-41d4-a716-446655440003",
    "name": "Marketing",
    "headEmployeeId": "660e8400-e29b-41d4-a716-446655440001"
}
```

**Status Codes**
| Code | Description |
|------|-------------|
| 201 | Created successfully |
| 400 | Invalid request body |
| 422 | Validation error |
| 500 | Server error |

---

### Update Department

Updates an existing department.

**Request**
```http
PUT /api/departments/{id}
Content-Type: application/json

{
    "name": "Marketing & Sales",
    "headEmployeeId": "660e8400-e29b-41d4-a716-446655440002"
}
```

**Parameters**
| Name | Type | Location | Description |
|------|------|----------|-------------|
| id | UUID | path | Department ID |

**Request Body**
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| name | string | Yes | Department name (1-100 chars) |
| headEmployeeId | UUID | No | ID of department head employee |

**Response**
```json
{
    "id": "550e8400-e29b-41d4-a716-446655440003",
    "name": "Marketing & Sales",
    "headEmployeeId": "660e8400-e29b-41d4-a716-446655440002"
}
```

**Status Codes**
| Code | Description |
|------|-------------|
| 200 | Updated successfully |
| 400 | Invalid request body |
| 404 | Department not found |
| 422 | Validation error |
| 500 | Server error |

---

### Delete Department

Deletes a department.

**Request**
```http
DELETE /api/departments/{id}
```

**Parameters**
| Name | Type | Location | Description |
|------|------|----------|-------------|
| id | UUID | path | Department ID |

**Response**
```http
HTTP/1.1 204 No Content
```

**Status Codes**
| Code | Description |
|------|-------------|
| 204 | Deleted successfully |
| 404 | Department not found |
| 409 | Conflict (department has employees) |
| 500 | Server error |

---

## Employees API

### List All Employees

Retrieves all employees in the system.

**Request**
```http
GET /api/employees
```

**Response**
```json
[
    {
        "id": "660e8400-e29b-41d4-a716-446655440001",
        "firstName": "John",
        "lastName": "Doe",
        "email": "john.doe@example.com",
        "phone": "+1-555-0100",
        "hireDate": "2023-01-15",
        "departmentId": "550e8400-e29b-41d4-a716-446655440000",
        "salaryGradeId": "770e8400-e29b-41d4-a716-446655440001",
        "managerId": null
    },
    {
        "id": "660e8400-e29b-41d4-a716-446655440002",
        "firstName": "Jane",
        "lastName": "Smith",
        "email": "jane.smith@example.com",
        "phone": "+1-555-0101",
        "hireDate": "2023-06-01",
        "departmentId": "550e8400-e29b-41d4-a716-446655440000",
        "salaryGradeId": "770e8400-e29b-41d4-a716-446655440002",
        "managerId": "660e8400-e29b-41d4-a716-446655440001"
    }
]
```

**Status Codes**
| Code | Description |
|------|-------------|
| 200 | Success |
| 500 | Server error |

---

### Get Employee by ID

Retrieves a single employee by their ID.

**Request**
```http
GET /api/employees/{id}
```

**Parameters**
| Name | Type | Location | Description |
|------|------|----------|-------------|
| id | UUID | path | Employee ID |

**Response**
```json
{
    "id": "660e8400-e29b-41d4-a716-446655440001",
    "firstName": "John",
    "lastName": "Doe",
    "email": "john.doe@example.com",
    "phone": "+1-555-0100",
    "hireDate": "2023-01-15",
    "departmentId": "550e8400-e29b-41d4-a716-446655440000",
    "salaryGradeId": "770e8400-e29b-41d4-a716-446655440001",
    "managerId": null
}
```

**Status Codes**
| Code | Description |
|------|-------------|
| 200 | Success |
| 404 | Employee not found |
| 500 | Server error |

---

### Create Employee

Creates a new employee.

**Request**
```http
POST /api/employees
Content-Type: application/json

{
    "firstName": "Alice",
    "lastName": "Johnson",
    "email": "alice.johnson@example.com",
    "phone": "+1-555-0102",
    "hireDate": "2024-01-15",
    "departmentId": "550e8400-e29b-41d4-a716-446655440000",
    "salaryGradeId": "770e8400-e29b-41d4-a716-446655440001",
    "managerId": "660e8400-e29b-41d4-a716-446655440001"
}
```

**Request Body**
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| firstName | string | Yes | First name (1-50 chars) |
| lastName | string | Yes | Last name (1-50 chars) |
| email | string | Yes | Email address (valid format) |
| phone | string | No | Phone number |
| hireDate | string | Yes | Hire date (YYYY-MM-DD) |
| departmentId | UUID | Yes | Department ID |
| salaryGradeId | UUID | Yes | Salary grade ID |
| managerId | UUID | No | Manager's employee ID |

**Response**
```json
{
    "id": "660e8400-e29b-41d4-a716-446655440003",
    "firstName": "Alice",
    "lastName": "Johnson",
    "email": "alice.johnson@example.com",
    "phone": "+1-555-0102",
    "hireDate": "2024-01-15",
    "departmentId": "550e8400-e29b-41d4-a716-446655440000",
    "salaryGradeId": "770e8400-e29b-41d4-a716-446655440001",
    "managerId": "660e8400-e29b-41d4-a716-446655440001"
}
```

**Status Codes**
| Code | Description |
|------|-------------|
| 201 | Created successfully |
| 400 | Invalid request body |
| 422 | Validation error |
| 500 | Server error |

---

### Update Employee

Updates an existing employee.

**Request**
```http
PUT /api/employees/{id}
Content-Type: application/json

{
    "firstName": "Alice",
    "lastName": "Johnson-Smith",
    "email": "alice.johnson-smith@example.com",
    "phone": "+1-555-0102",
    "hireDate": "2024-01-15",
    "departmentId": "550e8400-e29b-41d4-a716-446655440002",
    "salaryGradeId": "770e8400-e29b-41d4-a716-446655440002",
    "managerId": null
}
```

**Parameters**
| Name | Type | Location | Description |
|------|------|----------|-------------|
| id | UUID | path | Employee ID |

**Request Body**
Same as Create Employee.

**Response**
```json
{
    "id": "660e8400-e29b-41d4-a716-446655440003",
    "firstName": "Alice",
    "lastName": "Johnson-Smith",
    "email": "alice.johnson-smith@example.com",
    "phone": "+1-555-0102",
    "hireDate": "2024-01-15",
    "departmentId": "550e8400-e29b-41d4-a716-446655440002",
    "salaryGradeId": "770e8400-e29b-41d4-a716-446655440002",
    "managerId": null
}
```

**Status Codes**
| Code | Description |
|------|-------------|
| 200 | Updated successfully |
| 400 | Invalid request body |
| 404 | Employee not found |
| 422 | Validation error |
| 500 | Server error |

---

### Delete Employee

Deletes an employee.

**Request**
```http
DELETE /api/employees/{id}
```

**Parameters**
| Name | Type | Location | Description |
|------|------|----------|-------------|
| id | UUID | path | Employee ID |

**Response**
```http
HTTP/1.1 204 No Content
```

**Status Codes**
| Code | Description |
|------|-------------|
| 204 | Deleted successfully |
| 404 | Employee not found |
| 409 | Conflict (employee is a manager or department head) |
| 500 | Server error |

---

## Salary Grades API

### List All Salary Grades

Retrieves all salary grades in the system.

**Request**
```http
GET /api/salary-grades
```

**Response**
```json
[
    {
        "id": "770e8400-e29b-41d4-a716-446655440001",
        "code": "SG-001",
        "baseSalary": 40000.00
    },
    {
        "id": "770e8400-e29b-41d4-a716-446655440002",
        "code": "SG-002",
        "baseSalary": 55000.00
    },
    {
        "id": "770e8400-e29b-41d4-a716-446655440003",
        "code": "SG-003",
        "baseSalary": 75000.00
    }
]
```

**Status Codes**
| Code | Description |
|------|-------------|
| 200 | Success |
| 500 | Server error |

---

### Get Salary Grade by ID

Retrieves a single salary grade by its ID.

**Request**
```http
GET /api/salary-grades/{id}
```

**Parameters**
| Name | Type | Location | Description |
|------|------|----------|-------------|
| id | UUID | path | Salary grade ID |

**Response**
```json
{
    "id": "770e8400-e29b-41d4-a716-446655440001",
    "code": "SG-001",
    "baseSalary": 40000.00
}
```

**Status Codes**
| Code | Description |
|------|-------------|
| 200 | Success |
| 404 | Salary grade not found |
| 500 | Server error |

---

### Create Salary Grade

Creates a new salary grade.

**Request**
```http
POST /api/salary-grades
Content-Type: application/json

{
    "code": "SG-004",
    "baseSalary": 95000.00
}
```

**Request Body**
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| code | string | Yes | Grade code (1-20 chars, unique) |
| baseSalary | number | Yes | Base salary amount (>= 0) |

**Response**
```json
{
    "id": "770e8400-e29b-41d4-a716-446655440004",
    "code": "SG-004",
    "baseSalary": 95000.00
}
```

**Status Codes**
| Code | Description |
|------|-------------|
| 201 | Created successfully |
| 400 | Invalid request body |
| 409 | Conflict (code already exists) |
| 422 | Validation error |
| 500 | Server error |

---

### Update Salary Grade

Updates an existing salary grade.

**Request**
```http
PUT /api/salary-grades/{id}
Content-Type: application/json

{
    "code": "SG-004",
    "baseSalary": 100000.00
}
```

**Parameters**
| Name | Type | Location | Description |
|------|------|----------|-------------|
| id | UUID | path | Salary grade ID |

**Request Body**
Same as Create Salary Grade.

**Response**
```json
{
    "id": "770e8400-e29b-41d4-a716-446655440004",
    "code": "SG-004",
    "baseSalary": 100000.00
}
```

**Status Codes**
| Code | Description |
|------|-------------|
| 200 | Updated successfully |
| 400 | Invalid request body |
| 404 | Salary grade not found |
| 409 | Conflict (code already exists) |
| 422 | Validation error |
| 500 | Server error |

---

### Delete Salary Grade

Deletes a salary grade.

**Request**
```http
DELETE /api/salary-grades/{id}
```

**Parameters**
| Name | Type | Location | Description |
|------|------|----------|-------------|
| id | UUID | path | Salary grade ID |

**Response**
```http
HTTP/1.1 204 No Content
```

**Status Codes**
| Code | Description |
|------|-------------|
| 204 | Deleted successfully |
| 404 | Salary grade not found |
| 409 | Conflict (salary grade is in use) |
| 500 | Server error |

---

## Error Handling

### Error Response Format

All error responses follow this format:

```json
{
    "error": {
        "code": "VALIDATION_ERROR",
        "message": "Validation failed",
        "details": [
            {
                "field": "email",
                "message": "Invalid email format"
            }
        ]
    }
}
```

### Common Error Codes

| Code | HTTP Status | Description |
|------|-------------|-------------|
| `NOT_FOUND` | 404 | Resource not found |
| `VALIDATION_ERROR` | 422 | Request validation failed |
| `CONFLICT` | 409 | Resource conflict (duplicate, in use) |
| `BAD_REQUEST` | 400 | Invalid request format |
| `INTERNAL_ERROR` | 500 | Server error |

### Client-Side Error Handling

```cpp
void ApiClient::handleResponse(QNetworkReply* reply) {
    if (reply->error() != QNetworkReply::NoError) {
        int statusCode = reply->attribute(
            QNetworkRequest::HttpStatusCodeAttribute).toInt();
        
        QJsonDocument doc = QJsonDocument::fromJson(reply->readAll());
        QString message;
        
        if (doc.isObject() && doc.object().contains("error")) {
            message = doc.object()["error"].toObject()["message"].toString();
        } else {
            message = reply->errorString();
        }
        
        emit error(statusCode, message);
        return;
    }
    
    // Process successful response
    QJsonDocument doc = QJsonDocument::fromJson(reply->readAll());
    emit success(doc);
}
```

---

## Rate Limiting

The API may implement rate limiting in future versions:

| Limit Type | Value |
|------------|-------|
| Requests per minute | 60 |
| Requests per hour | 1000 |

Rate limit headers (future):
```http
X-RateLimit-Limit: 60
X-RateLimit-Remaining: 45
X-RateLimit-Reset: 1699876543
```

---

## Client Implementation

### Qt/C++ Example

```cpp
// Making a GET request
void ApiClient::getDepartments() {
    QNetworkRequest request(QUrl(Config::instance().apiUrl() + "/departments"));
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    
    QNetworkReply* reply = m_networkManager->get(request);
    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        handleResponse(reply, [this](const QJsonDocument& doc) {
            emit departmentsLoaded(doc.array());
        });
        reply->deleteLater();
    });
}

// Making a POST request
void ApiClient::createDepartment(const QJsonObject& data) {
    QNetworkRequest request(QUrl(Config::instance().apiUrl() + "/departments"));
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    
    QNetworkReply* reply = m_networkManager->post(
        request, 
        QJsonDocument(data).toJson()
    );
    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        handleResponse(reply, [this](const QJsonDocument& doc) {
            emit departmentCreated(doc.object());
        });
        reply->deleteLater();
    });
}

// Making a PUT request
void ApiClient::updateDepartment(const QString& id, const QJsonObject& data) {
    QNetworkRequest request(QUrl(
        Config::instance().apiUrl() + "/departments/" + id
    ));
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    
    QNetworkReply* reply = m_networkManager->put(
        request, 
        QJsonDocument(data).toJson()
    );
    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        handleResponse(reply, [this](const QJsonDocument& doc) {
            emit departmentUpdated(doc.object());
        });
        reply->deleteLater();
    });
}

// Making a DELETE request
void ApiClient::deleteDepartment(const QString& id) {
    QNetworkRequest request(QUrl(
        Config::instance().apiUrl() + "/departments/" + id
    ));
    
    QNetworkReply* reply = m_networkManager->deleteResource(request);
    connect(reply, &QNetworkReply::finished, this, [this, reply, id]() {
        if (reply->error() == QNetworkReply::NoError) {
            emit departmentDeleted(id);
        } else {
            handleError(reply);
        }
        reply->deleteLater();
    });
}
```

---

## Testing the API

### Using cURL

```bash
# List departments
curl -X GET http://localhost:8082/api/departments

# Create department
curl -X POST http://localhost:8082/api/departments \
  -H "Content-Type: application/json" \
  -d '{"name": "Test Department"}'

# Update department
curl -X PUT http://localhost:8082/api/departments/{id} \
  -H "Content-Type: application/json" \
  -d '{"name": "Updated Department"}'

# Delete department
curl -X DELETE http://localhost:8082/api/departments/{id}
```

### Using HTTPie

```bash
# List departments
http GET http://localhost:8082/api/departments

# Create department
http POST http://localhost:8082/api/departments \
  name="Test Department"

# Update department
http PUT http://localhost:8082/api/departments/{id} \
  name="Updated Department"

# Delete department
http DELETE http://localhost:8082/api/departments/{id}
```
