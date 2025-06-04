use strict;
use warnings;

use Google::ProtocolBuffers::Dynamic;
use Grpc::XS::Server;
use Grpc::XS::ServerCredentials;
use Grpc::Constants qw(
    GRPC_OP_RECV_MESSAGE
    GRPC_OP_RECV_CLOSE_ON_SERVER
    GRPC_OP_SEND_INITIAL_METADATA
    GRPC_OP_SEND_MESSAGE
    GRPC_OP_SEND_STATUS_FROM_SERVER
    GRPC_STATUS_OK
);

sub slurp {
    my ($file) = @_;
    open my $fh, '<', $file or die "Cannot open $file: $!";
    local $/; return <$fh>;
}

# Load OpenTelemetry protobuf definitions
my $pb = Google::ProtocolBuffers::Dynamic->new(ignore_unknown_fields => 1);
$pb->load_file('trace_service.proto', { include_path => ['.'] });
$pb->resolve_references;

# TLS credentials
my $cert = slurp('server.crt');
my $key  = slurp('server.key');
my $creds = Grpc::XS::ServerCredentials::createSsl(
    pem_private_key => $key,
    pem_cert_chain  => $cert,
);

# Create gRPC server
my $server = Grpc::XS::Server->new();
$server->addSecureHttp2Port('0.0.0.0:4317', $creds);
$server->start;

print "OTLP gRPC server listening on 0.0.0.0:4317\n";

while (1) {
    my $call_info = $server->requestCall;
    my $call      = $call_info->{call};

    # Receive request message
    my $event = $call->startBatch(
        GRPC_OP_RECV_MESSAGE()      => 1,
        GRPC_OP_RECV_CLOSE_ON_SERVER() => 1,
    );
    my $payload = $event->{message};
    my $req = $pb->decode('opentelemetry.proto.collector.trace.v1.ExportTraceServiceRequest', $payload);

    my $span_sets = 0;
    if ($req->{resource_spans}) {
        for my $rs (@{ $req->{resource_spans} }) {
            $span_sets += @{ $rs->{scope_spans} || [] };
        }
    }
    print "Received ExportTraceServiceRequest with $span_sets span sets\n";

    # Send empty response with status OK
    my $resp_bin = $pb->encode('opentelemetry.proto.collector.trace.v1.ExportTraceServiceResponse', {});
    $call->startBatch(
        GRPC_OP_SEND_INITIAL_METADATA()  => {},
        GRPC_OP_SEND_MESSAGE()           => { message => $resp_bin },
        GRPC_OP_SEND_STATUS_FROM_SERVER() => { code => GRPC_STATUS_OK, details => '' },
    );
}

