# Architecture Documentation

## Overview

The Personnel Management System is a cross-platform desktop application built using modern C++17 and the Qt6 framework. It follows a layered architecture pattern with clear separation of concerns between the user interface, business logic, and data access layers.

## System Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                        Personnel Management System                   │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │                    Presentation Layer (QML)                  │    │
│  │  ┌───────────┐  ┌───────────┐  ┌───────────────────────┐   │    │
│  │  │   Views   │  │  Dialogs  │  │      Components       │   │    │
│  │  └───────────┘  └───────────┘  └───────────────────────┘   │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                              │                                       │
│                    Q_PROPERTY Bindings                               │
│                              │                                       │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │                   Application Layer (C++)                    │    │
│  │  ┌───────────────┐  ┌────────────┐  ┌─────────────────┐    │    │
│  │  │ PersonnelApp  │  │   Models   │  │ Material3Colors │    │    │
│  │  │ (Controller)  │  │ (Entities) │  │    (Theme)      │    │    │
│  │  └───────────────┘  └────────────┘  └─────────────────────┘    │
│  └─────────────────────────────────────────────────────────────┘    │
│                              │                                       │
│                       Signals & Slots                                │
│                              │                                       │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │                     Data Access Layer                        │    │
│  │  ┌───────────────────────────────────────────────────────┐  │    │
│  │  │                    API Client                          │  │    │
│  │  │  ┌─────────────┐  ┌───────────┐  ┌─────────────────┐  │  │    │
│  │  │  │   Config    │  │  Network  │  │  JSON Handling  │  │  │    │
│  │  │  └─────────────┘  └───────────┘  └─────────────────┘  │  │    │
│  │  └───────────────────────────────────────────────────────┘  │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                              │                                       │
└──────────────────────────────│───────────────────────────────────────┘
                               │
                               ▼
                   ┌───────────────────────┐
                   │    Backend REST API    │
                   │  (External Service)    │
                   └───────────────────────┘
```

## Layer Descriptions

### 1. Presentation Layer (QML)

The presentation layer is built entirely with Qt Quick/QML, providing a declarative and responsive user interface.

#### Views
Located in `resources/qml/views/`:

| File | Purpose |
|------|---------|
| `DepartmentsView.qml` | Displays and manages department data |
| `EmployeesView.qml` | Displays and manages employee data |
| `SalaryGradesView.qml` | Displays and manages salary grade data |

#### Dialogs
Located in `resources/qml/dialogs/`:

| File | Purpose |
|------|---------|
| `ConfirmDialog.qml` | Generic confirmation dialog |
| `DepartmentEditDialog.qml` | Create/Edit department form |
| `EmployeeEditDialog.qml` | Create/Edit employee form |
| `SalaryGradeEditDialog.qml` | Create/Edit salary grade form |

#### Components
Located in `resources/qml/components/`:

| File | Purpose |
|------|---------|
| `MaterialButton.qml` | Material Design 3 styled button |
| `MaterialCard.qml` | Material Design 3 card container |
| `MaterialComboBox.qml` | Material Design 3 dropdown |
| `MaterialIcon.qml` | Material icon display component |
| `MaterialTextField.qml` | Material Design 3 text input |
| `SearchableEmployeeComboBox.qml` | Searchable employee selector |

### 2. Application Layer (C++)

The application layer contains the core business logic and acts as a bridge between the QML UI and the data layer.

#### PersonnelApp (`include/gui/personnelapp.h`)

The main application controller that:
- Manages application state
- Exposes data models to QML via Q_PROPERTY
- Handles user actions through Q_INVOKABLE methods
- Coordinates data operations between views and API

```cpp
class PersonnelApp : public QObject {
    Q_OBJECT
    Q_PROPERTY(QVariantList departments READ departments NOTIFY departmentsChanged)
    Q_PROPERTY(QVariantList employees READ employees NOTIFY employeesChanged)
    Q_PROPERTY(QVariantList salaryGrades READ salaryGrades NOTIFY salaryGradesChanged)
    Q_PROPERTY(bool loading READ loading NOTIFY loadingChanged)
    Q_PROPERTY(QString error READ error NOTIFY errorChanged)
    
public:
    Q_INVOKABLE void loadDepartments();
    Q_INVOKABLE void createDepartment(const QVariantMap& data);
    Q_INVOKABLE void updateDepartment(const QString& id, const QVariantMap& data);
    Q_INVOKABLE void deleteDepartment(const QString& id);
    // ... similar methods for employees and salary grades
};
```

#### Models (`include/models/`)

Data models representing business entities:

| Model | Description | Properties |
|-------|-------------|------------|
| `Department` | Organizational unit | id, name, headEmployeeId |
| `Employee` | Personnel record | id, firstName, lastName, departmentId, salaryGradeId, etc. |
| `SalaryGrade` | Compensation level | id, code, baseSalary |

#### Material3Colors (`include/gui/material3colors.h`)

Theme management class providing Material Design 3 color palette:

```cpp
class Material3Colors : public QObject {
    Q_OBJECT
    Q_PROPERTY(bool darkMode READ darkMode WRITE setDarkMode NOTIFY darkModeChanged)
    Q_PROPERTY(QColor primary READ primary NOTIFY colorsChanged)
    Q_PROPERTY(QColor onPrimary READ onPrimary NOTIFY colorsChanged)
    Q_PROPERTY(QColor surface READ surface NOTIFY colorsChanged)
    // ... additional color properties
};
```

### 3. Data Access Layer

#### API Client (`include/api/apiclient.h`)

Handles all communication with the backend REST API:

```cpp
class ApiClient : public QObject {
    Q_OBJECT
    
public:
    // Singleton access
    static ApiClient& instance();
    
