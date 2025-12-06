package com.sibehgoodbank.grpc.notification;

import static io.grpc.MethodDescriptor.generateFullMethodName;

/**
 * <pre>
 * Notification Service
 * </pre>
 */
@javax.annotation.Generated(
    value = "by gRPC proto compiler (version 1.60.0)",
    comments = "Source: notification_service.proto")
@io.grpc.stub.annotations.GrpcGenerated
public final class NotificationServiceGrpc {

  private NotificationServiceGrpc() {}

  public static final java.lang.String SERVICE_NAME = "com.sibehgoodbank.grpc.notification.NotificationService";

  // Static method descriptors that strictly reflect the proto.
  private static volatile io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.notification.SendNotificationRequest,
      com.sibehgoodbank.grpc.notification.NotificationResponse> getSendNotificationMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "SendNotification",
      requestType = com.sibehgoodbank.grpc.notification.SendNotificationRequest.class,
      responseType = com.sibehgoodbank.grpc.notification.NotificationResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.notification.SendNotificationRequest,
      com.sibehgoodbank.grpc.notification.NotificationResponse> getSendNotificationMethod() {
    io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.notification.SendNotificationRequest, com.sibehgoodbank.grpc.notification.NotificationResponse> getSendNotificationMethod;
    if ((getSendNotificationMethod = NotificationServiceGrpc.getSendNotificationMethod) == null) {
      synchronized (NotificationServiceGrpc.class) {
        if ((getSendNotificationMethod = NotificationServiceGrpc.getSendNotificationMethod) == null) {
          NotificationServiceGrpc.getSendNotificationMethod = getSendNotificationMethod =
              io.grpc.MethodDescriptor.<com.sibehgoodbank.grpc.notification.SendNotificationRequest, com.sibehgoodbank.grpc.notification.NotificationResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "SendNotification"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.sibehgoodbank.grpc.notification.SendNotificationRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.sibehgoodbank.grpc.notification.NotificationResponse.getDefaultInstance()))
              .setSchemaDescriptor(new NotificationServiceMethodDescriptorSupplier("SendNotification"))
              .build();
        }
      }
    }
    return getSendNotificationMethod;
  }

  private static volatile io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.notification.SendBatchNotificationRequest,
      com.sibehgoodbank.grpc.notification.BatchNotificationResponse> getSendBatchNotificationMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "SendBatchNotification",
      requestType = com.sibehgoodbank.grpc.notification.SendBatchNotificationRequest.class,
      responseType = com.sibehgoodbank.grpc.notification.BatchNotificationResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.notification.SendBatchNotificationRequest,
      com.sibehgoodbank.grpc.notification.BatchNotificationResponse> getSendBatchNotificationMethod() {
    io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.notification.SendBatchNotificationRequest, com.sibehgoodbank.grpc.notification.BatchNotificationResponse> getSendBatchNotificationMethod;
    if ((getSendBatchNotificationMethod = NotificationServiceGrpc.getSendBatchNotificationMethod) == null) {
      synchronized (NotificationServiceGrpc.class) {
        if ((getSendBatchNotificationMethod = NotificationServiceGrpc.getSendBatchNotificationMethod) == null) {
          NotificationServiceGrpc.getSendBatchNotificationMethod = getSendBatchNotificationMethod =
              io.grpc.MethodDescriptor.<com.sibehgoodbank.grpc.notification.SendBatchNotificationRequest, com.sibehgoodbank.grpc.notification.BatchNotificationResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "SendBatchNotification"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.sibehgoodbank.grpc.notification.SendBatchNotificationRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.sibehgoodbank.grpc.notification.BatchNotificationResponse.getDefaultInstance()))
              .setSchemaDescriptor(new NotificationServiceMethodDescriptorSupplier("SendBatchNotification"))
              .build();
        }
      }
    }
    return getSendBatchNotificationMethod;
  }

  private static volatile io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.notification.GetNotificationRequest,
      com.sibehgoodbank.grpc.notification.NotificationDetails> getGetNotificationMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "GetNotification",
      requestType = com.sibehgoodbank.grpc.notification.GetNotificationRequest.class,
      responseType = com.sibehgoodbank.grpc.notification.NotificationDetails.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.notification.GetNotificationRequest,
      com.sibehgoodbank.grpc.notification.NotificationDetails> getGetNotificationMethod() {
    io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.notification.GetNotificationRequest, com.sibehgoodbank.grpc.notification.NotificationDetails> getGetNotificationMethod;
    if ((getGetNotificationMethod = NotificationServiceGrpc.getGetNotificationMethod) == null) {
      synchronized (NotificationServiceGrpc.class) {
        if ((getGetNotificationMethod = NotificationServiceGrpc.getGetNotificationMethod) == null) {
          NotificationServiceGrpc.getGetNotificationMethod = getGetNotificationMethod =
              io.grpc.MethodDescriptor.<com.sibehgoodbank.grpc.notification.GetNotificationRequest, com.sibehgoodbank.grpc.notification.NotificationDetails>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "GetNotification"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.sibehgoodbank.grpc.notification.GetNotificationRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.sibehgoodbank.grpc.notification.NotificationDetails.getDefaultInstance()))
              .setSchemaDescriptor(new NotificationServiceMethodDescriptorSupplier("GetNotification"))
              .build();
        }
      }
    }
    return getGetNotificationMethod;
  }

  private static volatile io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.notification.GetUserNotificationsRequest,
      com.sibehgoodbank.grpc.notification.UserNotificationsResponse> getGetUserNotificationsMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "GetUserNotifications",
      requestType = com.sibehgoodbank.grpc.notification.GetUserNotificationsRequest.class,
      responseType = com.sibehgoodbank.grpc.notification.UserNotificationsResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.notification.GetUserNotificationsRequest,
      com.sibehgoodbank.grpc.notification.UserNotificationsResponse> getGetUserNotificationsMethod() {
    io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.notification.GetUserNotificationsRequest, com.sibehgoodbank.grpc.notification.UserNotificationsResponse> getGetUserNotificationsMethod;
    if ((getGetUserNotificationsMethod = NotificationServiceGrpc.getGetUserNotificationsMethod) == null) {
      synchronized (NotificationServiceGrpc.class) {
        if ((getGetUserNotificationsMethod = NotificationServiceGrpc.getGetUserNotificationsMethod) == null) {
          NotificationServiceGrpc.getGetUserNotificationsMethod = getGetUserNotificationsMethod =
              io.grpc.MethodDescriptor.<com.sibehgoodbank.grpc.notification.GetUserNotificationsRequest, com.sibehgoodbank.grpc.notification.UserNotificationsResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "GetUserNotifications"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.sibehgoodbank.grpc.notification.GetUserNotificationsRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.sibehgoodbank.grpc.notification.UserNotificationsResponse.getDefaultInstance()))
              .setSchemaDescriptor(new NotificationServiceMethodDescriptorSupplier("GetUserNotifications"))
              .build();
        }
      }
    }
    return getGetUserNotificationsMethod;
  }

  private static volatile io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.notification.MarkAsReadRequest,
      com.sibehgoodbank.grpc.notification.MarkAsReadResponse> getMarkAsReadMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "MarkAsRead",
      requestType = com.sibehgoodbank.grpc.notification.MarkAsReadRequest.class,
      responseType = com.sibehgoodbank.grpc.notification.MarkAsReadResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.notification.MarkAsReadRequest,
      com.sibehgoodbank.grpc.notification.MarkAsReadResponse> getMarkAsReadMethod() {
    io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.notification.MarkAsReadRequest, com.sibehgoodbank.grpc.notification.MarkAsReadResponse> getMarkAsReadMethod;
    if ((getMarkAsReadMethod = NotificationServiceGrpc.getMarkAsReadMethod) == null) {
      synchronized (NotificationServiceGrpc.class) {
        if ((getMarkAsReadMethod = NotificationServiceGrpc.getMarkAsReadMethod) == null) {
          NotificationServiceGrpc.getMarkAsReadMethod = getMarkAsReadMethod =
              io.grpc.MethodDescriptor.<com.sibehgoodbank.grpc.notification.MarkAsReadRequest, com.sibehgoodbank.grpc.notification.MarkAsReadResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "MarkAsRead"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.sibehgoodbank.grpc.notification.MarkAsReadRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.sibehgoodbank.grpc.notification.MarkAsReadResponse.getDefaultInstance()))
              .setSchemaDescriptor(new NotificationServiceMethodDescriptorSupplier("MarkAsRead"))
              .build();
        }
      }
    }
    return getMarkAsReadMethod;
  }

  private static volatile io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.notification.MarkAllAsReadRequest,
      com.sibehgoodbank.grpc.notification.MarkAllAsReadResponse> getMarkAllAsReadMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "MarkAllAsRead",
      requestType = com.sibehgoodbank.grpc.notification.MarkAllAsReadRequest.class,
      responseType = com.sibehgoodbank.grpc.notification.MarkAllAsReadResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.notification.MarkAllAsReadRequest,
      com.sibehgoodbank.grpc.notification.MarkAllAsReadResponse> getMarkAllAsReadMethod() {
    io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.notification.MarkAllAsReadRequest, com.sibehgoodbank.grpc.notification.MarkAllAsReadResponse> getMarkAllAsReadMethod;
    if ((getMarkAllAsReadMethod = NotificationServiceGrpc.getMarkAllAsReadMethod) == null) {
      synchronized (NotificationServiceGrpc.class) {
        if ((getMarkAllAsReadMethod = NotificationServiceGrpc.getMarkAllAsReadMethod) == null) {
          NotificationServiceGrpc.getMarkAllAsReadMethod = getMarkAllAsReadMethod =
              io.grpc.MethodDescriptor.<com.sibehgoodbank.grpc.notification.MarkAllAsReadRequest, com.sibehgoodbank.grpc.notification.MarkAllAsReadResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "MarkAllAsRead"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.sibehgoodbank.grpc.notification.MarkAllAsReadRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.sibehgoodbank.grpc.notification.MarkAllAsReadResponse.getDefaultInstance()))
              .setSchemaDescriptor(new NotificationServiceMethodDescriptorSupplier("MarkAllAsRead"))
              .build();
        }
      }
    }
    return getMarkAllAsReadMethod;
  }

  private static volatile io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.notification.GetPreferencesRequest,
      com.sibehgoodbank.grpc.notification.PreferencesResponse> getGetPreferencesMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "GetPreferences",
      requestType = com.sibehgoodbank.grpc.notification.GetPreferencesRequest.class,
      responseType = com.sibehgoodbank.grpc.notification.PreferencesResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.notification.GetPreferencesRequest,
      com.sibehgoodbank.grpc.notification.PreferencesResponse> getGetPreferencesMethod() {
    io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.notification.GetPreferencesRequest, com.sibehgoodbank.grpc.notification.PreferencesResponse> getGetPreferencesMethod;
    if ((getGetPreferencesMethod = NotificationServiceGrpc.getGetPreferencesMethod) == null) {
      synchronized (NotificationServiceGrpc.class) {
        if ((getGetPreferencesMethod = NotificationServiceGrpc.getGetPreferencesMethod) == null) {
          NotificationServiceGrpc.getGetPreferencesMethod = getGetPreferencesMethod =
              io.grpc.MethodDescriptor.<com.sibehgoodbank.grpc.notification.GetPreferencesRequest, com.sibehgoodbank.grpc.notification.PreferencesResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "GetPreferences"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.sibehgoodbank.grpc.notification.GetPreferencesRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.sibehgoodbank.grpc.notification.PreferencesResponse.getDefaultInstance()))
              .setSchemaDescriptor(new NotificationServiceMethodDescriptorSupplier("GetPreferences"))
              .build();
        }
      }
    }
    return getGetPreferencesMethod;
  }

  private static volatile io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.notification.UpdatePreferencesRequest,
      com.sibehgoodbank.grpc.notification.PreferencesResponse> getUpdatePreferencesMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "UpdatePreferences",
      requestType = com.sibehgoodbank.grpc.notification.UpdatePreferencesRequest.class,
      responseType = com.sibehgoodbank.grpc.notification.PreferencesResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.notification.UpdatePreferencesRequest,
      com.sibehgoodbank.grpc.notification.PreferencesResponse> getUpdatePreferencesMethod() {
    io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.notification.UpdatePreferencesRequest, com.sibehgoodbank.grpc.notification.PreferencesResponse> getUpdatePreferencesMethod;
    if ((getUpdatePreferencesMethod = NotificationServiceGrpc.getUpdatePreferencesMethod) == null) {
      synchronized (NotificationServiceGrpc.class) {
        if ((getUpdatePreferencesMethod = NotificationServiceGrpc.getUpdatePreferencesMethod) == null) {
          NotificationServiceGrpc.getUpdatePreferencesMethod = getUpdatePreferencesMethod =
              io.grpc.MethodDescriptor.<com.sibehgoodbank.grpc.notification.UpdatePreferencesRequest, com.sibehgoodbank.grpc.notification.PreferencesResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "UpdatePreferences"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.sibehgoodbank.grpc.notification.UpdatePreferencesRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.sibehgoodbank.grpc.notification.PreferencesResponse.getDefaultInstance()))
              .setSchemaDescriptor(new NotificationServiceMethodDescriptorSupplier("UpdatePreferences"))
              .build();
        }
      }
    }
    return getUpdatePreferencesMethod;
  }

  private static volatile io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.notification.RegisterDeviceRequest,
      com.sibehgoodbank.grpc.notification.RegisterDeviceResponse> getRegisterDeviceMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "RegisterDevice",
      requestType = com.sibehgoodbank.grpc.notification.RegisterDeviceRequest.class,
      responseType = com.sibehgoodbank.grpc.notification.RegisterDeviceResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.notification.RegisterDeviceRequest,
      com.sibehgoodbank.grpc.notification.RegisterDeviceResponse> getRegisterDeviceMethod() {
    io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.notification.RegisterDeviceRequest, com.sibehgoodbank.grpc.notification.RegisterDeviceResponse> getRegisterDeviceMethod;
    if ((getRegisterDeviceMethod = NotificationServiceGrpc.getRegisterDeviceMethod) == null) {
      synchronized (NotificationServiceGrpc.class) {
        if ((getRegisterDeviceMethod = NotificationServiceGrpc.getRegisterDeviceMethod) == null) {
          NotificationServiceGrpc.getRegisterDeviceMethod = getRegisterDeviceMethod =
              io.grpc.MethodDescriptor.<com.sibehgoodbank.grpc.notification.RegisterDeviceRequest, com.sibehgoodbank.grpc.notification.RegisterDeviceResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "RegisterDevice"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.sibehgoodbank.grpc.notification.RegisterDeviceRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.sibehgoodbank.grpc.notification.RegisterDeviceResponse.getDefaultInstance()))
              .setSchemaDescriptor(new NotificationServiceMethodDescriptorSupplier("RegisterDevice"))
              .build();
        }
      }
    }
    return getRegisterDeviceMethod;
  }

  private static volatile io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.notification.UnregisterDeviceRequest,
      com.sibehgoodbank.grpc.notification.RegisterDeviceResponse> getUnregisterDeviceMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "UnregisterDevice",
      requestType = com.sibehgoodbank.grpc.notification.UnregisterDeviceRequest.class,
      responseType = com.sibehgoodbank.grpc.notification.RegisterDeviceResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.notification.UnregisterDeviceRequest,
      com.sibehgoodbank.grpc.notification.RegisterDeviceResponse> getUnregisterDeviceMethod() {
    io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.notification.UnregisterDeviceRequest, com.sibehgoodbank.grpc.notification.RegisterDeviceResponse> getUnregisterDeviceMethod;
    if ((getUnregisterDeviceMethod = NotificationServiceGrpc.getUnregisterDeviceMethod) == null) {
      synchronized (NotificationServiceGrpc.class) {
        if ((getUnregisterDeviceMethod = NotificationServiceGrpc.getUnregisterDeviceMethod) == null) {
          NotificationServiceGrpc.getUnregisterDeviceMethod = getUnregisterDeviceMethod =
              io.grpc.MethodDescriptor.<com.sibehgoodbank.grpc.notification.UnregisterDeviceRequest, com.sibehgoodbank.grpc.notification.RegisterDeviceResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "UnregisterDevice"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.sibehgoodbank.grpc.notification.UnregisterDeviceRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.sibehgoodbank.grpc.notification.RegisterDeviceResponse.getDefaultInstance()))
              .setSchemaDescriptor(new NotificationServiceMethodDescriptorSupplier("UnregisterDevice"))
              .build();
        }
      }
    }
    return getUnregisterDeviceMethod;
  }

  /**
   * Creates a new async stub that supports all call types for the service
   */
  public static NotificationServiceStub newStub(io.grpc.Channel channel) {
    io.grpc.stub.AbstractStub.StubFactory<NotificationServiceStub> factory =
      new io.grpc.stub.AbstractStub.StubFactory<NotificationServiceStub>() {
        @java.lang.Override
        public NotificationServiceStub newStub(io.grpc.Channel channel, io.grpc.CallOptions callOptions) {
          return new NotificationServiceStub(channel, callOptions);
        }
      };
    return NotificationServiceStub.newStub(factory, channel);
  }

  /**
   * Creates a new blocking-style stub that supports unary and streaming output calls on the service
   */
  public static NotificationServiceBlockingStub newBlockingStub(
      io.grpc.Channel channel) {
    io.grpc.stub.AbstractStub.StubFactory<NotificationServiceBlockingStub> factory =
      new io.grpc.stub.AbstractStub.StubFactory<NotificationServiceBlockingStub>() {
        @java.lang.Override
        public NotificationServiceBlockingStub newStub(io.grpc.Channel channel, io.grpc.CallOptions callOptions) {
          return new NotificationServiceBlockingStub(channel, callOptions);
        }
      };
    return NotificationServiceBlockingStub.newStub(factory, channel);
  }

  /**
   * Creates a new ListenableFuture-style stub that supports unary calls on the service
   */
  public static NotificationServiceFutureStub newFutureStub(
      io.grpc.Channel channel) {
    io.grpc.stub.AbstractStub.StubFactory<NotificationServiceFutureStub> factory =
      new io.grpc.stub.AbstractStub.StubFactory<NotificationServiceFutureStub>() {
        @java.lang.Override
        public NotificationServiceFutureStub newStub(io.grpc.Channel channel, io.grpc.CallOptions callOptions) {
          return new NotificationServiceFutureStub(channel, callOptions);
        }
      };
    return NotificationServiceFutureStub.newStub(factory, channel);
  }

  /**
   * <pre>
   * Notification Service
   * </pre>
   */
  public interface AsyncService {

    /**
     * <pre>
     * Send single notification
     * </pre>
     */
    default void sendNotification(com.sibehgoodbank.grpc.notification.SendNotificationRequest request,
        io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.notification.NotificationResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getSendNotificationMethod(), responseObserver);
    }

    /**
     * <pre>
     * Send batch notifications
     * </pre>
     */
    default void sendBatchNotification(com.sibehgoodbank.grpc.notification.SendBatchNotificationRequest request,
        io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.notification.BatchNotificationResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getSendBatchNotificationMethod(), responseObserver);
    }

    /**
     * <pre>
     * Get notification by ID
     * </pre>
     */
    default void getNotification(com.sibehgoodbank.grpc.notification.GetNotificationRequest request,
        io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.notification.NotificationDetails> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getGetNotificationMethod(), responseObserver);
    }

    /**
     * <pre>
     * Get user's notifications
     * </pre>
     */
    default void getUserNotifications(com.sibehgoodbank.grpc.notification.GetUserNotificationsRequest request,
        io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.notification.UserNotificationsResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getGetUserNotificationsMethod(), responseObserver);
    }

    /**
     * <pre>
     * Mark notification as read
     * </pre>
     */
    default void markAsRead(com.sibehgoodbank.grpc.notification.MarkAsReadRequest request,
        io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.notification.MarkAsReadResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getMarkAsReadMethod(), responseObserver);
    }

    /**
     * <pre>
     * Mark all notifications as read
     * </pre>
     */
    default void markAllAsRead(com.sibehgoodbank.grpc.notification.MarkAllAsReadRequest request,
        io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.notification.MarkAllAsReadResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getMarkAllAsReadMethod(), responseObserver);
    }

    /**
     * <pre>
     * Get notification preferences
     * </pre>
     */
    default void getPreferences(com.sibehgoodbank.grpc.notification.GetPreferencesRequest request,
        io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.notification.PreferencesResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getGetPreferencesMethod(), responseObserver);
    }

    /**
     * <pre>
     * Update notification preferences
     * </pre>
     */
    default void updatePreferences(com.sibehgoodbank.grpc.notification.UpdatePreferencesRequest request,
        io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.notification.PreferencesResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getUpdatePreferencesMethod(), responseObserver);
    }

    /**
     * <pre>
     * Register device for push notifications
     * </pre>
     */
    default void registerDevice(com.sibehgoodbank.grpc.notification.RegisterDeviceRequest request,
        io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.notification.RegisterDeviceResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getRegisterDeviceMethod(), responseObserver);
    }

    /**
     * <pre>
     * Unregister device
     * </pre>
     */
    default void unregisterDevice(com.sibehgoodbank.grpc.notification.UnregisterDeviceRequest request,
        io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.notification.RegisterDeviceResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getUnregisterDeviceMethod(), responseObserver);
    }
  }

  /**
   * Base class for the server implementation of the service NotificationService.
   * <pre>
   * Notification Service
   * </pre>
   */
  public static abstract class NotificationServiceImplBase
      implements io.grpc.BindableService, AsyncService {

    @java.lang.Override public final io.grpc.ServerServiceDefinition bindService() {
      return NotificationServiceGrpc.bindService(this);
    }
  }

  /**
   * A stub to allow clients to do asynchronous rpc calls to service NotificationService.
   * <pre>
   * Notification Service
   * </pre>
   */
  public static final class NotificationServiceStub
      extends io.grpc.stub.AbstractAsyncStub<NotificationServiceStub> {
    private NotificationServiceStub(
        io.grpc.Channel channel, io.grpc.CallOptions callOptions) {
      super(channel, callOptions);
    }

    @java.lang.Override
    protected NotificationServiceStub build(
        io.grpc.Channel channel, io.grpc.CallOptions callOptions) {
      return new NotificationServiceStub(channel, callOptions);
    }

    /**
     * <pre>
     * Send single notification
     * </pre>
     */
    public void sendNotification(com.sibehgoodbank.grpc.notification.SendNotificationRequest request,
        io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.notification.NotificationResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getSendNotificationMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     * <pre>
     * Send batch notifications
     * </pre>
     */
    public void sendBatchNotification(com.sibehgoodbank.grpc.notification.SendBatchNotificationRequest request,
        io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.notification.BatchNotificationResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getSendBatchNotificationMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     * <pre>
     * Get notification by ID
     * </pre>
     */
    public void getNotification(com.sibehgoodbank.grpc.notification.GetNotificationRequest request,
        io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.notification.NotificationDetails> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getGetNotificationMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     * <pre>
     * Get user's notifications
     * </pre>
     */
    public void getUserNotifications(com.sibehgoodbank.grpc.notification.GetUserNotificationsRequest request,
        io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.notification.UserNotificationsResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getGetUserNotificationsMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     * <pre>
     * Mark notification as read
     * </pre>
     */
    public void markAsRead(com.sibehgoodbank.grpc.notification.MarkAsReadRequest request,
        io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.notification.MarkAsReadResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getMarkAsReadMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     * <pre>
     * Mark all notifications as read
     * </pre>
     */
    public void markAllAsRead(com.sibehgoodbank.grpc.notification.MarkAllAsReadRequest request,
        io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.notification.MarkAllAsReadResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getMarkAllAsReadMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     * <pre>
     * Get notification preferences
     * </pre>
     */
    public void getPreferences(com.sibehgoodbank.grpc.notification.GetPreferencesRequest request,
        io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.notification.PreferencesResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getGetPreferencesMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     * <pre>
     * Update notification preferences
     * </pre>
     */
    public void updatePreferences(com.sibehgoodbank.grpc.notification.UpdatePreferencesRequest request,
        io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.notification.PreferencesResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getUpdatePreferencesMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     * <pre>
     * Register device for push notifications
     * </pre>
     */
    public void registerDevice(com.sibehgoodbank.grpc.notification.RegisterDeviceRequest request,
        io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.notification.RegisterDeviceResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getRegisterDeviceMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     * <pre>
     * Unregister device
     * </pre>
     */
    public void unregisterDevice(com.sibehgoodbank.grpc.notification.UnregisterDeviceRequest request,
        io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.notification.RegisterDeviceResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getUnregisterDeviceMethod(), getCallOptions()), request, responseObserver);
    }
  }

  /**
   * A stub to allow clients to do synchronous rpc calls to service NotificationService.
   * <pre>
   * Notification Service
   * </pre>
   */
  public static final class NotificationServiceBlockingStub
      extends io.grpc.stub.AbstractBlockingStub<NotificationServiceBlockingStub> {
    private NotificationServiceBlockingStub(
        io.grpc.Channel channel, io.grpc.CallOptions callOptions) {
      super(channel, callOptions);
    }

    @java.lang.Override
    protected NotificationServiceBlockingStub build(
        io.grpc.Channel channel, io.grpc.CallOptions callOptions) {
      return new NotificationServiceBlockingStub(channel, callOptions);
    }

    /**
     * <pre>
     * Send single notification
     * </pre>
     */
    public com.sibehgoodbank.grpc.notification.NotificationResponse sendNotification(com.sibehgoodbank.grpc.notification.SendNotificationRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getSendNotificationMethod(), getCallOptions(), request);
    }

    /**
     * <pre>
     * Send batch notifications
     * </pre>
     */
    public com.sibehgoodbank.grpc.notification.BatchNotificationResponse sendBatchNotification(com.sibehgoodbank.grpc.notification.SendBatchNotificationRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getSendBatchNotificationMethod(), getCallOptions(), request);
    }

    /**
     * <pre>
     * Get notification by ID
     * </pre>
     */
    public com.sibehgoodbank.grpc.notification.NotificationDetails getNotification(com.sibehgoodbank.grpc.notification.GetNotificationRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getGetNotificationMethod(), getCallOptions(), request);
    }

    /**
     * <pre>
     * Get user's notifications
     * </pre>
     */
    public com.sibehgoodbank.grpc.notification.UserNotificationsResponse getUserNotifications(com.sibehgoodbank.grpc.notification.GetUserNotificationsRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getGetUserNotificationsMethod(), getCallOptions(), request);
    }

    /**
     * <pre>
     * Mark notification as read
     * </pre>
     */
    public com.sibehgoodbank.grpc.notification.MarkAsReadResponse markAsRead(com.sibehgoodbank.grpc.notification.MarkAsReadRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getMarkAsReadMethod(), getCallOptions(), request);
    }

    /**
     * <pre>
     * Mark all notifications as read
     * </pre>
     */
    public com.sibehgoodbank.grpc.notification.MarkAllAsReadResponse markAllAsRead(com.sibehgoodbank.grpc.notification.MarkAllAsReadRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getMarkAllAsReadMethod(), getCallOptions(), request);
    }

    /**
     * <pre>
     * Get notification preferences
     * </pre>
     */
    public com.sibehgoodbank.grpc.notification.PreferencesResponse getPreferences(com.sibehgoodbank.grpc.notification.GetPreferencesRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getGetPreferencesMethod(), getCallOptions(), request);
    }

    /**
     * <pre>
     * Update notification preferences
     * </pre>
     */
    public com.sibehgoodbank.grpc.notification.PreferencesResponse updatePreferences(com.sibehgoodbank.grpc.notification.UpdatePreferencesRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getUpdatePreferencesMethod(), getCallOptions(), request);
    }

    /**
     * <pre>
     * Register device for push notifications
     * </pre>
     */
    public com.sibehgoodbank.grpc.notification.RegisterDeviceResponse registerDevice(com.sibehgoodbank.grpc.notification.RegisterDeviceRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getRegisterDeviceMethod(), getCallOptions(), request);
    }

    /**
     * <pre>
     * Unregister device
     * </pre>
     */
    public com.sibehgoodbank.grpc.notification.RegisterDeviceResponse unregisterDevice(com.sibehgoodbank.grpc.notification.UnregisterDeviceRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getUnregisterDeviceMethod(), getCallOptions(), request);
    }
  }

  /**
   * A stub to allow clients to do ListenableFuture-style rpc calls to service NotificationService.
   * <pre>
   * Notification Service
   * </pre>
   */
  public static final class NotificationServiceFutureStub
      extends io.grpc.stub.AbstractFutureStub<NotificationServiceFutureStub> {
    private NotificationServiceFutureStub(
        io.grpc.Channel channel, io.grpc.CallOptions callOptions) {
      super(channel, callOptions);
    }

    @java.lang.Override
    protected NotificationServiceFutureStub build(
        io.grpc.Channel channel, io.grpc.CallOptions callOptions) {
      return new NotificationServiceFutureStub(channel, callOptions);
    }

    /**
     * <pre>
     * Send single notification
     * </pre>
     */
    public com.google.common.util.concurrent.ListenableFuture<com.sibehgoodbank.grpc.notification.NotificationResponse> sendNotification(
        com.sibehgoodbank.grpc.notification.SendNotificationRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getSendNotificationMethod(), getCallOptions()), request);
    }

    /**
     * <pre>
     * Send batch notifications
     * </pre>
     */
    public com.google.common.util.concurrent.ListenableFuture<com.sibehgoodbank.grpc.notification.BatchNotificationResponse> sendBatchNotification(
        com.sibehgoodbank.grpc.notification.SendBatchNotificationRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getSendBatchNotificationMethod(), getCallOptions()), request);
    }

    /**
     * <pre>
     * Get notification by ID
     * </pre>
     */
    public com.google.common.util.concurrent.ListenableFuture<com.sibehgoodbank.grpc.notification.NotificationDetails> getNotification(
        com.sibehgoodbank.grpc.notification.GetNotificationRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getGetNotificationMethod(), getCallOptions()), request);
    }

    /**
     * <pre>
     * Get user's notifications
     * </pre>
     */
    public com.google.common.util.concurrent.ListenableFuture<com.sibehgoodbank.grpc.notification.UserNotificationsResponse> getUserNotifications(
        com.sibehgoodbank.grpc.notification.GetUserNotificationsRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getGetUserNotificationsMethod(), getCallOptions()), request);
    }

    /**
     * <pre>
     * Mark notification as read
     * </pre>
     */
    public com.google.common.util.concurrent.ListenableFuture<com.sibehgoodbank.grpc.notification.MarkAsReadResponse> markAsRead(
        com.sibehgoodbank.grpc.notification.MarkAsReadRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getMarkAsReadMethod(), getCallOptions()), request);
    }

    /**
     * <pre>
     * Mark all notifications as read
     * </pre>
     */
    public com.google.common.util.concurrent.ListenableFuture<com.sibehgoodbank.grpc.notification.MarkAllAsReadResponse> markAllAsRead(
        com.sibehgoodbank.grpc.notification.MarkAllAsReadRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getMarkAllAsReadMethod(), getCallOptions()), request);
    }

    /**
     * <pre>
     * Get notification preferences
     * </pre>
     */
    public com.google.common.util.concurrent.ListenableFuture<com.sibehgoodbank.grpc.notification.PreferencesResponse> getPreferences(
        com.sibehgoodbank.grpc.notification.GetPreferencesRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getGetPreferencesMethod(), getCallOptions()), request);
    }

    /**
     * <pre>
     * Update notification preferences
     * </pre>
     */
    public com.google.common.util.concurrent.ListenableFuture<com.sibehgoodbank.grpc.notification.PreferencesResponse> updatePreferences(
        com.sibehgoodbank.grpc.notification.UpdatePreferencesRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getUpdatePreferencesMethod(), getCallOptions()), request);
    }

    /**
     * <pre>
     * Register device for push notifications
     * </pre>
     */
    public com.google.common.util.concurrent.ListenableFuture<com.sibehgoodbank.grpc.notification.RegisterDeviceResponse> registerDevice(
        com.sibehgoodbank.grpc.notification.RegisterDeviceRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getRegisterDeviceMethod(), getCallOptions()), request);
    }

    /**
     * <pre>
     * Unregister device
     * </pre>
     */
    public com.google.common.util.concurrent.ListenableFuture<com.sibehgoodbank.grpc.notification.RegisterDeviceResponse> unregisterDevice(
        com.sibehgoodbank.grpc.notification.UnregisterDeviceRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getUnregisterDeviceMethod(), getCallOptions()), request);
    }
  }

  private static final int METHODID_SEND_NOTIFICATION = 0;
  private static final int METHODID_SEND_BATCH_NOTIFICATION = 1;
  private static final int METHODID_GET_NOTIFICATION = 2;
  private static final int METHODID_GET_USER_NOTIFICATIONS = 3;
  private static final int METHODID_MARK_AS_READ = 4;
  private static final int METHODID_MARK_ALL_AS_READ = 5;
  private static final int METHODID_GET_PREFERENCES = 6;
  private static final int METHODID_UPDATE_PREFERENCES = 7;
  private static final int METHODID_REGISTER_DEVICE = 8;
  private static final int METHODID_UNREGISTER_DEVICE = 9;

  private static final class MethodHandlers<Req, Resp> implements
      io.grpc.stub.ServerCalls.UnaryMethod<Req, Resp>,
      io.grpc.stub.ServerCalls.ServerStreamingMethod<Req, Resp>,
      io.grpc.stub.ServerCalls.ClientStreamingMethod<Req, Resp>,
      io.grpc.stub.ServerCalls.BidiStreamingMethod<Req, Resp> {
    private final AsyncService serviceImpl;
    private final int methodId;

    MethodHandlers(AsyncService serviceImpl, int methodId) {
      this.serviceImpl = serviceImpl;
      this.methodId = methodId;
    }

    @java.lang.Override
    @java.lang.SuppressWarnings("unchecked")
    public void invoke(Req request, io.grpc.stub.StreamObserver<Resp> responseObserver) {
      switch (methodId) {
        case METHODID_SEND_NOTIFICATION:
          serviceImpl.sendNotification((com.sibehgoodbank.grpc.notification.SendNotificationRequest) request,
              (io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.notification.NotificationResponse>) responseObserver);
          break;
        case METHODID_SEND_BATCH_NOTIFICATION:
          serviceImpl.sendBatchNotification((com.sibehgoodbank.grpc.notification.SendBatchNotificationRequest) request,
              (io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.notification.BatchNotificationResponse>) responseObserver);
          break;
        case METHODID_GET_NOTIFICATION:
          serviceImpl.getNotification((com.sibehgoodbank.grpc.notification.GetNotificationRequest) request,
              (io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.notification.NotificationDetails>) responseObserver);
          break;
        case METHODID_GET_USER_NOTIFICATIONS:
          serviceImpl.getUserNotifications((com.sibehgoodbank.grpc.notification.GetUserNotificationsRequest) request,
              (io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.notification.UserNotificationsResponse>) responseObserver);
          break;
        case METHODID_MARK_AS_READ:
          serviceImpl.markAsRead((com.sibehgoodbank.grpc.notification.MarkAsReadRequest) request,
              (io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.notification.MarkAsReadResponse>) responseObserver);
          break;
        case METHODID_MARK_ALL_AS_READ:
          serviceImpl.markAllAsRead((com.sibehgoodbank.grpc.notification.MarkAllAsReadRequest) request,
              (io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.notification.MarkAllAsReadResponse>) responseObserver);
          break;
        case METHODID_GET_PREFERENCES:
          serviceImpl.getPreferences((com.sibehgoodbank.grpc.notification.GetPreferencesRequest) request,
              (io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.notification.PreferencesResponse>) responseObserver);
          break;
        case METHODID_UPDATE_PREFERENCES:
          serviceImpl.updatePreferences((com.sibehgoodbank.grpc.notification.UpdatePreferencesRequest) request,
              (io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.notification.PreferencesResponse>) responseObserver);
          break;
        case METHODID_REGISTER_DEVICE:
          serviceImpl.registerDevice((com.sibehgoodbank.grpc.notification.RegisterDeviceRequest) request,
              (io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.notification.RegisterDeviceResponse>) responseObserver);
          break;
        case METHODID_UNREGISTER_DEVICE:
          serviceImpl.unregisterDevice((com.sibehgoodbank.grpc.notification.UnregisterDeviceRequest) request,
              (io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.notification.RegisterDeviceResponse>) responseObserver);
          break;
        default:
          throw new AssertionError();
      }
    }

    @java.lang.Override
    @java.lang.SuppressWarnings("unchecked")
    public io.grpc.stub.StreamObserver<Req> invoke(
        io.grpc.stub.StreamObserver<Resp> responseObserver) {
      switch (methodId) {
        default:
          throw new AssertionError();
      }
    }
  }

  public static final io.grpc.ServerServiceDefinition bindService(AsyncService service) {
    return io.grpc.ServerServiceDefinition.builder(getServiceDescriptor())
        .addMethod(
          getSendNotificationMethod(),
          io.grpc.stub.ServerCalls.asyncUnaryCall(
            new MethodHandlers<
              com.sibehgoodbank.grpc.notification.SendNotificationRequest,
              com.sibehgoodbank.grpc.notification.NotificationResponse>(
                service, METHODID_SEND_NOTIFICATION)))
        .addMethod(
          getSendBatchNotificationMethod(),
          io.grpc.stub.ServerCalls.asyncUnaryCall(
            new MethodHandlers<
              com.sibehgoodbank.grpc.notification.SendBatchNotificationRequest,
              com.sibehgoodbank.grpc.notification.BatchNotificationResponse>(
                service, METHODID_SEND_BATCH_NOTIFICATION)))
        .addMethod(
          getGetNotificationMethod(),
          io.grpc.stub.ServerCalls.asyncUnaryCall(
            new MethodHandlers<
              com.sibehgoodbank.grpc.notification.GetNotificationRequest,
              com.sibehgoodbank.grpc.notification.NotificationDetails>(
                service, METHODID_GET_NOTIFICATION)))
        .addMethod(
          getGetUserNotificationsMethod(),
          io.grpc.stub.ServerCalls.asyncUnaryCall(
            new MethodHandlers<
              com.sibehgoodbank.grpc.notification.GetUserNotificationsRequest,
              com.sibehgoodbank.grpc.notification.UserNotificationsResponse>(
                service, METHODID_GET_USER_NOTIFICATIONS)))
        .addMethod(
          getMarkAsReadMethod(),
          io.grpc.stub.ServerCalls.asyncUnaryCall(
            new MethodHandlers<
              com.sibehgoodbank.grpc.notification.MarkAsReadRequest,
              com.sibehgoodbank.grpc.notification.MarkAsReadResponse>(
                service, METHODID_MARK_AS_READ)))
        .addMethod(
          getMarkAllAsReadMethod(),
          io.grpc.stub.ServerCalls.asyncUnaryCall(
            new MethodHandlers<
              com.sibehgoodbank.grpc.notification.MarkAllAsReadRequest,
              com.sibehgoodbank.grpc.notification.MarkAllAsReadResponse>(
                service, METHODID_MARK_ALL_AS_READ)))
        .addMethod(
          getGetPreferencesMethod(),
          io.grpc.stub.ServerCalls.asyncUnaryCall(
            new MethodHandlers<
              com.sibehgoodbank.grpc.notification.GetPreferencesRequest,
              com.sibehgoodbank.grpc.notification.PreferencesResponse>(
                service, METHODID_GET_PREFERENCES)))
        .addMethod(
          getUpdatePreferencesMethod(),
          io.grpc.stub.ServerCalls.asyncUnaryCall(
            new MethodHandlers<
              com.sibehgoodbank.grpc.notification.UpdatePreferencesRequest,
              com.sibehgoodbank.grpc.notification.PreferencesResponse>(
                service, METHODID_UPDATE_PREFERENCES)))
        .addMethod(
          getRegisterDeviceMethod(),
          io.grpc.stub.ServerCalls.asyncUnaryCall(
            new MethodHandlers<
              com.sibehgoodbank.grpc.notification.RegisterDeviceRequest,
              com.sibehgoodbank.grpc.notification.RegisterDeviceResponse>(
                service, METHODID_REGISTER_DEVICE)))
        .addMethod(
          getUnregisterDeviceMethod(),
          io.grpc.stub.ServerCalls.asyncUnaryCall(
            new MethodHandlers<
              com.sibehgoodbank.grpc.notification.UnregisterDeviceRequest,
              com.sibehgoodbank.grpc.notification.RegisterDeviceResponse>(
                service, METHODID_UNREGISTER_DEVICE)))
        .build();
  }

  private static abstract class NotificationServiceBaseDescriptorSupplier
      implements io.grpc.protobuf.ProtoFileDescriptorSupplier, io.grpc.protobuf.ProtoServiceDescriptorSupplier {
    NotificationServiceBaseDescriptorSupplier() {}

    @java.lang.Override
    public com.google.protobuf.Descriptors.FileDescriptor getFileDescriptor() {
      return com.sibehgoodbank.grpc.notification.NotificationServiceProto.getDescriptor();
    }

    @java.lang.Override
    public com.google.protobuf.Descriptors.ServiceDescriptor getServiceDescriptor() {
      return getFileDescriptor().findServiceByName("NotificationService");
    }
  }

  private static final class NotificationServiceFileDescriptorSupplier
      extends NotificationServiceBaseDescriptorSupplier {
    NotificationServiceFileDescriptorSupplier() {}
  }

  private static final class NotificationServiceMethodDescriptorSupplier
      extends NotificationServiceBaseDescriptorSupplier
      implements io.grpc.protobuf.ProtoMethodDescriptorSupplier {
    private final java.lang.String methodName;

    NotificationServiceMethodDescriptorSupplier(java.lang.String methodName) {
      this.methodName = methodName;
    }

    @java.lang.Override
    public com.google.protobuf.Descriptors.MethodDescriptor getMethodDescriptor() {
      return getServiceDescriptor().findMethodByName(methodName);
    }
  }

  private static volatile io.grpc.ServiceDescriptor serviceDescriptor;

  public static io.grpc.ServiceDescriptor getServiceDescriptor() {
    io.grpc.ServiceDescriptor result = serviceDescriptor;
    if (result == null) {
      synchronized (NotificationServiceGrpc.class) {
        result = serviceDescriptor;
        if (result == null) {
          serviceDescriptor = result = io.grpc.ServiceDescriptor.newBuilder(SERVICE_NAME)
              .setSchemaDescriptor(new NotificationServiceFileDescriptorSupplier())
              .addMethod(getSendNotificationMethod())
              .addMethod(getSendBatchNotificationMethod())
              .addMethod(getGetNotificationMethod())
              .addMethod(getGetUserNotificationsMethod())
              .addMethod(getMarkAsReadMethod())
              .addMethod(getMarkAllAsReadMethod())
              .addMethod(getGetPreferencesMethod())
              .addMethod(getUpdatePreferencesMethod())
              .addMethod(getRegisterDeviceMethod())
              .addMethod(getUnregisterDeviceMethod())
              .build();
        }
      }
    }
    return result;
  }
}
