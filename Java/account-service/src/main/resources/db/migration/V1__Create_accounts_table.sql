-- V1__Create_accounts_table.sql
-- Account Service Database Schema

-- Create accounts table
CREATE TABLE accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    account_number VARCHAR(20) NOT NULL UNIQUE,
    user_id UUID NOT NULL,
    account_type VARCHAR(30) NOT NULL,
    account_name VARCHAR(100) NOT NULL,
    currency VARCHAR(3) NOT NULL DEFAULT 'SGD',
    balance DECIMAL(19, 4) NOT NULL DEFAULT 0.0000,
    available_balance DECIMAL(19, 4) NOT NULL DEFAULT 0.0000,
    hold_amount DECIMAL(19, 4) NOT NULL DEFAULT 0.0000,
    daily_transfer_limit DECIMAL(19, 4) NOT NULL DEFAULT 5000.0000,
    daily_transferred_amount DECIMAL(19, 4) NOT NULL DEFAULT 0.0000,
    last_transfer_date DATE,
    interest_rate DECIMAL(6, 4) NOT NULL DEFAULT 0.0000,
    overdraft_limit DECIMAL(19, 4) NOT NULL DEFAULT 0.0000,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    is_primary BOOLEAN NOT NULL DEFAULT FALSE,
    opened_date TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    closed_date TIMESTAMP WITH TIME ZONE,
    last_activity_date TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version BIGINT NOT NULL DEFAULT 0,
    
    -- Constraints
    CONSTRAINT chk_balance_non_negative CHECK (balance >= -overdraft_limit),
    CONSTRAINT chk_available_balance CHECK (available_balance >= -overdraft_limit),
    CONSTRAINT chk_hold_amount_non_negative CHECK (hold_amount >= 0),
    CONSTRAINT chk_daily_transfer_limit_positive CHECK (daily_transfer_limit >= 0),
    CONSTRAINT chk_daily_transferred_non_negative CHECK (daily_transferred_amount >= 0),
    CONSTRAINT chk_interest_rate_range CHECK (interest_rate >= 0 AND interest_rate <= 1),
    CONSTRAINT chk_overdraft_limit_non_negative CHECK (overdraft_limit >= 0),
    CONSTRAINT chk_account_type CHECK (account_type IN ('SAVINGS', 'CHECKING', 'FIXED_DEPOSIT', 'MULTI_CURRENCY', 'INVESTMENT', 'LOAN', 'CREDIT')),
    CONSTRAINT chk_currency CHECK (currency IN ('SGD', 'USD', 'EUR', 'GBP', 'JPY', 'CNY', 'HKD', 'AUD', 'MYR', 'THB', 'IDR')),
    CONSTRAINT chk_status CHECK (status IN ('PENDING', 'ACTIVE', 'FROZEN', 'DORMANT', 'CLOSED'))
);

-- Create indexes for faster queries
CREATE INDEX idx_accounts_user_id ON accounts(user_id);
CREATE INDEX idx_accounts_account_number ON accounts(account_number);
CREATE INDEX idx_accounts_status ON accounts(status);
CREATE INDEX idx_accounts_account_type ON accounts(account_type);
CREATE INDEX idx_accounts_currency ON accounts(currency);
CREATE INDEX idx_accounts_user_status ON accounts(user_id, status);
CREATE INDEX idx_accounts_user_type ON accounts(user_id, account_type);
CREATE INDEX idx_accounts_user_primary ON accounts(user_id, is_primary) WHERE is_primary = TRUE;
CREATE INDEX idx_accounts_created_at ON accounts(created_at);
CREATE INDEX idx_accounts_last_activity ON accounts(last_activity_date);

