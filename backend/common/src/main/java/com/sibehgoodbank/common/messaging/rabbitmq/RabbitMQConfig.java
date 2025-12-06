package com.sibehgoodbank.common.messaging.rabbitmq;

import org.springframework.amqp.core.*;
import org.springframework.amqp.rabbit.config.SimpleRabbitListenerContainerFactory;
import org.springframework.amqp.rabbit.connection.CachingConnectionFactory;
import org.springframework.amqp.rabbit.connection.ConnectionFactory;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.amqp.support.converter.Jackson2JsonMessageConverter;
import org.springframework.amqp.support.converter.MessageConverter;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * RabbitMQ configuration for reliable message delivery
 * Used for critical banking operations requiring guaranteed delivery
 */
@Configuration
public class RabbitMQConfig {

    @Value("${spring.rabbitmq.host:localhost}")
    private String host;

    @Value("${spring.rabbitmq.port:5672}")
    private int port;

    @Value("${spring.rabbitmq.username:guest}")
    private String username;

    @Value("${spring.rabbitmq.password:guest}")
    private String password;

    // ==================== Exchange Names ====================

    public static final String EXCHANGE_DIRECT = "sibehgoodbank.direct";
    public static final String EXCHANGE_TOPIC = "sibehgoodbank.topic";
    public static final String EXCHANGE_FANOUT = "sibehgoodbank.fanout";
    public static final String EXCHANGE_DEAD_LETTER = "sibehgoodbank.dlx";

    // ==================== Queue Names ====================

    public static final String QUEUE_TRANSACTION_PROCESSING = "transaction.processing";
    public static final String QUEUE_TRANSACTION_VERIFICATION = "transaction.verification";
    public static final String QUEUE_NOTIFICATION_EMAIL = "notification.email";
    public static final String QUEUE_NOTIFICATION_SMS = "notification.sms";
    public static final String QUEUE_NOTIFICATION_PUSH = "notification.push";
    public static final String QUEUE_FRAUD_ALERT = "fraud.alert";
    public static final String QUEUE_AUDIT_LOG = "audit.log";
    public static final String QUEUE_AI_TASK = "ai.task";
    public static final String QUEUE_DEAD_LETTER = "dead.letter.queue";

    // ==================== Routing Keys ====================

    public static final String ROUTING_TRANSACTION = "transaction.*";
    public static final String ROUTING_NOTIFICATION = "notification.*";
    public static final String ROUTING_FRAUD = "fraud.*";

    // ==================== Connection Factory ====================

    @Bean
    public ConnectionFactory connectionFactory() {
        CachingConnectionFactory connectionFactory = new CachingConnectionFactory();
        connectionFactory.setHost(host);
        connectionFactory.setPort(port);
        connectionFactory.setUsername(username);
        connectionFactory.setPassword(password);
        connectionFactory.setPublisherConfirmType(CachingConnectionFactory.ConfirmType.CORRELATED);
        connectionFactory.setPublisherReturns(true);
        return connectionFactory;
    }

    // ==================== Message Converter ====================

    @Bean
    public MessageConverter jsonMessageConverter() {
        return new Jackson2JsonMessageConverter();
    }

    // ==================== RabbitTemplate ====================

    @Bean
    public RabbitTemplate rabbitTemplate(ConnectionFactory connectionFactory) {
        RabbitTemplate template = new RabbitTemplate(connectionFactory);
        template.setMessageConverter(jsonMessageConverter());
        template.setMandatory(true);
        
        // Confirm callback for reliable delivery
        template.setConfirmCallback((correlationData, ack, cause) -> {
            if (!ack) {
                System.err.println("Message delivery failed: " + cause);
                // Handle failed delivery - retry or store for later
            }
        });
        
        // Return callback for unroutable messages
        template.setReturnsCallback(returned -> {
            System.err.println("Message returned: " + returned.getMessage() +
                    ", replyCode: " + returned.getReplyCode() +
                    ", replyText: " + returned.getReplyText());
        });
        
        return template;
    }

    // ==================== Listener Container Factory ====================

    @Bean
    public SimpleRabbitListenerContainerFactory rabbitListenerContainerFactory(
            ConnectionFactory connectionFactory) {
        SimpleRabbitListenerContainerFactory factory = new SimpleRabbitListenerContainerFactory();
        factory.setConnectionFactory(connectionFactory);
        factory.setMessageConverter(jsonMessageConverter());
        factory.setConcurrentConsumers(3);
        factory.setMaxConcurrentConsumers(10);
        factory.setAcknowledgeMode(AcknowledgeMode.MANUAL);
        factory.setPrefetchCount(10);
        factory.setDefaultRequeueRejected(false); // Send to DLQ instead of requeue
        return factory;
    }

    // ==================== Exchanges ====================

