#include "../include/grep_engine.h"
#include <algorithm>
#include <cctype>
#include <fstream>
#include <filesystem>
#include <regex>
#include <iostream>


namespace fs = std::filesystem;

String GrepEngine::toLower(const String& str) {
    String result = str;
    std::transform(result.begin(), result.end(), result.begin(),
                   [](unsigned char c) { return std::tolower(c); });
    return result;
}

String GrepEngine::wildcardToRegex(const String& wildcard) {
    String regex;
    for (char c : wildcard) {
        if (c == '*') {
            regex += ".*";
        } else if (c == '?') {
            regex += ".";
        } else if (c == '.' || c == '^' || c == '$' || c == '\\' || 
                   c == '+' || c == '(' || c == ')' || c == '[' || 
                   c == ']' || c == '{' || c == '}' || c == '|') {
            regex += '\\';
            regex += c;
        } else {
            regex += c;
        }
    }
    return regex;
}

StringVec GrepEngine::expandWildcard(const String& wildcardPath) {
    StringVec files;
    
    fs::path pathObj(wildcardPath);
    fs::path dirPath = pathObj.parent_path();
    String filenamePattern = pathObj.filename().string();
    
    if (dirPath.empty()) {
        dirPath = ".";
    }
    
    String regexPattern = wildcardToRegex(filenamePattern);
    std::regex pattern(regexPattern);
    
    try {
        for (const auto& entry : fs::directory_iterator(dirPath)) {
            if (entry.is_regular_file()) {
                String filename = entry.path().filename().string();
                if (std::regex_match(filename, pattern)) {
                    files.push_back(entry.path().string());
                }
            }
        }
    } catch (const fs::filesystem_error& e) {
        std::cerr << "Error reading directory: " << e.what() << '\n';
    }
    
    return files;
}

bool GrepEngine::lineMatches(const String& line, const String& pattern, bool caseInsensitive) {
    if (caseInsensitive) {
        String lineLower = toLower(line);
        String patternLower = toLower(pattern);
        return lineLower.find(patternLower) != String::npos;
    }
    return line.find(pattern) != String::npos;
}

SearchResults GrepEngine::search(const SearchOptions& options) {
    SearchResults results;
    StringVec files = options.files;
    
    // Handle wildcard expansion
    if (files.size() == 1 && files[0].find_first_of("*?") != String::npos) {
        files = expandWildcard(files[0]);
        if (files.empty()) {
            std::cerr << "No files matching pattern '" << options.files[0] << "'\n";
            return results;
        }
    }
    
    // Store expanded file count
    options.expandedFileCount = files.size();
    
    // Search each file
    for (const auto& filename : files) {
        std::ifstream file(filename);
        if (!file.is_open()) {
            std::cerr << "Error: Could not open file '" << filename << "'\n";
            continue;
        }
        
        String line;
        int lineNumber = 1;
        
        while (std::getline(file, line)) {
            if (lineMatches(line, options.pattern, options.caseInsensitive)) {
                SearchResult result;
                result.filename = filename;
                result.lineNumber = lineNumber;
                result.lineContent = line;
                results.push_back(result);
            }
            lineNumber++;
        }
    }
    
    return results;
}