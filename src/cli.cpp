#include "../include/cli.h"
#include <iostream>

void CLI::printUsage(const String& programName) {
    std::cerr << "Usage: " << programName << " [-i] <pattern> <file...>\n";
    std::cerr << "\nOptions:\n";
    std::cerr << "  -i    Case-insensitive search\n";
    std::cerr << "\nExamples:\n";
    std::cerr << "  " << programName << " \"error\" log.txt\n";
    std::cerr << "  " << programName << " -i \"TODO\" *.cpp\n";
}

SearchOptions CLI::parseArguments(int argc, char* argv[]) {
    SearchOptions options;
    int argIndex = 1;
    
    if (argc < 3) {
        printUsage(argv[0]);
        throw std::runtime_error("Insufficient arguments");
    }
    
    // Check for -i flag
    if (String(argv[argIndex]) == "-i") {
        options.caseInsensitive = true;
        argIndex++;
    }
    
    // Get pattern
    if (argIndex >= argc) {
        std::cerr << "Error: Pattern is required\n";
        throw std::runtime_error("Pattern missing");
    }
    options.pattern = argv[argIndex++];
    
    // Get filenames
    if (argIndex >= argc) {
        std::cerr << "Error: At least one filename is required\n";
        throw std::runtime_error("No files specified");
    }
    
    for (; argIndex < argc; ++argIndex) {
        options.files.push_back(argv[argIndex]);
    }
    
    return options;
}

void CLI::printResults(const SearchResults& results, bool multipleFiles) {
    for (const auto& result : results) {
        if (multipleFiles) {
            std::cout << result.filename << ":";
        }
        std::cout << result.lineNumber << ": " << result.lineContent << '\n';
    }
}

int CLI::run(int argc, char* argv[]) {
    try {
        SearchOptions options = parseArguments(argc, argv);
        SearchResults results = GrepEngine::search(options);
        
        // Show filename when multiple files were searched
        bool multipleFiles = options.expandedFileCount > 1;
        
        printResults(results, multipleFiles);
        return 0;
        
    } catch (const std::exception& e) {
        return 1;
    }
}