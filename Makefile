SHELL=/bin/bash
G++VER := $(shell command -v g++-4.9)

# Eigen is not currently compatible with optimization in gcc 5
ifndef G++VER
CPP:=g++
else
CPP:=g++-4.9
endif

CFLAGS = -O2 -Wall -std=c++11 --pedantic -Wno-deprecated-declarations
MKFILE_PATH := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
ABCDIR = $(MKFILE_PATH)
SQLDIR  = $(ABCDIR)/sqdb

# adapted from http://stackoverflow.com/questions/714100/os-detecting-makefile
ifeq ($(OS),Windows_NT)
    CFLAGS += -D WIN32
    ifeq ($(PROCESSOR_ARCHITECTURE),AMD64)
        CFLAGS += -D AMD64
    endif
    ifeq ($(PROCESSOR_ARCHITECTURE),x86)
        CFLAGS += -D IA32
    endif
else
    UNAME_S := $(shell uname -s)
    ifeq ($(UNAME_S),Linux)
        CFLAGS += -D LINUX
    endif
    ifeq ($(UNAME_S),Darwin)
        CFLAGS += -D OSX -arch x86_64
				AR := libtool -static -a
    endif
    # UNAME_P := $(shell uname -p)
    # ifeq ($(UNAME_P),x86_64)
    #     CFLAGS += -D AMD64
    # endif
    # ifneq ($(filter %86,$(UNAME_P)),)
    #     CFLAGS += -D IA32
    # endif
    # ifneq ($(filter arm%,$(UNAME_P)),)
    #     CFLAGS += -D ARM
    # endif
endif

INCLUDE = -I. -I$(ABCDIR) -I$(ABCDIR)/jsoncpp/include -I$(SQLDIR)

red:=$(shell tput setaf 1)
reset:=$(shell tput sgr0)

ifndef TACC_GSL_INC
ifndef HPC_GSL_INC
$(info $(red)Neither TACC_GSL_INC nor HPC_GSL_INC are defined. Do you need to run 'module load gsl'?$(reset))
endif
endif

ifdef TACC_GSL_INC
INCLUDE += -I$(TACC_GSL_INC)
endif
ifdef HPC_GSL_INC
INCLUDE += -I$(HPC_GSL_INC)
endif

# LIBS = -lm -lgsl -lgslcblas
# ifdef TACC_GSL_LIB
# LIBS += -L$(TACC_GSL_INC)/
# endif
# ifdef HPC_GSL_LIB
# LIBS += -L$(HPC_GSL_INC)/
# endif

SOURCES =  AbcSmc.cpp AbcUtil.cpp CCRC32.cpp
JSONDIR = $(ABCDIR)/jsoncpp/src
JSONSOURCES = $(JSONDIR)/json_reader.cpp $(JSONDIR)/json_value.cpp $(JSONDIR)/json_writer.cpp
SQLSOURCES  = $(SQLDIR)/sqdb.cpp

LIBABC  = libabc.a
LIBJSON = libjsoncpp.a
LIBSQL  = libsqdb.a

OBJECTS     = $(SOURCES:.cpp=.o)
JSONOBJECTS = $(JSONSOURCES:.cpp=.o)
SQLOBJECTS  = $(SQLSOURCES:.cpp=.o)
ABC_HEADER = ./pls.h ./AbcUtil.h ./AbcSmc.h

default: .all
.all:  $(LIBJSON) sqlite3.o $(LIBSQL) $(SOURCES) $(LIBABC)

sqlite3.o: $(SQLDIR)/sqlite3.c $(SQLDIR)/sqlite3.h
	$(CPP) -g -c $< -I$(SQLDIR)

$(LIBABC): $(ABC_HEADER) $(OBJECTS) $(LIBSQL)
	$(AR) -o $@ $(OBJECTS) $(LIBSQL)

$(LIBJSON): $(JSONOBJECTS)
	$(AR) -o $@ $^

$(LIBSQL): $(SQLOBJECTS)
	$(AR) -o $@ $^

%.o: %.cpp $(ABC_HEADER)
	$(CPP) $(CFLAGS) -c $(INCLUDE) $< -o $@

clean:
	rm -f $(OBJECTS) $(JSONOBJECTS) $(SQLOBJECTS) $(LIBABC) $(LIBJSON) $(LIBSQL)
