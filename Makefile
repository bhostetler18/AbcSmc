include minc.mk

SOURCES     := $(addprefix $(ABCDIR)/,AbcSmc.cpp AbcUtil.cpp CCRC32.cpp)
JSONDIR     := $(ABCDIR)/jsoncpp/src
JSONSOURCES := $(addprefix $(JSONDIR)/,json_reader.cpp json_value.cpp json_writer.cpp)
SQLSOURCES  := $(SQLDIR)/sqdb.cpp

LIBABC  := libabc.a
LIBJSON := libjsoncpp.a
LIBSQL  := libsqdb.a

OBJECTS     := $(SOURCES:.cpp=.o)
JSONOBJECTS := $(JSONSOURCES:.cpp=.o)
SQLOBJECTS  := $(SQLSOURCES:.cpp=.o)
ABC_HEADER  := $(addprefix $(ABCDIR)/,pls.h AbcUtil.h AbcSmc.h)

default: $(LIBABC)
.all:  $(LIBJSON) sqlite3.o $(LIBSQL) $(SOURCES) $(LIBABC)

sqlite3.o: $(SQLDIR)/sqlite3.c $(SQLDIR)/sqlite3.h
	$(CPP) -g -c $< -I$(SQLDIR)

$(LIBABC): $(ABC_HEADER) $(OBJECTS) $(LIBSQL) $(LIBJSON)
	$(AR) -o $@ $(OBJECTS) $(LIBSQL)

$(LIBJSON): $(JSONOBJECTS)
	$(AR) -o $@ $^

$(LIBSQL): $(SQLOBJECTS)
	$(AR) -o $@ $^

%.o: %.cpp $(ABC_HEADER)
	$(CPP) $(CFLAGS) -c $(INCLUDE) $< -o $@

clean:
	rm -f $(OBJECTS) $(JSONOBJECTS) $(SQLOBJECTS) $(LIBABC) $(LIBJSON) $(LIBSQL)
