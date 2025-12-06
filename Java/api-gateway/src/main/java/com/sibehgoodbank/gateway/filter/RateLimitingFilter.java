package com.sibehgoodbank.gateway.filter;

import lombok.extern.slf4j.Slf4j;
import org.springframework.cloud.gateway.filter.GatewayFilter;
import org.springframework.cloud.gateway.filter.factory.AbstractGatewayFilterFactory;
import org.springframework.data.redis.core.ReactiveRedisTemplate;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import reactor.core.publisher.Mono;

import java.time.Duration;

@Component
@Slf4j
public class RateLimitingFilter extends AbstractGatewayFilterFactory<RateLimitingFilter.Config> {

    private final ReactiveRedisTemplate<String, String> redisTemplate;

    public RateLimitingFilter(ReactiveRedisTemplate<String, String> redisTemplate) {
        super(Config.class);
        this.redisTemplate = redisTemplate;
    }

    @Override
    public GatewayFilter apply(Config config) {
        return (exchange, chain) -> {
            String clientIp = exchange.getRequest().getRemoteAddress().getAddress().getHostAddress();
            String userId = exchange.getRequest().getHeaders().getFirst("X-User-Id");
            
            String key = String.format("rate_limit:%s:%s", 
                    userId != null ? userId : clientIp,
                    exchange.getRequest().getPath().value());
            
            return redisTemplate.opsForValue()
                    .increment(key)
                    .flatMap(count -> {
                        if (count == 1) {
                            // First request, set expiry
                            return redisTemplate.expire(key, Duration.ofSeconds(config.getReplenishRate()))
                                    .thenReturn(count);
                        }
                        return Mono.just(count);
                    })
                    .flatMap(count -> {
                        if (count > config.getBurstCapacity()) {
                            log.warn("Rate limit exceeded for key: {} | Count: {}", key, count);
                            exchange.getResponse().setStatusCode(HttpStatus.TOO_MANY_REQUESTS);
                            exchange.getResponse().getHeaders().add("X-RateLimit-Limit", 
                                    String.valueOf(config.getBurstCapacity()));
                            exchange.getResponse().getHeaders().add("X-RateLimit-Remaining", "0");
                            return exchange.getResponse().setComplete();
                        }
                        
                        exchange.getResponse().getHeaders().add("X-RateLimit-Limit", 
                                String.valueOf(config.getBurstCapacity()));
                        exchange.getResponse().getHeaders().add("X-RateLimit-Remaining", 
                                String.valueOf(Math.max(0, config.getBurstCapacity() - count)));
                        
                        return chain.filter(exchange);
                    });
        };
    }

    public static class Config {
        private int replenishRate = 60; // seconds
        private int burstCapacity = 100; // max requests per replenish period

        public int getReplenishRate() {
            return replenishRate;
        }

        public void setReplenishRate(int replenishRate) {
            this.replenishRate = replenishRate;
        }

        public int getBurstCapacity() {
            return burstCapacity;
        }

        public void setBurstCapacity(int burstCapacity) {
            this.burstCapacity = burstCapacity;
        }
    }
}
