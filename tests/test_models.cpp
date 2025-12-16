#include "models/department.h"
#include "models/employee.h"
#include "models/salarygrade.h"

#include <QDateTime>
#include <QJsonDocument>
#include <QJsonObject>

#include <gtest/gtest.h>

// ============================================================================
// Employee Tests
// ============================================================================

class EmployeeTest : public ::testing::Test {
protected:
    void SetUp() override {
        // Setup common test data
        testEmployee.id = "emp-123";
        testEmployee.firstName = "John";
        testEmployee.lastName = "Doe";
        testEmployee.email = "john.doe@example.com";
        testEmployee.role = "Developer";
        testEmployee.active = true;
        testEmployee.departmentId = "dept-456";
        testEmployee.managerId = "emp-789";
        testEmployee.salaryGradeId = "grade-001";
        testEmployee.hireDate = QDateTime::fromString("2023-01-15T00:00:00Z", Qt::ISODate);
        testEmployee.createdAt = QDateTime::fromString("2023-01-10T10:30:00Z", Qt::ISODate);
        testEmployee.updatedAt = QDateTime::fromString("2023-06-20T14:20:00Z", Qt::ISODate);
    }

    Employee testEmployee;
};

TEST_F(EmployeeTest, DefaultConstructor) {
    Employee emp;
    EXPECT_TRUE(emp.id.isEmpty());
    EXPECT_TRUE(emp.firstName.isEmpty());
    EXPECT_TRUE(emp.lastName.isEmpty());
    EXPECT_TRUE(emp.email.isEmpty());
    EXPECT_TRUE(emp.active);
}

TEST_F(EmployeeTest, FullName) {
    EXPECT_EQ(testEmployee.fullName(), "John Doe");

    Employee emp;
    emp.firstName = "Jane";
    emp.lastName = "Smith";
    EXPECT_EQ(emp.fullName(), "Jane Smith");
}

TEST_F(EmployeeTest, ToJson) {
    QJsonObject json = testEmployee.toJson();

    // Note: id is not included in toJson() as it's typically only used for creation/updates
    EXPECT_EQ(json["first_name"].toString(), "John");
    EXPECT_EQ(json["last_name"].toString(), "Doe");
    EXPECT_EQ(json["email"].toString(), "john.doe@example.com");
    EXPECT_EQ(json["role"].toString(), "Developer");
    EXPECT_TRUE(json["active"].toBool());
    EXPECT_EQ(json["department_id"].toString(), "dept-456");
    EXPECT_EQ(json["manager_id"].toString(), "emp-789");
    EXPECT_EQ(json["salary_grade_id"].toString(), "grade-001");
    EXPECT_TRUE(json.contains("hire_date"));
}

TEST_F(EmployeeTest, FromJson) {
    QJsonObject json;
    json["id"] = "emp-999";
    json["first_name"] = "Alice";
    json["last_name"] = "Johnson";
    json["email"] = "alice.j@example.com";
    json["role"] = "Manager";
    json["active"] = true;
    json["department_id"] = "dept-111";
    json["manager_id"] = "emp-222";
    json["salary_grade_id"] = "grade-002";
    json["hire_date"] = "2022-03-01T00:00:00Z";
    json["created_at"] = "2022-02-15T08:00:00Z";
    json["updated_at"] = "2023-01-01T12:00:00Z";

    Employee emp = Employee::fromJson(json);

    EXPECT_EQ(emp.id, "emp-999");
    EXPECT_EQ(emp.firstName, "Alice");
    EXPECT_EQ(emp.lastName, "Johnson");
    EXPECT_EQ(emp.email, "alice.j@example.com");
    EXPECT_EQ(emp.role, "Manager");
    EXPECT_TRUE(emp.active);
    EXPECT_EQ(emp.departmentId, "dept-111");
    EXPECT_EQ(emp.managerId, "emp-222");
    EXPECT_EQ(emp.salaryGradeId, "grade-002");
    EXPECT_TRUE(emp.hireDate.isValid());
    EXPECT_TRUE(emp.createdAt.isValid());
    EXPECT_TRUE(emp.updatedAt.isValid());
}

TEST_F(EmployeeTest, FromJsonWithMissingFields) {
    QJsonObject json;
    json["id"] = "emp-100";
    json["first_name"] = "Bob";
    json["last_name"] = "Smith";

    Employee emp = Employee::fromJson(json);

    EXPECT_EQ(emp.id, "emp-100");
    EXPECT_EQ(emp.firstName, "Bob");
    EXPECT_EQ(emp.lastName, "Smith");
    EXPECT_TRUE(emp.email.isEmpty());
    EXPECT_TRUE(emp.departmentId.isEmpty());
}

