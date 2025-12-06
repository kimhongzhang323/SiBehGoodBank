# SibehGoodBank Backend

A comprehensive, enterprise-grade banking microservices backend built with Java 21 and Spring Boot 3.2.

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              API Gateway (8080)                               │
│                    Spring Cloud Gateway + JWT + Rate Limiting                 │
└─────────────────────────────────────────────────────────────────────────────┘
                                        │
        ┌───────────────────────────────┼───────────────────────────────┐
        │                               │                               │
        ▼                               ▼                               ▼
┌───────────────┐           ┌───────────────┐           ┌───────────────┐
│ User Service  │           │Account Service│           │  Transaction  │
│    (8081)     │           │    (8082)     │           │   Service     │
│               │           │               │           │    (8083)     │
└───────────────┘           └───────────────┘           └───────────────┘
        │                               │                               │
        └───────────────────────────────┼───────────────────────────────┘
                                        │
        ┌───────────────────────────────┼───────────────────────────────┐
        │                               │                               │
        ▼                               ▼                               ▼
┌───────────────┐           ┌───────────────┐           ┌───────────────┐
│   AI Agent    │           │ Notification  │           │  Analytics    │
│   Service     │           │   Service     │           │   Service     │
│    (8084)     │           │    (8085)     │           │    (8086)     │
└───────────────┘           └───────────────┘           └───────────────┘
        │                               │                               │
        └───────────────────────────────┼───────────────────────────────┘
                                        │
┌─────────────────────────────────────────────────────────────────────────────┐
│                           Infrastructure Services                            │
├─────────────┬─────────────┬─────────────┬─────────────┬─────────────────────┤
│  Discovery  │   Config    │  PostgreSQL │   Redis     │  Kafka + RabbitMQ   │
│   (8761)    │   (8888)    │   (5432)    │   (6379)    │  (9092)   (5672)    │
└─────────────┴─────────────┴─────────────┴─────────────┴─────────────────────┘
```

## 🚀 Microservices

### Core Services

| Service | Port | Description |
|---------|------|-------------|
| **API Gateway** | 8080 | Central entry point with JWT validation, rate limiting, circuit breakers |
| **User Service** | 8081 | User management, authentication, authorization |
| **Account Service** | 8082 | Bank account management, balance operations |
| **Transaction Service** | 8083 | Transaction processing, transfers, fraud detection |
| **AI Agent Service** | 8084 | Anthropic Claude-powered banking assistant |
| **Notification Service** | 8085 | Multi-channel notifications (Email, SMS, Push) |
| **Analytics Service** | 8086 | Real-time analytics and reporting |

### Infrastructure Services

| Service | Port | Description |
|---------|------|-------------|
| **Discovery Service** | 8761 | Eureka service registry |
| **Config Service** | 8888 | Centralized configuration |

## 🔐 Security Features

- **Encryption**: AES-256-GCM for data encryption, RSA-4096 for key exchange
- **Password Hashing**: Argon2id with configurable parameters
- **JWT Authentication**: Secure token-based authentication
- **Field-Level Encryption**: Sensitive data encrypted at rest
- **Rate Limiting**: Redis-based request throttling
- **Circuit Breakers**: Resilience4j for fault tolerance

## 🤖 AI Agent Service

The AI Agent Service integrates with Anthropic's Claude API to provide an intelligent banking assistant with tool use capabilities:

### Available Banking Tools

| Tool | Description |
|------|-------------|
| `check_balance` | Check account balance |
| `get_transactions` | Retrieve transaction history |
| `transfer_funds` | Initiate money transfers |
| `get_account_details` | Get detailed account information |
| `get_exchange_rates` | Get current exchange rates |
| `calculate_loan` | Calculate loan payments |
| `report_suspicious_activity` | Report potential fraud |

### API Endpoints

```bash
# Chat with AI agent
POST /api/v1/ai/chat
{
  "sessionId": "uuid",
  "userId": "uuid",
  "message": "What's my account balance?"
}

# Streaming chat
GET /api/v1/ai/chat/stream?sessionId=xxx&userId=xxx&message=xxx

# Chat with tools enabled
POST /api/v1/ai/chat/tools
```

## 📨 Notification Service

Multi-channel notification delivery with:

- **Email**: JavaMail + Thymeleaf templates
- **SMS**: Twilio integration
- **Push**: Firebase Cloud Messaging
- **In-App**: Real-time notifications via RabbitMQ

## 🛠️ Tech Stack

| Category | Technology |
|----------|------------|
| **Framework** | Spring Boot 3.2.1, Spring Cloud 2023.0.0 |
| **Language** | Java 21 |
| **Database** | PostgreSQL 15 |
| **Cache** | Redis 7 |
| **Message Queue** | Apache Kafka, RabbitMQ |
| **Service Discovery** | Netflix Eureka |
| **API Gateway** | Spring Cloud Gateway |
| **Security** | Spring Security, JWT, Bouncy Castle |
| **AI** | Anthropic Claude API |
| **Inter-Service Communication** | gRPC + Protocol Buffers |
| **Monitoring** | Prometheus, Grafana |
| **Containerization** | Docker, Docker Compose |

## 📡 gRPC Inter-Service Communication

Services communicate internally using gRPC for high-performance, type-safe RPC calls:

### gRPC Services

| Service | gRPC Port | Proto File |
|---------|-----------|------------|
| User Service | 9081 | `user_service.proto` |
| Account Service | 9082 | `account_service.proto` |
| Transaction Service | 9083 | `transaction_service.proto` |
| Notification Service | 9085 | `notification_service.proto` |

### Example gRPC Methods

```protobuf
// Account Service
service AccountService {
    rpc GetAccount(GetAccountRequest) returns (AccountResponse);
    rpc GetBalance(GetBalanceRequest) returns (BalanceResponse);
    rpc UpdateBalance(UpdateBalanceRequest) returns (UpdateBalanceResponse);
    rpc ValidateAccount(ValidateAccountRequest) returns (ValidateAccountResponse);
}

