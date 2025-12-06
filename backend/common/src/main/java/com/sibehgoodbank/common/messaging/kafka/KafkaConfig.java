package com.sibehgoodbank.common.messaging.kafka;

import org.apache.kafka.clients.admin.AdminClientConfig;
import org.apache.kafka.clients.admin.NewTopic;
import org.apache.kafka.clients.consumer.ConsumerConfig;
import org.apache.kafka.clients.producer.ProducerConfig;
import org.apache.kafka.common.serialization.StringDeserializer;
import org.apache.kafka.common.serialization.StringSerializer;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.kafka.config.ConcurrentKafkaListenerContainerFactory;
import org.springframework.kafka.config.TopicBuilder;
import org.springframework.kafka.core.*;
import org.springframework.kafka.support.serializer.JsonDeserializer;
import org.springframework.kafka.support.serializer.JsonSerializer;

import java.util.HashMap;
import java.util.Map;

/**
 * Kafka configuration for event-driven microservices communication
 */
@Configuration
public class KafkaConfig {

    @Value("${spring.kafka.bootstrap-servers:localhost:9092}")
    private String bootstrapServers;

    @Value("${spring.kafka.consumer.group-id:sibehgoodbank-group}")
    private String consumerGroupId;

    // ==================== Topic Names ====================

    public static final String TOPIC_USER_EVENTS = "user-events";
    public static final String TOPIC_TRANSACTION_EVENTS = "transaction-events";
    public static final String TOPIC_ACCOUNT_EVENTS = "account-events";
    public static final String TOPIC_NOTIFICATION_EVENTS = "notification-events";
    public static final String TOPIC_AUDIT_EVENTS = "audit-events";
    public static final String TOPIC_FRAUD_DETECTION = "fraud-detection";
    public static final String TOPIC_AI_REQUESTS = "ai-requests";
    public static final String TOPIC_AI_RESPONSES = "ai-responses";

    // ==================== Admin Config ====================

    @Bean
    public KafkaAdmin kafkaAdmin() {
        Map<String, Object> configs = new HashMap<>();
        configs.put(AdminClientConfig.BOOTSTRAP_SERVERS_CONFIG, bootstrapServers);
        return new KafkaAdmin(configs);
    }

    // ==================== Topic Definitions ====================

    @Bean
    public NewTopic userEventsTopic() {
        return TopicBuilder.name(TOPIC_USER_EVENTS)
                .partitions(3)
                .replicas(1)
                .config("retention.ms", "604800000") // 7 days
                .build();
    }

    @Bean
    public NewTopic transactionEventsTopic() {
        return TopicBuilder.name(TOPIC_TRANSACTION_EVENTS)
                .partitions(6) // More partitions for high throughput
                .replicas(1)
                .config("retention.ms", "2592000000") // 30 days
                .build();
    }

    @Bean
    public NewTopic accountEventsTopic() {
        return TopicBuilder.name(TOPIC_ACCOUNT_EVENTS)
                .partitions(3)
                .replicas(1)
                .build();
    }

    @Bean
    public NewTopic notificationEventsTopic() {
        return TopicBuilder.name(TOPIC_NOTIFICATION_EVENTS)
                .partitions(3)
                .replicas(1)
                .build();
    }

    @Bean
    public NewTopic auditEventsTopic() {
        return TopicBuilder.name(TOPIC_AUDIT_EVENTS)
                .partitions(3)
                .replicas(1)
                .config("retention.ms", "31536000000") // 1 year for compliance
                .build();
    }

    @Bean
    public NewTopic fraudDetectionTopic() {
        return TopicBuilder.name(TOPIC_FRAUD_DETECTION)
                .partitions(6)
                .replicas(1)
                .build();
    }

    @Bean
    public NewTopic aiRequestsTopic() {
        return TopicBuilder.name(TOPIC_AI_REQUESTS)
                .partitions(3)
                .replicas(1)
                .build();
    }

    @Bean
    public NewTopic aiResponsesTopic() {
        return TopicBuilder.name(TOPIC_AI_RESPONSES)
                .partitions(3)
                .replicas(1)
                .build();
    }

    // ==================== Producer Config ====================

    @Bean
    public ProducerFactory<String, Object> producerFactory() {
        Map<String, Object> configProps = new HashMap<>();
        configProps.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, bootstrapServers);
        configProps.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class);
        configProps.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, JsonSerializer.class);
        configProps.put(ProducerConfig.ACKS_CONFIG, "all"); // Wait for all replicas
        configProps.put(ProducerConfig.RETRIES_CONFIG, 3);
        configProps.put(ProducerConfig.ENABLE_IDEMPOTENCE_CONFIG, true); // Exactly-once semantics
        configProps.put(ProducerConfig.MAX_IN_FLIGHT_REQUESTS_PER_CONNECTION, 5);
        return new DefaultKafkaProducerFactory<>(configProps);
    }

    @Bean
    public KafkaTemplate<String, Object> kafkaTemplate() {
        return new KafkaTemplate<>(producerFactory());
    }

    // ==================== Consumer Config ====================

    @Bean
    public ConsumerFactory<String, Object> consumerFactory() {
        Map<String, Object> props = new HashMap<>();
        props.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, bootstrapServers);
        props.put(ConsumerConfig.GROUP_ID_CONFIG, consumerGroupId);
        props.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class);
        props.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, JsonDeserializer.class);
        props.put(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, "earliest");
        props.put(ConsumerConfig.ENABLE_AUTO_COMMIT_CONFIG, false); // Manual commit for reliability
        props.put(JsonDeserializer.TRUSTED_PACKAGES, "com.sibehgoodbank.*");
        return new DefaultKafkaConsumerFactory<>(props);
    }

    @Bean
    public ConcurrentKafkaListenerContainerFactory<String, Object> kafkaListenerContainerFactory() {
        ConcurrentKafkaListenerContainerFactory<String, Object> factory =
                new ConcurrentKafkaListenerContainerFactory<>();
        factory.setConsumerFactory(consumerFactory());
        factory.setConcurrency(3); // Number of concurrent listeners
        factory.getContainerProperties().setAckMode(
                org.springframework.kafka.listener.ContainerProperties.AckMode.MANUAL_IMMEDIATE
        );
        return factory;
    }
}
