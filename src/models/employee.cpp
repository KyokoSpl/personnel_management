#include "models/employee.h"

Employee Employee::fromJson(const QJsonObject& json) {
    Employee emp;
    emp.id = json["id"].toString();
    emp.firstName = json["first_name"].toString();
    emp.lastName = json["last_name"].toString();
    emp.email = json["email"].toString();
    emp.role = json["role"].toString();
    emp.active = json["active"].toBool(true);
    emp.departmentId = json["department_id"].toString();
    emp.managerId = json["manager_id"].toString();
    emp.salaryGradeId = json["salary_grade_id"].toString();

    if (json.contains("hire_date") && !json["hire_date"].isNull()) {
        emp.hireDate = QDateTime::fromString(json["hire_date"].toString(), Qt::ISODate);
    }
    if (json.contains("created_at") && !json["created_at"].isNull()) {
        emp.createdAt = QDateTime::fromString(json["created_at"].toString(), Qt::ISODate);
    }
    if (json.contains("updated_at") && !json["updated_at"].isNull()) {
        emp.updatedAt = QDateTime::fromString(json["updated_at"].toString(), Qt::ISODate);
    }
    if (json.contains("deleted_at") && !json["deleted_at"].isNull()) {
        emp.deletedAt = QDateTime::fromString(json["deleted_at"].toString(), Qt::ISODate);
    }

    return emp;
}

QJsonObject Employee::toJson() const {
    QJsonObject json;
    json["first_name"] = firstName;
    json["last_name"] = lastName;
    json["email"] = email;
    if (!role.isEmpty())
        json["role"] = role;
    json["active"] = active;
    if (!departmentId.isEmpty())
        json["department_id"] = departmentId;
    if (!managerId.isEmpty())
        json["manager_id"] = managerId;
    if (!salaryGradeId.isEmpty())
        json["salary_grade_id"] = salaryGradeId;
    if (hireDate.isValid())
        json["hire_date"] = hireDate.toString(Qt::ISODate);
    return json;
}
