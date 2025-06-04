# ubiquitous-journey
Testing ChatGPT Codex connector with GitHub

## Perl OTLP gRPC Server Example

This repository now includes a basic example of using Perl to receive
OpenTelemetry Protocol (OTLP) messages over gRPC with TLS. Because the
`Grpc::XS` module is no longer actively maintained, a minimal FFI binding to
the gRPC C library is provided instead. The binding is implemented in
`ffi_grpc_server/` and loaded using `FFI::Platypus`.

### Files

- `otel_grpc_server/otel_grpc_server.pl` – legacy example using `Grpc::XS`.
- `ffi_grpc_server.pl` – example using the FFI binding.
- `ffi_grpc_server/` – C wrapper and build instructions.
- `otel_grpc_server/*.proto` – required protobuf definitions.

### Running the example

1. Install the required packages and Perl modules:

   ```shell
   sudo apt-get install libgrpc-dev libffi-platypus-perl
   cpan Google::ProtocolBuffers::Dynamic
   ```

2. Build the FFI wrapper:

   ```shell
   (cd ffi_grpc_server && make)
   ```

3. Create `server.crt` and `server.key` files for TLS and place them in the
   repository root.

4. Run the FFI-based server:

   ```shell
   perl ffi_grpc_server.pl
   ```

The server listens on port `4317` (the default OTLP gRPC port). The example
implementation currently only starts the server and does not yet decode
messages. It demonstrates how to bind to the gRPC C library without relying
on the unmaintained `Grpc::XS` module.
