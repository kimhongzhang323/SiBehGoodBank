package com.sibehgoodbank.aiagent.tools;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;
import java.util.Map;

/**
 * Defines all banking tools available to the AI agent.
 * These tools are used by Claude to execute banking operations.
 */
public class BankingToolDefinitions {

    // Tool names as constants
    public static final String CHECK_BALANCE = "check_balance";
    public static final String GET_TRANSACTIONS = "get_transactions";
    public static final String TRANSFER_FUNDS = "transfer_funds";
    public static final String GET_ACCOUNT_DETAILS = "get_account_details";
    public static final String LIST_BENEFICIARIES = "list_beneficiaries";
    public static final String ADD_BENEFICIARY = "add_beneficiary";
    public static final String GET_EXCHANGE_RATE = "get_exchange_rate";
    public static final String ANALYZE_SPENDING = "analyze_spending";
    public static final String GET_CARD_INFO = "get_card_info";
    public static final String REPORT_ISSUE = "report_issue";
    public static final String SCHEDULE_TRANSFER = "schedule_transfer";
    public static final String GET_NOTIFICATIONS = "get_notifications";

    /**
     * Tool definition for Anthropic API
     */
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ToolDefinition {
        private String name;
        private String description;
        private InputSchema inputSchema;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class InputSchema {
        private String type;
        private Map<String, PropertyDefinition> properties;
        private List<String> required;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class PropertyDefinition {
        private String type;
        private String description;
        @Builder.Default
        private List<String> enumValues = null;
    }

    /**
     * Returns all available banking tools for the AI agent
     */
    public static List<ToolDefinition> getAllTools() {
        return List.of(
                buildCheckBalanceTool(),
                buildGetTransactionsTool(),
                buildTransferFundsTool(),
                buildGetAccountDetailsTool(),
                buildListBeneficiariesTool(),
                buildAddBeneficiaryTool(),
                buildGetExchangeRateTool(),
                buildAnalyzeSpendingTool(),
                buildGetCardInfoTool(),
                buildReportIssueTool(),
                buildScheduleTransferTool(),
                buildGetNotificationsTool()
        );
    }

    private static ToolDefinition buildCheckBalanceTool() {
        return ToolDefinition.builder()
                .name(CHECK_BALANCE)
                .description("Check the current balance of a specific account. Returns available balance, total balance, and currency.")
                .inputSchema(InputSchema.builder()
                        .type("object")
                        .properties(Map.of(
                                "account_id", PropertyDefinition.builder()
                                        .type("string")
                                        .description("The unique identifier of the account to check balance for. If not provided, returns all account balances.")
                                        .build(),
                                "include_pending", PropertyDefinition.builder()
                                        .type("boolean")
                                        .description("Whether to include pending transactions in the balance calculation. Default is false.")
                                        .build()
                        ))
                        .required(List.of())
                        .build())
                .build();
    }

    private static ToolDefinition buildGetTransactionsTool() {
        return ToolDefinition.builder()
                .name(GET_TRANSACTIONS)
                .description("Retrieve transaction history for an account. Can filter by date range, amount, type, and category.")
                .inputSchema(InputSchema.builder()
                        .type("object")
                        .properties(Map.of(
                                "account_id", PropertyDefinition.builder()
                                        .type("string")
                                        .description("The account ID to get transactions for.")
                                        .build(),
                                "start_date", PropertyDefinition.builder()
                                        .type("string")
                                        .description("Start date for transaction filter in ISO 8601 format (YYYY-MM-DD).")
                                        .build(),
                                "end_date", PropertyDefinition.builder()
                                        .type("string")
                                        .description("End date for transaction filter in ISO 8601 format (YYYY-MM-DD).")
                                        .build(),
                                "transaction_type", PropertyDefinition.builder()
                                        .type("string")
                                        .description("Filter by transaction type.")
                                        .enumValues(List.of("DEPOSIT", "WITHDRAWAL", "TRANSFER", "PAYMENT", "FEE", "INTEREST", "REFUND"))
                                        .build(),
                                "limit", PropertyDefinition.builder()
                                        .type("integer")
                                        .description("Maximum number of transactions to return. Default is 20.")
                                        .build()
                        ))
                        .required(List.of())
                        .build())
                .build();
    }

    private static ToolDefinition buildTransferFundsTool() {
        return ToolDefinition.builder()
                .name(TRANSFER_FUNDS)
                .description("Transfer funds from one account to another. Requires user confirmation for amounts over $1000.")
                .inputSchema(InputSchema.builder()
                        .type("object")
                        .properties(Map.of(
                                "from_account_id", PropertyDefinition.builder()
                                        .type("string")
                                        .description("The source account ID to transfer from.")
                                        .build(),
                                "to_account_id", PropertyDefinition.builder()
                                        .type("string")
                                        .description("The destination account ID to transfer to. Can be internal account or beneficiary ID.")
                                        .build(),
                                "amount", PropertyDefinition.builder()
                                        .type("number")
                                        .description("The amount to transfer in the source account's currency.")
                                        .build(),
                                "currency", PropertyDefinition.builder()
                                        .type("string")
                                        .description("The currency code (ISO 4217) for the transfer. Default is SGD.")
                                        .build(),
                                "description", PropertyDefinition.builder()
                                        .type("string")
                                        .description("A description or reference for the transfer.")
                                        .build(),
                                "transfer_type", PropertyDefinition.builder()
                                        .type("string")
                                        .description("Type of transfer.")
                                        .enumValues(List.of("INTERNAL", "DOMESTIC", "INTERNATIONAL"))
                                        .build()
                        ))
                        .required(List.of("from_account_id", "to_account_id", "amount"))
                        .build())
                .build();
    }

    private static ToolDefinition buildGetAccountDetailsTool() {
        return ToolDefinition.builder()
                .name(GET_ACCOUNT_DETAILS)
                .description("Get detailed information about an account including account type, status, interest rate, and limits.")
                .inputSchema(InputSchema.builder()
                        .type("object")
                        .properties(Map.of(
                                "account_id", PropertyDefinition.builder()
                                        .type("string")
                                        .description("The account ID to get details for.")
                                        .build()
                        ))
                        .required(List.of("account_id"))
                        .build())
                .build();
    }

    private static ToolDefinition buildListBeneficiariesTool() {
        return ToolDefinition.builder()
                .name(LIST_BENEFICIARIES)
                .description("List all saved beneficiaries for the user. Returns name, bank, account number (masked), and nickname.")
                .inputSchema(InputSchema.builder()
                        .type("object")
                        .properties(Map.of(
                                "bank_filter", PropertyDefinition.builder()
                                        .type("string")
                                        .description("Optional filter to show only beneficiaries from a specific bank.")
                                        .build()
                        ))
                        .required(List.of())
                        .build())
                .build();
    }

    private static ToolDefinition buildAddBeneficiaryTool() {
        return ToolDefinition.builder()
                .name(ADD_BENEFICIARY)
                .description("Add a new beneficiary for future transfers. Requires verification via OTP.")
                .inputSchema(InputSchema.builder()
                        .type("object")
                        .properties(Map.of(
                                "name", PropertyDefinition.builder()
                                        .type("string")
                                        .description("Full name of the beneficiary as it appears on their account.")
                                        .build(),
                                "bank_code", PropertyDefinition.builder()
                                        .type("string")
                                        .description("The bank code or SWIFT code of the beneficiary's bank.")
                                        .build(),
                                "account_number", PropertyDefinition.builder()
                                        .type("string")
                                        .description("The beneficiary's account number.")
                                        .build(),
                                "nickname", PropertyDefinition.builder()
                                        .type("string")
                                        .description("A friendly nickname for the beneficiary for easy identification.")
                                        .build(),
                                "transfer_limit", PropertyDefinition.builder()
                                        .type("number")
                                        .description("Daily transfer limit for this beneficiary.")
                                        .build()
                        ))
                        .required(List.of("name", "bank_code", "account_number"))
                        .build())
                .build();
    }

    private static ToolDefinition buildGetExchangeRateTool() {
        return ToolDefinition.builder()
                .name(GET_EXCHANGE_RATE)
                .description("Get current exchange rates between currencies.")
                .inputSchema(InputSchema.builder()
                        .type("object")
                        .properties(Map.of(
                                "from_currency", PropertyDefinition.builder()
                                        .type("string")
                                        .description("Source currency code (ISO 4217), e.g., SGD, USD, EUR.")
                                        .build(),
                                "to_currency", PropertyDefinition.builder()
                                        .type("string")
                                        .description("Target currency code (ISO 4217).")
                                        .build(),
                                "amount", PropertyDefinition.builder()
                                        .type("number")
                                        .description("Optional amount to convert. If provided, returns the converted amount.")
                                        .build()
                        ))
                        .required(List.of("from_currency", "to_currency"))
                        .build())
                .build();
    }

    private static ToolDefinition buildAnalyzeSpendingTool() {
        return ToolDefinition.builder()
                .name(ANALYZE_SPENDING)
                .description("Analyze spending patterns and provide insights. Can group by category, merchant, or time period.")
                .inputSchema(InputSchema.builder()
                        .type("object")
                        .properties(Map.of(
                                "account_id", PropertyDefinition.builder()
                                        .type("string")
                                        .description("The account ID to analyze spending for.")
                                        .build(),
                                "period", PropertyDefinition.builder()
                                        .type("string")
                                        .description("Time period for analysis.")
                                        .enumValues(List.of("WEEK", "MONTH", "QUARTER", "YEAR"))
                                        .build(),
                                "group_by", PropertyDefinition.builder()
                                        .type("string")
                                        .description("How to group the spending data.")
                                        .enumValues(List.of("CATEGORY", "MERCHANT", "DAY", "WEEK", "MONTH"))
                                        .build(),
                                "include_insights", PropertyDefinition.builder()
                                        .type("boolean")
                                        .description("Whether to include AI-generated insights. Default is true.")
                                        .build()
                        ))
                        .required(List.of())
                        .build())
                .build();
    }

    private static ToolDefinition buildGetCardInfoTool() {
        return ToolDefinition.builder()
                .name(GET_CARD_INFO)
                .description("Get information about linked cards including type, status, limits, and expiry date.")
                .inputSchema(InputSchema.builder()
                        .type("object")
                        .properties(Map.of(
                                "card_id", PropertyDefinition.builder()
                                        .type("string")
                                        .description("Specific card ID to get info for. If not provided, returns all cards.")
                                        .build(),
                                "include_transactions", PropertyDefinition.builder()
                                        .type("boolean")
                                        .description("Whether to include recent card transactions. Default is false.")
                                        .build()
                        ))
                        .required(List.of())
                        .build())
                .build();
    }

    private static ToolDefinition buildReportIssueTool() {
        return ToolDefinition.builder()
                .name(REPORT_ISSUE)
                .description("Report an issue or problem to customer support. Creates a support ticket.")
                .inputSchema(InputSchema.builder()
                        .type("object")
                        .properties(Map.of(
                                "issue_type", PropertyDefinition.builder()
                                        .type("string")
                                        .description("Type of issue being reported.")
                                        .enumValues(List.of("FRAUD", "UNAUTHORIZED_TRANSACTION", "CARD_LOST", "ACCOUNT_ACCESS", "TECHNICAL", "OTHER"))
                                        .build(),
                                "description", PropertyDefinition.builder()
                                        .type("string")
                                        .description("Detailed description of the issue.")
                                        .build(),
                                "related_transaction_id", PropertyDefinition.builder()
                                        .type("string")
                                        .description("Transaction ID if the issue is related to a specific transaction.")
                                        .build(),
                                "priority", PropertyDefinition.builder()
                                        .type("string")
                                        .description("Priority level of the issue.")
                                        .enumValues(List.of("LOW", "MEDIUM", "HIGH", "URGENT"))
                                        .build()
                        ))
                        .required(List.of("issue_type", "description"))
                        .build())
                .build();
    }

    private static ToolDefinition buildScheduleTransferTool() {
        return ToolDefinition.builder()
                .name(SCHEDULE_TRANSFER)
                .description("Schedule a future or recurring transfer.")
                .inputSchema(InputSchema.builder()
                        .type("object")
                        .properties(Map.of(
                                "from_account_id", PropertyDefinition.builder()
                                        .type("string")
                                        .description("The source account ID.")
                                        .build(),
                                "to_account_id", PropertyDefinition.builder()
                                        .type("string")
                                        .description("The destination account ID or beneficiary ID.")
                                        .build(),
                                "amount", PropertyDefinition.builder()
                                        .type("number")
                                        .description("The amount to transfer.")
                                        .build(),
                                "scheduled_date", PropertyDefinition.builder()
                                        .type("string")
                                        .description("The date to execute the transfer (ISO 8601 format).")
                                        .build(),
                                "recurring", PropertyDefinition.builder()
                                        .type("boolean")
                                        .description("Whether this is a recurring transfer.")
                                        .build(),
                                "frequency", PropertyDefinition.builder()
                                        .type("string")
                                        .description("Frequency for recurring transfers.")
                                        .enumValues(List.of("DAILY", "WEEKLY", "BIWEEKLY", "MONTHLY", "QUARTERLY"))
                                        .build(),
                                "end_date", PropertyDefinition.builder()
                                        .type("string")
                                        .description("End date for recurring transfers (ISO 8601 format).")
                                        .build()
                        ))
                        .required(List.of("from_account_id", "to_account_id", "amount", "scheduled_date"))
                        .build())
                .build();
    }

    private static ToolDefinition buildGetNotificationsTool() {
        return ToolDefinition.builder()
                .name(GET_NOTIFICATIONS)
                .description("Get user notifications including alerts, promotions, and account updates.")
                .inputSchema(InputSchema.builder()
                        .type("object")
                        .properties(Map.of(
                                "unread_only", PropertyDefinition.builder()
                                        .type("boolean")
                                        .description("Whether to return only unread notifications. Default is false.")
                                        .build(),
                                "notification_type", PropertyDefinition.builder()
                                        .type("string")
                                        .description("Filter by notification type.")
                                        .enumValues(List.of("ALERT", "PROMOTION", "ACCOUNT_UPDATE", "SECURITY", "TRANSACTION"))
                                        .build(),
                                "limit", PropertyDefinition.builder()
                                        .type("integer")
                                        .description("Maximum number of notifications to return. Default is 10.")
                                        .build()
                        ))
                        .required(List.of())
                        .build())
                .build();
    }
}