    // CRUD operations
    void getDepartments();
    void createDepartment(const QJsonObject& data);
    void updateDepartment(const QString& id, const QJsonObject& data);
    void deleteDepartment(const QString& id);
    // ... similar methods for other entities
    
signals:
    void departmentsLoaded(const QJsonArray& departments);
    void departmentCreated(const QJsonObject& department);
    void departmentUpdated(const QJsonObject& department);
    void departmentDeleted(const QString& id);
    void error(const QString& message);
};
```

#### Configuration (`include/config.h`)

Singleton configuration manager:

```cpp
class Config {
public:
    static Config& instance();
    
    QString apiBaseUrl() const;
    QString apiPrefix() const;
    QString apiUrl() const;  // Returns apiBaseUrl + apiPrefix
    
private:
    void loadEnvFile();  // Loads .env configuration
};
```

## Design Patterns

### 1. Model-View-Controller (MVC)

```
┌─────────────┐     Notifies     ┌─────────────┐
│    View     │◄─────────────────│   Model     │
│   (QML)     │                  │   (C++)     │
└─────────────┘                  └─────────────┘
       │                               ▲
       │ User Actions                  │ Updates
       ▼                               │
┌─────────────────────────────────────────────┐
│              Controller (PersonnelApp)       │
└─────────────────────────────────────────────┘
```

### 2. Singleton Pattern

Used for:
- `Config` - Application configuration
- `ApiClient` - Network communication (optional)
- Qt's QML Engine - Single engine instance

### 3. Observer Pattern (Qt Signals & Slots)

```cpp
// Signal emission
emit departmentsChanged();

// Slot connection
connect(apiClient, &ApiClient::departmentsLoaded,
        this, &PersonnelApp::onDepartmentsLoaded);

// QML binding (automatic updates)
// In QML:
// model: personnelApp.departments
```

### 4. Property Binding

Qt's Q_PROPERTY system enables reactive UI updates:

```cpp
// C++ Declaration
Q_PROPERTY(QVariantList departments READ departments NOTIFY departmentsChanged)

