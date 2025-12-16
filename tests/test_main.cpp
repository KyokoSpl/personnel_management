#include <QCoreApplication>

#include <gtest/gtest.h>

int main(int argc, char** argv) {
    // Initialize Qt application for tests that need Qt event loop
    QCoreApplication app(argc, argv);

    // Initialize Google Test
    ::testing::InitGoogleTest(&argc, argv);

    // Run all tests
    return RUN_ALL_TESTS();
}