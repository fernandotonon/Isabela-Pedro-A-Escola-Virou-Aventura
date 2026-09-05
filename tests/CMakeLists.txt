# QML unit tests, run headless through Clayground's clay_add_qml_test (qmltestrunner over tst_*.qml).
include(claytest)

clay_add_qml_test(EscolaAventura
    DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)
