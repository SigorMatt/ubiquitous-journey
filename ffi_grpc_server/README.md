# FFI gRPC Server Wrapper

This directory contains a very small C wrapper around the gRPC C library. It exposes
functions for creating and destroying a gRPC server. The implementation is not complete
but demonstrates how one could bind to the gRPC core library from Perl using `FFI::Platypus`.

To build the shared library:

```sh
make
```

This requires the `libgrpc-dev` package to be installed.
