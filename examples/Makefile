SHELL := /bin/bash
G++VER := $(shell command -v g++-4.9)

# Eigen is not currently compatible with optimization in gcc 5
ifndef G++VER
CPP:=g++
else
CPP:=g++-4.9
endif

CFLAGS = -O2 -Wall -std=c++11 --pedantic -Wno-deprecated-declarations

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

MKFILE_PATH := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
ABCDIR = $(MKFILE_PATH)/..
ABC_INC = -I$(ABCDIR) -I$(ABCDIR)/sqdb

ABC_LIB = -L$(ABCDIR) -labc -ljsoncpp -lsqdb ../sqlite3.o
GSL_LIB = -lm -lgsl -lgslcblas -lpthread -ldl

ifdef TACC_GSL_INC
GSL_INC = $(TACC_GSL_INC)
endif
ifdef HPC_GSL_INC
GSL_INC = $(HPC_GSL_INC)
endif

ifdef TACC_GSL_LIB
GSL_LIB += -L$(TACC_GSL_LIB)/
endif
ifdef HPC_GSL_LIB
GSL_LIB += -L$(HPC_GSL_LIB)/
endif

default: demo

$(ABCDIR)/libabc.a:
	$(MAKE) -C $(ABCDIR) -f Makefile

# have a direct executable version (exec) and an sql-based version (sql)
abc_simulator_%.o: main_%.cpp $(ABCDIR)/libabc.a
	$(CPP) $(CFLAGS) -I$(GSL_INC) $(ABC_INC) $< -o $@ $(ABC_LIB) $(GSL_LIB)

dice_game.o: dice_game.cpp
	$(CPP) $(CFLAGS) -I$(GSL_INC) $< -o $@ $(GSL_LIB)

clean:
	$(MAKE) -C $(ABCDIR) clean
	rm -f *.o
	rm -f *.sqlite

demo: abc_simulator_sql.o abc_config_sql.json
	./$^ --process
	./$^ --simulate -n 1000
