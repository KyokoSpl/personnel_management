#ifndef APICLIENT_H
#define APICLIENT_H

#include "models/department.h"
#include "models/employee.h"
#include "models/salarygrade.h"

#include <QJsonArray>
#include <QJsonDocument>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QObject>

class ApiClient : public QObject {
    Q_OBJECT

public:
    explicit ApiClient(QObject* parent = nullptr);

    // Department operations
    void getDepartments();
    void createDepartment(const QString& name, const QString& headId = QString());
    void updateDepartment(const QString& id, const QString& name,
                          const QString& headId = QString());
    void deleteDepartment(const QString& id);

    // Employee operations
    void getEmployees(bool includeInactive = false);
    void createEmployee(const QString& firstName, const QString& lastName, const QString& email,
                        const QString& role = QString(), const QString& deptId = QString(),
                        const QString& managerId = QString(), const QString& gradeId = QString());
    void updateEmployee(const QString& id, const QJsonObject& updates);
    void deleteEmployee(const QString& id);

    // Salary Grade operations
    void getSalaryGrades();
    void createSalaryGrade(const QString& code, double baseSalary,
                           const QString& description = QString());
    void updateSalaryGrade(const QString& id, const QString& code, double baseSalary,
                           const QString& description = QString());
    void deleteSalaryGrade(const QString& id);

signals:
    void departmentsReceived(QList<Department> departments);
    void employeesReceived(QList<Employee> employees);
    void salaryGradesReceived(QList<SalaryGrade> grades);
    void operationCompleted(bool success, const QString& message);
    void errorOccurred(const QString& error);

private slots:
    void onReplyFinished();

private:
    QNetworkAccessManager* m_networkManager;
    QString getBaseUrl() const;
    void sendRequest(const QString& method, const QString& url,
                     const QJsonObject& data = QJsonObject());
};

#endif // APICLIENT_H
