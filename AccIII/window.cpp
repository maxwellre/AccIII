#include "stdafx.h"

#include "window.h"
#include "ui_window.h"
#include "iostream"

Window::Window(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::Window)
{
    //ui->setupUi(this);
    //setGeometry(400, 250, 542, 390);

    //setupPlot(ui->customPlot);
    //ui->customPlot->replot();

}

Window::~Window()
{
    delete ui;
}

/*
void Window::setupPlot(QCustomPlot *customPlot)
{
  // generate some data:
  QVector<double> x(101), y(101); // initialize with entries 0..100
  for (int i=0; i<101; ++i)
  {
    x[i] = i/50.0 - 1; // x goes from -1 to 1
    y[i] = x[i]*x[i];  // let's plot a quadratic function
  }
  // create graph and assign data to it:
  customPlot->addGraph();
  customPlot->graph(0)->setData(x, y);
  // give the axes some labels:
  customPlot->xAxis->setLabel("x");
  customPlot->yAxis->setLabel("y");
  // set axes ranges, so we see all data:
  customPlot->xAxis->setRange(-1, 1);
  customPlot->yAxis->setRange(0, 1);
}
*/

void Window::setupPlot(QCustomPlot *customPlot){

    QTimer *dataTimer = new QTimer(this);
    //std::cout << "setup" << std::endl;

    // ploting 2 graphs
    customPlot->addGraph(); // blue line
    customPlot->graph(0)->setPen(QPen(QColor(40, 110, 255)));
    //customPlot->addGraph(); // red line
    //customPlot->graph(1)->setPen(QPen(QColor(255, 110, 40)));

    QSharedPointer<QCPAxisTickerTime> timeTicker(new QCPAxisTickerTime);
    timeTicker->setTimeFormat("%h:%m:%s");
    customPlot->xAxis->setTicker(timeTicker);
    customPlot->axisRect()->setupFullAxesBox();
    customPlot->yAxis->setRange(-1.2, 1.2);

    // make left and bottom axes transfer their ranges to right and top axes:
    connect(customPlot->xAxis, SIGNAL(rangeChanged(QCPRange)), customPlot->xAxis2, SLOT(setRange(QCPRange)));
    connect(customPlot->yAxis, SIGNAL(rangeChanged(QCPRange)), customPlot->yAxis2, SLOT(setRange(QCPRange)));

    // setup a timer that repeatedly calls MainWindow::realtimeDataSlot:
    //connect(dataTimer, SIGNAL(timeout()), this, SLOT(realtimeDataSlot()));
	connect(dataTimer, SIGNAL(timeout()), this, SLOT(testPlot()));

    dataTimer->start(0); // Interval 0 means to refresh as fast as possible

}



// Test plotting data buffer 
void Window::testPlot()
{
	static QTime time(QTime::currentTime());
	// calculate two new data points:
	double key = time.elapsed() / 1000.0; // Unit: us
	static double lastPointKey = 0;

	if (key - lastPointKey > 0.002) // at most add point every 2 ms
	{
		// add data to lines:
		ui->customPlot->graph(0)->addData(key, plotBuffer_);


		// rescale value (vertical) axis to fit the current data:
		ui->customPlot->graph(0)->rescaleValueAxis();
		lastPointKey = key;
	}

	// make key axis range scroll with the data (at a constant range size of 8):
	ui->customPlot->xAxis->setRange(key, 8, Qt::AlignRight);
	ui->customPlot->replot();

	// calculate frames per second:
	static double lastFpsKey;
	static int frameCount;
	++frameCount;
	if (key - lastFpsKey > 2) // average fps over 2 seconds
	{
		ui->statusBar->showMessage(
			QString("%1 FPS, Total Data points: %2")
			.arg(frameCount / (key - lastFpsKey), 0, 'f', 0)
			.arg(ui->customPlot->graph(0)->data()->size())
			, 0);
		lastFpsKey = key;
		frameCount = 0;
	}
}

void Window::dataUpdate(int plotBuffer) 
{
	plotBuffer_ = plotBuffer;
}