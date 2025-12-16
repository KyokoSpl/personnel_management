#ifndef SALARYGRADE_H
#define SALARYGRADE_H

#include <QString>
#include <QDateTime>
#include <QJsonObject>

class SalaryGrade {
    Q_GADGET
    Q_PROPERTY(QString id MEMBER id)
    Q_PROPERTY(QString code MEMBER code)
    Q_PROPERTY(double baseSalary MEMBER baseSalary)
    Q_PROPERTY(QString description MEMBER description)

public:
    QString id;
    QString code;
    double baseSalary = 0.0;
    QString description;
    QDateTime createdAt;

    SalaryGrade() = default;

    static SalaryGrade fromJson(const QJsonObject& json);
    QJsonObject toJson() const;
};

Q_DECLARE_METATYPE(SalaryGrade)

#endif // SALARYGRADE_H