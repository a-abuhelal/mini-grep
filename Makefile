CXX := g++
CXXFLAGS := -std=c++17 -Wall -Wextra -Wpedantic -O2 -Iinclude

ifeq ($(OS),Windows_NT)
    TARGET := src/mgrep.exe
    RM := del /Q
else
    TARGET := src/mgrep
    RM := rm -f
endif

SRCS := src/mgrep.cpp src/cli.cpp src/grep_engine.cpp
OBJS := $(SRCS:.cpp=.o)

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CXX) $(OBJS) -o $(TARGET)

%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

test: $(TARGET)
	@bash test/mytest.sh

clean:
	@rm -f $(OBJS) $(TARGET) 2>/dev/null || true
	@rm -rf test/test_temp 2>/dev/null || true
	@rm -f nul 2>/dev/null || true

help:
	@echo "make          - build"
	@echo "make test     - build and test"
	@echo "make clean    - remove build files"
	@echo "make help     - show this"

.PHONY: all test clean help
