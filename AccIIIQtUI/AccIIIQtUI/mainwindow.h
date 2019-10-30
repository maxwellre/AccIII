#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QTimer>
#include "qcustomplot.h"

namespace Ui {
class MainWindow;
}

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    explicit MainWindow(QWidget *parent = nullptr);
    ~MainWindow();

    void setupPlot(QCustomPlot *customPlot);
    double arbitaryFunc(double x);

public slots:
    void realtimeDataSlot();


private:
    Ui::MainWindow *ui;
};

#endif // MAINWINDOW_H
