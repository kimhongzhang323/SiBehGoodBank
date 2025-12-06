-- V1__Create_transactions_table.sql
-- Transaction Service Database Schema

-- Create transactions table
CREATE TABLE transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reference_number VARCHAR(50) NOT NULL UNIQUE,
    user_id UUID NOT NULL,
    from_account_id UUID NOT NULL,
    from_account_number VARCHAR(20) NOT NULL,
    to_account_id UUID,
    to_account_number VARCHAR(50),
    to_external_account VARCHAR(50),
    to_bank_code VARCHAR(20),
    beneficiary_name VARCHAR(100),
    transaction_type VARCHAR(30) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    amount DECIMAL(19, 4) NOT NULL,
    converted_amount DECIMAL(19, 4),
    from_currency VARCHAR(3) NOT NULL,
    to_currency VARCHAR(3),
    exchange_rate DECIMAL(19, 8),
    fee DECIMAL(19, 4) DEFAULT 0,
    fee_type VARCHAR(20),
    description VARCHAR(500),
    remarks VARCHAR(500),
    channel VARCHAR(20),
    ip_address VARCHAR(45),
    device_id VARCHAR(100),
    device_type VARCHAR(50),
    location VARCHAR(100),
    risk_score INT NOT NULL DEFAULT 0,
    is_flagged BOOLEAN NOT NULL DEFAULT FALSE,
    flag_reason VARCHAR(500),
    is_reviewed BOOLEAN NOT NULL DEFAULT FALSE,
    reviewed_by UUID,
    reviewed_at TIMESTAMP WITH TIME ZONE,
    review_notes VARCHAR(500),
    scheduled_transfer_id UUID,
    scheduled_for TIMESTAMP WITH TIME ZONE,
    processed_at TIMESTAMP WITH TIME ZONE,
    balance_before DECIMAL(19, 4),
    balance_after DECIMAL(19, 4),
    external_reference_id VARCHAR(100),
    version BIGINT NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT chk_amount_positive CHECK (amount > 0),
    CONSTRAINT chk_risk_score_range CHECK (risk_score >= 0 AND risk_score <= 100),
    CONSTRAINT chk_transaction_type CHECK (transaction_type IN (
        'INTERNAL_TRANSFER', 'EXTERNAL_TRANSFER', 'INTERBANK_TRANSFER', 'INTERNATIONAL_TRANSFER',
        'BILL_PAYMENT', 'MERCHANT_PAYMENT', 'QR_PAYMENT', 'DEPOSIT', 'WITHDRAWAL', 'ATM_WITHDRAWAL',
        'FEE', 'INTEREST', 'REFUND', 'REVERSAL', 'ADJUSTMENT', 'LOAN_DISBURSEMENT',
        'LOAN_REPAYMENT', 'CARD_PURCHASE', 'CARD_REFUND'
    )),
    CONSTRAINT chk_status CHECK (status IN (
        'PENDING', 'PROCESSING', 'COMPLETED', 'FAILED', 'CANCELLED', 'REVERSED',
        'ON_HOLD', 'FLAGGED', 'UNDER_REVIEW', 'SCHEDULED', 'EXPIRED'
    )),
    CONSTRAINT chk_currency CHECK (from_currency IN ('SGD', 'USD', 'EUR', 'GBP', 'JPY', 'CNY', 'HKD', 'AUD', 'MYR', 'THB', 'IDR')),
    CONSTRAINT chk_fee_type CHECK (fee_type IS NULL OR fee_type IN (
        'TRANSFER_FEE', 'INTERBANK_FEE', 'INTERNATIONAL_FEE', 'CURRENCY_CONVERSION',
        'EXPEDITED_FEE', 'LATE_FEE', 'SERVICE_FEE', 'NONE'
    )),
    CONSTRAINT chk_channel CHECK (channel IS NULL OR channel IN (
        'MOBILE_APP', 'WEB_BANKING', 'ATM', 'BRANCH', 'PHONE_BANKING', 'API', 'SCHEDULED', 'THIRD_PARTY'
    ))
);

-- Create indexes for faster queries
CREATE INDEX idx_transactions_reference ON transactions(reference_number);
CREATE INDEX idx_transactions_user_id ON transactions(user_id);
CREATE INDEX idx_transactions_from_account ON transactions(from_account_id);
CREATE INDEX idx_transactions_to_account ON transactions(to_account_id);
CREATE INDEX idx_transactions_type ON transactions(transaction_type);
CREATE INDEX idx_transactions_status ON transactions(status);
CREATE INDEX idx_transactions_created_at ON transactions(created_at);
CREATE INDEX idx_transactions_processed_at ON transactions(processed_at);
CREATE INDEX idx_transactions_user_created ON transactions(user_id, created_at DESC);
CREATE INDEX idx_transactions_account_created ON transactions(from_account_id, created_at DESC);
CREATE INDEX idx_transactions_flagged ON transactions(is_flagged, is_reviewed) WHERE is_flagged = TRUE;
CREATE INDEX idx_transactions_scheduled ON transactions(scheduled_for) WHERE status = 'SCHEDULED';
CREATE INDEX idx_transactions_pending ON transactions(status, created_at) WHERE status = 'PENDING';
CREATE INDEX idx_transactions_external_ref ON transactions(external_reference_id) WHERE external_reference_id IS NOT NULL;

-- Create transaction_audit_log table
CREATE TABLE transaction_audit_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    transaction_id UUID NOT NULL REFERENCES transactions(id),
    action VARCHAR(50) NOT NULL,
    old_status VARCHAR(20),
    new_status VARCHAR(20),
    performed_by UUID,
    reason TEXT,
    metadata JSONB,
    ip_address VARCHAR(45),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT chk_audit_action CHECK (action IN (
        'CREATED', 'STATUS_CHANGED', 'REVIEWED', 'FLAGGED', 'UNFLAGGED',
        'REVERSED', 'CANCELLED', 'EXPIRED', 'RETRIED', 'MANUAL_OVERRIDE'
    ))
);

