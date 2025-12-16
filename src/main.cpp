#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QIcon>
#include <QDir>
#include <QDebug>
#include <QFontDatabase>
#include "gui/personnelapp.h"
#include "gui/material3colors.h"

int main(int argc, char *argv[]) {
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
    QString qmlPath = QCoreApplication::applicationDirPath() + "/resources/qml";
    if (!QDir(qmlPath).exists()) {
        // Try relative path for development
        qmlPath = QDir::currentPath() + "/resources/qml";
    }
    engine.addImportPath(qmlPath);
    engine.addImportPath(qmlPath + "/components");
    engine.addImportPath(qmlPath + "/views");
    
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
    
    if (QFile::exists(mainQmlPath)) {
        qmlFile = QUrl::fromLocalFile(mainQmlPath);
    } else {
        // Fallback to qrc if files not found
        qmlFile = QUrl(QStringLiteral("qrc:/qml/main.qml"));
    }
    
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [qmlFile](QObject *obj, const QUrl &objUrl) {
        if (!obj && qmlFile == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    
    engine.load(qmlFile);
    
    if (engine.rootObjects().isEmpty()) {
        return -1;
    }
    
    return app.exec();
}
