CC = gcc
CXX = g++
CFLAGS = -g -Wall
CXXFLAGS = -g -Wall -std=c++11

all: main sample

main: main.cpp
	$(CXX) $(CXXFLAGS) -o main main.cpp

sample: sample.c
	$(CC) $(CFLAGS) -o sample sample.c

clean:
	rm -f main sample *.o

.PHONY: all clean
