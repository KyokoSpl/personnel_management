#ifndef PERSONNELAPP_H
#define PERSONNELAPP_H

#include "api/apiclient.h"
#include "gui/material3colors.h"

#include <QObject>
#include <QQmlApplicationEngine>

class PersonnelApp : public QObject {
    Q_OBJECT

    Q_PROPERTY(int currentTab READ currentTab WRITE setCurrentTab NOTIFY currentTabChanged)
    Q_PROPERTY(bool darkMode READ darkMode WRITE setDarkMode NOTIFY darkModeChanged)
    Q_PROPERTY(QList<Department> departments READ departments NOTIFY departmentsChanged)
    Q_PROPERTY(QList<Employee> employees READ employees NOTIFY employeesChanged)
    Q_PROPERTY(QList<SalaryGrade> salaryGrades READ salaryGrades NOTIFY salaryGradesChanged)
    Q_PROPERTY(QString errorMessage READ errorMessage NOTIFY errorMessageChanged)

public:
    explicit PersonnelApp(QObject* parent = nullptr);

    int currentTab() const { return m_currentTab; }
    void setCurrentTab(int tab);

    bool darkMode() const { return m_darkMode; }
    void setDarkMode(bool dark);

    QList<Department> departments() const { return m_departments; }
    QList<Employee> employees() const { return m_employees; }
    QList<SalaryGrade> salaryGrades() const { return m_salaryGrades; }
    QString errorMessage() const { return m_errorMessage; }

    // Department operations
    Q_INVOKABLE void refreshDepartments();
    Q_INVOKABLE void createDepartment(const QString& name, const QString& headId);
    Q_INVOKABLE void updateDepartment(const QString& id, const QString& name,
                                      const QString& headId);
    Q_INVOKABLE void updateDepartmentWithHead(const QString& deptId, const QString& name,
                                              const QString& newHeadId, const QString& oldHeadId);
    Q_INVOKABLE void deleteDepartment(const QString& id);

    // Employee operations
    Q_INVOKABLE void refreshEmployees();
    Q_INVOKABLE void createEmployee(const QString& firstName, const QString& lastName,
                                    const QString& email, const QString& role,
                                    const QString& deptId, const QString& managerId,
                                    const QString& gradeId);
    Q_INVOKABLE void updateEmployee(const QString& id, const QVariantMap& updates);
    Q_INVOKABLE void deleteEmployee(const QString& id);

    // Salary Grade operations
    Q_INVOKABLE void refreshSalaryGrades();
    Q_INVOKABLE void createSalaryGrade(const QString& code, double baseSalary,
                                       const QString& description);
    Q_INVOKABLE void updateSalaryGrade(const QString& id, const QString& code, double baseSalary,
                                       const QString& description);
    Q_INVOKABLE void deleteSalaryGrade(const QString& id);

signals:
    void currentTabChanged();
    void darkModeChanged();
    void departmentsChanged();
    void employeesChanged();
    void salaryGradesChanged();
    void errorMessageChanged();

private slots:
    void onDepartmentsReceived(QList<Department> departments);
    void onEmployeesReceived(QList<Employee> employees);
    void onSalaryGradesReceived(QList<SalaryGrade> grades);
    void onOperationCompleted(bool success, const QString& message);
    void onErrorOccurred(const QString& error);

private:
    ApiClient* m_apiClient;
    Material3Colors* m_colors;
    int m_currentTab;
    bool m_darkMode;
    QList<Department> m_departments;
    QList<Employee> m_employees;
    QList<SalaryGrade> m_salaryGrades;
    QString m_errorMessage;
};

#endif // PERSONNELAPP_H
