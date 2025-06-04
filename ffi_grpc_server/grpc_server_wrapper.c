#include <grpc/grpc.h>
#include <grpc/grpc_security.h>
#include <grpc/status.h>
#include <stdlib.h>
#include <string.h>

struct server_ctx {
    grpc_server *server;
    grpc_completion_queue *cq;
};

struct server_ctx* otel_server_new(const char* address,const char* cert,const char* key){
    grpc_init();
    struct server_ctx *ctx = malloc(sizeof(struct server_ctx));
    ctx->cq = grpc_completion_queue_create_for_next(NULL);
    ctx->server = grpc_server_create(NULL, NULL);
    grpc_server_register_completion_queue(ctx->server, ctx->cq, NULL);

    grpc_ssl_pem_key_cert_pair pair = { key, cert };
    grpc_server_credentials *creds = grpc_ssl_server_credentials_create(NULL,&pair,1,0,NULL);
    grpc_server_add_secure_http2_port(ctx->server, address, creds);
    grpc_server_credentials_release(creds);
    grpc_server_start(ctx->server);
    return ctx;
}

void otel_server_destroy(struct server_ctx* ctx){
    if(!ctx) return;
    grpc_server_shutdown_and_notify(ctx->server, ctx->cq, NULL);
    grpc_completion_queue_next(ctx->cq, gpr_inf_future(GPR_CLOCK_REALTIME), NULL);
    grpc_server_destroy(ctx->server);
    grpc_completion_queue_shutdown(ctx->cq);
    grpc_completion_queue_next(ctx->cq, gpr_inf_future(GPR_CLOCK_REALTIME), NULL);
    grpc_completion_queue_destroy(ctx->cq);
    free(ctx);
    grpc_shutdown();
}

int otel_server_poll(struct server_ctx* ctx){
    return 0;
}
