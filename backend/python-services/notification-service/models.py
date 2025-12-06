"""
Pydantic models for Notification Service
"""
from pydantic import BaseModel, EmailStr, Field
from typing import Optional, List, Dict, Any
from datetime import datetime
from enum import Enum


class NotificationType(str, Enum):
    """Types of notifications"""
    EMAIL = "email"
    SMS = "sms"
    PUSH = "push"
    IN_APP = "in_app"


class NotificationPriority(str, Enum):
    """Priority levels for notifications"""
    LOW = "low"
    NORMAL = "normal"
    HIGH = "high"
    URGENT = "urgent"


class NotificationStatus(str, Enum):
    """Status of notification delivery"""
    PENDING = "pending"
    QUEUED = "queued"
    SENT = "sent"
    DELIVERED = "delivered"
    FAILED = "failed"
    CANCELLED = "cancelled"


class NotificationCategory(str, Enum):
    """Categories of banking notifications"""
    TRANSACTION = "transaction"
    SECURITY = "security"
    MARKETING = "marketing"
    ACCOUNT = "account"
    REMINDER = "reminder"
    ALERT = "alert"
    OTP = "otp"


# ==================== Email Models ====================

class EmailAttachment(BaseModel):
    """Email attachment model"""
    filename: str
    content: str  # Base64 encoded
    content_type: str = "application/octet-stream"


class EmailRequest(BaseModel):
    """Request model for sending email"""
    to: List[EmailStr]
    subject: str
    body: str
    html_body: Optional[str] = None
    cc: Optional[List[EmailStr]] = None
    bcc: Optional[List[EmailStr]] = None
    attachments: Optional[List[EmailAttachment]] = None
    template_name: Optional[str] = None
    template_data: Optional[Dict[str, Any]] = None
    priority: NotificationPriority = NotificationPriority.NORMAL
    category: NotificationCategory = NotificationCategory.ACCOUNT
    user_id: Optional[str] = None
    reference_id: Optional[str] = None


class EmailResponse(BaseModel):
    """Response model for email operations"""
    success: bool
    message_id: Optional[str] = None
    status: NotificationStatus
    error: Optional[str] = None
    timestamp: datetime = Field(default_factory=datetime.utcnow)


# ==================== SMS Models ====================

class SMSRequest(BaseModel):
    """Request model for sending SMS"""
    phone_number: str = Field(..., pattern=r"^\+?[1-9]\d{7,14}$")
    message: str = Field(..., max_length=1600)  # SMS segment limit
    priority: NotificationPriority = NotificationPriority.NORMAL
    category: NotificationCategory = NotificationCategory.ACCOUNT
    user_id: Optional[str] = None
    reference_id: Optional[str] = None


class SMSResponse(BaseModel):
    """Response model for SMS operations"""
    success: bool
    message_id: Optional[str] = None
    status: NotificationStatus
    segments: int = 1  # Number of SMS segments used
    error: Optional[str] = None
    timestamp: datetime = Field(default_factory=datetime.utcnow)


# ==================== Push Notification Models ====================

class PushNotificationPayload(BaseModel):
    """Push notification payload"""
    title: str
    body: str
    image_url: Optional[str] = None
    click_action: Optional[str] = None
    data: Optional[Dict[str, str]] = None


class PushRequest(BaseModel):
    """Request model for sending push notifications"""
    device_tokens: List[str]
    payload: PushNotificationPayload
    topic: Optional[str] = None  # For topic-based messaging
    priority: NotificationPriority = NotificationPriority.NORMAL
    category: NotificationCategory = NotificationCategory.ACCOUNT
    user_id: Optional[str] = None
    reference_id: Optional[str] = None
    ttl_seconds: int = 86400  # 24 hours default


class PushResponse(BaseModel):
    """Response model for push notification operations"""
    success: bool
    success_count: int = 0
    failure_count: int = 0
    message_ids: List[str] = []
    failed_tokens: List[str] = []
    error: Optional[str] = None
    timestamp: datetime = Field(default_factory=datetime.utcnow)


# ==================== Bulk Notification Models ====================

class BulkEmailRequest(BaseModel):
    """Request model for bulk email sending"""
    recipients: List[Dict[str, Any]]  # List of {email, name, custom_data}
    subject: str
    template_name: str
    common_data: Optional[Dict[str, Any]] = None
    category: NotificationCategory = NotificationCategory.MARKETING