// Transaction Service
service TransactionService {
    rpc CreateTransfer(CreateTransferRequest) returns (TransactionCreatedResponse);
    rpc GetTransaction(GetTransactionRequest) returns (TransactionResponse);
    rpc ValidateTransaction(ValidateTransactionRequest) returns (ValidateTransactionResponse);
}
```

## 🏃 Quick Start

### Prerequisites

- Java 21
- Maven 3.9+
- Docker & Docker Compose
- PostgreSQL (or use Docker)
- Redis (or use Docker)

### Environment Variables

Create a `.env` file in the `backend` directory:

```env
# Database
DB_USERNAME=postgres
DB_PASSWORD=postgres

# Redis
REDIS_PASSWORD=redis-secret

# JWT
JWT_SECRET=your-256-bit-secret-key-for-jwt-signing-must-be-at-least-256-bits

# Anthropic AI
ANTHROPIC_API_KEY=your-anthropic-api-key

# Email (Optional)
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=your-email@gmail.com
MAIL_PASSWORD=your-app-password

# Twilio (Optional)
TWILIO_ACCOUNT_SID=your-twilio-sid
TWILIO_AUTH_TOKEN=your-twilio-token
TWILIO_PHONE_NUMBER=+1234567890

# Firebase (Optional)
FIREBASE_CREDENTIALS_PATH=/path/to/firebase-credentials.json
```

### Running with Docker Compose

```bash
# Start all services
cd backend
docker-compose up -d

# Check service status
docker-compose ps

# View logs
docker-compose logs -f [service-name]

# Stop all services
docker-compose down
```

### Running Locally

```bash
# Build all modules
mvn clean install -DskipTests

# Start infrastructure services first
docker-compose up -d postgres redis kafka rabbitmq

# Start Discovery Service
cd discovery-service && mvn spring-boot:run

# Start Config Service
cd config-service && mvn spring-boot:run

# Start other services
cd user-service && mvn spring-boot:run
cd account-service && mvn spring-boot:run
cd transaction-service && mvn spring-boot:run
cd ai-agent-service && mvn spring-boot:run
cd notification-service && mvn spring-boot:run
cd analytics-service && mvn spring-boot:run

# Start API Gateway
cd api-gateway && mvn spring-boot:run
```

## 📡 API Documentation

Once running, access Swagger UI:

- **API Gateway**: http://localhost:8080/swagger-ui.html
- **User Service**: http://localhost:8081/swagger-ui.html
- **Account Service**: http://localhost:8082/swagger-ui.html
- **Transaction Service**: http://localhost:8083/swagger-ui.html
- **Notification Service**: http://localhost:8085/swagger-ui.html

## 🔍 Monitoring

- **Eureka Dashboard**: http://localhost:8761
- **Prometheus**: http://localhost:9090
- **Grafana**: http://localhost:3000 (admin/admin)
- **RabbitMQ Management**: http://localhost:15672 (guest/guest)

## 📊 Health Endpoints

Each service exposes health endpoints:

```bash
# Check service health
curl http://localhost:8081/actuator/health

# Get metrics
curl http://localhost:8081/actuator/metrics

# Prometheus metrics
curl http://localhost:8081/actuator/prometheus
```

## 🧪 Testing

```bash
# Run all tests
mvn test

# Run tests for specific service
mvn test -pl user-service

# Run with coverage
mvn test jacoco:report
```

## 📁 Project Structure

```
backend/
├── api-gateway/           # API Gateway with routing & security
├── config-service/        # Centralized configuration
├── discovery-service/     # Eureka service registry
├── common/               # Shared utilities & encryption
├── user-service/         # User management & auth
├── account-service/      # Account management
├── transaction-service/  # Transaction processing
├── ai-agent-service/     # AI banking assistant
├── notification-service/ # Multi-channel notifications
├── analytics-service/    # Analytics & reporting
├── monitoring/           # Prometheus & Grafana configs
├── scripts/              # Database initialization
├── docker-compose.yml    # Container orchestration
└── pom.xml              # Parent POM
```

## 🔒 Security Considerations

1. **Never commit secrets** to version control
2. Use environment variables for sensitive configuration
3. Enable HTTPS in production
4. Rotate JWT secrets regularly
5. Use strong encryption keys (256-bit minimum)
6. Enable audit logging for sensitive operations

## 📝 License

This project is proprietary software for SibehGoodBank.

## 👥 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request
