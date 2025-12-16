#include "models/department.h"

#include <QJsonValue>

Department Department::fromJson(const QJsonObject& json) {
    Department dept;
    dept.id = json["id"].toString();
    dept.name = json["name"].toString();
    dept.headId = json["head_id"].toString();

    if (json.contains("created_at") && !json["created_at"].isNull()) {
        dept.createdAt = QDateTime::fromString(json["created_at"].toString(), Qt::ISODate);
    }
    if (json.contains("updated_at") && !json["updated_at"].isNull()) {
        dept.updatedAt = QDateTime::fromString(json["updated_at"].toString(), Qt::ISODate);
    }

    return dept;
}

QJsonObject Department::toJson() const {
    QJsonObject json;
    json["name"] = name;
    if (!headId.isEmpty()) {
        json["head_id"] = headId;
    }
    return json;
}