class BulkSMSRequest(BaseModel):
    """Request model for bulk SMS sending"""
    recipients: List[Dict[str, str]]  # List of {phone_number, custom_message}
    default_message: Optional[str] = None
    category: NotificationCategory = NotificationCategory.MARKETING


class BulkResponse(BaseModel):
    """Response model for bulk operations"""
    success: bool
    total: int
    sent: int
    failed: int
    errors: List[Dict[str, str]] = []
    timestamp: datetime = Field(default_factory=datetime.utcnow)


# ==================== OTP Models ====================

class OTPRequest(BaseModel):
    """Request model for OTP generation and sending"""
    user_id: str
    channel: NotificationType  # email or sms
    destination: str  # email address or phone number
    purpose: str = "verification"
    length: int = Field(default=6, ge=4, le=8)
    expiry_minutes: int = Field(default=5, ge=1, le=30)


class OTPVerifyRequest(BaseModel):
    """Request model for OTP verification"""
    user_id: str
    otp: str
    purpose: str = "verification"


class OTPResponse(BaseModel):
    """Response model for OTP operations"""
    success: bool
    message: str
    expires_at: Optional[datetime] = None
    attempts_remaining: Optional[int] = None


# ==================== Notification History Models ====================

class NotificationRecord(BaseModel):
    """Model for notification history"""
    id: str
    user_id: Optional[str]
    type: NotificationType
    category: NotificationCategory
    priority: NotificationPriority
    status: NotificationStatus
    destination: str  # email, phone, or device token
    subject: Optional[str] = None
    content_preview: str
    reference_id: Optional[str] = None
    created_at: datetime
    sent_at: Optional[datetime] = None
    delivered_at: Optional[datetime] = None
    error_message: Optional[str] = None
    retry_count: int = 0


class NotificationHistoryRequest(BaseModel):
    """Request model for fetching notification history"""
    user_id: Optional[str] = None
    type: Optional[NotificationType] = None
    category: Optional[NotificationCategory] = None
    status: Optional[NotificationStatus] = None
    start_date: Optional[datetime] = None
    end_date: Optional[datetime] = None
    limit: int = Field(default=50, le=200)
    offset: int = 0


class NotificationHistoryResponse(BaseModel):
    """Response model for notification history"""
    notifications: List[NotificationRecord]
    total: int
    limit: int
    offset: int


# ==================== Template Models ====================

class NotificationTemplate(BaseModel):
    """Model for notification templates"""
    id: str
    name: str
    type: NotificationType
    category: NotificationCategory
    subject: Optional[str] = None  # For emails
    content: str
    html_content: Optional[str] = None  # For HTML emails
    variables: List[str] = []  # List of template variables
    is_active: bool = True
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: Optional[datetime] = None


# ==================== Preference Models ====================

class NotificationPreferences(BaseModel):
    """User notification preferences"""
    user_id: str
    email_enabled: bool = True
    sms_enabled: bool = True
    push_enabled: bool = True
    
    # Category preferences
    transaction_alerts: bool = True
    security_alerts: bool = True
    marketing_emails: bool = False
    account_updates: bool = True
    reminder_notifications: bool = True
    
    # Quiet hours
    quiet_hours_enabled: bool = False
    quiet_hours_start: Optional[str] = "22:00"  # HH:MM format
    quiet_hours_end: Optional[str] = "07:00"
    
    # Frequency preferences
    daily_digest: bool = False
    weekly_summary: bool = False


class PreferencesUpdateRequest(BaseModel):
    """Request model for updating preferences"""
    email_enabled: Optional[bool] = None
    sms_enabled: Optional[bool] = None
    push_enabled: Optional[bool] = None
    transaction_alerts: Optional[bool] = None
    security_alerts: Optional[bool] = None
    marketing_emails: Optional[bool] = None
    account_updates: Optional[bool] = None
    reminder_notifications: Optional[bool] = None
    quiet_hours_enabled: Optional[bool] = None
    quiet_hours_start: Optional[str] = None
    quiet_hours_end: Optional[str] = None
    daily_digest: Optional[bool] = None
    weekly_summary: Optional[bool] = None
