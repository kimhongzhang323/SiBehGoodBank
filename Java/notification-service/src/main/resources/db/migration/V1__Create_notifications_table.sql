-- V1__Create_notifications_table.sql
-- Notification Service Database Schema

-- Notifications table
CREATE TABLE IF NOT EXISTS notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    channel VARCHAR(20) NOT NULL,
    type VARCHAR(30) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    priority VARCHAR(20) NOT NULL DEFAULT 'NORMAL',
    subject VARCHAR(500),
    body TEXT NOT NULL,
    recipient_email VARCHAR(255),
    recipient_phone VARCHAR(20),
    device_token VARCHAR(500),
    template_name VARCHAR(100),
    template_data JSONB,
    metadata JSONB,
    external_id VARCHAR(255),
    error_message TEXT,
    retry_count INTEGER DEFAULT 0,
    max_retries INTEGER DEFAULT 3,
    scheduled_at TIMESTAMP WITH TIME ZONE,
    sent_at TIMESTAMP WITH TIME ZONE,
    delivered_at TIMESTAMP WITH TIME ZONE,
    read_at TIMESTAMP WITH TIME ZONE,
    expires_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Notification preferences table
CREATE TABLE IF NOT EXISTS notification_preferences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL UNIQUE,
    email_enabled BOOLEAN DEFAULT TRUE,
    sms_enabled BOOLEAN DEFAULT TRUE,
    push_enabled BOOLEAN DEFAULT TRUE,
    in_app_enabled BOOLEAN DEFAULT TRUE,
    transaction_notifications BOOLEAN DEFAULT TRUE,
    security_notifications BOOLEAN DEFAULT TRUE,
    marketing_notifications BOOLEAN DEFAULT FALSE,
    account_notifications BOOLEAN DEFAULT TRUE,
    otp_notifications BOOLEAN DEFAULT TRUE,
    alert_notifications BOOLEAN DEFAULT TRUE,
    quiet_hours_enabled BOOLEAN DEFAULT FALSE,
    quiet_hours_start TIME,
    quiet_hours_end TIME,
    timezone VARCHAR(50) DEFAULT 'UTC',
    preferred_language VARCHAR(10) DEFAULT 'en',
    email_frequency VARCHAR(20) DEFAULT 'IMMEDIATE',
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- OTP codes table
CREATE TABLE IF NOT EXISTS otp_codes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    code VARCHAR(10) NOT NULL,
    purpose VARCHAR(50) NOT NULL,
    channel VARCHAR(20) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    attempts INTEGER DEFAULT 0,
    max_attempts INTEGER DEFAULT 3,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    verified_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Notification templates table
CREATE TABLE IF NOT EXISTS notification_templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL UNIQUE,
    channel VARCHAR(20) NOT NULL,
    type VARCHAR(30) NOT NULL,
    subject VARCHAR(500),
    body_template TEXT NOT NULL,
    html_template TEXT,
    variables JSONB,
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Device tokens table for push notifications
CREATE TABLE IF NOT EXISTS device_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    device_token VARCHAR(500) NOT NULL,
    device_type VARCHAR(20) NOT NULL,
    device_name VARCHAR(100),
    platform VARCHAR(20),
    app_version VARCHAR(20),
    active BOOLEAN DEFAULT TRUE,
    last_used_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, device_token)
);

-- Indexes for notifications
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_status ON notifications(status);
CREATE INDEX IF NOT EXISTS idx_notifications_channel ON notifications(channel);
CREATE INDEX IF NOT EXISTS idx_notifications_type ON notifications(type);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON notifications(created_at);
CREATE INDEX IF NOT EXISTS idx_notifications_user_status ON notifications(user_id, status);
CREATE INDEX IF NOT EXISTS idx_notifications_user_read ON notifications(user_id, read_at);
CREATE INDEX IF NOT EXISTS idx_notifications_pending ON notifications(status, scheduled_at) 
    WHERE status = 'PENDING';
CREATE INDEX IF NOT EXISTS idx_notifications_retry ON notifications(status, retry_count, updated_at) 
    WHERE status = 'FAILED' AND retry_count < max_retries;

-- Indexes for OTP codes
CREATE INDEX IF NOT EXISTS idx_otp_codes_user_id ON otp_codes(user_id);
CREATE INDEX IF NOT EXISTS idx_otp_codes_lookup ON otp_codes(user_id, purpose, status);
CREATE INDEX IF NOT EXISTS idx_otp_codes_expires_at ON otp_codes(expires_at) 
    WHERE status = 'ACTIVE';

-- Indexes for device tokens
CREATE INDEX IF NOT EXISTS idx_device_tokens_user_id ON device_tokens(user_id);
CREATE INDEX IF NOT EXISTS idx_device_tokens_active ON device_tokens(user_id, active) 
    WHERE active = TRUE;

-- Trigger for updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_notifications_updated_at
    BEFORE UPDATE ON notifications
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_notification_preferences_updated_at
    BEFORE UPDATE ON notification_preferences
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_notification_templates_updated_at
    BEFORE UPDATE ON notification_templates
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_device_tokens_updated_at
    BEFORE UPDATE ON device_tokens
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Insert default notification templates
INSERT INTO notification_templates (name, channel, type, subject, body_template, variables) VALUES
('transaction_completed', 'EMAIL', 'TRANSACTION', 'Transaction Completed - {{amount}} {{currency}}', 
 'Dear {{userName}}, Your transaction of {{amount}} {{currency}} has been completed successfully. Transaction ID: {{transactionId}}', 
 '["userName", "amount", "currency", "transactionId"]'::jsonb),

('transaction_completed', 'PUSH', 'TRANSACTION', 'Transaction Completed', 
 'Your transaction of {{amount}} {{currency}} has been completed.', 
 '["amount", "currency"]'::jsonb),

('login_alert', 'EMAIL', 'SECURITY', 'New Login Detected - SibehGoodBank', 
 'Dear {{userName}}, A new login was detected on your account from {{device}} at {{location}} on {{timestamp}}. If this wasn''t you, please secure your account immediately.', 
 '["userName", "device", "location", "timestamp"]'::jsonb),

('otp_verification', 'SMS', 'OTP', NULL, 
 'Your SibehGoodBank verification code is: {{otp}}. Valid for {{validityMinutes}} minutes. Do not share this code.', 
 '["otp", "validityMinutes"]'::jsonb),

('otp_verification', 'EMAIL', 'OTP', 'Your Verification Code - SibehGoodBank', 
 'Your verification code is: {{otp}}. This code is valid for {{validityMinutes}} minutes. Do not share this code with anyone.', 
 '["otp", "validityMinutes"]'::jsonb),

('welcome', 'EMAIL', 'ACCOUNT', 'Welcome to SibehGoodBank!', 
 'Dear {{userName}}, Welcome to SibehGoodBank! Your account has been created successfully. Start exploring our features today.', 
 '["userName"]'::jsonb),

('low_balance', 'PUSH', 'ALERT', 'Low Balance Alert', 
 'Your account balance is low: {{balance}} {{currency}}. Consider topping up.', 
 '["balance", "currency"]'::jsonb);