TEST_F(EmployeeTest, RoundTripJsonConversion) {
    QJsonObject json1 = testEmployee.toJson();
    Employee emp2 = Employee::fromJson(json1);
    QJsonObject json2 = emp2.toJson();

    // Compare the fields that are included in toJson()
    EXPECT_EQ(json1["first_name"], json2["first_name"]);
    EXPECT_EQ(json1["last_name"], json2["last_name"]);
    EXPECT_EQ(json1["email"], json2["email"]);
    EXPECT_EQ(json1["role"], json2["role"]);
    EXPECT_EQ(json1["active"], json2["active"]);
    EXPECT_EQ(json1["department_id"], json2["department_id"]);
}

// ============================================================================
// Department Tests
// ============================================================================

class DepartmentTest : public ::testing::Test {
protected:
    void SetUp() override {
        testDepartment.id = "dept-123";
        testDepartment.name = "Engineering";
        testDepartment.headId = "emp-456";
        testDepartment.createdAt = QDateTime::fromString("2023-01-01T00:00:00Z", Qt::ISODate);
        testDepartment.updatedAt = QDateTime::fromString("2023-06-15T10:30:00Z", Qt::ISODate);
    }

    Department testDepartment;
};

TEST_F(DepartmentTest, DefaultConstructor) {
    Department dept;
    EXPECT_TRUE(dept.id.isEmpty());
    EXPECT_TRUE(dept.name.isEmpty());
    EXPECT_TRUE(dept.headId.isEmpty());
}

TEST_F(DepartmentTest, ParameterizedConstructor) {
    Department dept("dept-999", "Marketing", "emp-111");

    EXPECT_EQ(dept.id, "dept-999");
    EXPECT_EQ(dept.name, "Marketing");
    EXPECT_EQ(dept.headId, "emp-111");
}

TEST_F(DepartmentTest, ParameterizedConstructorWithoutHead) {
    Department dept("dept-888", "Sales");

    EXPECT_EQ(dept.id, "dept-888");
    EXPECT_EQ(dept.name, "Sales");
    EXPECT_TRUE(dept.headId.isEmpty());
}

TEST_F(DepartmentTest, ToJson) {
    QJsonObject json = testDepartment.toJson();

    // Note: id, created_at, updated_at are not included in toJson() as they're server-managed
    EXPECT_EQ(json["name"].toString(), "Engineering");
    EXPECT_EQ(json["head_id"].toString(), "emp-456");
}

TEST_F(DepartmentTest, FromJson) {
    QJsonObject json;
    json["id"] = "dept-777";
    json["name"] = "Human Resources";
    json["head_id"] = "emp-888";
    json["created_at"] = "2022-05-10T08:00:00Z";
    json["updated_at"] = "2023-03-20T14:30:00Z";

    Department dept = Department::fromJson(json);

    EXPECT_EQ(dept.id, "dept-777");
    EXPECT_EQ(dept.name, "Human Resources");
    EXPECT_EQ(dept.headId, "emp-888");
    EXPECT_TRUE(dept.createdAt.isValid());
    EXPECT_TRUE(dept.updatedAt.isValid());
}

TEST_F(DepartmentTest, FromJsonWithoutHead) {
    QJsonObject json;
    json["id"] = "dept-666";
    json["name"] = "Finance";

    Department dept = Department::fromJson(json);

    EXPECT_EQ(dept.id, "dept-666");
    EXPECT_EQ(dept.name, "Finance");
    EXPECT_TRUE(dept.headId.isEmpty());
}

TEST_F(DepartmentTest, RoundTripJsonConversion) {
    QJsonObject json1 = testDepartment.toJson();
    Department dept2 = Department::fromJson(json1);
    QJsonObject json2 = dept2.toJson();

    // Compare the fields that are included in toJson()
    EXPECT_EQ(json1["name"], json2["name"]);
    EXPECT_EQ(json1["head_id"], json2["head_id"]);
}

// ============================================================================
// SalaryGrade Tests
// ============================================================================

class SalaryGradeTest : public ::testing::Test {
protected:
    void SetUp() override {
        testGrade.id = "grade-123";
        testGrade.code = "L5";
        testGrade.baseSalary = 85000.50;
        testGrade.description = "Senior Engineer Level";
        testGrade.createdAt = QDateTime::fromString("2023-01-01T00:00:00Z", Qt::ISODate);
    }

    SalaryGrade testGrade;
};

TEST_F(SalaryGradeTest, DefaultConstructor) {
    SalaryGrade grade;
    EXPECT_TRUE(grade.id.isEmpty());
    EXPECT_TRUE(grade.code.isEmpty());
    EXPECT_DOUBLE_EQ(grade.baseSalary, 0.0);
    EXPECT_TRUE(grade.description.isEmpty());
}

TEST_F(SalaryGradeTest, ToJson) {
    QJsonObject json = testGrade.toJson();

    // Note: id is not included in toJson() as it's server-managed
    EXPECT_EQ(json["code"].toString(), "L5");
    EXPECT_DOUBLE_EQ(json["base_salary"].toDouble(), 85000.50);
    EXPECT_EQ(json["description"].toString(), "Senior Engineer Level");
}