// QML Usage
ListView {
    model: personnelApp.departments
    delegate: DepartmentItem { /* ... */ }
}
// Automatically updates when departmentsChanged() is emitted
```

## Data Flow

### Read Operation Flow

```
┌───────────────────────────────────────────────────────────────────┐
│                         Read Data Flow                            │
└───────────────────────────────────────────────────────────────────┘

  QML View              PersonnelApp           ApiClient          Backend
     │                       │                     │                  │
     │  loadDepartments()    │                     │                  │
     │──────────────────────►│                     │                  │
     │                       │  getDepartments()   │                  │
     │                       │────────────────────►│                  │
     │                       │                     │  GET /api/...    │
     │                       │                     │─────────────────►│
     │                       │                     │                  │
     │                       │                     │  JSON Response   │
     │                       │                     │◄─────────────────│
     │                       │  departmentsLoaded  │                  │
     │                       │◄────────────────────│                  │
     │  departmentsChanged   │                     │                  │
     │◄──────────────────────│                     │                  │
     │                       │                     │                  │
   [UI Updates via binding]  │                     │                  │
```

### Write Operation Flow

```
┌───────────────────────────────────────────────────────────────────┐
│                        Write Data Flow                            │
└───────────────────────────────────────────────────────────────────┘

  QML Dialog            PersonnelApp           ApiClient          Backend
     │                       │                     │                  │
     │  createDepartment()   │                     │                  │
     │──────────────────────►│                     │                  │
     │                       │  validate()         │                  │
     │                       │────────┐            │                  │
     │                       │◄───────┘            │                  │
     │                       │                     │                  │
     │                       │  createDepartment() │                  │
     │                       │────────────────────►│                  │
     │                       │                     │  POST /api/...   │
     │                       │                     │─────────────────►│
     │                       │                     │                  │
     │                       │                     │  JSON Response   │
     │                       │                     │◄─────────────────│
     │                       │  departmentCreated  │                  │
     │                       │◄────────────────────│                  │
     │  departmentsChanged   │                     │                  │
     │◄──────────────────────│                     │                  │
     │                       │                     │                  │
   [Close dialog, refresh]   │                     │                  │
```

## Component Interactions

### QML to C++ Communication

```qml
// QML calling C++ methods
Button {
    onClicked: {
        personnelApp.createDepartment({
            name: nameField.text,
            headEmployeeId: headCombo.currentValue
        })
    }
}

// QML reading C++ properties
ListView {
    model: personnelApp.departments
}

// QML responding to C++ signals
Connections {
    target: personnelApp
    function onErrorChanged() {
        errorDialog.text = personnelApp.error
        errorDialog.open()
    }
}
```

### C++ to QML Communication

```cpp
// Emitting signals to update QML
void PersonnelApp::onDepartmentsLoaded(const QJsonArray& data) {
    m_departments.clear();
    for (const auto& item : data) {
        m_departments.append(item.toObject().toVariantMap());
    }
    emit departmentsChanged();  // QML automatically updates
}
```

## Resource Management

### Qt Resource System

Resources are embedded in the binary using Qt's resource system:

```xml
<!-- fonts.qrc -->
<RCC>
    <qresource prefix="/fonts">
        <file>fonts/MaterialIcons-Regular.ttf</file>
    </qresource>
</RCC>
```

### QML Import Paths

QML files are loaded from the filesystem at runtime:

```cpp
// In main.cpp
QQmlApplicationEngine engine;
engine.addImportPath(QCoreApplication::applicationDirPath() + "/resources/qml");
engine.load(QUrl::fromLocalFile("resources/qml/main.qml"));
```

## Error Handling

### Network Errors

```cpp
void ApiClient::handleNetworkError(QNetworkReply* reply) {
    QString errorMessage;
    switch (reply->error()) {
        case QNetworkReply::ConnectionRefusedError:
            errorMessage = "Cannot connect to server";
            break;
        case QNetworkReply::TimeoutError:
            errorMessage = "Request timed out";
            break;
        default:
            errorMessage = reply->errorString();
    }
    emit error(errorMessage);
}
```

### Validation Errors

```cpp
bool PersonnelApp::validateDepartment(const QVariantMap& data) {
    QString name = data["name"].toString();
    if (name.isEmpty()) {
        setError("Department name is required");
        return false;
    }
    if (name.length() > 100) {
        setError("Department name is too long");
        return false;
    }
    return true;
}
```

### QML Error Display

```qml
Dialog {
    id: errorDialog
    property string text: personnelApp.error
    visible: text.length > 0
    
    Text {
        text: errorDialog.text
        color: Material3.colors.error
    }
}
```

## Threading Model

The application uses Qt's event-driven model:

```
┌─────────────────────────────────────────────────────────────────┐
│                        Main Thread                               │
│  ┌───────────┐  ┌───────────┐  ┌───────────┐  ┌───────────┐    │
│  │ QML Engine│  │  Models   │  │ API Client│  │Event Loop │    │
│  └───────────┘  └───────────┘  └───────────┘  └───────────┘    │
└─────────────────────────────────────────────────────────────────┘
                                        │
                          Non-blocking I/O
                                        │
                                        ▼
                           ┌───────────────────┐
                           │  Network Requests │
                           │  (Async via Qt)   │
                           └───────────────────┘
