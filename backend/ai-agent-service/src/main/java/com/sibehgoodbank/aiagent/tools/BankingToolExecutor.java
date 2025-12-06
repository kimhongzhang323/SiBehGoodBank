package com.sibehgoodbank.aiagent.tools;

import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Executes banking tools called by the AI agent.
 * Makes calls to other microservices to fulfill tool requests.
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class BankingToolExecutor {

    private final WebClient.Builder webClientBuilder;
    private final ObjectMapper objectMapper;
    
    // Service URLs - would be configured via Eureka in production
    private static final String USER_SERVICE_URL = "http://user-service";
    private static final String ACCOUNT_SERVICE_URL = "http://account-service";
    private static final String TRANSACTION_SERVICE_URL = "http://transaction-service";
    
    // Cache for exchange rates (simple in-memory cache)
    private final Map<String, CachedExchangeRate> exchangeRateCache = new ConcurrentHashMap<>();
    
    /**
     * Execute a tool call and return the result
     */
    public Mono<Object> executeTool(String toolName, Map<String, Object> input, UUID userId) {
        log.info("Executing tool: {} for user: {} with input: {}", toolName, userId, input);
        
        return switch (toolName) {
            case BankingToolDefinitions.CHECK_BALANCE -> checkBalance(input, userId);
            case BankingToolDefinitions.GET_TRANSACTIONS -> getTransactions(input, userId);
            case BankingToolDefinitions.TRANSFER_FUNDS -> transferFunds(input, userId);
            case BankingToolDefinitions.GET_ACCOUNT_DETAILS -> getAccountDetails(input, userId);
            case BankingToolDefinitions.LIST_BENEFICIARIES -> listBeneficiaries(input, userId);
            case BankingToolDefinitions.ADD_BENEFICIARY -> addBeneficiary(input, userId);
            case BankingToolDefinitions.GET_EXCHANGE_RATE -> getExchangeRate(input);
            case BankingToolDefinitions.ANALYZE_SPENDING -> analyzeSpending(input, userId);
            case BankingToolDefinitions.GET_CARD_INFO -> getCardInfo(input, userId);
            case BankingToolDefinitions.REPORT_ISSUE -> reportIssue(input, userId);
            case BankingToolDefinitions.SCHEDULE_TRANSFER -> scheduleTransfer(input, userId);
            case BankingToolDefinitions.GET_NOTIFICATIONS -> getNotifications(input, userId);
            default -> Mono.error(new IllegalArgumentException("Unknown tool: " + toolName));
        };
    }
    
    private Mono<Object> checkBalance(Map<String, Object> input, UUID userId) {
        String accountId = (String) input.get("account_id");
        Boolean includePending = (Boolean) input.getOrDefault("include_pending", false);
        
        if (accountId == null) {
            // Return all account balances
            return webClientBuilder.build()
                    .get()
                    .uri(ACCOUNT_SERVICE_URL + "/api/v1/accounts/user/{userId}", userId)
                    .retrieve()
                    .bodyToMono(Object.class)
                    .map(accounts -> {
                        Map<String, Object> result = new HashMap<>();
                        result.put("accounts", accounts);
                        result.put("include_pending", includePending);
                        result.put("retrieved_at", LocalDateTime.now().toString());
                        return result;
                    })
                    .onErrorResume(e -> {
                        log.error("Error fetching balances: {}", e.getMessage());
                        return Mono.just(createMockBalanceResponse(userId));
                    });
        }
        
        return webClientBuilder.build()
                .get()
                .uri(ACCOUNT_SERVICE_URL + "/api/v1/accounts/{accountId}/balance?includePending={includePending}",
                        accountId, includePending)
                .retrieve()
                .bodyToMono(Object.class)
                .onErrorResume(e -> {
                    log.error("Error fetching balance for account {}: {}", accountId, e.getMessage());
                    return Mono.just(createMockBalanceForAccount(accountId));
                });
    }
    
    private Mono<Object> getTransactions(Map<String, Object> input, UUID userId) {
        String accountId = (String) input.get("account_id");
        String startDate = (String) input.get("start_date");
        String endDate = (String) input.get("end_date");
        String transactionType = (String) input.get("transaction_type");
        Integer limit = (Integer) input.getOrDefault("limit", 20);
        
        StringBuilder uriBuilder = new StringBuilder(TRANSACTION_SERVICE_URL + "/api/v1/transactions?");
        List<String> params = new ArrayList<>();
        
        if (accountId != null) params.add("accountId=" + accountId);
        if (startDate != null) params.add("startDate=" + startDate);
        if (endDate != null) params.add("endDate=" + endDate);
        if (transactionType != null) params.add("type=" + transactionType);
        params.add("limit=" + limit);
        params.add("userId=" + userId);
        
        uriBuilder.append(String.join("&", params));
        
        return webClientBuilder.build()
                .get()
                .uri(uriBuilder.toString())
                .retrieve()
                .bodyToMono(Object.class)
                .onErrorResume(e -> {
                    log.error("Error fetching transactions: {}", e.getMessage());
                    return Mono.just(createMockTransactions(limit));
                });
    }
    
    private Mono<Object> transferFunds(Map<String, Object> input, UUID userId) {
        String fromAccountId = (String) input.get("from_account_id");
        String toAccountId = (String) input.get("to_account_id");
        Number amountNum = (Number) input.get("amount");
        BigDecimal amount = new BigDecimal(amountNum.toString());
        String currency = (String) input.getOrDefault("currency", "SGD");
        String description = (String) input.get("description");
        String transferType = (String) input.getOrDefault("transfer_type", "INTERNAL");
        
        // Check if amount requires additional confirmation
        if (amount.compareTo(new BigDecimal("1000")) > 0) {
            Map<String, Object> confirmationRequired = new HashMap<>();
            confirmationRequired.put("requires_confirmation", true);
            confirmationRequired.put("amount", amount);
            confirmationRequired.put("currency", currency);
            confirmationRequired.put("from_account", fromAccountId);
            confirmationRequired.put("to_account", toAccountId);
            confirmationRequired.put("message", "Transfer amount exceeds $1000. Please confirm this transaction.");
            confirmationRequired.put("confirmation_token", UUID.randomUUID().toString());
            return Mono.just(confirmationRequired);
        }
        
        Map<String, Object> transferRequest = new HashMap<>();
        transferRequest.put("sourceAccountId", fromAccountId);
        transferRequest.put("destinationAccountId", toAccountId);
        transferRequest.put("amount", amount);
        transferRequest.put("currency", currency);
        transferRequest.put("description", description);
        transferRequest.put("transferType", transferType);
        transferRequest.put("initiatedBy", userId.toString());
        
        return webClientBuilder.build()
                .post()
                .uri(TRANSACTION_SERVICE_URL + "/api/v1/transactions")
                .bodyValue(transferRequest)
                .retrieve()
                .bodyToMono(Object.class)
                .onErrorResume(e -> {
                    log.error("Error executing transfer: {}", e.getMessage());
                    return Mono.just(createMockTransferResponse(fromAccountId, toAccountId, amount, currency));
                });
    }
    
    private Mono<Object> getAccountDetails(Map<String, Object> input, UUID userId) {
        String accountId = (String) input.get("account_id");
        
        return webClientBuilder.build()
                .get()
                .uri(ACCOUNT_SERVICE_URL + "/api/v1/accounts/{accountId}", accountId)
                .retrieve()
                .bodyToMono(Object.class)
                .onErrorResume(e -> {
                    log.error("Error fetching account details: {}", e.getMessage());
                    return Mono.just(createMockAccountDetails(accountId));
                });
    }
    
    private Mono<Object> listBeneficiaries(Map<String, Object> input, UUID userId) {
        String bankFilter = (String) input.get("bank_filter");
        
        String uri = ACCOUNT_SERVICE_URL + "/api/v1/beneficiaries/user/" + userId;
        if (bankFilter != null) {
            uri += "?bankFilter=" + bankFilter;
        }
        
        return webClientBuilder.build()
                .get()
                .uri(uri)
                .retrieve()
                .bodyToMono(Object.class)
                .onErrorResume(e -> {
                    log.error("Error fetching beneficiaries: {}", e.getMessage());
                    return Mono.just(createMockBeneficiaries());
                });
    }
    
    private Mono<Object> addBeneficiary(Map<String, Object> input, UUID userId) {
        Map<String, Object> beneficiaryRequest = new HashMap<>();
        beneficiaryRequest.put("name", input.get("name"));
        beneficiaryRequest.put("bankCode", input.get("bank_code"));
        beneficiaryRequest.put("accountNumber", input.get("account_number"));
        beneficiaryRequest.put("nickname", input.get("nickname"));
        beneficiaryRequest.put("dailyTransferLimit", input.get("transfer_limit"));
        beneficiaryRequest.put("userId", userId.toString());
        
        // This operation requires OTP verification
        Map<String, Object> otpRequired = new HashMap<>();
        otpRequired.put("requires_otp", true);
        otpRequired.put("beneficiary_details", beneficiaryRequest);
        otpRequired.put("message", "Adding a new beneficiary requires OTP verification. An OTP has been sent to your registered mobile number.");
        otpRequired.put("otp_reference", UUID.randomUUID().toString());
        otpRequired.put("expires_in_seconds", 300);
        
        return Mono.just(otpRequired);
    }
    
    private Mono<Object> getExchangeRate(Map<String, Object> input) {
        String fromCurrency = (String) input.get("from_currency");
        String toCurrency = (String) input.get("to_currency");
        Number amountNum = (Number) input.get("amount");
        
        String cacheKey = fromCurrency + "_" + toCurrency;
        CachedExchangeRate cached = exchangeRateCache.get(cacheKey);
        
        // Use cached rate if available and fresh (less than 5 minutes old)
        if (cached != null && cached.isValid()) {
            return Mono.just(buildExchangeRateResponse(fromCurrency, toCurrency, cached.rate, amountNum));
        }
        
        // Mock exchange rates - in production, would call external forex API
        BigDecimal rate = getMockExchangeRate(fromCurrency, toCurrency);
        exchangeRateCache.put(cacheKey, new CachedExchangeRate(rate, LocalDateTime.now()));
        
        return Mono.just(buildExchangeRateResponse(fromCurrency, toCurrency, rate, amountNum));
    }
    
    private Map<String, Object> buildExchangeRateResponse(String from, String to, BigDecimal rate, Number amount) {
        Map<String, Object> response = new HashMap<>();
        response.put("from_currency", from);
        response.put("to_currency", to);
        response.put("exchange_rate", rate);
        response.put("rate_timestamp", LocalDateTime.now().toString());
        response.put("rate_source", "SibehGoodBank Forex");
        
        if (amount != null) {
            BigDecimal amountBd = new BigDecimal(amount.toString());
            BigDecimal converted = amountBd.multiply(rate).setScale(2, RoundingMode.HALF_UP);
            response.put("original_amount", amount);
            response.put("converted_amount", converted);
        }
        
        return response;
    }
    
    private BigDecimal getMockExchangeRate(String from, String to) {
        // Mock exchange rates based on SGD
        Map<String, BigDecimal> ratesFromSGD = new HashMap<>();
        ratesFromSGD.put("USD", new BigDecimal("0.74"));
        ratesFromSGD.put("EUR", new BigDecimal("0.68"));
        ratesFromSGD.put("GBP", new BigDecimal("0.58"));
        ratesFromSGD.put("JPY", new BigDecimal("110.50"));
        ratesFromSGD.put("MYR", new BigDecimal("3.47"));
        ratesFromSGD.put("CNY", new BigDecimal("5.35"));
        ratesFromSGD.put("AUD", new BigDecimal("1.12"));
        ratesFromSGD.put("SGD", BigDecimal.ONE);
        
        if (from.equals(to)) {
            return BigDecimal.ONE;
        }
        
        BigDecimal fromRate = ratesFromSGD.getOrDefault(from, BigDecimal.ONE);
        BigDecimal toRate = ratesFromSGD.getOrDefault(to, BigDecimal.ONE);
        
        return toRate.divide(fromRate, 6, RoundingMode.HALF_UP);
    }
    
    private Mono<Object> analyzeSpending(Map<String, Object> input, UUID userId) {
        String accountId = (String) input.get("account_id");
        String period = (String) input.getOrDefault("period", "MONTH");
        String groupBy = (String) input.getOrDefault("group_by", "CATEGORY");
        Boolean includeInsights = (Boolean) input.getOrDefault("include_insights", true);
        
        // Mock spending analysis
        Map<String, Object> analysis = new HashMap<>();
        analysis.put("account_id", accountId);
        analysis.put("period", period);
        analysis.put("group_by", groupBy);
        analysis.put("analysis_date", LocalDateTime.now().toString());
        
        // Category breakdown
        List<Map<String, Object>> categories = new ArrayList<>();
        categories.add(createCategorySpend("Food & Dining", 850.00, 28.3));
        categories.add(createCategorySpend("Transportation", 420.00, 14.0));
        categories.add(createCategorySpend("Shopping", 620.00, 20.7));
        categories.add(createCategorySpend("Bills & Utilities", 380.00, 12.7));
        categories.add(createCategorySpend("Entertainment", 280.00, 9.3));
        categories.add(createCategorySpend("Health & Fitness", 150.00, 5.0));
        categories.add(createCategorySpend("Others", 300.00, 10.0));
        
        analysis.put("spending_breakdown", categories);
        analysis.put("total_spending", 3000.00);
        analysis.put("average_daily_spending", 100.00);
        
        if (includeInsights) {
            List<String> insights = new ArrayList<>();
            insights.add("Your food & dining expenses are 15% higher than last month.");
            insights.add("Great job! Your entertainment spending is down by 20%.");
            insights.add("Consider setting a budget for shopping - it's your second highest category.");
            insights.add("You have 3 recurring subscriptions totaling $45.90/month.");
            analysis.put("insights", insights);
        }
        
        return Mono.just(analysis);
    }
    
    private Map<String, Object> createCategorySpend(String category, double amount, double percentage) {
        Map<String, Object> cat = new HashMap<>();
        cat.put("category", category);
        cat.put("amount", amount);
        cat.put("percentage", percentage);
        cat.put("currency", "SGD");
        return cat;
    }
    
    private Mono<Object> getCardInfo(Map<String, Object> input, UUID userId) {
        String cardId = (String) input.get("card_id");
        Boolean includeTransactions = (Boolean) input.getOrDefault("include_transactions", false);
        
        // Mock card info
        List<Map<String, Object>> cards = new ArrayList<>();
        
        Map<String, Object> card1 = new HashMap<>();
        card1.put("card_id", "CARD-001");
        card1.put("card_type", "DEBIT");
        card1.put("card_number_masked", "**** **** **** 1234");
        card1.put("card_network", "VISA");
        card1.put("status", "ACTIVE");
        card1.put("expiry_date", "12/26");
        card1.put("daily_limit", 5000.00);
        card1.put("available_limit", 4250.00);
        cards.add(card1);
        
        Map<String, Object> card2 = new HashMap<>();
        card2.put("card_id", "CARD-002");
        card2.put("card_type", "CREDIT");
        card2.put("card_number_masked", "**** **** **** 5678");
        card2.put("card_network", "MASTERCARD");
        card2.put("status", "ACTIVE");
        card2.put("expiry_date", "08/27");
        card2.put("credit_limit", 15000.00);
        card2.put("available_credit", 12500.00);
        card2.put("outstanding_balance", 2500.00);
        card2.put("minimum_payment", 50.00);
        card2.put("payment_due_date", LocalDate.now().plusDays(15).toString());
        cards.add(card2);
        
        Map<String, Object> response = new HashMap<>();
        
        if (cardId != null) {
            response.put("card", cards.stream()
                    .filter(c -> cardId.equals(c.get("card_id")))
                    .findFirst()
                    .orElse(cards.get(0)));
        } else {
            response.put("cards", cards);
        }
        
        if (includeTransactions) {
            response.put("recent_transactions", createMockTransactions(5));
        }
        
        return Mono.just(response);
    }
    
    private Mono<Object> reportIssue(Map<String, Object> input, UUID userId) {
        String issueType = (String) input.get("issue_type");
        String description = (String) input.get("description");
        String relatedTransactionId = (String) input.get("related_transaction_id");
        String priority = (String) input.getOrDefault("priority", "MEDIUM");
        
        // Create support ticket
        Map<String, Object> ticket = new HashMap<>();
        ticket.put("ticket_id", "TKT-" + System.currentTimeMillis());
        ticket.put("issue_type", issueType);
        ticket.put("description", description);
        ticket.put("priority", priority);
        ticket.put("status", "OPEN");
        ticket.put("created_at", LocalDateTime.now().toString());
        ticket.put("user_id", userId.toString());
        
        if (relatedTransactionId != null) {
            ticket.put("related_transaction_id", relatedTransactionId);
        }
        
        // Set expected response time based on priority and issue type
        String expectedResponse;
        if ("URGENT".equals(priority) || "FRAUD".equals(issueType) || "UNAUTHORIZED_TRANSACTION".equals(issueType)) {
            expectedResponse = "Within 2 hours";
            ticket.put("escalated", true);
        } else if ("HIGH".equals(priority) || "CARD_LOST".equals(issueType)) {
            expectedResponse = "Within 4 hours";
        } else if ("MEDIUM".equals(priority)) {
            expectedResponse = "Within 24 hours";
        } else {
            expectedResponse = "Within 48 hours";
        }
        
        ticket.put("expected_response", expectedResponse);
        ticket.put("message", "Your issue has been reported successfully. Our support team will contact you shortly.");
        
        // For fraud/security issues, add immediate actions taken
        if ("FRAUD".equals(issueType) || "UNAUTHORIZED_TRANSACTION".equals(issueType) || "CARD_LOST".equals(issueType)) {
            List<String> immediateActions = new ArrayList<>();
            immediateActions.add("Your account has been flagged for monitoring.");
            immediateActions.add("Suspicious activity alerts have been enabled.");
            if ("CARD_LOST".equals(issueType)) {
                immediateActions.add("Your card has been temporarily blocked. You can unblock it via the app once found.");
            }
            ticket.put("immediate_actions", immediateActions);
        }
        
        return Mono.just(ticket);
    }
    
    private Mono<Object> scheduleTransfer(Map<String, Object> input, UUID userId) {
        String fromAccountId = (String) input.get("from_account_id");
        String toAccountId = (String) input.get("to_account_id");
        Number amountNum = (Number) input.get("amount");
        BigDecimal amount = new BigDecimal(amountNum.toString());
        String scheduledDate = (String) input.get("scheduled_date");
        Boolean recurring = (Boolean) input.getOrDefault("recurring", false);
        String frequency = (String) input.get("frequency");
        String endDate = (String) input.get("end_date");
        
        Map<String, Object> scheduledTransfer = new HashMap<>();
        scheduledTransfer.put("schedule_id", "SCH-" + System.currentTimeMillis());
        scheduledTransfer.put("from_account", fromAccountId);
        scheduledTransfer.put("to_account", toAccountId);
        scheduledTransfer.put("amount", amount);
        scheduledTransfer.put("currency", "SGD");
        scheduledTransfer.put("scheduled_date", scheduledDate);
        scheduledTransfer.put("status", "SCHEDULED");
        scheduledTransfer.put("created_at", LocalDateTime.now().toString());
        
        if (recurring) {
            scheduledTransfer.put("recurring", true);
            scheduledTransfer.put("frequency", frequency);
            if (endDate != null) {
                scheduledTransfer.put("end_date", endDate);
            }
            scheduledTransfer.put("message", String.format("Recurring transfer of SGD %.2f scheduled %s starting %s",
                    amount, frequency.toLowerCase(), scheduledDate));
        } else {
            scheduledTransfer.put("recurring", false);
            scheduledTransfer.put("message", String.format("Transfer of SGD %.2f scheduled for %s", amount, scheduledDate));
        }
        
        return Mono.just(scheduledTransfer);
    }
    
    private Mono<Object> getNotifications(Map<String, Object> input, UUID userId) {
        Boolean unreadOnly = (Boolean) input.getOrDefault("unread_only", false);
        String notificationType = (String) input.get("notification_type");
        Integer limit = (Integer) input.getOrDefault("limit", 10);
        
        List<Map<String, Object>> notifications = new ArrayList<>();
        
        notifications.add(createNotification("TRANSACTION", "Payment received",
                "You received SGD 1,500.00 from John Doe", false, LocalDateTime.now().minusHours(2)));
        notifications.add(createNotification("SECURITY", "New device login",
                "New login detected from iPhone 15 Pro in Singapore", true, LocalDateTime.now().minusHours(5)));
        notifications.add(createNotification("ACCOUNT_UPDATE", "Statement ready",
                "Your November 2024 statement is ready to view", true, LocalDateTime.now().minusDays(1)));
        notifications.add(createNotification("PROMOTION", "Exclusive offer",
                "Get 5% cashback on all dining transactions this weekend!", true, LocalDateTime.now().minusDays(2)));
        notifications.add(createNotification("ALERT", "Low balance alert",
                "Your Savings Account balance is below SGD 500", false, LocalDateTime.now().minusDays(3)));
        
        // Apply filters
        List<Map<String, Object>> filtered = notifications.stream()
                .filter(n -> !unreadOnly || (Boolean) n.get("unread"))
                .filter(n -> notificationType == null || notificationType.equals(n.get("type")))
                .limit(limit)
                .toList();
        
        Map<String, Object> response = new HashMap<>();
        response.put("notifications", filtered);
        response.put("total_unread", notifications.stream().filter(n -> (Boolean) n.get("unread")).count());
        response.put("retrieved_at", LocalDateTime.now().toString());
        
        return Mono.just(response);
    }
    
    private Map<String, Object> createNotification(String type, String title, String message,
                                                    boolean unread, LocalDateTime timestamp) {
        Map<String, Object> notification = new HashMap<>();
        notification.put("id", UUID.randomUUID().toString());
        notification.put("type", type);
        notification.put("title", title);
        notification.put("message", message);
        notification.put("unread", unread);
        notification.put("timestamp", timestamp.toString());
        return notification;
    }
    
    // Mock data generators for fallback scenarios
    private Map<String, Object> createMockBalanceResponse(UUID userId) {
        List<Map<String, Object>> accounts = new ArrayList<>();
        
        Map<String, Object> savings = new HashMap<>();
        savings.put("account_id", "ACC-SAV-001");
        savings.put("account_type", "SAVINGS");
        savings.put("account_name", "Premier Savings");
        savings.put("available_balance", 15420.50);
        savings.put("total_balance", 15620.50);
        savings.put("currency", "SGD");
        savings.put("pending_amount", 200.00);
        accounts.add(savings);
        
        Map<String, Object> current = new HashMap<>();
        current.put("account_id", "ACC-CUR-001");
        current.put("account_type", "CURRENT");
        current.put("account_name", "Current Account");
        current.put("available_balance", 8750.00);
        current.put("total_balance", 8750.00);
        current.put("currency", "SGD");
        current.put("pending_amount", 0.00);
        accounts.add(current);
        
        Map<String, Object> result = new HashMap<>();
        result.put("accounts", accounts);
        result.put("total_balance_sgd", 24170.50);
        result.put("retrieved_at", LocalDateTime.now().toString());
        
        return result;
    }
    
    private Map<String, Object> createMockBalanceForAccount(String accountId) {
        Map<String, Object> balance = new HashMap<>();
        balance.put("account_id", accountId);
        balance.put("available_balance", 15420.50);
        balance.put("total_balance", 15620.50);
        balance.put("currency", "SGD");
        balance.put("pending_transactions", 1);
        balance.put("pending_amount", 200.00);
        balance.put("as_of", LocalDateTime.now().toString());
        return balance;
    }
    
    private Map<String, Object> createMockTransferResponse(String from, String to, BigDecimal amount, String currency) {
        Map<String, Object> response = new HashMap<>();
        response.put("transaction_id", "TXN-" + System.currentTimeMillis());
        response.put("status", "COMPLETED");
        response.put("from_account", from);
        response.put("to_account", to);
        response.put("amount", amount);
        response.put("currency", currency);
        response.put("timestamp", LocalDateTime.now().toString());
        response.put("reference", "REF" + System.currentTimeMillis());
        response.put("message", String.format("Successfully transferred %s %.2f", currency, amount));
        return response;
    }
    
    private Map<String, Object> createMockAccountDetails(String accountId) {
        Map<String, Object> details = new HashMap<>();
        details.put("account_id", accountId);
        details.put("account_type", "SAVINGS");
        details.put("account_name", "Premier Savings Account");
        details.put("account_number_masked", "**** **** 1234");
        details.put("status", "ACTIVE");
        details.put("currency", "SGD");
        details.put("interest_rate", 2.5);
        details.put("opened_date", "2023-01-15");
        details.put("daily_transfer_limit", 50000.00);
        details.put("monthly_transfer_limit", 200000.00);
        details.put("remaining_daily_limit", 45000.00);
        return details;
    }
    
    private List<Map<String, Object>> createMockBeneficiaries() {
        List<Map<String, Object>> beneficiaries = new ArrayList<>();
        
        Map<String, Object> ben1 = new HashMap<>();
        ben1.put("id", "BEN-001");
        ben1.put("name", "Jane Smith");
        ben1.put("nickname", "Jane");
        ben1.put("bank", "DBS Bank");
        ben1.put("account_number_masked", "**** **** 5678");
        ben1.put("daily_limit", 10000.00);
        beneficiaries.add(ben1);
        
        Map<String, Object> ben2 = new HashMap<>();
        ben2.put("id", "BEN-002");
        ben2.put("name", "ACME Corp");
        ben2.put("nickname", "ACME");
        ben2.put("bank", "OCBC Bank");
        ben2.put("account_number_masked", "**** **** 9012");
        ben2.put("daily_limit", 50000.00);
        beneficiaries.add(ben2);
        
        return beneficiaries;
    }
    
    private List<Map<String, Object>> createMockTransactions(int limit) {
        List<Map<String, Object>> transactions = new ArrayList<>();
        LocalDateTime now = LocalDateTime.now();
        
        String[] descriptions = {
                "PayNow Transfer to John",
                "GRAB Ride",
                "NTUC FairPrice",
                "Salary Credit",
                "Netflix Subscription",
                "Coffee Bean",
                "Electricity Bill",
                "ATM Withdrawal"
        };
        
        String[] types = {"TRANSFER", "PAYMENT", "PAYMENT", "DEPOSIT", "PAYMENT", "PAYMENT", "PAYMENT", "WITHDRAWAL"};
        double[] amounts = {-500.00, -15.50, -85.30, 5500.00, -15.98, -8.50, -120.00, -200.00};
        
        for (int i = 0; i < Math.min(limit, descriptions.length); i++) {
            Map<String, Object> txn = new HashMap<>();
            txn.put("transaction_id", "TXN-" + (1000 + i));
            txn.put("type", types[i]);
            txn.put("description", descriptions[i]);
            txn.put("amount", amounts[i]);
            txn.put("currency", "SGD");
            txn.put("status", "COMPLETED");
            txn.put("timestamp", now.minusDays(i).format(DateTimeFormatter.ISO_LOCAL_DATE_TIME));
            txn.put("category", i % 2 == 0 ? "Transfer" : "Shopping");
            transactions.add(txn);
        }
        
        return transactions;
    }
    
    // Inner class for caching exchange rates
    private static class CachedExchangeRate {
        final BigDecimal rate;
        final LocalDateTime timestamp;
        
        CachedExchangeRate(BigDecimal rate, LocalDateTime timestamp) {
            this.rate = rate;
            this.timestamp = timestamp;
        }
        
        boolean isValid() {
            return timestamp.plusMinutes(5).isAfter(LocalDateTime.now());
        }
    }
}
