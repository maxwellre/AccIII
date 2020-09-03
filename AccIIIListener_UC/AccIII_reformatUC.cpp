/*
 * AccIIIListener.cpp
 *
 *  Created on: Aug 16, 2020
 *      Author: Basil Duvernoy
 */


#include <iostream>
#include <iomanip>

#include "acciii.h"

using namespace std;

int main(int argc, char **argv) {


	Acciii* acciii = new Acciii();

	std::vector<std::vector<double>> data_buffer;
	int dataSetNum;
	float fs;
	bool print_header, print_data;
	int headerSize;

	headerSize = 47+2;// +10;

	print_header = 1;
	print_data = 1; 

	float sampleTime = 3;

	acciii->setSampleTime(sampleTime);
	acciii->sampleData();

	dataSetNum = acciii->returnDataSetNum();
	fs = acciii->returnIdDataRate();

	if (print_header) {

		std::cout << std::endl << "HEADER : " << std::endl;
		acciii->decodeHeader(headerSize);
	}

	if (print_data) {

		std::cout << std::endl << "DATA : " << std::endl;
		data_buffer = acciii->decodeData();

		std::cout << "[" << data_buffer.size() << "," << data_buffer[0].size() << "]" << std::endl;
		for (int i = 0; i < data_buffer.size(); i++) {

			std::cout << setw(8) << data_buffer[i][0] << std::flush;
			std::cout << setw(8) << data_buffer[i][1] << std::flush;
			std::cout << setw(8) << data_buffer[i][2] << std::flush;

			std::cout << setw(16) << data_buffer[i][3] << std::flush;
			std::cout << setw(8)  << data_buffer[i][4] << std::flush;
			std::cout << setw(8)  << data_buffer[i][5] << std::flush;

			std::cout << setw(16) << data_buffer[i][6] << std::flush;
			std::cout << setw(8)  << data_buffer[i][7] << std::flush;
			std::cout << setw(8)  << data_buffer[i][8] << std::endl;
		}
	}

	return 0;
}


