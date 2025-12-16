#include "api/apiclient.h"
#include "config.h"
#include <QNetworkRequest>
#include <QJsonObject>
#include <QJsonArray>

#ifdef DEBUG_API
#include <QDebug>
#endif

ApiClient::ApiClient(QObject* parent)
    : QObject(parent), m_networkManager(new QNetworkAccessManager(this)) {
}

QString ApiClient::getBaseUrl() const {
    return Config::instance().apiUrl();
}

void ApiClient::getDepartments() {
    QString url = getBaseUrl() + Config::instance().routeDepartments();
#ifdef DEBUG_API
    qDebug() << "GET Departments:" << url;
#endif
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    
    QNetworkReply* reply = m_networkManager->get(request);
    reply->setProperty("operation", "getDepartments");
    connect(reply, &QNetworkReply::finished, this, &ApiClient::onReplyFinished);
}

void ApiClient::createDepartment(const QString& name, const QString& headId) {
    QJsonObject data;
    data["name"] = name;
    if (!headId.isEmpty()) data["head_id"] = headId;
    
    QString url = getBaseUrl() + Config::instance().routeDepartments();
    sendRequest("POST", url, data);
}

void ApiClient::updateDepartment(const QString& id, const QString& name, const QString& headId) {
    QJsonObject data;
    if (!name.isEmpty()) data["name"] = name;
    if (!headId.isEmpty()) data["head_id"] = headId;
    
    QString url = getBaseUrl() + Config::instance().routeDepartments() + "/" + id;
    sendRequest("PUT", url, data);
}

void ApiClient::deleteDepartment(const QString& id) {
    QString url = getBaseUrl() + Config::instance().routeDepartments() + "/" + id;
    sendRequest("DELETE", url);
}

void ApiClient::getEmployees(bool includeInactive) {
    QString url = getBaseUrl() + Config::instance().routeEmployees();
    if (includeInactive) url += "?include_inactive=true";
#ifdef DEBUG_API
    qDebug() << "GET Employees:" << url;
#endif
    
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    
    QNetworkReply* reply = m_networkManager->get(request);
    reply->setProperty("operation", "getEmployees");
    connect(reply, &QNetworkReply::finished, this, &ApiClient::onReplyFinished);
}

void ApiClient::createEmployee(const QString& firstName, const QString& lastName, 
                               const QString& email, const QString& role, 
                               const QString& deptId, const QString& managerId, 
                               const QString& gradeId) {
    QJsonObject data;
    data["first_name"] = firstName;
    data["last_name"] = lastName;
    data["email"] = email;
    if (!role.isEmpty()) data["role"] = role;
    if (!deptId.isEmpty()) data["department_id"] = deptId;
    if (!managerId.isEmpty()) data["manager_id"] = managerId;
    if (!gradeId.isEmpty()) data["salary_grade_id"] = gradeId;
    
    QString url = getBaseUrl() + Config::instance().routeEmployees();
    sendRequest("POST", url, data);
}

void ApiClient::updateEmployee(const QString& id, const QJsonObject& updates) {
    QString url = getBaseUrl() + Config::instance().routeEmployees() + "/" + id;
    sendRequest("PUT", url, updates);
}

void ApiClient::deleteEmployee(const QString& id) {
    QString url = getBaseUrl() + Config::instance().routeEmployees() + "/" + id;
    sendRequest("DELETE", url);
}

void ApiClient::getSalaryGrades() {
    QString url = getBaseUrl() + Config::instance().routeSalaryGrades();
#ifdef DEBUG_API
    qDebug() << "GET Salary Grades:" << url;
#endif
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    
    QNetworkReply* reply = m_networkManager->get(request);
    reply->setProperty("operation", "getSalaryGrades");
    connect(reply, &QNetworkReply::finished, this, &ApiClient::onReplyFinished);
}

