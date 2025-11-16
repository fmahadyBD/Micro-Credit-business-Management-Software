// lib/models/payment_schedule_model.dart

class PaymentScheduleModel {
  final int? id;
  final int installmentId;
  final String memberName;
  final String memberPhone;
  final double paidAmount;
  final double totalAmount;
  final double remainingAmount;
  final String status;
  final String agentName;
  final int agentId;
  final DateTime paymentDate;
  final String? notes;
  final DateTime? createdTime;
  final DateTime? updatedTime;
  final double? previousRemainingAmount;
  final bool? isFullyPaid;
  final int? totalPaymentsMade;

  PaymentScheduleModel({
    this.id,
    required this.installmentId,
    required this.memberName,
    required this.memberPhone,
    required this.paidAmount,
    required this.totalAmount,
    required this.remainingAmount,
    required this.status,
    required this.agentName,
    required this.agentId,
    required this.paymentDate,
    this.notes,
    this.createdTime,
    this.updatedTime,
    this.previousRemainingAmount,
    this.isFullyPaid,
    this.totalPaymentsMade,
  });

  factory PaymentScheduleModel.fromJson(Map<String, dynamic> json) {
    return PaymentScheduleModel(
      id: json['id'],
      installmentId: json['installmentId'],
      memberName: json['memberName'] ?? '',
      memberPhone: json['memberPhone'] ?? '',
      paidAmount: (json['paidAmount'] ?? 0).toDouble(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      remainingAmount: (json['remainingAmount'] ?? 0).toDouble(),
      status: json['status'] ?? 'PENDING',
      agentName: json['agentName'] ?? '',
      agentId: json['agentId'] ?? 0,
      paymentDate: DateTime.parse(json['paymentDate']),
      notes: json['notes'],
      createdTime: json['createdTime'] != null 
          ? DateTime.parse(json['createdTime']) 
          : null,
      updatedTime: json['updatedTime'] != null 
          ? DateTime.parse(json['updatedTime']) 
          : null,
      previousRemainingAmount: json['previousRemainingAmount'] != null 
          ? (json['previousRemainingAmount']).toDouble() 
          : null,
      isFullyPaid: json['isFullyPaid'],
      totalPaymentsMade: json['totalPaymentsMade'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'installmentId': installmentId,
      'agentId': agentId,
      'amount': paidAmount,
      if (notes != null) 'notes': notes,
    };
  }
}

class InstallmentBalanceModel {
  final int installmentId;
  final double totalAmount;
  final double totalPaid;
  final double remainingBalance;
  final int totalPayments;
  final String status;
  final double monthlyAmount;

  InstallmentBalanceModel({
    required this.installmentId,
    required this.totalAmount,
    required this.totalPaid,
    required this.remainingBalance,
    required this.totalPayments,
    required this.status,
    required this.monthlyAmount,
  });

  factory InstallmentBalanceModel.fromJson(Map<String, dynamic> json) {
    return InstallmentBalanceModel(
      installmentId: json['installmentId'],
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      totalPaid: (json['totalPaid'] ?? 0).toDouble(),
      remainingBalance: (json['remainingBalance'] ?? 0).toDouble(),
      totalPayments: json['totalPayments'] ?? 0,
      status: json['status'] ?? 'ACTIVE',
      monthlyAmount: (json['monthlyAmount'] ?? 0).toDouble(),
    );
  }
}