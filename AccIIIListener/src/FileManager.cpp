/*
 * FileManager.cpp
 *
 *  Created on: Aug 26, 2020
 *      Author: Basil Duvernoy
 */

#include "AccIIIListener/FileManager.h"

FileManager::FileManager(std::string fn) {

	if ("auto" == fn) {
		time_t timer;
		char buffer[26];
		struct tm* tm_info;

		timer = time(NULL);
		tm_info = localtime(&timer);

		strftime(buffer, 26, "%Y-%m-%d-%H-%M-%S", tm_info);

		setFileName("data_" + std::string(buffer));
	}

}

FileManager::~FileManager() {

}

/**
   ------ PRIVATE ------------------------------------
**/


/**
   ------ PROTECTED ----------------------------------
**/


/**
   ------ PUBLIC -------------------------------------
**/

bool FileManager::existFile(std::string fn) {

	std::ifstream f(fn.c_str());
	return f.good();
}

void FileManager::createFile(std::string fn) {

	std::ofstream outfile(fn);
	outfile << "" << std::flush;
	outfile.close();
}

bool FileManager::deleteFile(std::string fn) {
	if (remove(fn.c_str()) != 0) {
		perror("Error deleting file");
		return true;
	}
	else {
		puts("File successfully deleted");
		return false;
	}
}

bool FileManager::addToFile(std::string fn, vector3D_int data) {

	if (!existFile(fn)) return true;

	std::ofstream outfile(fn);

	for (int i = 0; i < data.size(); i++) {
		for (int j = 0; j < data[0].size(); j++) {
			outfile << data[i][j][0] << ";" << data[i][j][0] << ";" << data[i][j][0] << std::flush;
			if ((j + 1) == data[0].size()) {
				// if last sensor
				outfile << std::endl;
			}
			else {
				outfile << ";" << std::flush;
			}
		}
	}

	return false;
}

std::string FileManager::getFileName() {
	return this->fileName;
}

void FileManager::setFileName(std::string fn) {
	this->fileName = fn;
}