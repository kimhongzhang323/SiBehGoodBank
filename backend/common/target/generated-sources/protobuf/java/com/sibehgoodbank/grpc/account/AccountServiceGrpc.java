package com.sibehgoodbank.grpc.account;

import static io.grpc.MethodDescriptor.generateFullMethodName;

/**
 * <pre>
 * Account Service
 * </pre>
 */
@javax.annotation.Generated(
    value = "by gRPC proto compiler (version 1.60.0)",
    comments = "Source: account_service.proto")
@io.grpc.stub.annotations.GrpcGenerated
public final class AccountServiceGrpc {

  private AccountServiceGrpc() {}

  public static final java.lang.String SERVICE_NAME = "com.sibehgoodbank.grpc.account.AccountService";

  // Static method descriptors that strictly reflect the proto.
  private static volatile io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.account.GetAccountRequest,
      com.sibehgoodbank.grpc.account.AccountResponse> getGetAccountMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "GetAccount",
      requestType = com.sibehgoodbank.grpc.account.GetAccountRequest.class,
      responseType = com.sibehgoodbank.grpc.account.AccountResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.account.GetAccountRequest,
      com.sibehgoodbank.grpc.account.AccountResponse> getGetAccountMethod() {
    io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.account.GetAccountRequest, com.sibehgoodbank.grpc.account.AccountResponse> getGetAccountMethod;
    if ((getGetAccountMethod = AccountServiceGrpc.getGetAccountMethod) == null) {
      synchronized (AccountServiceGrpc.class) {
        if ((getGetAccountMethod = AccountServiceGrpc.getGetAccountMethod) == null) {
          AccountServiceGrpc.getGetAccountMethod = getGetAccountMethod =
              io.grpc.MethodDescriptor.<com.sibehgoodbank.grpc.account.GetAccountRequest, com.sibehgoodbank.grpc.account.AccountResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "GetAccount"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.sibehgoodbank.grpc.account.GetAccountRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.sibehgoodbank.grpc.account.AccountResponse.getDefaultInstance()))
              .setSchemaDescriptor(new AccountServiceMethodDescriptorSupplier("GetAccount"))
              .build();
        }
      }
    }
    return getGetAccountMethod;
  }

  private static volatile io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.account.GetAccountByNumberRequest,
      com.sibehgoodbank.grpc.account.AccountResponse> getGetAccountByNumberMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "GetAccountByNumber",
      requestType = com.sibehgoodbank.grpc.account.GetAccountByNumberRequest.class,
      responseType = com.sibehgoodbank.grpc.account.AccountResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.account.GetAccountByNumberRequest,
      com.sibehgoodbank.grpc.account.AccountResponse> getGetAccountByNumberMethod() {
    io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.account.GetAccountByNumberRequest, com.sibehgoodbank.grpc.account.AccountResponse> getGetAccountByNumberMethod;
    if ((getGetAccountByNumberMethod = AccountServiceGrpc.getGetAccountByNumberMethod) == null) {
      synchronized (AccountServiceGrpc.class) {
        if ((getGetAccountByNumberMethod = AccountServiceGrpc.getGetAccountByNumberMethod) == null) {
          AccountServiceGrpc.getGetAccountByNumberMethod = getGetAccountByNumberMethod =
              io.grpc.MethodDescriptor.<com.sibehgoodbank.grpc.account.GetAccountByNumberRequest, com.sibehgoodbank.grpc.account.AccountResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "GetAccountByNumber"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.sibehgoodbank.grpc.account.GetAccountByNumberRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.sibehgoodbank.grpc.account.AccountResponse.getDefaultInstance()))
              .setSchemaDescriptor(new AccountServiceMethodDescriptorSupplier("GetAccountByNumber"))
              .build();
        }
      }
    }
    return getGetAccountByNumberMethod;
  }

  private static volatile io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.account.GetAccountsByUserRequest,
      com.sibehgoodbank.grpc.account.AccountsResponse> getGetAccountsByUserMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "GetAccountsByUser",
      requestType = com.sibehgoodbank.grpc.account.GetAccountsByUserRequest.class,
      responseType = com.sibehgoodbank.grpc.account.AccountsResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.account.GetAccountsByUserRequest,
      com.sibehgoodbank.grpc.account.AccountsResponse> getGetAccountsByUserMethod() {
    io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.account.GetAccountsByUserRequest, com.sibehgoodbank.grpc.account.AccountsResponse> getGetAccountsByUserMethod;
    if ((getGetAccountsByUserMethod = AccountServiceGrpc.getGetAccountsByUserMethod) == null) {
      synchronized (AccountServiceGrpc.class) {
        if ((getGetAccountsByUserMethod = AccountServiceGrpc.getGetAccountsByUserMethod) == null) {
          AccountServiceGrpc.getGetAccountsByUserMethod = getGetAccountsByUserMethod =
              io.grpc.MethodDescriptor.<com.sibehgoodbank.grpc.account.GetAccountsByUserRequest, com.sibehgoodbank.grpc.account.AccountsResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "GetAccountsByUser"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.sibehgoodbank.grpc.account.GetAccountsByUserRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.sibehgoodbank.grpc.account.AccountsResponse.getDefaultInstance()))
              .setSchemaDescriptor(new AccountServiceMethodDescriptorSupplier("GetAccountsByUser"))
              .build();
        }
      }
    }
    return getGetAccountsByUserMethod;
  }

  private static volatile io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.account.ValidateAccountRequest,
      com.sibehgoodbank.grpc.account.ValidateAccountResponse> getValidateAccountMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "ValidateAccount",
      requestType = com.sibehgoodbank.grpc.account.ValidateAccountRequest.class,
      responseType = com.sibehgoodbank.grpc.account.ValidateAccountResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.account.ValidateAccountRequest,
      com.sibehgoodbank.grpc.account.ValidateAccountResponse> getValidateAccountMethod() {
    io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.account.ValidateAccountRequest, com.sibehgoodbank.grpc.account.ValidateAccountResponse> getValidateAccountMethod;
    if ((getValidateAccountMethod = AccountServiceGrpc.getValidateAccountMethod) == null) {
      synchronized (AccountServiceGrpc.class) {
        if ((getValidateAccountMethod = AccountServiceGrpc.getValidateAccountMethod) == null) {
          AccountServiceGrpc.getValidateAccountMethod = getValidateAccountMethod =
              io.grpc.MethodDescriptor.<com.sibehgoodbank.grpc.account.ValidateAccountRequest, com.sibehgoodbank.grpc.account.ValidateAccountResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "ValidateAccount"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.sibehgoodbank.grpc.account.ValidateAccountRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.sibehgoodbank.grpc.account.ValidateAccountResponse.getDefaultInstance()))
              .setSchemaDescriptor(new AccountServiceMethodDescriptorSupplier("ValidateAccount"))
              .build();
        }
      }
    }
    return getValidateAccountMethod;
  }

  private static volatile io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.account.GetBalanceRequest,
      com.sibehgoodbank.grpc.account.BalanceResponse> getGetBalanceMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "GetBalance",
      requestType = com.sibehgoodbank.grpc.account.GetBalanceRequest.class,
      responseType = com.sibehgoodbank.grpc.account.BalanceResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.account.GetBalanceRequest,
      com.sibehgoodbank.grpc.account.BalanceResponse> getGetBalanceMethod() {
    io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.account.GetBalanceRequest, com.sibehgoodbank.grpc.account.BalanceResponse> getGetBalanceMethod;
    if ((getGetBalanceMethod = AccountServiceGrpc.getGetBalanceMethod) == null) {
      synchronized (AccountServiceGrpc.class) {
        if ((getGetBalanceMethod = AccountServiceGrpc.getGetBalanceMethod) == null) {
          AccountServiceGrpc.getGetBalanceMethod = getGetBalanceMethod =
              io.grpc.MethodDescriptor.<com.sibehgoodbank.grpc.account.GetBalanceRequest, com.sibehgoodbank.grpc.account.BalanceResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "GetBalance"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.sibehgoodbank.grpc.account.GetBalanceRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.sibehgoodbank.grpc.account.BalanceResponse.getDefaultInstance()))
              .setSchemaDescriptor(new AccountServiceMethodDescriptorSupplier("GetBalance"))
              .build();
        }
      }
    }
    return getGetBalanceMethod;
  }

  private static volatile io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.account.UpdateBalanceRequest,
      com.sibehgoodbank.grpc.account.UpdateBalanceResponse> getUpdateBalanceMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "UpdateBalance",
      requestType = com.sibehgoodbank.grpc.account.UpdateBalanceRequest.class,
      responseType = com.sibehgoodbank.grpc.account.UpdateBalanceResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.account.UpdateBalanceRequest,
      com.sibehgoodbank.grpc.account.UpdateBalanceResponse> getUpdateBalanceMethod() {
    io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.account.UpdateBalanceRequest, com.sibehgoodbank.grpc.account.UpdateBalanceResponse> getUpdateBalanceMethod;
    if ((getUpdateBalanceMethod = AccountServiceGrpc.getUpdateBalanceMethod) == null) {
      synchronized (AccountServiceGrpc.class) {
        if ((getUpdateBalanceMethod = AccountServiceGrpc.getUpdateBalanceMethod) == null) {
          AccountServiceGrpc.getUpdateBalanceMethod = getUpdateBalanceMethod =
              io.grpc.MethodDescriptor.<com.sibehgoodbank.grpc.account.UpdateBalanceRequest, com.sibehgoodbank.grpc.account.UpdateBalanceResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "UpdateBalance"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.sibehgoodbank.grpc.account.UpdateBalanceRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.sibehgoodbank.grpc.account.UpdateBalanceResponse.getDefaultInstance()))
              .setSchemaDescriptor(new AccountServiceMethodDescriptorSupplier("UpdateBalance"))
              .build();
        }
      }
    }
    return getUpdateBalanceMethod;
  }

  private static volatile io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.account.HoldFundsRequest,
      com.sibehgoodbank.grpc.account.HoldResponse> getHoldFundsMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "HoldFunds",
      requestType = com.sibehgoodbank.grpc.account.HoldFundsRequest.class,
      responseType = com.sibehgoodbank.grpc.account.HoldResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.account.HoldFundsRequest,
      com.sibehgoodbank.grpc.account.HoldResponse> getHoldFundsMethod() {
    io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.account.HoldFundsRequest, com.sibehgoodbank.grpc.account.HoldResponse> getHoldFundsMethod;
    if ((getHoldFundsMethod = AccountServiceGrpc.getHoldFundsMethod) == null) {
      synchronized (AccountServiceGrpc.class) {
        if ((getHoldFundsMethod = AccountServiceGrpc.getHoldFundsMethod) == null) {
          AccountServiceGrpc.getHoldFundsMethod = getHoldFundsMethod =
              io.grpc.MethodDescriptor.<com.sibehgoodbank.grpc.account.HoldFundsRequest, com.sibehgoodbank.grpc.account.HoldResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "HoldFunds"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.sibehgoodbank.grpc.account.HoldFundsRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.sibehgoodbank.grpc.account.HoldResponse.getDefaultInstance()))
              .setSchemaDescriptor(new AccountServiceMethodDescriptorSupplier("HoldFunds"))
              .build();
        }
      }
    }
    return getHoldFundsMethod;
  }

  private static volatile io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.account.ReleaseHoldRequest,
      com.sibehgoodbank.grpc.account.HoldResponse> getReleaseHoldMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "ReleaseHold",
      requestType = com.sibehgoodbank.grpc.account.ReleaseHoldRequest.class,
      responseType = com.sibehgoodbank.grpc.account.HoldResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.account.ReleaseHoldRequest,
      com.sibehgoodbank.grpc.account.HoldResponse> getReleaseHoldMethod() {
    io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.account.ReleaseHoldRequest, com.sibehgoodbank.grpc.account.HoldResponse> getReleaseHoldMethod;
    if ((getReleaseHoldMethod = AccountServiceGrpc.getReleaseHoldMethod) == null) {
      synchronized (AccountServiceGrpc.class) {
        if ((getReleaseHoldMethod = AccountServiceGrpc.getReleaseHoldMethod) == null) {
          AccountServiceGrpc.getReleaseHoldMethod = getReleaseHoldMethod =
              io.grpc.MethodDescriptor.<com.sibehgoodbank.grpc.account.ReleaseHoldRequest, com.sibehgoodbank.grpc.account.HoldResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "ReleaseHold"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.sibehgoodbank.grpc.account.ReleaseHoldRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.sibehgoodbank.grpc.account.HoldResponse.getDefaultInstance()))
              .setSchemaDescriptor(new AccountServiceMethodDescriptorSupplier("ReleaseHold"))
              .build();
        }
      }
    }
    return getReleaseHoldMethod;
  }

  private static volatile io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.account.AccountExistsRequest,
      com.sibehgoodbank.grpc.account.AccountExistsResponse> getAccountExistsMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "AccountExists",
      requestType = com.sibehgoodbank.grpc.account.AccountExistsRequest.class,
      responseType = com.sibehgoodbank.grpc.account.AccountExistsResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.account.AccountExistsRequest,
      com.sibehgoodbank.grpc.account.AccountExistsResponse> getAccountExistsMethod() {
    io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.account.AccountExistsRequest, com.sibehgoodbank.grpc.account.AccountExistsResponse> getAccountExistsMethod;
    if ((getAccountExistsMethod = AccountServiceGrpc.getAccountExistsMethod) == null) {
      synchronized (AccountServiceGrpc.class) {
        if ((getAccountExistsMethod = AccountServiceGrpc.getAccountExistsMethod) == null) {
          AccountServiceGrpc.getAccountExistsMethod = getAccountExistsMethod =
              io.grpc.MethodDescriptor.<com.sibehgoodbank.grpc.account.AccountExistsRequest, com.sibehgoodbank.grpc.account.AccountExistsResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "AccountExists"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.sibehgoodbank.grpc.account.AccountExistsRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.sibehgoodbank.grpc.account.AccountExistsResponse.getDefaultInstance()))
              .setSchemaDescriptor(new AccountServiceMethodDescriptorSupplier("AccountExists"))
              .build();
        }
      }
    }
    return getAccountExistsMethod;
  }

  /**
   * Creates a new async stub that supports all call types for the service
   */
  public static AccountServiceStub newStub(io.grpc.Channel channel) {
    io.grpc.stub.AbstractStub.StubFactory<AccountServiceStub> factory =
      new io.grpc.stub.AbstractStub.StubFactory<AccountServiceStub>() {
        @java.lang.Override
        public AccountServiceStub newStub(io.grpc.Channel channel, io.grpc.CallOptions callOptions) {
          return new AccountServiceStub(channel, callOptions);
        }
      };
    return AccountServiceStub.newStub(factory, channel);
  }

  /**
   * Creates a new blocking-style stub that supports unary and streaming output calls on the service
   */
  public static AccountServiceBlockingStub newBlockingStub(
      io.grpc.Channel channel) {
    io.grpc.stub.AbstractStub.StubFactory<AccountServiceBlockingStub> factory =
      new io.grpc.stub.AbstractStub.StubFactory<AccountServiceBlockingStub>() {
        @java.lang.Override
        public AccountServiceBlockingStub newStub(io.grpc.Channel channel, io.grpc.CallOptions callOptions) {
          return new AccountServiceBlockingStub(channel, callOptions);
        }
      };
    return AccountServiceBlockingStub.newStub(factory, channel);
  }

  /**
   * Creates a new ListenableFuture-style stub that supports unary calls on the service
   */
  public static AccountServiceFutureStub newFutureStub(
      io.grpc.Channel channel) {
    io.grpc.stub.AbstractStub.StubFactory<AccountServiceFutureStub> factory =
      new io.grpc.stub.AbstractStub.StubFactory<AccountServiceFutureStub>() {
        @java.lang.Override
        public AccountServiceFutureStub newStub(io.grpc.Channel channel, io.grpc.CallOptions callOptions) {
          return new AccountServiceFutureStub(channel, callOptions);
        }
      };
    return AccountServiceFutureStub.newStub(factory, channel);
  }

  /**
   * <pre>
   * Account Service
   * </pre>
   */
  public interface AsyncService {

    /**
     * <pre>
     * Get account by ID
     * </pre>
     */
    default void getAccount(com.sibehgoodbank.grpc.account.GetAccountRequest request,
        io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.account.AccountResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getGetAccountMethod(), responseObserver);
    }

    /**
     * <pre>
     * Get account by account number
     * </pre>
     */
    default void getAccountByNumber(com.sibehgoodbank.grpc.account.GetAccountByNumberRequest request,
        io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.account.AccountResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getGetAccountByNumberMethod(), responseObserver);
    }

    /**
     * <pre>
     * Get all accounts for a user
     * </pre>
     */
    default void getAccountsByUser(com.sibehgoodbank.grpc.account.GetAccountsByUserRequest request,
        io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.account.AccountsResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getGetAccountsByUserMethod(), responseObserver);
    }

    /**
     * <pre>
     * Validate account
     * </pre>
     */
    default void validateAccount(com.sibehgoodbank.grpc.account.ValidateAccountRequest request,
        io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.account.ValidateAccountResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getValidateAccountMethod(), responseObserver);
    }

    /**
     * <pre>
     * Get account balance
     * </pre>
     */
    default void getBalance(com.sibehgoodbank.grpc.account.GetBalanceRequest request,
        io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.account.BalanceResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getGetBalanceMethod(), responseObserver);
    }

    /**
     * <pre>
     * Update account balance (internal)
     * </pre>
     */
    default void updateBalance(com.sibehgoodbank.grpc.account.UpdateBalanceRequest request,
        io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.account.UpdateBalanceResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getUpdateBalanceMethod(), responseObserver);
    }

    /**
     * <pre>
     * Hold funds for pending transaction
     * </pre>
     */
    default void holdFunds(com.sibehgoodbank.grpc.account.HoldFundsRequest request,
        io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.account.HoldResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getHoldFundsMethod(), responseObserver);
    }

    /**
     * <pre>
     * Release or capture held funds
     * </pre>
     */
    default void releaseHold(com.sibehgoodbank.grpc.account.ReleaseHoldRequest request,
        io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.account.HoldResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getReleaseHoldMethod(), responseObserver);
    }

    /**
     * <pre>
     * Check if account exists
     * </pre>
     */
    default void accountExists(com.sibehgoodbank.grpc.account.AccountExistsRequest request,
        io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.account.AccountExistsResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getAccountExistsMethod(), responseObserver);
    }
  }

  /**
   * Base class for the server implementation of the service AccountService.
   * <pre>
   * Account Service
   * </pre>
   */
  public static abstract class AccountServiceImplBase
      implements io.grpc.BindableService, AsyncService {

    @java.lang.Override public final io.grpc.ServerServiceDefinition bindService() {
      return AccountServiceGrpc.bindService(this);
    }
  }

  /**
   * A stub to allow clients to do asynchronous rpc calls to service AccountService.
   * <pre>
   * Account Service
   * </pre>
   */
  public static final class AccountServiceStub
      extends io.grpc.stub.AbstractAsyncStub<AccountServiceStub> {
    private AccountServiceStub(
        io.grpc.Channel channel, io.grpc.CallOptions callOptions) {
      super(channel, callOptions);
    }

    @java.lang.Override
    protected AccountServiceStub build(
        io.grpc.Channel channel, io.grpc.CallOptions callOptions) {
      return new AccountServiceStub(channel, callOptions);
    }

    /**
     * <pre>
     * Get account by ID
     * </pre>
     */
    public void getAccount(com.sibehgoodbank.grpc.account.GetAccountRequest request,
        io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.account.AccountResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getGetAccountMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     * <pre>
     * Get account by account number
     * </pre>
     */
    public void getAccountByNumber(com.sibehgoodbank.grpc.account.GetAccountByNumberRequest request,
        io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.account.AccountResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getGetAccountByNumberMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     * <pre>
     * Get all accounts for a user
     * </pre>
     */
    public void getAccountsByUser(com.sibehgoodbank.grpc.account.GetAccountsByUserRequest request,
        io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.account.AccountsResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getGetAccountsByUserMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     * <pre>
     * Validate account
     * </pre>
     */
    public void validateAccount(com.sibehgoodbank.grpc.account.ValidateAccountRequest request,
        io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.account.ValidateAccountResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getValidateAccountMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     * <pre>
     * Get account balance
     * </pre>
     */
    public void getBalance(com.sibehgoodbank.grpc.account.GetBalanceRequest request,
        io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.account.BalanceResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getGetBalanceMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     * <pre>
     * Update account balance (internal)
     * </pre>
     */
    public void updateBalance(com.sibehgoodbank.grpc.account.UpdateBalanceRequest request,
        io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.account.UpdateBalanceResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getUpdateBalanceMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     * <pre>
     * Hold funds for pending transaction
     * </pre>
     */
    public void holdFunds(com.sibehgoodbank.grpc.account.HoldFundsRequest request,
        io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.account.HoldResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getHoldFundsMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     * <pre>
     * Release or capture held funds
     * </pre>
     */
    public void releaseHold(com.sibehgoodbank.grpc.account.ReleaseHoldRequest request,
        io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.account.HoldResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getReleaseHoldMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     * <pre>
     * Check if account exists
     * </pre>
     */
    public void accountExists(com.sibehgoodbank.grpc.account.AccountExistsRequest request,
        io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.account.AccountExistsResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getAccountExistsMethod(), getCallOptions()), request, responseObserver);
    }
  }

  /**
   * A stub to allow clients to do synchronous rpc calls to service AccountService.
   * <pre>
   * Account Service
   * </pre>
   */
  public static final class AccountServiceBlockingStub
      extends io.grpc.stub.AbstractBlockingStub<AccountServiceBlockingStub> {
    private AccountServiceBlockingStub(
        io.grpc.Channel channel, io.grpc.CallOptions callOptions) {
      super(channel, callOptions);
    }

    @java.lang.Override
    protected AccountServiceBlockingStub build(
        io.grpc.Channel channel, io.grpc.CallOptions callOptions) {
      return new AccountServiceBlockingStub(channel, callOptions);
    }

    /**
     * <pre>
     * Get account by ID
     * </pre>
     */
    public com.sibehgoodbank.grpc.account.AccountResponse getAccount(com.sibehgoodbank.grpc.account.GetAccountRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getGetAccountMethod(), getCallOptions(), request);
    }

    /**
     * <pre>
     * Get account by account number
     * </pre>
     */
    public com.sibehgoodbank.grpc.account.AccountResponse getAccountByNumber(com.sibehgoodbank.grpc.account.GetAccountByNumberRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getGetAccountByNumberMethod(), getCallOptions(), request);
    }

    /**
     * <pre>
     * Get all accounts for a user
     * </pre>
     */
    public com.sibehgoodbank.grpc.account.AccountsResponse getAccountsByUser(com.sibehgoodbank.grpc.account.GetAccountsByUserRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getGetAccountsByUserMethod(), getCallOptions(), request);
    }

    /**
     * <pre>
     * Validate account
     * </pre>
     */
    public com.sibehgoodbank.grpc.account.ValidateAccountResponse validateAccount(com.sibehgoodbank.grpc.account.ValidateAccountRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getValidateAccountMethod(), getCallOptions(), request);
    }

    /**
     * <pre>
     * Get account balance
     * </pre>
     */
    public com.sibehgoodbank.grpc.account.BalanceResponse getBalance(com.sibehgoodbank.grpc.account.GetBalanceRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getGetBalanceMethod(), getCallOptions(), request);
    }

    /**
     * <pre>
     * Update account balance (internal)
     * </pre>
     */
    public com.sibehgoodbank.grpc.account.UpdateBalanceResponse updateBalance(com.sibehgoodbank.grpc.account.UpdateBalanceRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getUpdateBalanceMethod(), getCallOptions(), request);
    }

    /**
     * <pre>
     * Hold funds for pending transaction
     * </pre>
     */
    public com.sibehgoodbank.grpc.account.HoldResponse holdFunds(com.sibehgoodbank.grpc.account.HoldFundsRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getHoldFundsMethod(), getCallOptions(), request);
    }

    /**
     * <pre>
     * Release or capture held funds
     * </pre>
     */
    public com.sibehgoodbank.grpc.account.HoldResponse releaseHold(com.sibehgoodbank.grpc.account.ReleaseHoldRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getReleaseHoldMethod(), getCallOptions(), request);
    }

    /**
     * <pre>
     * Check if account exists
     * </pre>
     */
    public com.sibehgoodbank.grpc.account.AccountExistsResponse accountExists(com.sibehgoodbank.grpc.account.AccountExistsRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getAccountExistsMethod(), getCallOptions(), request);
    }
  }

  /**
   * A stub to allow clients to do ListenableFuture-style rpc calls to service AccountService.
   * <pre>
   * Account Service
   * </pre>
   */
  public static final class AccountServiceFutureStub
      extends io.grpc.stub.AbstractFutureStub<AccountServiceFutureStub> {
    private AccountServiceFutureStub(
        io.grpc.Channel channel, io.grpc.CallOptions callOptions) {
      super(channel, callOptions);
    }

    @java.lang.Override
    protected AccountServiceFutureStub build(
        io.grpc.Channel channel, io.grpc.CallOptions callOptions) {
      return new AccountServiceFutureStub(channel, callOptions);
    }

    /**
     * <pre>
     * Get account by ID
     * </pre>
     */
    public com.google.common.util.concurrent.ListenableFuture<com.sibehgoodbank.grpc.account.AccountResponse> getAccount(
        com.sibehgoodbank.grpc.account.GetAccountRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getGetAccountMethod(), getCallOptions()), request);
    }

    /**
     * <pre>
     * Get account by account number
     * </pre>
     */
    public com.google.common.util.concurrent.ListenableFuture<com.sibehgoodbank.grpc.account.AccountResponse> getAccountByNumber(
        com.sibehgoodbank.grpc.account.GetAccountByNumberRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getGetAccountByNumberMethod(), getCallOptions()), request);
    }

    /**
     * <pre>
     * Get all accounts for a user
     * </pre>
     */
    public com.google.common.util.concurrent.ListenableFuture<com.sibehgoodbank.grpc.account.AccountsResponse> getAccountsByUser(
        com.sibehgoodbank.grpc.account.GetAccountsByUserRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getGetAccountsByUserMethod(), getCallOptions()), request);
    }

    /**
     * <pre>
     * Validate account
     * </pre>
     */
    public com.google.common.util.concurrent.ListenableFuture<com.sibehgoodbank.grpc.account.ValidateAccountResponse> validateAccount(
        com.sibehgoodbank.grpc.account.ValidateAccountRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getValidateAccountMethod(), getCallOptions()), request);
    }

    /**
     * <pre>
     * Get account balance
     * </pre>
     */
    public com.google.common.util.concurrent.ListenableFuture<com.sibehgoodbank.grpc.account.BalanceResponse> getBalance(
        com.sibehgoodbank.grpc.account.GetBalanceRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getGetBalanceMethod(), getCallOptions()), request);
    }

    /**
     * <pre>
     * Update account balance (internal)
     * </pre>
     */
    public com.google.common.util.concurrent.ListenableFuture<com.sibehgoodbank.grpc.account.UpdateBalanceResponse> updateBalance(
        com.sibehgoodbank.grpc.account.UpdateBalanceRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getUpdateBalanceMethod(), getCallOptions()), request);
    }

    /**
     * <pre>
     * Hold funds for pending transaction
     * </pre>
     */
    public com.google.common.util.concurrent.ListenableFuture<com.sibehgoodbank.grpc.account.HoldResponse> holdFunds(
        com.sibehgoodbank.grpc.account.HoldFundsRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getHoldFundsMethod(), getCallOptions()), request);
    }

    /**
     * <pre>
     * Release or capture held funds
     * </pre>
     */
    public com.google.common.util.concurrent.ListenableFuture<com.sibehgoodbank.grpc.account.HoldResponse> releaseHold(
        com.sibehgoodbank.grpc.account.ReleaseHoldRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getReleaseHoldMethod(), getCallOptions()), request);
    }

    /**
     * <pre>
     * Check if account exists
     * </pre>
     */
    public com.google.common.util.concurrent.ListenableFuture<com.sibehgoodbank.grpc.account.AccountExistsResponse> accountExists(
        com.sibehgoodbank.grpc.account.AccountExistsRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getAccountExistsMethod(), getCallOptions()), request);
    }
  }

  private static final int METHODID_GET_ACCOUNT = 0;
  private static final int METHODID_GET_ACCOUNT_BY_NUMBER = 1;
  private static final int METHODID_GET_ACCOUNTS_BY_USER = 2;
  private static final int METHODID_VALIDATE_ACCOUNT = 3;
  private static final int METHODID_GET_BALANCE = 4;
  private static final int METHODID_UPDATE_BALANCE = 5;
  private static final int METHODID_HOLD_FUNDS = 6;
  private static final int METHODID_RELEASE_HOLD = 7;
  private static final int METHODID_ACCOUNT_EXISTS = 8;

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
        case METHODID_GET_ACCOUNT:
          serviceImpl.getAccount((com.sibehgoodbank.grpc.account.GetAccountRequest) request,
              (io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.account.AccountResponse>) responseObserver);
          break;
        case METHODID_GET_ACCOUNT_BY_NUMBER:
          serviceImpl.getAccountByNumber((com.sibehgoodbank.grpc.account.GetAccountByNumberRequest) request,
              (io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.account.AccountResponse>) responseObserver);
          break;
        case METHODID_GET_ACCOUNTS_BY_USER:
          serviceImpl.getAccountsByUser((com.sibehgoodbank.grpc.account.GetAccountsByUserRequest) request,
              (io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.account.AccountsResponse>) responseObserver);
          break;
        case METHODID_VALIDATE_ACCOUNT:
          serviceImpl.validateAccount((com.sibehgoodbank.grpc.account.ValidateAccountRequest) request,
              (io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.account.ValidateAccountResponse>) responseObserver);
          break;
        case METHODID_GET_BALANCE:
          serviceImpl.getBalance((com.sibehgoodbank.grpc.account.GetBalanceRequest) request,
              (io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.account.BalanceResponse>) responseObserver);
          break;
        case METHODID_UPDATE_BALANCE:
          serviceImpl.updateBalance((com.sibehgoodbank.grpc.account.UpdateBalanceRequest) request,
              (io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.account.UpdateBalanceResponse>) responseObserver);
          break;
        case METHODID_HOLD_FUNDS:
          serviceImpl.holdFunds((com.sibehgoodbank.grpc.account.HoldFundsRequest) request,
              (io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.account.HoldResponse>) responseObserver);
          break;
        case METHODID_RELEASE_HOLD:
          serviceImpl.releaseHold((com.sibehgoodbank.grpc.account.ReleaseHoldRequest) request,
              (io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.account.HoldResponse>) responseObserver);
          break;
        case METHODID_ACCOUNT_EXISTS:
          serviceImpl.accountExists((com.sibehgoodbank.grpc.account.AccountExistsRequest) request,
              (io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.account.AccountExistsResponse>) responseObserver);
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
          getGetAccountMethod(),
          io.grpc.stub.ServerCalls.asyncUnaryCall(
            new MethodHandlers<
              com.sibehgoodbank.grpc.account.GetAccountRequest,
              com.sibehgoodbank.grpc.account.AccountResponse>(
                service, METHODID_GET_ACCOUNT)))
        .addMethod(
          getGetAccountByNumberMethod(),
          io.grpc.stub.ServerCalls.asyncUnaryCall(
            new MethodHandlers<
              com.sibehgoodbank.grpc.account.GetAccountByNumberRequest,
              com.sibehgoodbank.grpc.account.AccountResponse>(
                service, METHODID_GET_ACCOUNT_BY_NUMBER)))
        .addMethod(
          getGetAccountsByUserMethod(),
          io.grpc.stub.ServerCalls.asyncUnaryCall(
            new MethodHandlers<
              com.sibehgoodbank.grpc.account.GetAccountsByUserRequest,
              com.sibehgoodbank.grpc.account.AccountsResponse>(
                service, METHODID_GET_ACCOUNTS_BY_USER)))
        .addMethod(
          getValidateAccountMethod(),
          io.grpc.stub.ServerCalls.asyncUnaryCall(
            new MethodHandlers<
              com.sibehgoodbank.grpc.account.ValidateAccountRequest,
              com.sibehgoodbank.grpc.account.ValidateAccountResponse>(
                service, METHODID_VALIDATE_ACCOUNT)))
        .addMethod(
          getGetBalanceMethod(),
          io.grpc.stub.ServerCalls.asyncUnaryCall(
            new MethodHandlers<
              com.sibehgoodbank.grpc.account.GetBalanceRequest,
              com.sibehgoodbank.grpc.account.BalanceResponse>(
                service, METHODID_GET_BALANCE)))
        .addMethod(
          getUpdateBalanceMethod(),
          io.grpc.stub.ServerCalls.asyncUnaryCall(
            new MethodHandlers<
              com.sibehgoodbank.grpc.account.UpdateBalanceRequest,
              com.sibehgoodbank.grpc.account.UpdateBalanceResponse>(
                service, METHODID_UPDATE_BALANCE)))
        .addMethod(
          getHoldFundsMethod(),
          io.grpc.stub.ServerCalls.asyncUnaryCall(
            new MethodHandlers<
              com.sibehgoodbank.grpc.account.HoldFundsRequest,
              com.sibehgoodbank.grpc.account.HoldResponse>(
                service, METHODID_HOLD_FUNDS)))
        .addMethod(
          getReleaseHoldMethod(),
          io.grpc.stub.ServerCalls.asyncUnaryCall(
            new MethodHandlers<
              com.sibehgoodbank.grpc.account.ReleaseHoldRequest,
              com.sibehgoodbank.grpc.account.HoldResponse>(
                service, METHODID_RELEASE_HOLD)))
        .addMethod(
          getAccountExistsMethod(),
          io.grpc.stub.ServerCalls.asyncUnaryCall(
            new MethodHandlers<
              com.sibehgoodbank.grpc.account.AccountExistsRequest,
              com.sibehgoodbank.grpc.account.AccountExistsResponse>(
                service, METHODID_ACCOUNT_EXISTS)))
        .build();
  }

  private static abstract class AccountServiceBaseDescriptorSupplier
      implements io.grpc.protobuf.ProtoFileDescriptorSupplier, io.grpc.protobuf.ProtoServiceDescriptorSupplier {
    AccountServiceBaseDescriptorSupplier() {}

    @java.lang.Override
    public com.google.protobuf.Descriptors.FileDescriptor getFileDescriptor() {
      return com.sibehgoodbank.grpc.account.AccountServiceProto.getDescriptor();
    }

    @java.lang.Override
    public com.google.protobuf.Descriptors.ServiceDescriptor getServiceDescriptor() {
      return getFileDescriptor().findServiceByName("AccountService");
    }
  }

  private static final class AccountServiceFileDescriptorSupplier
      extends AccountServiceBaseDescriptorSupplier {
    AccountServiceFileDescriptorSupplier() {}
  }

  private static final class AccountServiceMethodDescriptorSupplier
      extends AccountServiceBaseDescriptorSupplier
      implements io.grpc.protobuf.ProtoMethodDescriptorSupplier {
    private final java.lang.String methodName;

    AccountServiceMethodDescriptorSupplier(java.lang.String methodName) {
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
      synchronized (AccountServiceGrpc.class) {
        result = serviceDescriptor;
        if (result == null) {
          serviceDescriptor = result = io.grpc.ServiceDescriptor.newBuilder(SERVICE_NAME)
              .setSchemaDescriptor(new AccountServiceFileDescriptorSupplier())
              .addMethod(getGetAccountMethod())
              .addMethod(getGetAccountByNumberMethod())
              .addMethod(getGetAccountsByUserMethod())
              .addMethod(getValidateAccountMethod())
              .addMethod(getGetBalanceMethod())
              .addMethod(getUpdateBalanceMethod())
              .addMethod(getHoldFundsMethod())
              .addMethod(getReleaseHoldMethod())
              .addMethod(getAccountExistsMethod())
              .build();
        }
      }
    }
    return result;
  }
}
