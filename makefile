CC = gcc
CFLAGS = -Wall -g # -g for debugging symbols

# Or use g++ if you prefer C++ for the .y actions
# CXX = g++
# CXXFLAGS = -Wall -g

TARGET = interpreter

# Bison generates .tab.c and .tab.h
# Flex generates .lex.c

all: $(TARGET)

$(TARGET): lang.tab.c lex.yy.c
	$(CC) $(CFLAGS) -o $(TARGET) lang.tab.c lex.yy.c -lfl # Link with flex library if needed (usually for yywrap)

lang.tab.c lang.tab.h: lang.y
	bison -d -v lang.y  # -d generates .tab.h, -v generates .output for grammar debugging

lex.yy.c: lang.l lang.tab.h
	flex -o lex.yy.c lang.l

clean:
	rm -f $(TARGET) lex.yy.c lang.tab.c lang.tab.h lang.output y.output core *~