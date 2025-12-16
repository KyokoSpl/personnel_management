#ifndef EMPLOYEE_H
#define EMPLOYEE_H

#include <QString>
#include <QDateTime>
#include <QJsonObject>

class Employee {
    Q_GADGET
    Q_PROPERTY(QString id MEMBER id)
    Q_PROPERTY(QString firstName MEMBER firstName)
    Q_PROPERTY(QString lastName MEMBER lastName)
    Q_PROPERTY(QString email MEMBER email)
    Q_PROPERTY(QString role MEMBER role)
    Q_PROPERTY(bool active MEMBER active)
    Q_PROPERTY(QString departmentId MEMBER departmentId)
    Q_PROPERTY(QString managerId MEMBER managerId)
    Q_PROPERTY(QString salaryGradeId MEMBER salaryGradeId)
    Q_PROPERTY(QDateTime hireDate MEMBER hireDate)
    Q_PROPERTY(QDateTime createdAt MEMBER createdAt)
    Q_PROPERTY(QDateTime updatedAt MEMBER updatedAt)
    Q_PROPERTY(QDateTime deletedAt MEMBER deletedAt)

public:
    QString id;
    QString firstName;
    QString lastName;
    QString email;
    QString role;
    bool active = true;
    QString departmentId;
    QString managerId;
    QString salaryGradeId;
    QDateTime hireDate;
    QDateTime createdAt;
    QDateTime updatedAt;
    QDateTime deletedAt;

    Employee() = default;
    
    QString fullName() const { return firstName + " " + lastName; }

    static Employee fromJson(const QJsonObject& json);
    QJsonObject toJson() const;
};

Q_DECLARE_METATYPE(Employee)

#endif // EMPLOYEE_H