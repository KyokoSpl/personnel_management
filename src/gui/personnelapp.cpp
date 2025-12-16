#include "gui/personnelapp.h"
#include <QJsonObject>

PersonnelApp::PersonnelApp(QObject* parent)
    : QObject(parent),
      m_apiClient(new ApiClient(this)),
      m_colors(new Material3Colors(true, this)),
      m_currentTab(0),
      m_darkMode(true) {
    
    // Connect signals
    connect(m_apiClient, &ApiClient::departmentsReceived, this, &PersonnelApp::onDepartmentsReceived);
    connect(m_apiClient, &ApiClient::employeesReceived, this, &PersonnelApp::onEmployeesReceived);
    connect(m_apiClient, &ApiClient::salaryGradesReceived, this, &PersonnelApp::onSalaryGradesReceived);
    connect(m_apiClient, &ApiClient::operationCompleted, this, &PersonnelApp::onOperationCompleted);
    connect(m_apiClient, &ApiClient::errorOccurred, this, &PersonnelApp::onErrorOccurred);
    
    // Load initial data
    refreshDepartments();
    refreshEmployees();
    refreshSalaryGrades();
}

void PersonnelApp::setCurrentTab(int tab) {
    if (m_currentTab != tab) {
        m_currentTab = tab;
        emit currentTabChanged();
    }
}

void PersonnelApp::setDarkMode(bool dark) {
    if (m_darkMode != dark) {
        m_darkMode = dark;
        delete m_colors;
        m_colors = new Material3Colors(dark, this);
        emit darkModeChanged();
    }
}

void PersonnelApp::refreshDepartments() {
    m_apiClient->getDepartments();
}

void PersonnelApp::createDepartment(const QString& name, const QString& headId) {
    m_apiClient->createDepartment(name, headId);
}

void PersonnelApp::updateDepartment(const QString& id, const QString& name, const QString& headId) {
    m_apiClient->updateDepartment(id, name, headId);
}

void PersonnelApp::updateDepartmentWithHead(const QString& deptId, const QString& name, 
                                             const QString& newHeadId, const QString& oldHeadId) {
    // Update the department first
    m_apiClient->updateDepartment(deptId, name, newHeadId);
    
    // If there was an old head and it's different from the new one, update their role
    if (!oldHeadId.isEmpty() && oldHeadId != newHeadId) {
        QJsonObject oldHeadUpdate;
        oldHeadUpdate["role"] = "Employee";
        m_apiClient->updateEmployee(oldHeadId, oldHeadUpdate);
    }
    
    // If there's a new head, update their role to DepartmentHead (no space - API format)
    if (!newHeadId.isEmpty()) {
        QJsonObject newHeadUpdate;
        newHeadUpdate["role"] = "DepartmentHead";
        m_apiClient->updateEmployee(newHeadId, newHeadUpdate);
    }
}

void PersonnelApp::deleteDepartment(const QString& id) {
    m_apiClient->deleteDepartment(id);
}

void PersonnelApp::refreshEmployees() {
    m_apiClient->getEmployees(false);
}

void PersonnelApp::createEmployee(const QString& firstName, const QString& lastName,
                                 const QString& email, const QString& role,
                                 const QString& deptId, const QString& managerId,
                                 const QString& gradeId) {
    m_apiClient->createEmployee(firstName, lastName, email, role, deptId, managerId, gradeId);
}

void PersonnelApp::updateEmployee(const QString& id, const QVariantMap& updates) {
    QJsonObject json;
    for (auto it = updates.begin(); it != updates.end(); ++it) {
        json[it.key()] = QJsonValue::fromVariant(it.value());
    }
    m_apiClient->updateEmployee(id, json);
}

void PersonnelApp::deleteEmployee(const QString& id) {
    m_apiClient->deleteEmployee(id);
}

void PersonnelApp::refreshSalaryGrades() {
    m_apiClient->getSalaryGrades();
}

void PersonnelApp::createSalaryGrade(const QString& code, double baseSalary, const QString& description) {
    m_apiClient->createSalaryGrade(code, baseSalary, description);
}

void PersonnelApp::updateSalaryGrade(const QString& id, const QString& code, double baseSalary, const QString& description) {
    m_apiClient->updateSalaryGrade(id, code, baseSalary, description);
}

void PersonnelApp::deleteSalaryGrade(const QString& id) {
    m_apiClient->deleteSalaryGrade(id);
}

void PersonnelApp::onDepartmentsReceived(QList<Department> departments) {
    m_departments = departments;
    emit departmentsChanged();
}

void PersonnelApp::onEmployeesReceived(QList<Employee> employees) {
    m_employees = employees;
    emit employeesChanged();
}

void PersonnelApp::onSalaryGradesReceived(QList<SalaryGrade> grades) {
    m_salaryGrades = grades;
    emit salaryGradesChanged();
}

void PersonnelApp::onOperationCompleted(bool success, const QString& message) {
    if (success) {
        // Refresh data after successful operation
        refreshDepartments();
        refreshEmployees();
        refreshSalaryGrades();
        m_errorMessage.clear();
    } else {
        m_errorMessage = message;
    }
    emit errorMessageChanged();
}

void PersonnelApp::onErrorOccurred(const QString& error) {
    m_errorMessage = error;
    emit errorMessageChanged();
}
