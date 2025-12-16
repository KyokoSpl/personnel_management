#ifndef MATERIAL3COLORS_H
#define MATERIAL3COLORS_H

#include <QColor>
#include <QObject>

class Material3Colors : public QObject {
    Q_OBJECT

    // Primary colors
    Q_PROPERTY(QColor primary READ primary CONSTANT)
    Q_PROPERTY(QColor onPrimary READ onPrimary CONSTANT)
    Q_PROPERTY(QColor primaryContainer READ primaryContainer CONSTANT)
    Q_PROPERTY(QColor onPrimaryContainer READ onPrimaryContainer CONSTANT)

    // Secondary colors
    Q_PROPERTY(QColor secondary READ secondary CONSTANT)
    Q_PROPERTY(QColor onSecondary READ onSecondary CONSTANT)
    Q_PROPERTY(QColor secondaryContainer READ secondaryContainer CONSTANT)

    // Surface colors
    Q_PROPERTY(QColor surface READ surface CONSTANT)
    Q_PROPERTY(QColor surfaceDim READ surfaceDim CONSTANT)
    Q_PROPERTY(QColor surfaceBright READ surfaceBright CONSTANT)
    Q_PROPERTY(QColor onSurface READ onSurface CONSTANT)
    Q_PROPERTY(QColor surfaceVariant READ surfaceVariant CONSTANT)
    Q_PROPERTY(QColor onSurfaceVariant READ onSurfaceVariant CONSTANT)

    // Outline colors
    Q_PROPERTY(QColor outline READ outline CONSTANT)
    Q_PROPERTY(QColor outlineVariant READ outlineVariant CONSTANT)

    // Semantic colors
    Q_PROPERTY(QColor error READ error CONSTANT)
    Q_PROPERTY(QColor onError READ onError CONSTANT)
    Q_PROPERTY(QColor success READ success CONSTANT)

public:
    explicit Material3Colors(bool darkMode = true, QObject* parent = nullptr);

    QColor primary() const { return m_primary; }
    QColor onPrimary() const { return m_onPrimary; }
    QColor primaryContainer() const { return m_primaryContainer; }
    QColor onPrimaryContainer() const { return m_onPrimaryContainer; }
    QColor secondary() const { return m_secondary; }
    QColor onSecondary() const { return m_onSecondary; }
    QColor secondaryContainer() const { return m_secondaryContainer; }
    QColor surface() const { return m_surface; }
    QColor surfaceDim() const { return m_surfaceDim; }
    QColor surfaceBright() const { return m_surfaceBright; }
    QColor onSurface() const { return m_onSurface; }
    QColor surfaceVariant() const { return m_surfaceVariant; }
    QColor onSurfaceVariant() const { return m_onSurfaceVariant; }
    QColor outline() const { return m_outline; }
    QColor outlineVariant() const { return m_outlineVariant; }
    QColor error() const { return m_error; }
    QColor onError() const { return m_onError; }
    QColor success() const { return m_success; }

private:
    void initDarkTheme();
    void initLightTheme();

    QColor m_primary, m_onPrimary, m_primaryContainer, m_onPrimaryContainer;
    QColor m_secondary, m_onSecondary, m_secondaryContainer;
    QColor m_surface, m_surfaceDim, m_surfaceBright, m_onSurface;
    QColor m_surfaceVariant, m_onSurfaceVariant;
    QColor m_outline, m_outlineVariant;
    QColor m_error, m_onError, m_success;
};

#endif // MATERIAL3COLORS_H
