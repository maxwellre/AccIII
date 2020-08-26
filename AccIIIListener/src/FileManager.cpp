/*
 * FileManager.cpp
 *
 *  Created on: Aug 26, 2020
 *      Author: Basil Duvernoy
 */

#include "AccIIIListener/FileManager.h"

FileManager::FileManager(std::string fn) {
	setFileName(fn);
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

bool FileManager::createFile(std::string fn) {

	std::ofstream outfile(fn);
	outfile << "" << std::flush;
	outfile.close();

	return false;
}

bool FileManager::deleteFile(std::string fn) {

}

bool FileManager::addToFile(std::string fn, vector3D_int data) {

}

std::string FileManager::getFileName() {
	return this->fileName;
}

void FileManager::setFileName(std::string fn) {
	this->fileName = fn;
}