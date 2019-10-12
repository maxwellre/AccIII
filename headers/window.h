#ifndef WINDOW_H
#define WINDOW_H

#include <QMainWindow>
#include <QTimer>
#include "qcustomplot.h"

namespace Ui {
class Window;
}

class Window : public QMainWindow
{
    Q_OBJECT

public:
    explicit Window(QWidget *parent = nullptr);
    ~Window();

    void setupPlot(QCustomPlot *customPlot);
	void dataUpdate(int plotBuffer);

	int plotBuffer_;

public slots:
    //void realtimeDataSlot();
	void testPlot();

private:
    Ui::Window *ui;
};

#endif // WINDOW_H