void ApiClient::createSalaryGrade(const QString& code, double baseSalary, const QString& description) {
    QJsonObject data;
    data["code"] = code;
    data["base_salary"] = baseSalary;
    if (!description.isEmpty()) data["description"] = description;
    
    QString url = getBaseUrl() + Config::instance().routeSalaryGrades();
    sendRequest("POST", url, data);
}

void ApiClient::updateSalaryGrade(const QString& id, const QString& code, double baseSalary, const QString& description) {
    QJsonObject data;
    if (!code.isEmpty()) data["code"] = code;
    if (baseSalary > 0) data["base_salary"] = baseSalary;
    if (!description.isEmpty()) data["description"] = description;
    
    QString url = getBaseUrl() + Config::instance().routeSalaryGrades() + "/" + id;
    sendRequest("PUT", url, data);
}

void ApiClient::deleteSalaryGrade(const QString& id) {
    QString url = getBaseUrl() + Config::instance().routeSalaryGrades() + "/" + id;
    sendRequest("DELETE", url);
}

void ApiClient::sendRequest(const QString& method, const QString& url, const QJsonObject& data) {
#ifdef DEBUG_API
    qDebug() << method << "request to:" << url;
    if (!data.isEmpty()) {
        qDebug() << "Request data:" << QJsonDocument(data).toJson(QJsonDocument::Compact);
    }
#endif
    
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    
    QNetworkReply* reply = nullptr;
    if (method == "POST") {
        reply = m_networkManager->post(request, QJsonDocument(data).toJson());
    } else if (method == "PUT") {
        reply = m_networkManager->put(request, QJsonDocument(data).toJson());
    } else if (method == "DELETE") {
        reply = m_networkManager->deleteResource(request);
    }
    
    if (reply) {
        reply->setProperty("operation", method.toLower());
        connect(reply, &QNetworkReply::finished, this, &ApiClient::onReplyFinished);
    }
}

void ApiClient::onReplyFinished() {
    QNetworkReply* reply = qobject_cast<QNetworkReply*>(sender());
    if (!reply) return;
    
    QString operation = reply->property("operation").toString();
#ifdef DEBUG_API
    qDebug() << "Response received for operation:" << operation;
#endif
    
    if (reply->error() != QNetworkReply::NoError) {
#ifdef DEBUG_API
        qDebug() << "Error:" << reply->errorString();
#endif
        emit errorOccurred(reply->errorString());
        emit operationCompleted(false, reply->errorString());
        reply->deleteLater();
        return;
    }
    
    QByteArray responseData = reply->readAll();
#ifdef DEBUG_API
    qDebug() << "Response data:" << responseData.left(200);
#endif
    QJsonDocument doc = QJsonDocument::fromJson(responseData);
    
    if (operation == "getDepartments") {
        QList<Department> departments;
        QJsonArray array = doc.array();
#ifdef DEBUG_API
        qDebug() << "Received" << array.size() << "departments";
#endif
        for (const QJsonValue& value : array) {
            departments.append(Department::fromJson(value.toObject()));
        }
        emit departmentsReceived(departments);
    } else if (operation == "getEmployees") {
        QList<Employee> employees;
        QJsonArray array = doc.array();
#ifdef DEBUG_API
        qDebug() << "Received" << array.size() << "employees";
#endif
        for (const QJsonValue& value : array) {
            employees.append(Employee::fromJson(value.toObject()));
        }
        emit employeesReceived(employees);
    } else if (operation == "getSalaryGrades") {
        QList<SalaryGrade> grades;
        QJsonArray array = doc.array();
#ifdef DEBUG_API
        qDebug() << "Received" << array.size() << "salary grades";
#endif
        for (const QJsonValue& value : array) {
            grades.append(SalaryGrade::fromJson(value.toObject()));
        }
        emit salaryGradesReceived(grades);
    } else {
#ifdef DEBUG_API
        qDebug() << "Operation completed successfully:" << operation;
#endif
        emit operationCompleted(true, "Operation completed successfully");
    }
    
    reply->deleteLater();
}
