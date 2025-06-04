# ubiquitous-journey
Testing ChatGPT Codex connector with GitHub

## Perl OTLP gRPC Server Example

This repository now includes a basic example of using Perl to receive
OpenTelemetry Protocol (OTLP) messages over gRPC with TLS. The example
uses `Grpc::XS` for the transport layer and `Google::ProtocolBuffers::Dynamic`
for loading the OTLP protobuf files at runtime.

### Files

- `otel_grpc_server/otel_grpc_server.pl` – minimal gRPC server example.
- `otel_grpc_server/*.proto` – required protobuf definitions.

### Running the example

1. Install the required CPAN modules:

   ```shell
   cpan Google::ProtocolBuffers::Dynamic Grpc::XS
   ```

2. Create `server.crt` and `server.key` files for TLS and place them in the
   `otel_grpc_server` directory.

3. Run the server:

   ```shell
   perl otel_grpc_server/otel_grpc_server.pl
   ```

The server listens on port `4317` (the default OTLP gRPC port) and prints the
number of span sets it receives in each request.