```

**Key Points:**
- All UI operations happen on the main thread
- Network requests are asynchronous (non-blocking)
- Qt's event loop processes signals and slots
- No manual thread management required for basic operations

## Security Considerations

### Configuration Security

- Sensitive configuration stored in `.env` (not committed to git)
- Environment variables take precedence over defaults
- No hardcoded credentials in source code

### Network Security

- HTTPS support via QNetworkAccessManager
- SSL certificate validation (Qt default)
- Timeout handling for network requests

### Input Validation

- Client-side validation before API calls
- Server-side validation as primary security
- Proper escaping for displayed data

## Performance Considerations

### QML Optimization

- Use `Loader` for lazy loading of views
- Implement `ListView` with delegates for large lists
- Cache frequently accessed data

### Network Optimization

- Batch API calls where possible
- Implement request caching
- Use pagination for large datasets

### Memory Management

- Qt's parent-child ownership model
- Smart pointers for non-QObject classes
- Proper cleanup in destructors

## Extensibility

### Adding a New Entity

1. **Create Model** (`include/models/newentity.h`)
2. **Add API Methods** (`include/api/apiclient.h`)
3. **Add Controller Methods** (`include/gui/personnelapp.h`)
4. **Create QML View** (`resources/qml/views/NewEntityView.qml`)
5. **Create QML Dialog** (`resources/qml/dialogs/NewEntityEditDialog.qml`)
6. **Update Navigation** (`resources/qml/main.qml`)

### Adding a New Feature

1. Identify the layer(s) affected
2. Follow existing patterns in that layer
3. Use signals/slots for cross-layer communication
4. Update documentation

## Testing Strategy

### Unit Testing

```cpp
// Using Qt Test framework
class TestDepartment : public QObject {
    Q_OBJECT
private slots:
    void testCreate();
    void testValidation();
    void testJsonSerialization();
};
```

### Integration Testing

```cpp
class TestApiClient : public QObject {
    Q_OBJECT
private slots:
    void testGetDepartments();
    void testCreateDepartment();
    void testErrorHandling();
};
```

### QML Testing

```qml
// Using Qt Quick Test
TestCase {
    name: "MaterialButton"
    
    MaterialButton {
        id: testButton
        text: "Test"
    }
    
    function test_click() {
        var clicked = false
        testButton.clicked.connect(function() { clicked = true })
        mouseClick(testButton)
        verify(clicked)
    }
}
```

## Deployment Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                      Deployment Package                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌─────────────────┐  ┌─────────────────┐  ┌────────────────┐  │
│  │    Executable   │  │   QML Files     │  │   Resources    │  │
│  │personnel_mgmt   │  │  resources/qml/ │  │  fonts, icons  │  │
│  └─────────────────┘  └─────────────────┘  └────────────────┘  │
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │               Qt Runtime Libraries                       │    │
│  │  Qt6Core  Qt6Gui  Qt6Quick  Qt6Network  Qt6QmlModels    │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │              Platform Plugins                            │    │
│  │  platforms/  imageformats/  styles/  qml/               │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

## References

- [Qt Documentation](https://doc.qt.io/)
- [QML Book](https://www.qt.io/product/qt6/qml-book)
- [Material Design 3](https://m3.material.io/)
- [C++ Core Guidelines](https://isocpp.github.io/CppCoreGuidelines/)