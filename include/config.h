#ifndef CONFIG_H
#define CONFIG_H

#include <QString>
#include <QSettings>
#include <QFile>
#include <QTextStream>
#include <QDir>
#include <QDebug>
#include <QCoreApplication>

class Config {
public:
    static Config& instance() {
        static Config config;
        return config;
    }

    QString apiBaseUrl() const { return m_apiBaseUrl; }
    QString apiPrefix() const { return m_apiPrefix; }
    QString routeDepartments() const { return m_routeDepartments; }
    QString routeEmployees() const { return m_routeEmployees; }
    QString routeSalaryGrades() const { return m_routeSalaryGrades; }

    QString apiUrl() const { return m_apiBaseUrl + m_apiPrefix; }

private:
    Config() {
        // Load .env file first
        loadEnvFile();
        
        // Load from environment or use defaults
        m_apiBaseUrl = qEnvironmentVariable("API_BASE_URL", "http://212.132.110.72:8082");
        m_apiPrefix = qEnvironmentVariable("API_PREFIX", "/api");
        m_routeDepartments = qEnvironmentVariable("ROUTE_DEPARTMENTS", "/departments");
        m_routeEmployees = qEnvironmentVariable("ROUTE_EMPLOYEES", "/employees");
        m_routeSalaryGrades = qEnvironmentVariable("ROUTE_SALARY_GRADES", "/salary-grades");
        
#ifdef DEBUG_CONFIG
        qDebug() << "API Base URL:" << m_apiBaseUrl;
        qDebug() << "Full API URL:" << apiUrl();
#endif
    }
    
    void loadEnvFile() {
        // Try to find .env file in current directory or parent directories
        QStringList searchPaths = {
            QDir::currentPath() + "/.env",
            QCoreApplication::applicationDirPath() + "/.env",
            QDir::currentPath() + "/../.env"
        };
        
        for (const QString& envPath : searchPaths) {
            QFile envFile(envPath);
            if (envFile.exists() && envFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
#ifdef DEBUG_CONFIG
                qDebug() << "Loading .env from:" << envPath;
#endif
                QTextStream in(&envFile);
                while (!in.atEnd()) {
                    QString line = in.readLine().trimmed();
                    
                    // Skip empty lines and comments
                    if (line.isEmpty() || line.startsWith('#')) {
                        continue;
                    }
                    
                    // Parse KEY=VALUE format
                    int separatorIndex = line.indexOf('=');
                    if (separatorIndex > 0) {
                        QString key = line.left(separatorIndex).trimmed();
                        QString value = line.mid(separatorIndex + 1).trimmed();
                        
                        // Remove quotes if present
                        if ((value.startsWith('"') && value.endsWith('"')) ||
                            (value.startsWith('\'') && value.endsWith('\''))) {
                            value = value.mid(1, value.length() - 2);
                        }
                        
                        qputenv(key.toUtf8(), value.toUtf8());
#ifdef DEBUG_CONFIG
                        qDebug() << "Set env:" << key << "=" << value;
#endif
                    }
                }
                envFile.close();
                return;
            }
        }
        
#ifdef DEBUG_CONFIG
        qDebug() << "No .env file found, using defaults";
#endif
    }

    QString m_apiBaseUrl;
    QString m_apiPrefix;
    QString m_routeDepartments;
    QString m_routeEmployees;
    QString m_routeSalaryGrades;
};

#endif // CONFIG_H
