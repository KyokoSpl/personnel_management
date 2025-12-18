#include "gui/material3colors.h"
#include "gui/personnelapp.h"

#include <QDebug>
#include <QDir>
#include <QFontDatabase>
#include <QGuiApplication>
#include <QIcon>
#include <QQmlApplicationEngine>
#include <QQmlContext>

int main(int argc, char* argv[]) {
    QGuiApplication app(argc, argv);

    // Set application metadata
    app.setApplicationName("Personnel Management System");
    app.setOrganizationName("LF11A Project");
    app.setApplicationVersion("0.2.0");

    // Load Material Icons font from resources
    int fontId = QFontDatabase::addApplicationFont(":/fonts/fonts/MaterialIcons-Regular.ttf");
    if (fontId != -1) {
        QStringList fontFamilies = QFontDatabase::applicationFontFamilies(fontId);
        if (!fontFamilies.isEmpty()) {
            qDebug() << "Material Icons font loaded successfully:" << fontFamilies.first();
        }
    } else {
        qWarning() << "Failed to load Material Icons font from resources";
    }

    // Create QML engine
    QQmlApplicationEngine engine;

    // Add import paths for QML files (from file system, not resources)
    QString qmlPath;

    // Try multiple paths in order of preference
    QStringList possiblePaths = {
        "/usr/share/personnel_management/qml", // Installed location (Linux)
        QCoreApplication::applicationDirPath() +
            "/../share/personnel_management/qml",                  // Relative to bin
        QCoreApplication::applicationDirPath() + "/resources/qml", // Build directory
        QDir::currentPath() + "/resources/qml"                     // Development
    };

    for (const QString& path : possiblePaths) {
        if (QDir(path).exists()) {
            qmlPath = path;
            break;
        }
    }

    if (!qmlPath.isEmpty()) {
        engine.addImportPath(qmlPath);
        engine.addImportPath(qmlPath + "/components");
        engine.addImportPath(qmlPath + "/views");
    }

    // Register custom types
    qmlRegisterUncreatableType<Material3Colors>("PersonnelManagement", 1, 0, "Material3Colors",
                                                "Material3Colors cannot be created from QML");

    // Create app instance
    PersonnelApp personnelApp;

    // Expose to QML BEFORE loading
    engine.rootContext()->setContextProperty("personnelApp", &personnelApp);
    engine.rootContext()->setContextProperty("colors", personnelApp.property("colors"));

    // Load main QML file from file system
    QUrl qmlFile;
    QString mainQmlPath = qmlPath + "/main.qml";

    if (!qmlPath.isEmpty() && QFile::exists(mainQmlPath)) {
        qmlFile = QUrl::fromLocalFile(mainQmlPath);
        qDebug() << "Loading QML from:" << mainQmlPath;
    } else {
        // Fallback to qrc if files not found
        qmlFile = QUrl(QStringLiteral("qrc:/qml/main.qml"));
        qDebug() << "Loading QML from resources";
    }

    QObject::connect(
        &engine, &QQmlApplicationEngine::objectCreated, &app,
        [qmlFile](QObject* obj, const QUrl& objUrl) {
            if (!obj && qmlFile == objUrl)
                QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection);

    engine.load(qmlFile);

    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    return app.exec();
}