TEST_F(SalaryGradeTest, FromJson) {
    QJsonObject json;
    json["id"] = "grade-999";
    json["code"] = "L3";
    json["base_salary"] = 65000.75;
    json["description"] = "Mid-level Engineer";
    json["created_at"] = "2022-06-15T10:00:00Z";

    SalaryGrade grade = SalaryGrade::fromJson(json);

    EXPECT_EQ(grade.id, "grade-999");
    EXPECT_EQ(grade.code, "L3");
    EXPECT_DOUBLE_EQ(grade.baseSalary, 65000.75);
    EXPECT_EQ(grade.description, "Mid-level Engineer");
    EXPECT_TRUE(grade.createdAt.isValid());
}

TEST_F(SalaryGradeTest, FromJsonWithMissingDescription) {
    QJsonObject json;
    json["id"] = "grade-888";
    json["code"] = "L1";
    json["base_salary"] = 45000.00;

    SalaryGrade grade = SalaryGrade::fromJson(json);

    EXPECT_EQ(grade.id, "grade-888");
    EXPECT_EQ(grade.code, "L1");
    EXPECT_DOUBLE_EQ(grade.baseSalary, 45000.00);
    EXPECT_TRUE(grade.description.isEmpty());
}

TEST_F(SalaryGradeTest, RoundTripJsonConversion) {
    QJsonObject json1 = testGrade.toJson();
    SalaryGrade grade2 = SalaryGrade::fromJson(json1);
    QJsonObject json2 = grade2.toJson();

    // Compare the fields that are included in toJson()
    EXPECT_EQ(json1["code"], json2["code"]);
    EXPECT_EQ(json1["base_salary"], json2["base_salary"]);
    EXPECT_EQ(json1["description"], json2["description"]);
}

TEST_F(SalaryGradeTest, HandleZeroSalary) {
    SalaryGrade grade;
    grade.id = "grade-001";
    grade.code = "L0";
    grade.baseSalary = 0.0;

    QJsonObject json = grade.toJson();
    EXPECT_DOUBLE_EQ(json["base_salary"].toDouble(), 0.0);

    SalaryGrade grade2 = SalaryGrade::fromJson(json);
    EXPECT_DOUBLE_EQ(grade2.baseSalary, 0.0);
}

TEST_F(SalaryGradeTest, HandleLargeSalary) {
    SalaryGrade grade;
    grade.id = "grade-exec";
    grade.code = "EXEC";
    grade.baseSalary = 999999.99;
    grade.description = "Executive Level";

    QJsonObject json = grade.toJson();
    EXPECT_DOUBLE_EQ(json["base_salary"].toDouble(), 999999.99);

    SalaryGrade grade2 = SalaryGrade::fromJson(json);
    EXPECT_DOUBLE_EQ(grade2.baseSalary, 999999.99);
}

// ============================================================================
// Edge Cases and Integration Tests
// ============================================================================

TEST(ModelEdgeCasesTest, EmptyJsonObject) {
    QJsonObject emptyJson;

    Employee emp = Employee::fromJson(emptyJson);
    EXPECT_TRUE(emp.id.isEmpty());

    Department dept = Department::fromJson(emptyJson);
    EXPECT_TRUE(dept.id.isEmpty());

    SalaryGrade grade = SalaryGrade::fromJson(emptyJson);
    EXPECT_TRUE(grade.id.isEmpty());
}

TEST(ModelEdgeCasesTest, InvalidJsonTypes) {
    QJsonObject json;
    json["id"] = 12345;              // Number instead of string
    json["active"] = "true";         // String instead of bool
    json["base_salary"] = "invalid"; // String instead of number

    // Should handle gracefully without crashing
    Employee emp = Employee::fromJson(json);
    SalaryGrade grade = SalaryGrade::fromJson(json);

    // Verify it doesn't crash and handles type mismatches
    EXPECT_NO_THROW({
        emp.toJson();
        grade.toJson();
    });
}

TEST(ModelEdgeCasesTest, SpecialCharactersInStrings) {
    Employee emp;
    emp.firstName = "Jean-François";
    emp.lastName = "O'Brien";
    emp.email = "test+alias@example.com";
    emp.role = "Engineer/Designer";

    QJsonObject json = emp.toJson();
    Employee emp2 = Employee::fromJson(json);

    EXPECT_EQ(emp2.firstName, "Jean-François");
    EXPECT_EQ(emp2.lastName, "O'Brien");
    EXPECT_EQ(emp2.email, "test+alias@example.com");
    EXPECT_EQ(emp2.role, "Engineer/Designer");
}

TEST(ModelEdgeCasesTest, VeryLongStrings) {
    QString longString(10000, 'a');

    Employee emp;
    emp.id = longString;
    emp.firstName = longString;
    emp.email = longString;

    QJsonObject json = emp.toJson();
    Employee emp2 = Employee::fromJson(json);

    // Note: id is not included in toJson(), so we can't test its round-trip
    // Test other fields that are included
    EXPECT_EQ(emp2.firstName.length(), 10000);
    EXPECT_EQ(emp2.email.length(), 10000);
}