MAKEFLAGS=rR

CXX:= g++
CC:=gcc
CXXFLAGS:= -Iinc -ggdb3 -O0 -I include/boost
LDDFLAGS:= -ggdb3 -O0 -I include/boost
C++SRC:=$(wildcard *.cc)
C++OBJ:=$(patsubst %.cc, %.o, $(C++SRC))
C++EXE:=lfs parse

#$(warning $(C++SRC))mke

C++LIB:=$(filter-out $(patsubst %.cc, %, $(warning $(C++SRC))))

C++LIB:=
LIBCURL_LIBS=-Llib/x86_64-linux-gnu -L/usr/lib/x86_64-linux-gnu/mit-krb5 -Wl,-Bsymbolic-functions -Wl,-z,relro -lcurl -lssl -lcrypto -lssl -lcrypto  
#LIBCURL_LIBS=-Llib/x86_64-linux-gnu -L/usr/lib/x86_64-linux-gnu/mit-krb5 -lcurlpp -Wl,-Bsymbolic-functions -Wl,-z,relro -lcurl -lssl -lcrypto -lssl -lcrypto  -lcom_err 
#-llber -lldap -llber -lbrotlidec -lz
LIBCURL_INCS=-Iinclude -I/usr/include/x86_64-linux-gnu

all: curlsend-test

CFLAGS:= -ggdb3 -O0
LDFLAGS:= -lcurl

curlsend-test: curlsend
	report bash runtest.sh ./curlsend

LIB:=$(patsubst %.cc,%.o,$(wildcard lib/*.cc))

curlsend: curlsend.o $(LIB) $(C++OBJ)
	$(CXX) $(LD_FLAGS) $< -o $@ $(LIB) $(LIBCURL_LIBS) $(C++OBJ)

%.i: %.cc
	$(CXX) $(CXXFLAGS) $(LIBCURL_INCS) $< -o $@ -E

%.o: %.cc
	$(CXX) $(CXXFLAGS) $(LIBCURL_INCS) $< -o $@ -c

tags: Makefile
	find . -name '*.cc' -o -name '*.hh' > tagfiles 
	cat tagfiles | xargs ctags --language-force=c++

clean:
	find -name '*.o' | xargs rm -f