CREATE INDEX idx_transaction_audit_transaction_id ON transaction_audit_log(transaction_id);
CREATE INDEX idx_transaction_audit_action ON transaction_audit_log(action);
CREATE INDEX idx_transaction_audit_created_at ON transaction_audit_log(created_at);

-- Create fraud_detection_log table
CREATE TABLE fraud_detection_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    transaction_id UUID NOT NULL REFERENCES transactions(id),
    user_id UUID NOT NULL,
    risk_score INT NOT NULL,
    risk_level VARCHAR(20) NOT NULL,
    risk_factors JSONB,
    analysis_details JSONB,
    recommended_action VARCHAR(30),
    actual_action VARCHAR(30),
    ip_address VARCHAR(45),
    device_id VARCHAR(100),
    location VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT chk_risk_level CHECK (risk_level IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL'))
);

CREATE INDEX idx_fraud_log_transaction_id ON fraud_detection_log(transaction_id);
CREATE INDEX idx_fraud_log_user_id ON fraud_detection_log(user_id);
CREATE INDEX idx_fraud_log_risk_level ON fraud_detection_log(risk_level);
CREATE INDEX idx_fraud_log_created_at ON fraud_detection_log(created_at);

-- Create recurring_transactions table for scheduled/recurring transactions
CREATE TABLE recurring_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    from_account_id UUID NOT NULL,
    to_account_id UUID,
    to_external_account VARCHAR(50),
    to_bank_code VARCHAR(20),
    beneficiary_name VARCHAR(100),
    amount DECIMAL(19, 4) NOT NULL,
    currency VARCHAR(3) NOT NULL DEFAULT 'SGD',
    frequency VARCHAR(20) NOT NULL,
    next_execution_date DATE NOT NULL,
    last_execution_date DATE,
    end_date DATE,
    total_executions INT NOT NULL DEFAULT 0,
    max_executions INT,
    description VARCHAR(500),
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    failure_count INT NOT NULL DEFAULT 0,
    max_failures INT NOT NULL DEFAULT 3,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT chk_recurring_amount CHECK (amount > 0),
    CONSTRAINT chk_frequency CHECK (frequency IN ('DAILY', 'WEEKLY', 'BIWEEKLY', 'MONTHLY', 'QUARTERLY', 'YEARLY')),
    CONSTRAINT chk_recurring_status CHECK (status IN ('ACTIVE', 'PAUSED', 'COMPLETED', 'CANCELLED', 'FAILED'))
);

CREATE INDEX idx_recurring_user_id ON recurring_transactions(user_id);
CREATE INDEX idx_recurring_next_execution ON recurring_transactions(next_execution_date) WHERE status = 'ACTIVE';
CREATE INDEX idx_recurring_status ON recurring_transactions(status);

-- Create daily_transaction_summary table for analytics
CREATE TABLE daily_transaction_summary (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    summary_date DATE NOT NULL,
    user_id UUID,
    account_id UUID,
    transaction_type VARCHAR(30),
    total_count INT NOT NULL DEFAULT 0,
    total_amount DECIMAL(19, 4) NOT NULL DEFAULT 0,
    total_fees DECIMAL(19, 4) NOT NULL DEFAULT 0,
    successful_count INT NOT NULL DEFAULT 0,
    failed_count INT NOT NULL DEFAULT 0,
    flagged_count INT NOT NULL DEFAULT 0,
    average_amount DECIMAL(19, 4),
    min_amount DECIMAL(19, 4),
    max_amount DECIMAL(19, 4),
    currency VARCHAR(3) NOT NULL DEFAULT 'SGD',
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT uq_daily_summary UNIQUE (summary_date, user_id, account_id, transaction_type, currency)
);

CREATE INDEX idx_daily_summary_date ON daily_transaction_summary(summary_date);
CREATE INDEX idx_daily_summary_user ON daily_transaction_summary(user_id);
CREATE INDEX idx_daily_summary_account ON daily_transaction_summary(account_id);

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers
CREATE TRIGGER update_transactions_updated_at
    BEFORE UPDATE ON transactions
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_recurring_transactions_updated_at
    BEFORE UPDATE ON recurring_transactions
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Create function to log transaction status changes
CREATE OR REPLACE FUNCTION log_transaction_status_change()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.status IS DISTINCT FROM NEW.status THEN
        INSERT INTO transaction_audit_log (transaction_id, action, old_status, new_status, created_at)
        VALUES (NEW.id, 'STATUS_CHANGED', OLD.status, NEW.status, CURRENT_TIMESTAMP);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_transaction_status_change
    AFTER UPDATE OF status ON transactions
    FOR EACH ROW
    EXECUTE FUNCTION log_transaction_status_change();

-- Add comments
COMMENT ON TABLE transactions IS 'Main transactions table storing all banking transactions';
COMMENT ON TABLE transaction_audit_log IS 'Audit trail for transaction status changes and actions';
COMMENT ON TABLE fraud_detection_log IS 'Log of fraud detection analysis results';
COMMENT ON TABLE recurring_transactions IS 'Configuration for recurring/scheduled transactions';
COMMENT ON TABLE daily_transaction_summary IS 'Pre-aggregated daily transaction statistics for analytics';
COMMENT ON COLUMN transactions.risk_score IS 'Fraud risk score from 0 to 100';
COMMENT ON COLUMN transactions.is_flagged IS 'True if transaction requires manual review';
COMMENT ON COLUMN transactions.external_reference_id IS 'External idempotency key to prevent duplicate transactions';
