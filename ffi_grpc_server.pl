use strict;
use warnings;
use FFI::Platypus 1.00;
use FFI::Platypus::Memory qw( free );

my $ffi = FFI::Platypus->new( api => 1 );
$ffi->lib('./ffi_grpc_server/libgrpcwrap.so');

$ffi->type('opaque' => 'server');

$ffi->attach( otel_server_new => ['string','string','string'] => 'server' );
$ffi->attach( otel_server_destroy => ['server'] );

# create server with cert/key
my $cert = do {
  open my $fh, '<', 'server.crt' or die "server.crt: $!";
  local $/;
  <$fh>;
};
my $key = do {
  open my $fh, '<', 'server.key' or die "server.key: $!";
  local $/;
  <$fh>;
};

my $server = otel_server_new('0.0.0.0:4317',$cert,$key);
print "Started FFI gRPC server on 0.0.0.0:4317\n";

END {
  otel_server_destroy($server) if $server;
}

sleep while 1;
