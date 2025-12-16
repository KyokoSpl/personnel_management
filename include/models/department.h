#ifndef DEPARTMENT_H
#define DEPARTMENT_H

#include <QString>
#include <QDateTime>
#include <QJsonObject>
#include <QObject>

class Department {
    Q_GADGET
    Q_PROPERTY(QString id MEMBER id)
    Q_PROPERTY(QString name MEMBER name)
    Q_PROPERTY(QString headId MEMBER headId)
    Q_PROPERTY(QDateTime createdAt MEMBER createdAt)
    Q_PROPERTY(QDateTime updatedAt MEMBER updatedAt)

public:
    QString id;
    QString name;
    QString headId;
    QDateTime createdAt;
    QDateTime updatedAt;

    Department() = default;
    Department(const QString& id, const QString& name, const QString& headId = QString())
        : id(id), name(name), headId(headId) {}

    static Department fromJson(const QJsonObject& json);
    QJsonObject toJson() const;
};

Q_DECLARE_METATYPE(Department)

#endif // DEPARTMENT_H