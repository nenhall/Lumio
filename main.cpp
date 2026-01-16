#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "app/ViewModel/RawProcessor.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    RawProcessor rawProcessor;
    engine.rootContext()->setContextProperty("rawProcessor", &rawProcessor);

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("Lumio", "Main");

    return app.exec();
}
