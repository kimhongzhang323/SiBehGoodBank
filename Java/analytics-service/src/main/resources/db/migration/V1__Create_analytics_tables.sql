-- V1__Create_analytics_tables.sql

-- Daily analytics table for aggregated metrics
CREATE TABLE IF NOT EXISTS daily_analytics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    analytics_date DATE NOT NULL,
    user_id UUID,
    
    -- Transaction metrics
    total_transaction_volume DECIMAL(19, 4) DEFAULT 0,
    total_transaction_count BIGINT DEFAULT 0,
    successful_transactions BIGINT DEFAULT 0,
    failed_transactions BIGINT DEFAULT 0,
    average_transaction_amount DECIMAL(19, 4) DEFAULT 0,
    
    -- Account metrics
    new_accounts_created BIGINT DEFAULT 0,
    active_accounts BIGINT DEFAULT 0,
    total_deposits DECIMAL(19, 4) DEFAULT 0,
    total_withdrawals DECIMAL(19, 4) DEFAULT 0,
    
    -- User metrics
    new_users_registered BIGINT DEFAULT 0,
    active_users BIGINT DEFAULT 0,
    login_count BIGINT DEFAULT 0,
    
    -- Security metrics
    fraud_alerts_generated BIGINT DEFAULT 0,
    suspicious_activities BIGINT DEFAULT 0,
    
    currency VARCHAR(3) DEFAULT 'USD',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT uk_daily_analytics_date_user UNIQUE (analytics_date, user_id)
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_daily_analytics_date ON daily_analytics(analytics_date);
CREATE INDEX IF NOT EXISTS idx_daily_analytics_user ON daily_analytics(user_id);
CREATE INDEX IF NOT EXISTS idx_daily_analytics_date_range ON daily_analytics(analytics_date, user_id) WHERE user_id IS NULL;

-- Event tracking table for real-time events before aggregation
CREATE TABLE IF NOT EXISTS analytics_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_type VARCHAR(50) NOT NULL,
    event_category VARCHAR(50) NOT NULL,
    user_id UUID,
    entity_id UUID,
    entity_type VARCHAR(50),
    amount DECIMAL(19, 4),
    currency VARCHAR(3),
    metadata JSONB,
    event_timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    processed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for event processing
CREATE INDEX IF NOT EXISTS idx_analytics_events_type ON analytics_events(event_type);
CREATE INDEX IF NOT EXISTS idx_analytics_events_timestamp ON analytics_events(event_timestamp);
CREATE INDEX IF NOT EXISTS idx_analytics_events_processed ON analytics_events(processed) WHERE processed = FALSE;
CREATE INDEX IF NOT EXISTS idx_analytics_events_user ON analytics_events(user_id);

-- Monthly summary table for reports
CREATE TABLE IF NOT EXISTS monthly_analytics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    analytics_month DATE NOT NULL,
    user_id UUID,
    
    total_transaction_volume DECIMAL(19, 4) DEFAULT 0,
    total_transaction_count BIGINT DEFAULT 0,
    average_daily_transactions DECIMAL(10, 2) DEFAULT 0,
    peak_transaction_day DATE,
    peak_transaction_count BIGINT DEFAULT 0,
    
    total_deposits DECIMAL(19, 4) DEFAULT 0,
    total_withdrawals DECIMAL(19, 4) DEFAULT 0,
    net_flow DECIMAL(19, 4) DEFAULT 0,
    
    total_new_users BIGINT DEFAULT 0,
    average_daily_active_users DECIMAL(10, 2) DEFAULT 0,
    
    total_fraud_alerts BIGINT DEFAULT 0,
    fraud_rate DECIMAL(5, 4) DEFAULT 0,
    
    currency VARCHAR(3) DEFAULT 'USD',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT uk_monthly_analytics_month_user UNIQUE (analytics_month, user_id)
);

CREATE INDEX IF NOT EXISTS idx_monthly_analytics_month ON monthly_analytics(analytics_month);
