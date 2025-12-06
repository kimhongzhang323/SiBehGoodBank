package com.sibehgoodbank.gateway.filter;

import lombok.extern.slf4j.Slf4j;
import org.springframework.cloud.gateway.filter.GatewayFilterChain;
import org.springframework.cloud.gateway.filter.GlobalFilter;
import org.springframework.core.Ordered;
import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;

import java.util.UUID;

@Component
@Slf4j
public class RequestLoggingFilter implements GlobalFilter, Ordered {

    private static final String REQUEST_ID_HEADER = "X-Request-Id";
    private static final String CORRELATION_ID_HEADER = "X-Correlation-Id";

    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        long startTime = System.currentTimeMillis();
        ServerHttpRequest request = exchange.getRequest();
        
        // Generate or use existing request ID
        String requestId = request.getHeaders().getFirst(REQUEST_ID_HEADER);
        if (requestId == null || requestId.isEmpty()) {
            requestId = UUID.randomUUID().toString();
        }
        
        // Generate or use existing correlation ID
        String correlationId = request.getHeaders().getFirst(CORRELATION_ID_HEADER);
        if (correlationId == null || correlationId.isEmpty()) {
            correlationId = UUID.randomUUID().toString();
        }
        
        String finalRequestId = requestId;
        String finalCorrelationId = correlationId;
        
        // Add headers to request
        ServerHttpRequest modifiedRequest = request.mutate()
                .header(REQUEST_ID_HEADER, finalRequestId)
                .header(CORRELATION_ID_HEADER, finalCorrelationId)
                .build();
        
        // Log incoming request
        log.info("Incoming request: {} {} | RequestId: {} | CorrelationId: {} | Client: {}",
                request.getMethod(),
                request.getURI().getPath(),
                finalRequestId,
                finalCorrelationId,
                request.getRemoteAddress());
        
        return chain.filter(exchange.mutate().request(modifiedRequest).build())
                .then(Mono.fromRunnable(() -> {
                    long duration = System.currentTimeMillis() - startTime;
                    log.info("Outgoing response: {} {} | Status: {} | Duration: {}ms | RequestId: {}",
                            request.getMethod(),
                            request.getURI().getPath(),
                            exchange.getResponse().getStatusCode(),
                            duration,
                            finalRequestId);
                }));
    }

    @Override
    public int getOrder() {
        return -200; // Execute before JWT filter
    }
}
