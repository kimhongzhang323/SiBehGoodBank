package com.sibehgoodbank.common.grpc;

import io.grpc.*;
import lombok.extern.slf4j.Slf4j;

/**
 * gRPC server interceptor for logging and validation.
 */
@Slf4j
public class GrpcServerInterceptor implements ServerInterceptor {

    @Override
    public <ReqT, RespT> ServerCall.Listener<ReqT> interceptCall(
            ServerCall<ReqT, RespT> call,
            Metadata headers,
            ServerCallHandler<ReqT, RespT> next) {

        String correlationId = headers.get(
                Metadata.Key.of("x-correlation-id", Metadata.ASCII_STRING_MARSHALLER)
        );
        String callingService = headers.get(
                Metadata.Key.of("x-calling-service", Metadata.ASCII_STRING_MARSHALLER)
        );

        log.debug("gRPC request: {} from {} (correlation: {})",
                call.getMethodDescriptor().getFullMethodName(),
                callingService,
                correlationId);

        long startTime = System.currentTimeMillis();

        return new ForwardingServerCallListener.SimpleForwardingServerCallListener<>(
                next.startCall(new ForwardingServerCall.SimpleForwardingServerCall<>(call) {
                    @Override
                    public void close(Status status, Metadata trailers) {
                        long duration = System.currentTimeMillis() - startTime;
                        
                        if (status.isOk()) {
                            log.debug("gRPC response: {} completed in {}ms",
                                    call.getMethodDescriptor().getFullMethodName(),
                                    duration);
                        } else {
                            log.warn("gRPC response: {} failed with {} in {}ms",
                                    call.getMethodDescriptor().getFullMethodName(),
                                    status.getCode(),
                                    duration);
                        }
                        
                        // Add correlation ID to response
                        if (correlationId != null) {
                            trailers.put(
                                    Metadata.Key.of("x-correlation-id", Metadata.ASCII_STRING_MARSHALLER),
                                    correlationId
                            );
                        }
                        
                        super.close(status, trailers);
                    }
                }, headers)
        ) {};
    }
}
