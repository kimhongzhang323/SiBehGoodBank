package com.sibehgoodbank.common.cache;

import com.fasterxml.jackson.annotation.JsonTypeInfo;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.jsontype.impl.LaissezFaireSubTypeValidator;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.cache.CacheManager;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.redis.cache.RedisCacheConfiguration;
import org.springframework.data.redis.cache.RedisCacheManager;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.data.redis.connection.RedisStandaloneConfiguration;
import org.springframework.data.redis.connection.lettuce.LettuceConnectionFactory;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.data.redis.serializer.GenericJackson2JsonRedisSerializer;
import org.springframework.data.redis.serializer.RedisSerializationContext;
import org.springframework.data.redis.serializer.StringRedisSerializer;

import java.time.Duration;
import java.util.HashMap;
import java.util.Map;

/**
 * Redis configuration for caching and distributed data storage
 */
@Configuration
@EnableCaching
public class RedisConfig {

    @Value("${spring.redis.host:localhost}")
    private String redisHost;

    @Value("${spring.redis.port:6379}")
    private int redisPort;

    @Value("${spring.redis.password:}")
    private String redisPassword;

    // ==================== Cache Key Prefixes ====================

    public static final String CACHE_USER = "user";
    public static final String CACHE_ACCOUNT = "account";
    public static final String CACHE_TRANSACTION = "transaction";
    public static final String CACHE_SESSION = "session";
    public static final String CACHE_OTP = "otp";
    public static final String CACHE_RATE_LIMIT = "rate_limit";
    public static final String CACHE_TOKEN_BLACKLIST = "token_blacklist";
    public static final String CACHE_EXCHANGE_RATES = "exchange_rates";

    // ==================== Connection Factory ====================

    @Bean
    public LettuceConnectionFactory redisConnectionFactory() {
        RedisStandaloneConfiguration config = new RedisStandaloneConfiguration();
        config.setHostName(redisHost);
        config.setPort(redisPort);
        if (redisPassword != null && !redisPassword.isEmpty()) {
            config.setPassword(redisPassword);
        }
        return new LettuceConnectionFactory(config);
    }

    // ==================== Object Mapper ====================

    private ObjectMapper redisObjectMapper() {
        ObjectMapper mapper = new ObjectMapper();
        mapper.registerModule(new JavaTimeModule());
        mapper.activateDefaultTyping(
                LaissezFaireSubTypeValidator.instance,
                ObjectMapper.DefaultTyping.NON_FINAL,
                JsonTypeInfo.As.PROPERTY
        );
        return mapper;
    }

    // ==================== Redis Template ====================

    @Bean
    public RedisTemplate<String, Object> redisTemplate(RedisConnectionFactory connectionFactory) {
        RedisTemplate<String, Object> template = new RedisTemplate<>();
        template.setConnectionFactory(connectionFactory);

        GenericJackson2JsonRedisSerializer jsonSerializer =
                new GenericJackson2JsonRedisSerializer(redisObjectMapper());

        template.setKeySerializer(new StringRedisSerializer());
        template.setValueSerializer(jsonSerializer);
        template.setHashKeySerializer(new StringRedisSerializer());
        template.setHashValueSerializer(jsonSerializer);
        template.setEnableTransactionSupport(true);
        template.afterPropertiesSet();

        return template;
    }

    @Bean
    public StringRedisTemplate stringRedisTemplate(RedisConnectionFactory connectionFactory) {
        return new StringRedisTemplate(connectionFactory);
    }

    // ==================== Cache Manager ====================

    @Bean
    public CacheManager cacheManager(RedisConnectionFactory connectionFactory) {
        RedisCacheConfiguration defaultConfig = RedisCacheConfiguration.defaultCacheConfig()
                .entryTtl(Duration.ofMinutes(30))
                .serializeKeysWith(RedisSerializationContext.SerializationPair
                        .fromSerializer(new StringRedisSerializer()))
                .serializeValuesWith(RedisSerializationContext.SerializationPair
                        .fromSerializer(new GenericJackson2JsonRedisSerializer(redisObjectMapper())))
                .disableCachingNullValues();

        Map<String, RedisCacheConfiguration> cacheConfigs = new HashMap<>();

        // User cache - 1 hour TTL
        cacheConfigs.put(CACHE_USER, defaultConfig.entryTtl(Duration.ofHours(1)));

        // Account cache - 30 minutes TTL
        cacheConfigs.put(CACHE_ACCOUNT, defaultConfig.entryTtl(Duration.ofMinutes(30)));

        // Transaction cache - 5 minutes TTL (frequently changing)
        cacheConfigs.put(CACHE_TRANSACTION, defaultConfig.entryTtl(Duration.ofMinutes(5)));

        // Session cache - 24 hours TTL
        cacheConfigs.put(CACHE_SESSION, defaultConfig.entryTtl(Duration.ofHours(24)));

        // OTP cache - 5 minutes TTL
        cacheConfigs.put(CACHE_OTP, defaultConfig.entryTtl(Duration.ofMinutes(5)));

        // Rate limit cache - 1 minute TTL
        cacheConfigs.put(CACHE_RATE_LIMIT, defaultConfig.entryTtl(Duration.ofMinutes(1)));

        // Token blacklist - 24 hours TTL (match refresh token expiry)
        cacheConfigs.put(CACHE_TOKEN_BLACKLIST, defaultConfig.entryTtl(Duration.ofHours(24)));

        // Exchange rates cache - 1 hour TTL
        cacheConfigs.put(CACHE_EXCHANGE_RATES, defaultConfig.entryTtl(Duration.ofHours(1)));

        return RedisCacheManager.builder(connectionFactory)
                .cacheDefaults(defaultConfig)
                .withInitialCacheConfigurations(cacheConfigs)
                .transactionAware()
                .build();
    }
}
