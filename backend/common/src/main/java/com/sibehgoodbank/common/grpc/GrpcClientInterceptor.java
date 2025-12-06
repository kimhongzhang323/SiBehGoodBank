package com.sibehgoodbank.common.grpc;

import io.grpc.*;
import lombok.extern.slf4j.Slf4j;

/**
 * gRPC client interceptor for adding common headers and handling errors.
 */
@Slf4j
public class GrpcClientInterceptor implements ClientInterceptor {

    private final String serviceName;
    private final String authToken;

    public GrpcClientInterceptor(String serviceName) {
        this(serviceName, null);
    }

    public GrpcClientInterceptor(String serviceName, String authToken) {
        this.serviceName = serviceName;
        this.authToken = authToken;
    }

    @Override
    public <ReqT, RespT> ClientCall<ReqT, RespT> interceptCall(
            MethodDescriptor<ReqT, RespT> method,
            CallOptions callOptions,
            Channel next) {

        return new ForwardingClientCall.SimpleForwardingClientCall<>(next.newCall(method, callOptions)) {

            @Override
            public void start(Listener<RespT> responseListener, Metadata headers) {
                // Add service name header
                headers.put(
                        Metadata.Key.of("x-calling-service", Metadata.ASCII_STRING_MARSHALLER),
                        serviceName
                );

                // Add correlation ID for tracing
                headers.put(
                        Metadata.Key.of("x-correlation-id", Metadata.ASCII_STRING_MARSHALLER),
                        java.util.UUID.randomUUID().toString()
                );

                // Add auth token if present
                if (authToken != null && !authToken.isEmpty()) {
                    headers.put(
                            Metadata.Key.of("authorization", Metadata.ASCII_STRING_MARSHALLER),
                            "Bearer " + authToken
                    );
                }

                log.debug("gRPC call: {} -> {}", serviceName, method.getFullMethodName());

                super.start(new ForwardingClientCallListener.SimpleForwardingClientCallListener<>(responseListener) {
                    @Override
                    public void onClose(Status status, Metadata trailers) {
                        if (!status.isOk()) {
                            log.warn("gRPC call failed: {} - {} ({})",
                                    method.getFullMethodName(),
                                    status.getCode(),
                                    status.getDescription());
                        }
                        super.onClose(status, trailers);
                    }
                }, headers);
            }
        };
    }
}
