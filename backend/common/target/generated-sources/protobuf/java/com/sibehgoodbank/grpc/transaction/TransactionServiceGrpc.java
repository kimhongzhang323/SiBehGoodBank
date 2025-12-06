package com.sibehgoodbank.grpc.transaction;

import static io.grpc.MethodDescriptor.generateFullMethodName;

/**
 * <pre>
 * Transaction Service
 * </pre>
 */
@javax.annotation.Generated(
    value = "by gRPC proto compiler (version 1.60.0)",
    comments = "Source: transaction_service.proto")
@io.grpc.stub.annotations.GrpcGenerated
public final class TransactionServiceGrpc {

  private TransactionServiceGrpc() {}

  public static final java.lang.String SERVICE_NAME = "com.sibehgoodbank.grpc.transaction.TransactionService";

  // Static method descriptors that strictly reflect the proto.
  private static volatile io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.transaction.GetTransactionRequest,
      com.sibehgoodbank.grpc.transaction.TransactionResponse> getGetTransactionMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "GetTransaction",
      requestType = com.sibehgoodbank.grpc.transaction.GetTransactionRequest.class,
      responseType = com.sibehgoodbank.grpc.transaction.TransactionResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.transaction.GetTransactionRequest,
      com.sibehgoodbank.grpc.transaction.TransactionResponse> getGetTransactionMethod() {
    io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.transaction.GetTransactionRequest, com.sibehgoodbank.grpc.transaction.TransactionResponse> getGetTransactionMethod;
    if ((getGetTransactionMethod = TransactionServiceGrpc.getGetTransactionMethod) == null) {
      synchronized (TransactionServiceGrpc.class) {
        if ((getGetTransactionMethod = TransactionServiceGrpc.getGetTransactionMethod) == null) {
          TransactionServiceGrpc.getGetTransactionMethod = getGetTransactionMethod =
              io.grpc.MethodDescriptor.<com.sibehgoodbank.grpc.transaction.GetTransactionRequest, com.sibehgoodbank.grpc.transaction.TransactionResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "GetTransaction"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.sibehgoodbank.grpc.transaction.GetTransactionRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.sibehgoodbank.grpc.transaction.TransactionResponse.getDefaultInstance()))
              .setSchemaDescriptor(new TransactionServiceMethodDescriptorSupplier("GetTransaction"))
              .build();
        }
      }
    }
    return getGetTransactionMethod;
  }

  private static volatile io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.transaction.GetTransactionsByAccountRequest,
      com.sibehgoodbank.grpc.transaction.TransactionsResponse> getGetTransactionsByAccountMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "GetTransactionsByAccount",
      requestType = com.sibehgoodbank.grpc.transaction.GetTransactionsByAccountRequest.class,
      responseType = com.sibehgoodbank.grpc.transaction.TransactionsResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.transaction.GetTransactionsByAccountRequest,
      com.sibehgoodbank.grpc.transaction.TransactionsResponse> getGetTransactionsByAccountMethod() {
    io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.transaction.GetTransactionsByAccountRequest, com.sibehgoodbank.grpc.transaction.TransactionsResponse> getGetTransactionsByAccountMethod;
    if ((getGetTransactionsByAccountMethod = TransactionServiceGrpc.getGetTransactionsByAccountMethod) == null) {
      synchronized (TransactionServiceGrpc.class) {
        if ((getGetTransactionsByAccountMethod = TransactionServiceGrpc.getGetTransactionsByAccountMethod) == null) {
          TransactionServiceGrpc.getGetTransactionsByAccountMethod = getGetTransactionsByAccountMethod =
              io.grpc.MethodDescriptor.<com.sibehgoodbank.grpc.transaction.GetTransactionsByAccountRequest, com.sibehgoodbank.grpc.transaction.TransactionsResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "GetTransactionsByAccount"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.sibehgoodbank.grpc.transaction.GetTransactionsByAccountRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.sibehgoodbank.grpc.transaction.TransactionsResponse.getDefaultInstance()))
              .setSchemaDescriptor(new TransactionServiceMethodDescriptorSupplier("GetTransactionsByAccount"))
              .build();
        }
      }
    }
    return getGetTransactionsByAccountMethod;
  }

  private static volatile io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.transaction.GetTransactionsByUserRequest,
      com.sibehgoodbank.grpc.transaction.TransactionsResponse> getGetTransactionsByUserMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "GetTransactionsByUser",
      requestType = com.sibehgoodbank.grpc.transaction.GetTransactionsByUserRequest.class,
      responseType = com.sibehgoodbank.grpc.transaction.TransactionsResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.transaction.GetTransactionsByUserRequest,
      com.sibehgoodbank.grpc.transaction.TransactionsResponse> getGetTransactionsByUserMethod() {
    io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.transaction.GetTransactionsByUserRequest, com.sibehgoodbank.grpc.transaction.TransactionsResponse> getGetTransactionsByUserMethod;
    if ((getGetTransactionsByUserMethod = TransactionServiceGrpc.getGetTransactionsByUserMethod) == null) {
      synchronized (TransactionServiceGrpc.class) {
        if ((getGetTransactionsByUserMethod = TransactionServiceGrpc.getGetTransactionsByUserMethod) == null) {
          TransactionServiceGrpc.getGetTransactionsByUserMethod = getGetTransactionsByUserMethod =
              io.grpc.MethodDescriptor.<com.sibehgoodbank.grpc.transaction.GetTransactionsByUserRequest, com.sibehgoodbank.grpc.transaction.TransactionsResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "GetTransactionsByUser"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.sibehgoodbank.grpc.transaction.GetTransactionsByUserRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.sibehgoodbank.grpc.transaction.TransactionsResponse.getDefaultInstance()))
              .setSchemaDescriptor(new TransactionServiceMethodDescriptorSupplier("GetTransactionsByUser"))
              .build();
        }
      }
    }
    return getGetTransactionsByUserMethod;
  }

  private static volatile io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.transaction.CreateTransferRequest,
      com.sibehgoodbank.grpc.transaction.TransactionCreatedResponse> getCreateTransferMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "CreateTransfer",
      requestType = com.sibehgoodbank.grpc.transaction.CreateTransferRequest.class,
      responseType = com.sibehgoodbank.grpc.transaction.TransactionCreatedResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.transaction.CreateTransferRequest,
      com.sibehgoodbank.grpc.transaction.TransactionCreatedResponse> getCreateTransferMethod() {
    io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.transaction.CreateTransferRequest, com.sibehgoodbank.grpc.transaction.TransactionCreatedResponse> getCreateTransferMethod;
    if ((getCreateTransferMethod = TransactionServiceGrpc.getCreateTransferMethod) == null) {
      synchronized (TransactionServiceGrpc.class) {
        if ((getCreateTransferMethod = TransactionServiceGrpc.getCreateTransferMethod) == null) {
          TransactionServiceGrpc.getCreateTransferMethod = getCreateTransferMethod =
              io.grpc.MethodDescriptor.<com.sibehgoodbank.grpc.transaction.CreateTransferRequest, com.sibehgoodbank.grpc.transaction.TransactionCreatedResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "CreateTransfer"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.sibehgoodbank.grpc.transaction.CreateTransferRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.sibehgoodbank.grpc.transaction.TransactionCreatedResponse.getDefaultInstance()))
              .setSchemaDescriptor(new TransactionServiceMethodDescriptorSupplier("CreateTransfer"))
              .build();
        }
      }
    }
    return getCreateTransferMethod;
  }

  private static volatile io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.transaction.CreateDepositRequest,
      com.sibehgoodbank.grpc.transaction.TransactionCreatedResponse> getCreateDepositMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "CreateDeposit",
      requestType = com.sibehgoodbank.grpc.transaction.CreateDepositRequest.class,
      responseType = com.sibehgoodbank.grpc.transaction.TransactionCreatedResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.transaction.CreateDepositRequest,
      com.sibehgoodbank.grpc.transaction.TransactionCreatedResponse> getCreateDepositMethod() {
    io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.transaction.CreateDepositRequest, com.sibehgoodbank.grpc.transaction.TransactionCreatedResponse> getCreateDepositMethod;
    if ((getCreateDepositMethod = TransactionServiceGrpc.getCreateDepositMethod) == null) {
      synchronized (TransactionServiceGrpc.class) {
        if ((getCreateDepositMethod = TransactionServiceGrpc.getCreateDepositMethod) == null) {
          TransactionServiceGrpc.getCreateDepositMethod = getCreateDepositMethod =
              io.grpc.MethodDescriptor.<com.sibehgoodbank.grpc.transaction.CreateDepositRequest, com.sibehgoodbank.grpc.transaction.TransactionCreatedResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "CreateDeposit"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.sibehgoodbank.grpc.transaction.CreateDepositRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.sibehgoodbank.grpc.transaction.TransactionCreatedResponse.getDefaultInstance()))
              .setSchemaDescriptor(new TransactionServiceMethodDescriptorSupplier("CreateDeposit"))
              .build();
        }
      }
    }
    return getCreateDepositMethod;
  }

  private static volatile io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.transaction.CreateWithdrawalRequest,
      com.sibehgoodbank.grpc.transaction.TransactionCreatedResponse> getCreateWithdrawalMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "CreateWithdrawal",
      requestType = com.sibehgoodbank.grpc.transaction.CreateWithdrawalRequest.class,
      responseType = com.sibehgoodbank.grpc.transaction.TransactionCreatedResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.transaction.CreateWithdrawalRequest,
      com.sibehgoodbank.grpc.transaction.TransactionCreatedResponse> getCreateWithdrawalMethod() {
    io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.transaction.CreateWithdrawalRequest, com.sibehgoodbank.grpc.transaction.TransactionCreatedResponse> getCreateWithdrawalMethod;
    if ((getCreateWithdrawalMethod = TransactionServiceGrpc.getCreateWithdrawalMethod) == null) {
      synchronized (TransactionServiceGrpc.class) {
        if ((getCreateWithdrawalMethod = TransactionServiceGrpc.getCreateWithdrawalMethod) == null) {
          TransactionServiceGrpc.getCreateWithdrawalMethod = getCreateWithdrawalMethod =
              io.grpc.MethodDescriptor.<com.sibehgoodbank.grpc.transaction.CreateWithdrawalRequest, com.sibehgoodbank.grpc.transaction.TransactionCreatedResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "CreateWithdrawal"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.sibehgoodbank.grpc.transaction.CreateWithdrawalRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.sibehgoodbank.grpc.transaction.TransactionCreatedResponse.getDefaultInstance()))
              .setSchemaDescriptor(new TransactionServiceMethodDescriptorSupplier("CreateWithdrawal"))
              .build();
        }
      }
    }
    return getCreateWithdrawalMethod;
  }

  private static volatile io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.transaction.GetTransactionStatusRequest,
      com.sibehgoodbank.grpc.transaction.TransactionStatusResponse> getGetTransactionStatusMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "GetTransactionStatus",
      requestType = com.sibehgoodbank.grpc.transaction.GetTransactionStatusRequest.class,
      responseType = com.sibehgoodbank.grpc.transaction.TransactionStatusResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.transaction.GetTransactionStatusRequest,
      com.sibehgoodbank.grpc.transaction.TransactionStatusResponse> getGetTransactionStatusMethod() {
    io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.transaction.GetTransactionStatusRequest, com.sibehgoodbank.grpc.transaction.TransactionStatusResponse> getGetTransactionStatusMethod;
    if ((getGetTransactionStatusMethod = TransactionServiceGrpc.getGetTransactionStatusMethod) == null) {
      synchronized (TransactionServiceGrpc.class) {
        if ((getGetTransactionStatusMethod = TransactionServiceGrpc.getGetTransactionStatusMethod) == null) {
          TransactionServiceGrpc.getGetTransactionStatusMethod = getGetTransactionStatusMethod =
              io.grpc.MethodDescriptor.<com.sibehgoodbank.grpc.transaction.GetTransactionStatusRequest, com.sibehgoodbank.grpc.transaction.TransactionStatusResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "GetTransactionStatus"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.sibehgoodbank.grpc.transaction.GetTransactionStatusRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.sibehgoodbank.grpc.transaction.TransactionStatusResponse.getDefaultInstance()))
              .setSchemaDescriptor(new TransactionServiceMethodDescriptorSupplier("GetTransactionStatus"))
              .build();
        }
      }
    }
    return getGetTransactionStatusMethod;
  }

  private static volatile io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.transaction.CancelTransactionRequest,
      com.sibehgoodbank.grpc.transaction.CancelTransactionResponse> getCancelTransactionMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "CancelTransaction",
      requestType = com.sibehgoodbank.grpc.transaction.CancelTransactionRequest.class,
      responseType = com.sibehgoodbank.grpc.transaction.CancelTransactionResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.transaction.CancelTransactionRequest,
      com.sibehgoodbank.grpc.transaction.CancelTransactionResponse> getCancelTransactionMethod() {
    io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.transaction.CancelTransactionRequest, com.sibehgoodbank.grpc.transaction.CancelTransactionResponse> getCancelTransactionMethod;
    if ((getCancelTransactionMethod = TransactionServiceGrpc.getCancelTransactionMethod) == null) {
      synchronized (TransactionServiceGrpc.class) {
        if ((getCancelTransactionMethod = TransactionServiceGrpc.getCancelTransactionMethod) == null) {
          TransactionServiceGrpc.getCancelTransactionMethod = getCancelTransactionMethod =
              io.grpc.MethodDescriptor.<com.sibehgoodbank.grpc.transaction.CancelTransactionRequest, com.sibehgoodbank.grpc.transaction.CancelTransactionResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "CancelTransaction"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.sibehgoodbank.grpc.transaction.CancelTransactionRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.sibehgoodbank.grpc.transaction.CancelTransactionResponse.getDefaultInstance()))
              .setSchemaDescriptor(new TransactionServiceMethodDescriptorSupplier("CancelTransaction"))
              .build();
        }
      }
    }
    return getCancelTransactionMethod;
  }

  private static volatile io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.transaction.ValidateTransactionRequest,
      com.sibehgoodbank.grpc.transaction.ValidateTransactionResponse> getValidateTransactionMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "ValidateTransaction",
      requestType = com.sibehgoodbank.grpc.transaction.ValidateTransactionRequest.class,
      responseType = com.sibehgoodbank.grpc.transaction.ValidateTransactionResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.transaction.ValidateTransactionRequest,
      com.sibehgoodbank.grpc.transaction.ValidateTransactionResponse> getValidateTransactionMethod() {
    io.grpc.MethodDescriptor<com.sibehgoodbank.grpc.transaction.ValidateTransactionRequest, com.sibehgoodbank.grpc.transaction.ValidateTransactionResponse> getValidateTransactionMethod;
    if ((getValidateTransactionMethod = TransactionServiceGrpc.getValidateTransactionMethod) == null) {
      synchronized (TransactionServiceGrpc.class) {
        if ((getValidateTransactionMethod = TransactionServiceGrpc.getValidateTransactionMethod) == null) {
          TransactionServiceGrpc.getValidateTransactionMethod = getValidateTransactionMethod =
              io.grpc.MethodDescriptor.<com.sibehgoodbank.grpc.transaction.ValidateTransactionRequest, com.sibehgoodbank.grpc.transaction.ValidateTransactionResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "ValidateTransaction"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.sibehgoodbank.grpc.transaction.ValidateTransactionRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.sibehgoodbank.grpc.transaction.ValidateTransactionResponse.getDefaultInstance()))
              .setSchemaDescriptor(new TransactionServiceMethodDescriptorSupplier("ValidateTransaction"))
              .build();
        }
      }
    }
    return getValidateTransactionMethod;
  }

  /**
   * Creates a new async stub that supports all call types for the service
   */
  public static TransactionServiceStub newStub(io.grpc.Channel channel) {
    io.grpc.stub.AbstractStub.StubFactory<TransactionServiceStub> factory =
      new io.grpc.stub.AbstractStub.StubFactory<TransactionServiceStub>() {
        @java.lang.Override
        public TransactionServiceStub newStub(io.grpc.Channel channel, io.grpc.CallOptions callOptions) {
          return new TransactionServiceStub(channel, callOptions);
        }
      };
    return TransactionServiceStub.newStub(factory, channel);
  }

  /**
   * Creates a new blocking-style stub that supports unary and streaming output calls on the service
   */
  public static TransactionServiceBlockingStub newBlockingStub(
      io.grpc.Channel channel) {
    io.grpc.stub.AbstractStub.StubFactory<TransactionServiceBlockingStub> factory =
      new io.grpc.stub.AbstractStub.StubFactory<TransactionServiceBlockingStub>() {
        @java.lang.Override
        public TransactionServiceBlockingStub newStub(io.grpc.Channel channel, io.grpc.CallOptions callOptions) {
          return new TransactionServiceBlockingStub(channel, callOptions);
        }
      };
    return TransactionServiceBlockingStub.newStub(factory, channel);
  }

  /**
   * Creates a new ListenableFuture-style stub that supports unary calls on the service
   */
  public static TransactionServiceFutureStub newFutureStub(
      io.grpc.Channel channel) {
    io.grpc.stub.AbstractStub.StubFactory<TransactionServiceFutureStub> factory =
      new io.grpc.stub.AbstractStub.StubFactory<TransactionServiceFutureStub>() {
        @java.lang.Override
        public TransactionServiceFutureStub newStub(io.grpc.Channel channel, io.grpc.CallOptions callOptions) {
          return new TransactionServiceFutureStub(channel, callOptions);
        }
      };
    return TransactionServiceFutureStub.newStub(factory, channel);
  }

  /**
   * <pre>
   * Transaction Service
   * </pre>
   */
  public interface AsyncService {

    /**
     * <pre>
     * Get transaction by ID
     * </pre>
     */
    default void getTransaction(com.sibehgoodbank.grpc.transaction.GetTransactionRequest request,
        io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.transaction.TransactionResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getGetTransactionMethod(), responseObserver);
    }

    /**
     * <pre>
     * Get transactions by account
     * </pre>
     */
    default void getTransactionsByAccount(com.sibehgoodbank.grpc.transaction.GetTransactionsByAccountRequest request,
        io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.transaction.TransactionsResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getGetTransactionsByAccountMethod(), responseObserver);
    }

    /**
     * <pre>
     * Get transactions by user
     * </pre>
     */
    default void getTransactionsByUser(com.sibehgoodbank.grpc.transaction.GetTransactionsByUserRequest request,
        io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.transaction.TransactionsResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getGetTransactionsByUserMethod(), responseObserver);
    }

    /**
     * <pre>
     * Create internal transfer
     * </pre>
     */
    default void createTransfer(com.sibehgoodbank.grpc.transaction.CreateTransferRequest request,
        io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.transaction.TransactionCreatedResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getCreateTransferMethod(), responseObserver);
    }

    /**
     * <pre>
     * Create deposit
     * </pre>
     */
    default void createDeposit(com.sibehgoodbank.grpc.transaction.CreateDepositRequest request,
        io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.transaction.TransactionCreatedResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getCreateDepositMethod(), responseObserver);
    }

    /**
     * <pre>
     * Create withdrawal
     * </pre>
     */
    default void createWithdrawal(com.sibehgoodbank.grpc.transaction.CreateWithdrawalRequest request,
        io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.transaction.TransactionCreatedResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getCreateWithdrawalMethod(), responseObserver);
    }

    /**
     * <pre>
     * Get transaction status
     * </pre>
     */
    default void getTransactionStatus(com.sibehgoodbank.grpc.transaction.GetTransactionStatusRequest request,
        io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.transaction.TransactionStatusResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getGetTransactionStatusMethod(), responseObserver);
    }

    /**
     * <pre>
     * Cancel pending transaction
     * </pre>
     */
    default void cancelTransaction(com.sibehgoodbank.grpc.transaction.CancelTransactionRequest request,
        io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.transaction.CancelTransactionResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getCancelTransactionMethod(), responseObserver);
    }

    /**
     * <pre>
     * Validate transaction before creation
     * </pre>
     */
    default void validateTransaction(com.sibehgoodbank.grpc.transaction.ValidateTransactionRequest request,
        io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.transaction.ValidateTransactionResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getValidateTransactionMethod(), responseObserver);
    }
  }

  /**
   * Base class for the server implementation of the service TransactionService.
   * <pre>
   * Transaction Service
   * </pre>
   */
  public static abstract class TransactionServiceImplBase
      implements io.grpc.BindableService, AsyncService {

    @java.lang.Override public final io.grpc.ServerServiceDefinition bindService() {
      return TransactionServiceGrpc.bindService(this);
    }
  }

  /**
   * A stub to allow clients to do asynchronous rpc calls to service TransactionService.
   * <pre>
   * Transaction Service
   * </pre>
   */
  public static final class TransactionServiceStub
      extends io.grpc.stub.AbstractAsyncStub<TransactionServiceStub> {
    private TransactionServiceStub(
        io.grpc.Channel channel, io.grpc.CallOptions callOptions) {
      super(channel, callOptions);
    }

    @java.lang.Override
    protected TransactionServiceStub build(
        io.grpc.Channel channel, io.grpc.CallOptions callOptions) {
      return new TransactionServiceStub(channel, callOptions);
    }

    /**
     * <pre>
     * Get transaction by ID
     * </pre>
     */
    public void getTransaction(com.sibehgoodbank.grpc.transaction.GetTransactionRequest request,
        io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.transaction.TransactionResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getGetTransactionMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     * <pre>
     * Get transactions by account
     * </pre>
     */
    public void getTransactionsByAccount(com.sibehgoodbank.grpc.transaction.GetTransactionsByAccountRequest request,
        io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.transaction.TransactionsResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getGetTransactionsByAccountMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     * <pre>
     * Get transactions by user
     * </pre>
     */
    public void getTransactionsByUser(com.sibehgoodbank.grpc.transaction.GetTransactionsByUserRequest request,
        io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.transaction.TransactionsResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getGetTransactionsByUserMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     * <pre>
     * Create internal transfer
     * </pre>
     */
    public void createTransfer(com.sibehgoodbank.grpc.transaction.CreateTransferRequest request,
        io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.transaction.TransactionCreatedResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getCreateTransferMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     * <pre>
     * Create deposit
     * </pre>
     */
    public void createDeposit(com.sibehgoodbank.grpc.transaction.CreateDepositRequest request,
        io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.transaction.TransactionCreatedResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getCreateDepositMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     * <pre>
     * Create withdrawal
     * </pre>
     */
    public void createWithdrawal(com.sibehgoodbank.grpc.transaction.CreateWithdrawalRequest request,
        io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.transaction.TransactionCreatedResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getCreateWithdrawalMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     * <pre>
     * Get transaction status
     * </pre>
     */
    public void getTransactionStatus(com.sibehgoodbank.grpc.transaction.GetTransactionStatusRequest request,
        io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.transaction.TransactionStatusResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getGetTransactionStatusMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     * <pre>
     * Cancel pending transaction
     * </pre>
     */
    public void cancelTransaction(com.sibehgoodbank.grpc.transaction.CancelTransactionRequest request,
        io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.transaction.CancelTransactionResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getCancelTransactionMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     * <pre>
     * Validate transaction before creation
     * </pre>
     */
    public void validateTransaction(com.sibehgoodbank.grpc.transaction.ValidateTransactionRequest request,
        io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.transaction.ValidateTransactionResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getValidateTransactionMethod(), getCallOptions()), request, responseObserver);
    }
  }

  /**
   * A stub to allow clients to do synchronous rpc calls to service TransactionService.
   * <pre>
   * Transaction Service
   * </pre>
   */
  public static final class TransactionServiceBlockingStub
      extends io.grpc.stub.AbstractBlockingStub<TransactionServiceBlockingStub> {
    private TransactionServiceBlockingStub(
        io.grpc.Channel channel, io.grpc.CallOptions callOptions) {
      super(channel, callOptions);
    }

    @java.lang.Override
    protected TransactionServiceBlockingStub build(
        io.grpc.Channel channel, io.grpc.CallOptions callOptions) {
      return new TransactionServiceBlockingStub(channel, callOptions);
    }

    /**
     * <pre>
     * Get transaction by ID
     * </pre>
     */
    public com.sibehgoodbank.grpc.transaction.TransactionResponse getTransaction(com.sibehgoodbank.grpc.transaction.GetTransactionRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getGetTransactionMethod(), getCallOptions(), request);
    }

    /**
     * <pre>
     * Get transactions by account
     * </pre>
     */
    public com.sibehgoodbank.grpc.transaction.TransactionsResponse getTransactionsByAccount(com.sibehgoodbank.grpc.transaction.GetTransactionsByAccountRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getGetTransactionsByAccountMethod(), getCallOptions(), request);
    }

    /**
     * <pre>
     * Get transactions by user
     * </pre>
     */
    public com.sibehgoodbank.grpc.transaction.TransactionsResponse getTransactionsByUser(com.sibehgoodbank.grpc.transaction.GetTransactionsByUserRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getGetTransactionsByUserMethod(), getCallOptions(), request);
    }

    /**
     * <pre>
     * Create internal transfer
     * </pre>
     */
    public com.sibehgoodbank.grpc.transaction.TransactionCreatedResponse createTransfer(com.sibehgoodbank.grpc.transaction.CreateTransferRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getCreateTransferMethod(), getCallOptions(), request);
    }

    /**
     * <pre>
     * Create deposit
     * </pre>
     */
    public com.sibehgoodbank.grpc.transaction.TransactionCreatedResponse createDeposit(com.sibehgoodbank.grpc.transaction.CreateDepositRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getCreateDepositMethod(), getCallOptions(), request);
    }

    /**
     * <pre>
     * Create withdrawal
     * </pre>
     */
    public com.sibehgoodbank.grpc.transaction.TransactionCreatedResponse createWithdrawal(com.sibehgoodbank.grpc.transaction.CreateWithdrawalRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getCreateWithdrawalMethod(), getCallOptions(), request);
    }

    /**
     * <pre>
     * Get transaction status
     * </pre>
     */
    public com.sibehgoodbank.grpc.transaction.TransactionStatusResponse getTransactionStatus(com.sibehgoodbank.grpc.transaction.GetTransactionStatusRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getGetTransactionStatusMethod(), getCallOptions(), request);
    }

    /**
     * <pre>
     * Cancel pending transaction
     * </pre>
     */
    public com.sibehgoodbank.grpc.transaction.CancelTransactionResponse cancelTransaction(com.sibehgoodbank.grpc.transaction.CancelTransactionRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getCancelTransactionMethod(), getCallOptions(), request);
    }

    /**
     * <pre>
     * Validate transaction before creation
     * </pre>
     */
    public com.sibehgoodbank.grpc.transaction.ValidateTransactionResponse validateTransaction(com.sibehgoodbank.grpc.transaction.ValidateTransactionRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getValidateTransactionMethod(), getCallOptions(), request);
    }
  }

  /**
   * A stub to allow clients to do ListenableFuture-style rpc calls to service TransactionService.
   * <pre>
   * Transaction Service
   * </pre>
   */
  public static final class TransactionServiceFutureStub
      extends io.grpc.stub.AbstractFutureStub<TransactionServiceFutureStub> {
    private TransactionServiceFutureStub(
        io.grpc.Channel channel, io.grpc.CallOptions callOptions) {
      super(channel, callOptions);
    }

    @java.lang.Override
    protected TransactionServiceFutureStub build(
        io.grpc.Channel channel, io.grpc.CallOptions callOptions) {
      return new TransactionServiceFutureStub(channel, callOptions);
    }

    /**
     * <pre>
     * Get transaction by ID
     * </pre>
     */
    public com.google.common.util.concurrent.ListenableFuture<com.sibehgoodbank.grpc.transaction.TransactionResponse> getTransaction(
        com.sibehgoodbank.grpc.transaction.GetTransactionRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getGetTransactionMethod(), getCallOptions()), request);
    }

    /**
     * <pre>
     * Get transactions by account
     * </pre>
     */
    public com.google.common.util.concurrent.ListenableFuture<com.sibehgoodbank.grpc.transaction.TransactionsResponse> getTransactionsByAccount(
        com.sibehgoodbank.grpc.transaction.GetTransactionsByAccountRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getGetTransactionsByAccountMethod(), getCallOptions()), request);
    }

    /**
     * <pre>
     * Get transactions by user
     * </pre>
     */
    public com.google.common.util.concurrent.ListenableFuture<com.sibehgoodbank.grpc.transaction.TransactionsResponse> getTransactionsByUser(
        com.sibehgoodbank.grpc.transaction.GetTransactionsByUserRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getGetTransactionsByUserMethod(), getCallOptions()), request);
    }

    /**
     * <pre>
     * Create internal transfer
     * </pre>
     */
    public com.google.common.util.concurrent.ListenableFuture<com.sibehgoodbank.grpc.transaction.TransactionCreatedResponse> createTransfer(
        com.sibehgoodbank.grpc.transaction.CreateTransferRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getCreateTransferMethod(), getCallOptions()), request);
    }

    /**
     * <pre>
     * Create deposit
     * </pre>
     */
    public com.google.common.util.concurrent.ListenableFuture<com.sibehgoodbank.grpc.transaction.TransactionCreatedResponse> createDeposit(
        com.sibehgoodbank.grpc.transaction.CreateDepositRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getCreateDepositMethod(), getCallOptions()), request);
    }

    /**
     * <pre>
     * Create withdrawal
     * </pre>
     */
    public com.google.common.util.concurrent.ListenableFuture<com.sibehgoodbank.grpc.transaction.TransactionCreatedResponse> createWithdrawal(
        com.sibehgoodbank.grpc.transaction.CreateWithdrawalRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getCreateWithdrawalMethod(), getCallOptions()), request);
    }

    /**
     * <pre>
     * Get transaction status
     * </pre>
     */
    public com.google.common.util.concurrent.ListenableFuture<com.sibehgoodbank.grpc.transaction.TransactionStatusResponse> getTransactionStatus(
        com.sibehgoodbank.grpc.transaction.GetTransactionStatusRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getGetTransactionStatusMethod(), getCallOptions()), request);
    }

    /**
     * <pre>
     * Cancel pending transaction
     * </pre>
     */
    public com.google.common.util.concurrent.ListenableFuture<com.sibehgoodbank.grpc.transaction.CancelTransactionResponse> cancelTransaction(
        com.sibehgoodbank.grpc.transaction.CancelTransactionRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getCancelTransactionMethod(), getCallOptions()), request);
    }

    /**
     * <pre>
     * Validate transaction before creation
     * </pre>
     */
    public com.google.common.util.concurrent.ListenableFuture<com.sibehgoodbank.grpc.transaction.ValidateTransactionResponse> validateTransaction(
        com.sibehgoodbank.grpc.transaction.ValidateTransactionRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getValidateTransactionMethod(), getCallOptions()), request);
    }
  }

  private static final int METHODID_GET_TRANSACTION = 0;
  private static final int METHODID_GET_TRANSACTIONS_BY_ACCOUNT = 1;
  private static final int METHODID_GET_TRANSACTIONS_BY_USER = 2;
  private static final int METHODID_CREATE_TRANSFER = 3;
  private static final int METHODID_CREATE_DEPOSIT = 4;
  private static final int METHODID_CREATE_WITHDRAWAL = 5;
  private static final int METHODID_GET_TRANSACTION_STATUS = 6;
  private static final int METHODID_CANCEL_TRANSACTION = 7;
  private static final int METHODID_VALIDATE_TRANSACTION = 8;

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
        case METHODID_GET_TRANSACTION:
          serviceImpl.getTransaction((com.sibehgoodbank.grpc.transaction.GetTransactionRequest) request,
              (io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.transaction.TransactionResponse>) responseObserver);
          break;
        case METHODID_GET_TRANSACTIONS_BY_ACCOUNT:
          serviceImpl.getTransactionsByAccount((com.sibehgoodbank.grpc.transaction.GetTransactionsByAccountRequest) request,
              (io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.transaction.TransactionsResponse>) responseObserver);
          break;
        case METHODID_GET_TRANSACTIONS_BY_USER:
          serviceImpl.getTransactionsByUser((com.sibehgoodbank.grpc.transaction.GetTransactionsByUserRequest) request,
              (io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.transaction.TransactionsResponse>) responseObserver);
          break;
        case METHODID_CREATE_TRANSFER:
          serviceImpl.createTransfer((com.sibehgoodbank.grpc.transaction.CreateTransferRequest) request,
              (io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.transaction.TransactionCreatedResponse>) responseObserver);
          break;
        case METHODID_CREATE_DEPOSIT:
          serviceImpl.createDeposit((com.sibehgoodbank.grpc.transaction.CreateDepositRequest) request,
              (io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.transaction.TransactionCreatedResponse>) responseObserver);
          break;
        case METHODID_CREATE_WITHDRAWAL:
          serviceImpl.createWithdrawal((com.sibehgoodbank.grpc.transaction.CreateWithdrawalRequest) request,
              (io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.transaction.TransactionCreatedResponse>) responseObserver);
          break;
        case METHODID_GET_TRANSACTION_STATUS:
          serviceImpl.getTransactionStatus((com.sibehgoodbank.grpc.transaction.GetTransactionStatusRequest) request,
              (io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.transaction.TransactionStatusResponse>) responseObserver);
          break;
        case METHODID_CANCEL_TRANSACTION:
          serviceImpl.cancelTransaction((com.sibehgoodbank.grpc.transaction.CancelTransactionRequest) request,
              (io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.transaction.CancelTransactionResponse>) responseObserver);
          break;
        case METHODID_VALIDATE_TRANSACTION:
          serviceImpl.validateTransaction((com.sibehgoodbank.grpc.transaction.ValidateTransactionRequest) request,
              (io.grpc.stub.StreamObserver<com.sibehgoodbank.grpc.transaction.ValidateTransactionResponse>) responseObserver);
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
          getGetTransactionMethod(),
          io.grpc.stub.ServerCalls.asyncUnaryCall(
            new MethodHandlers<
              com.sibehgoodbank.grpc.transaction.GetTransactionRequest,
              com.sibehgoodbank.grpc.transaction.TransactionResponse>(
                service, METHODID_GET_TRANSACTION)))
        .addMethod(
          getGetTransactionsByAccountMethod(),
          io.grpc.stub.ServerCalls.asyncUnaryCall(
            new MethodHandlers<
              com.sibehgoodbank.grpc.transaction.GetTransactionsByAccountRequest,
              com.sibehgoodbank.grpc.transaction.TransactionsResponse>(
                service, METHODID_GET_TRANSACTIONS_BY_ACCOUNT)))
        .addMethod(
          getGetTransactionsByUserMethod(),
          io.grpc.stub.ServerCalls.asyncUnaryCall(
            new MethodHandlers<
              com.sibehgoodbank.grpc.transaction.GetTransactionsByUserRequest,
              com.sibehgoodbank.grpc.transaction.TransactionsResponse>(
                service, METHODID_GET_TRANSACTIONS_BY_USER)))
        .addMethod(
          getCreateTransferMethod(),
          io.grpc.stub.ServerCalls.asyncUnaryCall(
            new MethodHandlers<
              com.sibehgoodbank.grpc.transaction.CreateTransferRequest,
              com.sibehgoodbank.grpc.transaction.TransactionCreatedResponse>(
                service, METHODID_CREATE_TRANSFER)))
        .addMethod(
          getCreateDepositMethod(),
          io.grpc.stub.ServerCalls.asyncUnaryCall(
            new MethodHandlers<
              com.sibehgoodbank.grpc.transaction.CreateDepositRequest,
              com.sibehgoodbank.grpc.transaction.TransactionCreatedResponse>(
                service, METHODID_CREATE_DEPOSIT)))
        .addMethod(
          getCreateWithdrawalMethod(),
          io.grpc.stub.ServerCalls.asyncUnaryCall(
            new MethodHandlers<
              com.sibehgoodbank.grpc.transaction.CreateWithdrawalRequest,
              com.sibehgoodbank.grpc.transaction.TransactionCreatedResponse>(
                service, METHODID_CREATE_WITHDRAWAL)))
        .addMethod(
          getGetTransactionStatusMethod(),
          io.grpc.stub.ServerCalls.asyncUnaryCall(
            new MethodHandlers<
              com.sibehgoodbank.grpc.transaction.GetTransactionStatusRequest,
              com.sibehgoodbank.grpc.transaction.TransactionStatusResponse>(
                service, METHODID_GET_TRANSACTION_STATUS)))
        .addMethod(
          getCancelTransactionMethod(),
          io.grpc.stub.ServerCalls.asyncUnaryCall(
            new MethodHandlers<
              com.sibehgoodbank.grpc.transaction.CancelTransactionRequest,
              com.sibehgoodbank.grpc.transaction.CancelTransactionResponse>(
                service, METHODID_CANCEL_TRANSACTION)))
        .addMethod(
          getValidateTransactionMethod(),
          io.grpc.stub.ServerCalls.asyncUnaryCall(
            new MethodHandlers<
              com.sibehgoodbank.grpc.transaction.ValidateTransactionRequest,
              com.sibehgoodbank.grpc.transaction.ValidateTransactionResponse>(
                service, METHODID_VALIDATE_TRANSACTION)))
        .build();
  }

  private static abstract class TransactionServiceBaseDescriptorSupplier
      implements io.grpc.protobuf.ProtoFileDescriptorSupplier, io.grpc.protobuf.ProtoServiceDescriptorSupplier {
    TransactionServiceBaseDescriptorSupplier() {}

    @java.lang.Override
    public com.google.protobuf.Descriptors.FileDescriptor getFileDescriptor() {
      return com.sibehgoodbank.grpc.transaction.TransactionServiceProto.getDescriptor();
    }

    @java.lang.Override
    public com.google.protobuf.Descriptors.ServiceDescriptor getServiceDescriptor() {
      return getFileDescriptor().findServiceByName("TransactionService");
    }
  }

  private static final class TransactionServiceFileDescriptorSupplier
      extends TransactionServiceBaseDescriptorSupplier {
    TransactionServiceFileDescriptorSupplier() {}
  }

  private static final class TransactionServiceMethodDescriptorSupplier
      extends TransactionServiceBaseDescriptorSupplier
      implements io.grpc.protobuf.ProtoMethodDescriptorSupplier {
    private final java.lang.String methodName;

    TransactionServiceMethodDescriptorSupplier(java.lang.String methodName) {
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
      synchronized (TransactionServiceGrpc.class) {
        result = serviceDescriptor;
        if (result == null) {
          serviceDescriptor = result = io.grpc.ServiceDescriptor.newBuilder(SERVICE_NAME)
              .setSchemaDescriptor(new TransactionServiceFileDescriptorSupplier())
              .addMethod(getGetTransactionMethod())
              .addMethod(getGetTransactionsByAccountMethod())
              .addMethod(getGetTransactionsByUserMethod())
              .addMethod(getCreateTransferMethod())
              .addMethod(getCreateDepositMethod())
              .addMethod(getCreateWithdrawalMethod())
              .addMethod(getGetTransactionStatusMethod())
              .addMethod(getCancelTransactionMethod())
              .addMethod(getValidateTransactionMethod())
              .build();
        }
      }
    }
    return result;
  }
}