    @Bean
    public DirectExchange directExchange() {
        return ExchangeBuilder.directExchange(EXCHANGE_DIRECT)
                .durable(true)
                .build();
    }

    @Bean
    public TopicExchange topicExchange() {
        return ExchangeBuilder.topicExchange(EXCHANGE_TOPIC)
                .durable(true)
                .build();
    }

    @Bean
    public FanoutExchange fanoutExchange() {
        return ExchangeBuilder.fanoutExchange(EXCHANGE_FANOUT)
                .durable(true)
                .build();
    }

    @Bean
    public DirectExchange deadLetterExchange() {
        return ExchangeBuilder.directExchange(EXCHANGE_DEAD_LETTER)
                .durable(true)
                .build();
    }

    // ==================== Queues ====================

    @Bean
    public Queue transactionProcessingQueue() {
        return QueueBuilder.durable(QUEUE_TRANSACTION_PROCESSING)
                .withArgument("x-dead-letter-exchange", EXCHANGE_DEAD_LETTER)
                .withArgument("x-dead-letter-routing-key", QUEUE_DEAD_LETTER)
                .build();
    }

    @Bean
    public Queue transactionVerificationQueue() {
        return QueueBuilder.durable(QUEUE_TRANSACTION_VERIFICATION)
                .withArgument("x-dead-letter-exchange", EXCHANGE_DEAD_LETTER)
                .withArgument("x-dead-letter-routing-key", QUEUE_DEAD_LETTER)
                .build();
    }

    @Bean
    public Queue notificationEmailQueue() {
        return QueueBuilder.durable(QUEUE_NOTIFICATION_EMAIL)
                .withArgument("x-dead-letter-exchange", EXCHANGE_DEAD_LETTER)
                .withArgument("x-dead-letter-routing-key", QUEUE_DEAD_LETTER)
                .build();
    }

    @Bean
    public Queue notificationSmsQueue() {
        return QueueBuilder.durable(QUEUE_NOTIFICATION_SMS)
                .withArgument("x-dead-letter-exchange", EXCHANGE_DEAD_LETTER)
                .build();
    }

    @Bean
    public Queue notificationPushQueue() {
        return QueueBuilder.durable(QUEUE_NOTIFICATION_PUSH)
                .withArgument("x-dead-letter-exchange", EXCHANGE_DEAD_LETTER)
                .build();
    }

    @Bean
    public Queue fraudAlertQueue() {
        return QueueBuilder.durable(QUEUE_FRAUD_ALERT)
                .withArgument("x-dead-letter-exchange", EXCHANGE_DEAD_LETTER)
                .build();
    }

    @Bean
    public Queue auditLogQueue() {
        return QueueBuilder.durable(QUEUE_AUDIT_LOG)
                .build();
    }

    @Bean
    public Queue aiTaskQueue() {
        return QueueBuilder.durable(QUEUE_AI_TASK)
                .withArgument("x-dead-letter-exchange", EXCHANGE_DEAD_LETTER)
                .build();
    }

    @Bean
    public Queue deadLetterQueue() {
        return QueueBuilder.durable(QUEUE_DEAD_LETTER)
                .build();
    }

    // ==================== Bindings ====================

    @Bean
    public Binding transactionProcessingBinding() {
        return BindingBuilder.bind(transactionProcessingQueue())
                .to(directExchange())
                .with("transaction.process");
    }

    @Bean
    public Binding transactionVerificationBinding() {
        return BindingBuilder.bind(transactionVerificationQueue())
                .to(directExchange())
                .with("transaction.verify");
    }

    @Bean
    public Binding notificationEmailBinding() {
        return BindingBuilder.bind(notificationEmailQueue())
                .to(topicExchange())
                .with("notification.email");
    }

    @Bean
    public Binding notificationSmsBinding() {
        return BindingBuilder.bind(notificationSmsQueue())
                .to(topicExchange())
                .with("notification.sms");
    }

    @Bean
    public Binding notificationPushBinding() {
        return BindingBuilder.bind(notificationPushQueue())
                .to(topicExchange())
                .with("notification.push");
    }

    @Bean
    public Binding fraudAlertBinding() {
        return BindingBuilder.bind(fraudAlertQueue())
                .to(directExchange())
                .with("fraud.alert");
    }

    @Bean
    public Binding auditLogBinding() {
        return BindingBuilder.bind(auditLogQueue())
                .to(fanoutExchange());
    }

    @Bean
    public Binding aiTaskBinding() {
        return BindingBuilder.bind(aiTaskQueue())
                .to(directExchange())
                .with("ai.task");
    }

    @Bean
    public Binding deadLetterBinding() {
        return BindingBuilder.bind(deadLetterQueue())
                .to(deadLetterExchange())
                .with(QUEUE_DEAD_LETTER);
    }
}