-- Create account_audit_log table for tracking all account changes
CREATE TABLE account_audit_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id UUID NOT NULL REFERENCES accounts(id),
    user_id UUID NOT NULL,
    action VARCHAR(50) NOT NULL,
    old_values JSONB,
    new_values JSONB,
    ip_address VARCHAR(45),
    user_agent TEXT,
    reason TEXT,
    performed_by UUID,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT chk_audit_action CHECK (action IN (
        'ACCOUNT_CREATED', 'ACCOUNT_UPDATED', 'ACCOUNT_CLOSED',
        'STATUS_CHANGED', 'BALANCE_UPDATED', 'LIMIT_CHANGED',
        'INTEREST_RATE_CHANGED', 'FREEZE_APPLIED', 'FREEZE_REMOVED',
        'HOLD_PLACED', 'HOLD_RELEASED', 'OVERDRAFT_CHANGED'
    ))
);

CREATE INDEX idx_account_audit_account_id ON account_audit_log(account_id);
CREATE INDEX idx_account_audit_user_id ON account_audit_log(user_id);
CREATE INDEX idx_account_audit_action ON account_audit_log(action);
CREATE INDEX idx_account_audit_created_at ON account_audit_log(created_at);

-- Create scheduled_transfers table for recurring transfers
CREATE TABLE scheduled_transfers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    from_account_id UUID NOT NULL REFERENCES accounts(id),
    to_account_id UUID REFERENCES accounts(id),
    to_external_account VARCHAR(50),
    to_bank_code VARCHAR(20),
    amount DECIMAL(19, 4) NOT NULL,
    currency VARCHAR(3) NOT NULL DEFAULT 'SGD',
    frequency VARCHAR(20) NOT NULL,
    next_execution_date DATE NOT NULL,
    last_execution_date DATE,
    end_date DATE,
    description TEXT,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    failure_count INT NOT NULL DEFAULT 0,
    max_failures INT NOT NULL DEFAULT 3,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT chk_amount_positive CHECK (amount > 0),
    CONSTRAINT chk_frequency CHECK (frequency IN ('DAILY', 'WEEKLY', 'BIWEEKLY', 'MONTHLY', 'QUARTERLY', 'YEARLY')),
    CONSTRAINT chk_scheduled_status CHECK (status IN ('ACTIVE', 'PAUSED', 'COMPLETED', 'CANCELLED', 'FAILED'))
);

CREATE INDEX idx_scheduled_transfers_from_account ON scheduled_transfers(from_account_id);
CREATE INDEX idx_scheduled_transfers_next_execution ON scheduled_transfers(next_execution_date) WHERE status = 'ACTIVE';
CREATE INDEX idx_scheduled_transfers_status ON scheduled_transfers(status);

-- Create account_holds table for pending transactions
CREATE TABLE account_holds (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id UUID NOT NULL REFERENCES accounts(id),
    amount DECIMAL(19, 4) NOT NULL,
    hold_type VARCHAR(30) NOT NULL,
    reference_id VARCHAR(100),
    description TEXT,
    expiry_date TIMESTAMP WITH TIME ZONE,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    released_at TIMESTAMP WITH TIME ZONE,
    
    CONSTRAINT chk_hold_amount_positive CHECK (amount > 0),
    CONSTRAINT chk_hold_type CHECK (hold_type IN ('TRANSFER_PENDING', 'PAYMENT_PENDING', 'CARD_AUTH', 'CHEQUE_DEPOSIT', 'FRAUD_INVESTIGATION', 'LEGAL_HOLD')),
    CONSTRAINT chk_hold_status CHECK (status IN ('ACTIVE', 'RELEASED', 'EXPIRED', 'CONVERTED'))
);

CREATE INDEX idx_account_holds_account_id ON account_holds(account_id);
CREATE INDEX idx_account_holds_status ON account_holds(status);
CREATE INDEX idx_account_holds_expiry ON account_holds(expiry_date) WHERE status = 'ACTIVE';
CREATE INDEX idx_account_holds_reference ON account_holds(reference_id);

