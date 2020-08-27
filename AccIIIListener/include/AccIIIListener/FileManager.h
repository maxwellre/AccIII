/*
 * FileManager.h
 *
 *  Created on: Aug 26, 2020
 *      Author: Basil Duvernoy
 */

#ifndef FILEMANAGER_H_
#define FILEMANAGER_H_

#include <errno.h>
#include <iostream>
#include <fstream> 
#include <stdio.h>

#include "AccIIIDriver_defines.h"

class FileManager {
private:

	std::string fileName;

protected:


public:

    FileManager(std::string fn="");
	virtual ~FileManager();

	bool existFile(std::string fn);
	void createFile(std::string fn);
	bool deleteFile(std::string fn);
	bool addToFile(std::string fn, vector3D_int data);
	
	/**------ PUBLIC --- GETTERS -------------------------**/
	std::string getFileName();
	void setFileName(std::string fn);
};

#endif /* FILEMANAGER_H_ */
