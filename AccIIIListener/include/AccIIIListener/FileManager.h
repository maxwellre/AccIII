/*
 * FileManager.h
 *
 *  Created on: Aug 26, 2020
 *      Author: Basil Duvernoy
 */

#ifndef FILEMANAGER_H_
#define FILEMANAGER_H_

#include <errno.h>
#include <fstream> 
#include <iostream>
#include <stdio.h>
#include <string>
#include <time.h>

#include "AccIIIDriver_defines.h"

class FileManager {
private:

	std::string fileName;

protected:


public:
	/*
	* @param fn name of the file. If auto, create a file with the current date, hour, min and sec.
	*/
    FileManager(std::string fn="auto");
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