-- Create exchange_rates table for multi-currency support
CREATE TABLE exchange_rates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    from_currency VARCHAR(3) NOT NULL,
    to_currency VARCHAR(3) NOT NULL,
    buy_rate DECIMAL(19, 8) NOT NULL,
    sell_rate DECIMAL(19, 8) NOT NULL,
    mid_rate DECIMAL(19, 8) NOT NULL,
    effective_date TIMESTAMP WITH TIME ZONE NOT NULL,
    expiry_date TIMESTAMP WITH TIME ZONE,
    source VARCHAR(50) NOT NULL DEFAULT 'INTERNAL',
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT chk_rates_positive CHECK (buy_rate > 0 AND sell_rate > 0 AND mid_rate > 0),
    CONSTRAINT uq_exchange_rate UNIQUE (from_currency, to_currency, effective_date)
);

CREATE INDEX idx_exchange_rates_currencies ON exchange_rates(from_currency, to_currency);
CREATE INDEX idx_exchange_rates_effective ON exchange_rates(effective_date);

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updated_at
CREATE TRIGGER update_accounts_updated_at
    BEFORE UPDATE ON accounts
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_scheduled_transfers_updated_at
    BEFORE UPDATE ON scheduled_transfers
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Insert default exchange rates (SGD base)
INSERT INTO exchange_rates (from_currency, to_currency, buy_rate, sell_rate, mid_rate, effective_date, source) VALUES
('SGD', 'USD', 0.7400, 0.7450, 0.7425, CURRENT_TIMESTAMP, 'INITIAL'),
('SGD', 'EUR', 0.6800, 0.6850, 0.6825, CURRENT_TIMESTAMP, 'INITIAL'),
('SGD', 'GBP', 0.5850, 0.5900, 0.5875, CURRENT_TIMESTAMP, 'INITIAL'),
('SGD', 'JPY', 110.00, 111.00, 110.50, CURRENT_TIMESTAMP, 'INITIAL'),
('SGD', 'CNY', 5.3000, 5.3500, 5.3250, CURRENT_TIMESTAMP, 'INITIAL'),
('SGD', 'MYR', 3.4500, 3.4800, 3.4650, CURRENT_TIMESTAMP, 'INITIAL'),
('SGD', 'THB', 26.5000, 26.8000, 26.6500, CURRENT_TIMESTAMP, 'INITIAL'),
('SGD', 'IDR', 11500.00, 11600.00, 11550.00, CURRENT_TIMESTAMP, 'INITIAL'),
('SGD', 'HKD', 5.7800, 5.8200, 5.8000, CURRENT_TIMESTAMP, 'INITIAL'),
('SGD', 'AUD', 1.1200, 1.1300, 1.1250, CURRENT_TIMESTAMP, 'INITIAL'),
('USD', 'SGD', 1.3400, 1.3520, 1.3460, CURRENT_TIMESTAMP, 'INITIAL'),
('EUR', 'SGD', 1.4600, 1.4720, 1.4660, CURRENT_TIMESTAMP, 'INITIAL'),
('GBP', 'SGD', 1.6950, 1.7100, 1.7025, CURRENT_TIMESTAMP, 'INITIAL');

-- Add comments
COMMENT ON TABLE accounts IS 'Main accounts table storing all bank account information';
COMMENT ON TABLE account_audit_log IS 'Audit trail for all account modifications';
COMMENT ON TABLE scheduled_transfers IS 'Recurring and scheduled transfer configurations';
COMMENT ON TABLE account_holds IS 'Pending holds on account balances';
COMMENT ON TABLE exchange_rates IS 'Currency exchange rates for multi-currency operations';
COMMENT ON COLUMN accounts.available_balance IS 'Balance minus holds, available for transactions';
COMMENT ON COLUMN accounts.hold_amount IS 'Total amount currently held for pending transactions';
COMMENT ON COLUMN accounts.version IS 'Optimistic locking version for concurrent updates';
