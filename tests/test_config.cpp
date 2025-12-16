#include "config.h"

#include <QCoreApplication>
#include <QDir>
#include <QFile>
#include <QTextStream>

#include <gtest/gtest.h>

class ConfigTest : public ::testing::Test {
protected:
    void SetUp() override {
        // Create a temporary .env file for testing
        createTestEnvFile();
    }

    void TearDown() override {
        // Clean up test env file
        QFile::remove(".env");
    }

    void createTestEnvFile() {
        QFile file(".env");
        if (file.open(QIODevice::WriteOnly | QIODevice::Text)) {
            QTextStream out(&file);
            out << "API_BASE_URL=http://testapi.example.com\n";
            out << "API_PREFIX=/api/v1\n";
            out << "ROUTE_EMPLOYEES=/employees\n";
            out << "ROUTE_DEPARTMENTS=/departments\n";
            out << "ROUTE_SALARY_GRADES=/salary-grades\n";
            file.close();
        }
    }
};

TEST_F(ConfigTest, SingletonInstance) {
    Config& instance1 = Config::instance();
    Config& instance2 = Config::instance();

    // Should be the same instance
    EXPECT_EQ(&instance1, &instance2);
}

TEST_F(ConfigTest, DefaultValues) {
    Config& config = Config::instance();

    // Check that default values are not empty
    EXPECT_FALSE(config.apiBaseUrl().isEmpty());
    EXPECT_FALSE(config.apiPrefix().isEmpty());
    EXPECT_FALSE(config.routeEmployees().isEmpty());
    EXPECT_FALSE(config.routeDepartments().isEmpty());
    EXPECT_FALSE(config.routeSalaryGrades().isEmpty());
}

TEST_F(ConfigTest, RouteValuesFormat) {
    Config& config = Config::instance();

    // Routes should start with /
    EXPECT_TRUE(config.routeEmployees().startsWith("/"));
    EXPECT_TRUE(config.routeDepartments().startsWith("/"));
    EXPECT_TRUE(config.routeSalaryGrades().startsWith("/"));
}

TEST_F(ConfigTest, BaseUrlFormat) {
    Config& config = Config::instance();
    QString baseUrl = config.apiBaseUrl();

    // Base URL should start with http:// or https://
    EXPECT_TRUE(baseUrl.startsWith("http://") || baseUrl.startsWith("https://"));
}

TEST_F(ConfigTest, ApiUrlCombination) {
    Config& config = Config::instance();
    QString apiUrl = config.apiUrl();

    // Should combine base URL and prefix
    EXPECT_TRUE(apiUrl.contains(config.apiPrefix()));
    EXPECT_TRUE(apiUrl.startsWith(config.apiBaseUrl()));
}

TEST_F(ConfigTest, ConfigNotEmpty) {
    Config& config = Config::instance();

    // All config values should have content
    EXPECT_GT(config.apiBaseUrl().length(), 0);
    EXPECT_GT(config.apiPrefix().length(), 0);
    EXPECT_GT(config.routeEmployees().length(), 0);
    EXPECT_GT(config.routeDepartments().length(), 0);
    EXPECT_GT(config.routeSalaryGrades().length(), 0);
}

// Test that routes are properly formatted for API calls
TEST(ConfigIntegrationTest, FullApiUrl) {
    Config& config = Config::instance();

    QString fullUrl = config.apiUrl() + config.routeEmployees();

    // Should be a valid URL format
    EXPECT_TRUE(fullUrl.contains("://"));
    EXPECT_TRUE(fullUrl.contains("/"));
}

TEST(ConfigIntegrationTest, AllRoutesUnique) {
    Config& config = Config::instance();

    QString employeesRoute = config.routeEmployees();
    QString departmentsRoute = config.routeDepartments();
    QString salaryGradesRoute = config.routeSalaryGrades();

    // All routes should be different
    EXPECT_NE(employeesRoute, departmentsRoute);
    EXPECT_NE(employeesRoute, salaryGradesRoute);
    EXPECT_NE(departmentsRoute, salaryGradesRoute);
}

TEST(ConfigIntegrationTest, ApiPrefixFormat) {
    Config& config = Config::instance();
    QString prefix = config.apiPrefix();

    // API prefix should start with / and not end with /
    EXPECT_TRUE(prefix.startsWith("/"));
    EXPECT_FALSE(prefix.endsWith("/"));
}

TEST(ConfigIntegrationTest, CompleteEndpointUrl) {
    Config& config = Config::instance();

    // Test building complete endpoint URLs
    QString employeesUrl = config.apiUrl() + config.routeEmployees();
    QString departmentsUrl = config.apiUrl() + config.routeDepartments();
    QString salaryGradesUrl = config.apiUrl() + config.routeSalaryGrades();

    // All URLs should be well-formed
    EXPECT_TRUE(employeesUrl.contains("http"));
    EXPECT_TRUE(departmentsUrl.contains("http"));
    EXPECT_TRUE(salaryGradesUrl.contains("http"));

    // Should not have double slashes in path (except after protocol)
    QString employeesPath = employeesUrl.mid(employeesUrl.indexOf("://") + 3);
    EXPECT_FALSE(employeesPath.contains("//"));
}