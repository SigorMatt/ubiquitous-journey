all: libgrpcwrap.so

libgrpcwrap.so: grpc_server_wrapper.o
	gcc -shared -o libgrpcwrap.so grpc_server_wrapper.o \
		-l:libgrpc++.so.1.51 -l:libgrpc++_reflection.so.1.51 \
		-lgrpc -labsl_synchronization -labsl_str_format_internal -labsl_base \
		-lssl -lcrypto -lpthread

grpc_server_wrapper.o: grpc_server_wrapper.c
	gcc -fPIC -c grpc_server_wrapper.c

clean:
	rm -f *.o libgrpcwrap.so
