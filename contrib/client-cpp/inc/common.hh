#ifndef common_hh
#define common_hh common.hh

#include <iostream>
#include <fcntl.h>
#include <unistd.h>
#include <string>
#include <vector>
#include <sstream>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <boost/core/demangle.hpp>
#include <boost/lexical_cast.hpp>
#include <iomanip>
#include <typeinfo>
#include <list>
#include <json.hh>

using std::setw;
using std::left;
using std::right;
using std::stringstream;
using boost::core::demangle;
using std::ostringstream;
using std::ios;
using std::exception;
using std::cerr;
using std::cout;
using std::endl;
using std::exception;
using std::ifstream;
using std::list;
using std::ofstream;
using std::runtime_error;
using std::string;
using std::vector;

#include <dbg.hh>
#include <util.hh>

#endif
