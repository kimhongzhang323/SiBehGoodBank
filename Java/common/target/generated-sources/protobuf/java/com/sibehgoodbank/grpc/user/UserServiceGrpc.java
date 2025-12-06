package com.sibehgoodbank.grpc.user;

import static io.grpc.MethodDescriptor.generateFullMethodName;

/**
 * <pre>
 * User Service
 * </pre>
 */
@javax.annotation.Generated(
    value = "by gRPC proto compiler (version 1.60.0)",
    comments = "Source: user_service.proto")
@io.grpc.stub.annotations.GrpcGenerated
public final class UserServiceGrpc {

  private UserServiceGrpc() {}

  public static final java.lang.String SERVICE_NAME = "com.sibehgoodbank.grpc.user.UserService";

  // Static method descriptors that strictly reflect the proto.
  private static volatile io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.user.GetUserRequest,
      com.sibehgoodbank.grpc.user.UserResponse> getGetUserMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "GetUser",
      requestType = com.sibehgoodbank.grpc.user.GetUserRequest.class,
      responseType = com.sibehgoodbank.grpc.user.UserResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.user.GetUserRequest,
      com.sibehgoodbank.grpc.user.UserResponse> getGetUserMethod() {
    io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.user.GetUserRequest, com.sibehgoodbank.grpc.user.UserResponse> getGetUserMethod;
    if ((getGetUserMethod = UserServiceGrpc.getGetUserMethod) == null) {
      synchronized (UserServiceGrpc.class) {
        if ((getGetUserMethod = UserServiceGrpc.getGetUserMethod) == null) {
          UserServiceGrpc.getGetUserMethod = getGetUserMethod =
              io.grpc.MethodDescriptor.<com.sibehgoodbank.grpc.user.GetUserRequest, com.sibehgoodbank.grpc.user.UserResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "GetUser"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.sibehgoodbank.grpc.user.GetUserRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.sibehgoodbank.grpc.user.UserResponse.getDefaultInstance()))
              .setSchemaDescriptor(new UserServiceMethodDescriptorSupplier("GetUser"))
              .build();
        }
      }
    }
    return getGetUserMethod;
  }

  private static volatile io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.user.GetUserByEmailRequest,
      com.sibehgoodbank.grpc.user.UserResponse> getGetUserByEmailMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "GetUserByEmail",
      requestType = com.sibehgoodbank.grpc.user.GetUserByEmailRequest.class,
      responseType = com.sibehgoodbank.grpc.user.UserResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.user.GetUserByEmailRequest,
      com.sibehgoodbank.grpc.user.UserResponse> getGetUserByEmailMethod() {
    io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.user.GetUserByEmailRequest, com.sibehgoodbank.grpc.user.UserResponse> getGetUserByEmailMethod;
    if ((getGetUserByEmailMethod = UserServiceGrpc.getGetUserByEmailMethod) == null) {
      synchronized (UserServiceGrpc.class) {
        if ((getGetUserByEmailMethod = UserServiceGrpc.getGetUserByEmailMethod) == null) {
          UserServiceGrpc.getGetUserByEmailMethod = getGetUserByEmailMethod =
              io.grpc.MethodDescriptor.<com.sibehgoodbank.grpc.user.GetUserByEmailRequest, com.sibehgoodbank.grpc.user.UserResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "GetUserByEmail"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.sibehgoodbank.grpc.user.GetUserByEmailRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.sibehgoodbank.grpc.user.UserResponse.getDefaultInstance()))
              .setSchemaDescriptor(new UserServiceMethodDescriptorSupplier("GetUserByEmail"))
              .build();
        }
      }
    }
    return getGetUserByEmailMethod;
  }

  private static volatile io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.user.ValidateUserRequest,
      com.sibehgoodbank.grpc.user.ValidateUserResponse> getValidateUserMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "ValidateUser",
      requestType = com.sibehgoodbank.grpc.user.ValidateUserRequest.class,
      responseType = com.sibehgoodbank.grpc.user.ValidateUserResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.user.ValidateUserRequest,
      com.sibehgoodbank.grpc.user.ValidateUserResponse> getValidateUserMethod() {
    io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.user.ValidateUserRequest, com.sibehgoodbank.grpc.user.ValidateUserResponse> getValidateUserMethod;
    if ((getValidateUserMethod = UserServiceGrpc.getValidateUserMethod) == null) {
      synchronized (UserServiceGrpc.class) {
        if ((getValidateUserMethod = UserServiceGrpc.getValidateUserMethod) == null) {
          UserServiceGrpc.getValidateUserMethod = getValidateUserMethod =
              io.grpc.MethodDescriptor.<com.sibehgoodbank.grpc.user.ValidateUserRequest, com.sibehgoodbank.grpc.user.ValidateUserResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "ValidateUser"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.sibehgoodbank.grpc.user.ValidateUserRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.sibehgoodbank.grpc.user.ValidateUserResponse.getDefaultInstance()))
              .setSchemaDescriptor(new UserServiceMethodDescriptorSupplier("ValidateUser"))
              .build();
        }
      }
    }
    return getValidateUserMethod;
  }

  private static volatile io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.user.GetUsersRequest,
      com.sibehgoodbank.grpc.user.GetUsersResponse> getGetUsersMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "GetUsers",
      requestType = com.sibehgoodbank.grpc.user.GetUsersRequest.class,
      responseType = com.sibehgoodbank.grpc.user.GetUsersResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.user.GetUsersRequest,
      com.sibehgoodbank.grpc.user.GetUsersResponse> getGetUsersMethod() {
    io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.user.GetUsersRequest, com.sibehgoodbank.grpc.user.GetUsersResponse> getGetUsersMethod;
    if ((getGetUsersMethod = UserServiceGrpc.getGetUsersMethod) == null) {
      synchronized (UserServiceGrpc.class) {
        if ((getGetUsersMethod = UserServiceGrpc.getGetUsersMethod) == null) {
          UserServiceGrpc.getGetUsersMethod = getGetUsersMethod =
              io.grpc.MethodDescriptor.<com.sibehgoodbank.grpc.user.GetUsersRequest, com.sibehgoodbank.grpc.user.GetUsersResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "GetUsers"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.sibehgoodbank.grpc.user.GetUsersRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.sibehgoodbank.grpc.user.GetUsersResponse.getDefaultInstance()))
              .setSchemaDescriptor(new UserServiceMethodDescriptorSupplier("GetUsers"))
              .build();
        }
      }
    }
    return getGetUsersMethod;
  }

  private static volatile io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.user.UserExistsRequest,
      com.sibehgoodbank.grpc.user.UserExistsResponse> getUserExistsMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "UserExists",
      requestType = com.sibehgoodbank.grpc.user.UserExistsRequest.class,
      responseType = com.sibehgoodbank.grpc.user.UserExistsResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.user.UserExistsRequest,
      com.sibehgoodbank.grpc.user.UserExistsResponse> getUserExistsMethod() {
    io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.user.UserExistsRequest, com.sibehgoodbank.grpc.user.UserExistsResponse> getUserExistsMethod;
    if ((getUserExistsMethod = UserServiceGrpc.getUserExistsMethod) == null) {
      synchronized (UserServiceGrpc.class) {
        if ((getUserExistsMethod = UserServiceGrpc.getUserExistsMethod) == null) {
          UserServiceGrpc.getUserExistsMethod = getUserExistsMethod =
              io.grpc.MethodDescriptor.<com.sibehgoodbank.grpc.user.UserExistsRequest, com.sibehgoodbank.grpc.user.UserExistsResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "UserExists"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.sibehgoodbank.grpc.user.UserExistsRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.sibehgoodbank.grpc.user.UserExistsResponse.getDefaultInstance()))
              .setSchemaDescriptor(new UserServiceMethodDescriptorSupplier("UserExists"))
              .build();
        }
      }
    }
    return getUserExistsMethod;
  }

  /**
   * Creates a new async stub that supports all call types for the service
   */
  public static UserServiceStub newStub(io.grpc.Channel channel) {
    io.grpc.stub.AbstractStub.StubFactory<UserServiceStub> factory =
      new io.grpc.stub.AbstractStub.StubFactory<UserServiceStub>() {
        @java.lang.Override
        public UserServiceStub newStub(io.grpc.Channel channel, io.grpc.CallOptions callOptions) {
          return new UserServiceStub(channel, callOptions);
        }
      };
    return UserServiceStub.newStub(factory, channel);
  }

  /**
   * Creates a new blocking-style stub that supports unary and streaming output calls on the service
   */
  public static UserServiceBlockingStub newBlockingStub(
      io.grpc.Channel channel) {
    io.grpc.stub.AbstractStub.StubFactory<UserServiceBlockingStub> factory =
      new io.grpc.stub.AbstractStub.StubFactory<UserServiceBlockingStub>() {
        @java.lang.Override
        public UserServiceBlockingStub newStub(io.grpc.Channel channel, io.grpc.CallOptions callOptions) {
          return new UserServiceBlockingStub(channel, callOptions);
        }
      };
    return UserServiceBlockingStub.newStub(factory, channel);
  }

  /**
   * Creates a new ListenableFuture-style stub that supports unary calls on the service
   */
  public static UserServiceFutureStub newFutureStub(
      io.grpc.Channel channel) {
    io.grpc.stub.AbstractStub.StubFactory<UserServiceFutureStub> factory =
      new io.grpc.stub.AbstractStub.StubFactory<UserServiceFutureStub>() {
        @java.lang.Override
        public UserServiceFutureStub newStub(io.grpc.Channel channel, io.grpc.CallOptions callOptions) {
          return new UserServiceFutureStub(channel, callOptions);
        }
      };
    return UserServiceFutureStub.newStub(factory, channel);
  }

  /**
   * <pre>
   * User Service
   * </pre>
   */
  public interface AsyncService {

    /**
     * <pre>
     * Get user by ID
     * </pre>
     */
    default void getUser(com.sibehgoodbank.grpc.user.GetUserRequest request,
        io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.user.UserResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getGetUserMethod(), responseObserver);
    }

    /**
     * <pre>
     * Get user by email
     * </pre>
     */
    default void getUserByEmail(com.sibehgoodbank.grpc.user.GetUserByEmailRequest request,
        io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.user.UserResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getGetUserByEmailMethod(), responseObserver);
    }

    /**
     * <pre>
     * Validate user for other services
     * </pre>
     */
    default void validateUser(com.sibehgoodbank.grpc.user.ValidateUserRequest request,
        io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.user.ValidateUserResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getValidateUserMethod(), responseObserver);
    }

    /**
     * <pre>
     * Get multiple users by IDs
     * </pre>
     */
    default void getUsers(com.sibehgoodbank.grpc.user.GetUsersRequest request,
        io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.user.GetUsersResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getGetUsersMethod(), responseObserver);
    }

    /**
     * <pre>
     * Check if user exists
     * </pre>
     */
    default void userExists(com.sibehgoodbank.grpc.user.UserExistsRequest request,
        io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.user.UserExistsResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getUserExistsMethod(), responseObserver);
    }
  }

  /**
   * Base class for the server implementation of the service UserService.
   * <pre>
   * User Service
   * </pre>
   */
  public static abstract class UserServiceImplBase
      implements io.grpc.BindableService, AsyncService {

    @java.lang.Override public final io.grpc.ServerServiceDefinition bindService() {
      return UserServiceGrpc.bindService(this);
    }
  }

  /**
   * A stub to allow clients to do asynchronous rpc calls to service UserService.
   * <pre>
   * User Service
   * </pre>
   */
  public static final class UserServiceStub
      extends io.grpc.stub.AbstractAsyncStub<UserServiceStub> {
    private UserServiceStub(
        io.grpc.Channel channel, io.grpc.CallOptions callOptions) {
      super(channel, callOptions);
    }

    @java.lang.Override
    protected UserServiceStub build(
        io.grpc.Channel channel, io.grpc.CallOptions callOptions) {
      return new UserServiceStub(channel, callOptions);
    }

    /**
     * <pre>
     * Get user by ID
     * </pre>
     */
    public void getUser(com.sibehgoodbank.grpc.user.GetUserRequest request,
        io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.user.UserResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getGetUserMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     * <pre>
     * Get user by email
     * </pre>
     */
    public void getUserByEmail(com.sibehgoodbank.grpc.user.GetUserByEmailRequest request,
        io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.user.UserResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getGetUserByEmailMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     * <pre>
     * Validate user for other services
     * </pre>
     */
    public void validateUser(com.sibehgoodbank.grpc.user.ValidateUserRequest request,
        io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.user.ValidateUserResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getValidateUserMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     * <pre>
     * Get multiple users by IDs
     * </pre>
     */
    public void getUsers(com.sibehgoodbank.grpc.user.GetUsersRequest request,
        io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.user.GetUsersResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getGetUsersMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     * <pre>
     * Check if user exists
     * </pre>
     */
    public void userExists(com.sibehgoodbank.grpc.user.UserExistsRequest request,
        io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.user.UserExistsResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getUserExistsMethod(), getCallOptions()), request, responseObserver);
    }
  }

  /**
   * A stub to allow clients to do synchronous rpc calls to service UserService.
   * <pre>
   * User Service
   * </pre>
   */
  public static final class UserServiceBlockingStub
      extends io.grpc.stub.AbstractBlockingStub<UserServiceBlockingStub> {
    private UserServiceBlockingStub(
        io.grpc.Channel channel, io.grpc.CallOptions callOptions) {
      super(channel, callOptions);
    }

    @java.lang.Override
    protected UserServiceBlockingStub build(
        io.grpc.Channel channel, io.grpc.CallOptions callOptions) {
      return new UserServiceBlockingStub(channel, callOptions);
    }

    /**
     * <pre>
     * Get user by ID
     * </pre>
     */
    public com.sibehgoodbank.grpc.user.UserResponse getUser(com.sibehgoodbank.grpc.user.GetUserRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getGetUserMethod(), getCallOptions(), request);
    }

    /**
     * <pre>
     * Get user by email
     * </pre>
     */
    public com.sibehgoodbank.grpc.user.UserResponse getUserByEmail(com.sibehgoodbank.grpc.user.GetUserByEmailRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getGetUserByEmailMethod(), getCallOptions(), request);
    }

    /**
     * <pre>
     * Validate user for other services
     * </pre>
     */
    public com.sibehgoodbank.grpc.user.ValidateUserResponse validateUser(com.sibehgoodbank.grpc.user.ValidateUserRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getValidateUserMethod(), getCallOptions(), request);
    }

    /**
     * <pre>
     * Get multiple users by IDs
     * </pre>
     */
    public com.sibehgoodbank.grpc.user.GetUsersResponse getUsers(com.sibehgoodbank.grpc.user.GetUsersRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getGetUsersMethod(), getCallOptions(), request);
    }

    /**
     * <pre>
     * Check if user exists
     * </pre>
     */
    public com.sibehgoodbank.grpc.user.UserExistsResponse userExists(com.sibehgoodbank.grpc.user.UserExistsRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getUserExistsMethod(), getCallOptions(), request);
    }
  }

  /**
   * A stub to allow clients to do ListenableFuture-style rpc calls to service UserService.
   * <pre>
   * User Service
   * </pre>
   */
  public static final class UserServiceFutureStub
      extends io.grpc.stub.AbstractFutureStub<UserServiceFutureStub> {
    private UserServiceFutureStub(
        io.grpc.Channel channel, io.grpc.CallOptions callOptions) {
      super(channel, callOptions);
    }

    @java.lang.Override
    protected UserServiceFutureStub build(
        io.grpc.Channel channel, io.grpc.CallOptions callOptions) {
      return new UserServiceFutureStub(channel, callOptions);
    }

    /**
     * <pre>
     * Get user by ID
     * </pre>
     */
    public com.google.common.util.concurrent.ListenableFuture<com.sibehgoodbank.grpc.user.UserResponse> getUser(
        com.sibehgoodbank.grpc.user.GetUserRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getGetUserMethod(), getCallOptions()), request);
    }

    /**
     * <pre>
     * Get user by email
     * </pre>
     */
    public com.google.common.util.concurrent.ListenableFuture<com.sibehgoodbank.grpc.user.UserResponse> getUserByEmail(
        com.sibehgoodbank.grpc.user.GetUserByEmailRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getGetUserByEmailMethod(), getCallOptions()), request);
    }

    /**
     * <pre>
     * Validate user for other services
     * </pre>
     */
    public com.google.common.util.concurrent.ListenableFuture<com.sibehgoodbank.grpc.user.ValidateUserResponse> validateUser(
        com.sibehgoodbank.grpc.user.ValidateUserRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getValidateUserMethod(), getCallOptions()), request);
    }

    /**
     * <pre>
     * Get multiple users by IDs
     * </pre>
     */
    public com.google.common.util.concurrent.ListenableFuture<com.sibehgoodbank.grpc.user.GetUsersResponse> getUsers(
        com.sibehgoodbank.grpc.user.GetUsersRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getGetUsersMethod(), getCallOptions()), request);
    }

    /**
     * <pre>
     * Check if user exists
     * </pre>
     */
    public com.google.common.util.concurrent.ListenableFuture<com.sibehgoodbank.grpc.user.UserExistsResponse> userExists(
        com.sibehgoodbank.grpc.user.UserExistsRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getUserExistsMethod(), getCallOptions()), request);
    }
  }

  private static final int METHODID_GET_USER = 0;
  private static final int METHODID_GET_USER_BY_EMAIL = 1;
  private static final int METHODID_VALIDATE_USER = 2;
  private static final int METHODID_GET_USERS = 3;
  private static final int METHODID_USER_EXISTS = 4;

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
        case METHODID_GET_USER:
          serviceImpl.getUser((com.sibehgoodbank.grpc.user.GetUserRequest) request,
              (io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.user.UserResponse>) responseObserver);
          break;
        case METHODID_GET_USER_BY_EMAIL:
          serviceImpl.getUserByEmail((com.sibehgoodbank.grpc.user.GetUserByEmailRequest) request,
              (io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.user.UserResponse>) responseObserver);
          break;
        case METHODID_VALIDATE_USER:
          serviceImpl.validateUser((com.sibehgoodbank.grpc.user.ValidateUserRequest) request,
              (io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.user.ValidateUserResponse>) responseObserver);
          break;
        case METHODID_GET_USERS:
          serviceImpl.getUsers((com.sibehgoodbank.grpc.user.GetUsersRequest) request,
              (io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.user.GetUsersResponse>) responseObserver);
          break;
        case METHODID_USER_EXISTS:
          serviceImpl.userExists((com.sibehgoodbank.grpc.user.UserExistsRequest) request,
              (io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.user.UserExistsResponse>) responseObserver);
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
          getGetUserMethod(),
          io.grpc.stub.ServerCalls.asyncUnaryCall(
            new MethodHandlers<
              com.sibehgoodbank.grpc.user.GetUserRequest,
              com.sibehgoodbank.grpc.user.UserResponse>(
                service, METHODID_GET_USER)))
        .addMethod(
          getGetUserByEmailMethod(),
          io.grpc.stub.ServerCalls.asyncUnaryCall(
            new MethodHandlers<
              com.sibehgoodbank.grpc.user.GetUserByEmailRequest,
              com.sibehgoodbank.grpc.user.UserResponse>(
                service, METHODID_GET_USER_BY_EMAIL)))
        .addMethod(
          getValidateUserMethod(),
          io.grpc.stub.ServerCalls.asyncUnaryCall(
            new MethodHandlers<
              com.sibehgoodbank.grpc.user.ValidateUserRequest,
              com.sibehgoodbank.grpc.user.ValidateUserResponse>(
                service, METHODID_VALIDATE_USER)))
        .addMethod(
          getGetUsersMethod(),
          io.grpc.stub.ServerCalls.asyncUnaryCall(
            new MethodHandlers<
              com.sibehgoodbank.grpc.user.GetUsersRequest,
              com.sibehgoodbank.grpc.user.GetUsersResponse>(
                service, METHODID_GET_USERS)))
        .addMethod(
          getUserExistsMethod(),
          io.grpc.stub.ServerCalls.asyncUnaryCall(
            new MethodHandlers<
              com.sibehgoodbank.grpc.user.UserExistsRequest,
              com.sibehgoodbank.grpc.user.UserExistsResponse>(
                service, METHODID_USER_EXISTS)))
        .build();
  }

  private static abstract class UserServiceBaseDescriptorSupplier
      implements io.grpc.protobuf.ProtoFileDescriptorSupplier, io.grpc.protobuf.ProtoServiceDescriptorSupplier {
    UserServiceBaseDescriptorSupplier() {}

    @java.lang.Override
    public com.google.protobuf.Descriptors.FileDescriptor getFileDescriptor() {
      return com.sibehgoodbank.grpc.user.UserServiceProto.getDescriptor();
    }

    @java.lang.Override
    public com.google.protobuf.Descriptors.ServiceDescriptor getServiceDescriptor() {
      return getFileDescriptor().findServiceByName("UserService");
    }
  }

  private static final class UserServiceFileDescriptorSupplier
      extends UserServiceBaseDescriptorSupplier {
    UserServiceFileDescriptorSupplier() {}
  }

  private static final class UserServiceMethodDescriptorSupplier
      extends UserServiceBaseDescriptorSupplier
      implements io.grpc.protobuf.ProtoMethodDescriptorSupplier {
    private final java.lang.String methodName;

    UserServiceMethodDescriptorSupplier(java.lang.String methodName) {
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
      synchronized (UserServiceGrpc.class) {
        result = serviceDescriptor;
        if (result == null) {
          serviceDescriptor = result = io.grpc.ServiceDescriptor.newBuilder(SERVICE_NAME)
              .setSchemaDescriptor(new UserServiceFileDescriptorSupplier())
              .addMethod(getGetUserMethod())
              .addMethod(getGetUserByEmailMethod())
              .addMethod(getValidateUserMethod())
              .addMethod(getGetUsersMethod())
              .addMethod(getUserExistsMethod())
              .build();
        }
      }
    }
    return result;
  }
}
