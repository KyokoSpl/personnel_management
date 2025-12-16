#include "models/salarygrade.h"

SalaryGrade SalaryGrade::fromJson(const QJsonObject& json) {
    SalaryGrade grade;
    grade.id = json["id"].toString();
    grade.code = json["code"].toString();
    grade.baseSalary = json["base_salary"].toDouble();
    grade.description = json["description"].toString();
    
    if (json.contains("created_at") && !json["created_at"].isNull()) {
        grade.createdAt = QDateTime::fromString(json["created_at"].toString(), Qt::ISODate);
    }
    
    return grade;
}

QJsonObject SalaryGrade::toJson() const {
    QJsonObject json;
    json["code"] = code;
    json["base_salary"] = baseSalary;
    if (!description.isEmpty()) {
        json["description"] = description;
    }
    return json;
}
