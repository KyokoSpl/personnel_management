#include "gui/material3colors.h"

Material3Colors::Material3Colors(bool darkMode, QObject* parent)
    : QObject(parent) {
    if (darkMode) {
        initDarkTheme();
    } else {
        initLightTheme();
    }
}

void Material3Colors::initDarkTheme() {
    // Primary - Light purple tones
    m_primary = QColor(208, 188, 255);
    m_onPrimary = QColor(56, 30, 114);
    m_primaryContainer = QColor(79, 55, 139);
    m_onPrimaryContainer = QColor(234, 221, 255);
    
    // Secondary - Gray purple tones
    m_secondary = QColor(204, 194, 220);
    m_onSecondary = QColor(51, 45, 65);
    m_secondaryContainer = QColor(74, 68, 88);
    
    // Surface - Dark background
    m_surface = QColor(20, 18, 24);
    m_surfaceDim = QColor(20, 18, 24);
    m_surfaceBright = QColor(59, 56, 62);
    m_onSurface = QColor(230, 225, 230);
    m_surfaceVariant = QColor(44, 40, 49);
    m_onSurfaceVariant = QColor(202, 196, 208);
    
    // Outline
    m_outline = QColor(147, 143, 153);
    m_outlineVariant = QColor(68, 64, 75);
    
    // Semantic
    m_error = QColor(242, 184, 181);
    m_onError = QColor(96, 20, 16);
    m_success = QColor(129, 199, 132);
}

void Material3Colors::initLightTheme() {
    // Primary - Deep purple tones
    m_primary = QColor(103, 80, 164);
    m_onPrimary = QColor(255, 255, 255);
    m_primaryContainer = QColor(234, 221, 255);
    m_onPrimaryContainer = QColor(33, 0, 93);
    
    // Secondary - Gray purple tones
    m_secondary = QColor(98, 91, 113);
    m_onSecondary = QColor(255, 255, 255);
    m_secondaryContainer = QColor(232, 222, 248);
    
    // Surface - Light background
    m_surface = QColor(254, 247, 255);
    m_surfaceDim = QColor(222, 216, 225);
    m_surfaceBright = QColor(254, 247, 255);
    m_onSurface = QColor(28, 27, 31);
    m_surfaceVariant = QColor(231, 224, 236);
    m_onSurfaceVariant = QColor(73, 69, 79);
    
    // Outline
    m_outline = QColor(121, 116, 126);
    m_outlineVariant = QColor(202, 196, 208);
    
    // Semantic
    m_error = QColor(179, 38, 30);
    m_onError = QColor(255, 255, 255);
    m_success = QColor(56, 142, 60);
}
