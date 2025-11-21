#ifndef CLI_H
#define CLI_H

#include "grep_engine.h"

class CLI {
public:
    static int run(int argc, char* argv[]);
    
private:
    static void printUsage(const String& programName);
    static void printResults(const SearchResults& results, bool multipleFiles);
    static SearchOptions parseArguments(int argc, char* argv[]);
};

#endif 