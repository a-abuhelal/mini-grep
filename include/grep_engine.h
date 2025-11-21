#ifndef GREP_ENGINE_H
#define GREP_ENGINE_H

#include <string>
#include <vector>

using String = std::string;
using StringVec = std::vector<std::string>;
using size_t = std::size_t;

struct SearchOptions {
    bool caseInsensitive = false;
    String pattern;
    StringVec files;
    mutable int expandedFileCount = 0;  // file count after exapnading wildcards
};

struct SearchResult {
    String filename;
    int lineNumber;
    String lineContent;
};

using SearchResults = std::vector<SearchResult>;

class GrepEngine {
public:
    static SearchResults search(const SearchOptions& options);
    
    // Helper functions
    static String toLower(const String& str);
    static String wildcardToRegex(const String& wildcard);
    static StringVec expandWildcard(const String& wildcardPath);
    
private:
    static bool lineMatches(const String& line, const String& pattern, bool caseInsensitive);
};

#endif 