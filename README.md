# mgrep

A simplified grep command built with C++. I wrote this to showcase my knowledge in C++ and systems programming.

## What it does

Searches text files for patterns. Shows you line numbers and can handle wildcards for searching multiple files at once.

## Features

- Basic substring search
- Case-insensitive option (`-i`)
- Wildcard file matching (`*.txt`, `*.cpp`, etc)
- Shows line numbers
- Handles multiple files
- Test suite and make file included

## Building

```bash
make
```

Or manually:
```bash
g++ -o mgrep src/mgrep.cpp src/cli.cpp src/grep_engine.cpp -std=c++17 -Wall -Wextra -O2 -Iinclude
```

Requires g++ 8.0+ for C++17.

## Usage

```bash
mgrep [-i] <pattern> <file...>
```

Examples:
```bash
mgrep "error" log.txt
mgrep -i "TODO" *.cpp
mgrep "bug" ../src/*
```

## Project structure

```
mini-grep/
├── include/
│   ├── cli.h              # command line interface
│   └── grep_engine.h      # search logic
├── src/
│   ├── mgrep.cpp          # main entry point
│   ├── cli.cpp            # CLI implementation
│   └── grep_engine.cpp    # search engine
├── test/
│   ├── mytest.sh          # test runner
│   ├── testfile.txt
│   └── output.txt
├── Makefile
└── README.md
```

## Testing

```bash
make test
```

or

```bash
bash test/mytest.sh
```

11 tests covering basic search, case-insensitive, wildcards, and error cases.

## How it works

Pretty straightforward:
- Parse command line args
- If there's a wildcard (`*.cpp`), expand it using filesystem iteration and regex matching
- For each file, read line by line and check if the pattern matches
- Print matches with line numbers

For case-insensitive search, converts both the pattern and each line to lowercase before comparing.

Type aliases (`using String = std::string`) are used for cleaner code.

## Compatibility

Works on Linux, macOS, and Windows (with MinGW). Test script needs bash.

---

Abdullah Helal
