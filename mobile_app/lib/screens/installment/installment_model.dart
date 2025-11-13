// lib/models/installment_model.dart
import 'package:mobile_app/models/agent_model.dart';
import 'package:mobile_app/models/member_model.dart';
import 'package:mobile_app/models/product_model.dart';

class InstallmentModel {
  final int? id;
  final ProductModel? product;
  final MemberModel? member;
  final double totalAmountOfProduct;
  final double otherCost;
  final double advancedPaid;
  final double? needPaidAmount;
  final int installmentMonths;
  final double interestRate;
  final String status;
  final List<String>? imageFilePaths;
  final AgentModel? givenProductAgent;
  final DateTime? createdTime;
  final List<PaymentSchedule>? paymentSchedules;
  final double? monthlyInstallmentAmount;
  final double? totalAmountWithInterest;
  
  // For creation
  final int? productId;
  final int? memberId;
  final int? agentId;

  InstallmentModel({
    this.id,
    this.product,
    this.member,
    required this.totalAmountOfProduct,
    this.otherCost = 0.0,
    required this.advancedPaid,
    this.needPaidAmount,
    required this.installmentMonths,
    required this.interestRate,
    this.status = 'ACTIVE',
    this.imageFilePaths,
    this.givenProductAgent,
    this.createdTime,
    this.paymentSchedules,
    this.monthlyInstallmentAmount,
    this.totalAmountWithInterest,
    this.productId,
    this.memberId,
    this.agentId,
  });

  factory InstallmentModel.fromJson(Map<String, dynamic> json) {
    return InstallmentModel(
      id: json['id'],
      product: json['product'] != null 
          ? ProductModel.fromJson(json['product']) 
          : null,
      member: json['member'] != null 
          ? MemberModel.fromJson(json['member']) 
          : null,
      totalAmountOfProduct: (json['totalAmountOfProduct'] ?? 0).toDouble(),
      otherCost: (json['otherCost'] ?? 0).toDouble(),
      advancedPaid: (json['advanced_paid'] ?? 0).toDouble(),
      needPaidAmount: json['needPaidAmount'] != null 
          ? (json['needPaidAmount']).toDouble() 
          : null,
      installmentMonths: json['installmentMonths'] ?? 0,
      interestRate: (json['interestRate'] ?? 0).toDouble(),
      status: json['status'] ?? 'ACTIVE',
      imageFilePaths: json['imageFilePaths'] != null 
          ? List<String>.from(json['imageFilePaths']) 
          : null,
      givenProductAgent: json['given_product_agent'] != null 
          ? AgentModel.fromJson(json['given_product_agent']) 
          : null,
      createdTime: json['createdTime'] != null 
          ? DateTime.parse(json['createdTime']) 
          : null,
      paymentSchedules: json['paymentSchedules'] != null
          ? (json['paymentSchedules'] as List)
              .map((e) => PaymentSchedule.fromJson(e))
              .toList()
          : null,
      monthlyInstallmentAmount: json['monthlyInstallmentAmount'] != null
          ? (json['monthlyInstallmentAmount']).toDouble()
          : null,
      totalAmountWithInterest: json['totalAmountWithInterest'] != null
          ? (json['totalAmountWithInterest']).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (productId != null) 'productId': productId,
      if (memberId != null) 'memberId': memberId,
      if (agentId != null) 'agentId': agentId,
      'totalAmountOfProduct': totalAmountOfProduct,
      'otherCost': otherCost,
      'advanced_paid': advancedPaid,
      'installmentMonths': installmentMonths,
      'interestRate': interestRate,
      'status': status,
    };
  }

  InstallmentModel copyWith({
    int? id,
    ProductModel? product,
    MemberModel? member,
    double? totalAmountOfProduct,
    double? otherCost,
    double? advancedPaid,
    double? needPaidAmount,
    int? installmentMonths,
    double? interestRate,
    String? status,
    List<String>? imageFilePaths,
    AgentModel? givenProductAgent,
    DateTime? createdTime,
    List<PaymentSchedule>? paymentSchedules,
    double? monthlyInstallmentAmount,
    double? totalAmountWithInterest,
    int? productId,
    int? memberId,
    int? agentId,
  }) {
    return InstallmentModel(
      id: id ?? this.id,
      product: product ?? this.product,
      member: member ?? this.member,
      totalAmountOfProduct: totalAmountOfProduct ?? this.totalAmountOfProduct,
      otherCost: otherCost ?? this.otherCost,
      advancedPaid: advancedPaid ?? this.advancedPaid,
      needPaidAmount: needPaidAmount ?? this.needPaidAmount,
      installmentMonths: installmentMonths ?? this.installmentMonths,
      interestRate: interestRate ?? this.interestRate,
      status: status ?? this.status,
      imageFilePaths: imageFilePaths ?? this.imageFilePaths,
      givenProductAgent: givenProductAgent ?? this.givenProductAgent,
      createdTime: createdTime ?? this.createdTime,
      paymentSchedules: paymentSchedules ?? this.paymentSchedules,
      monthlyInstallmentAmount: monthlyInstallmentAmount ?? this.monthlyInstallmentAmount,
      totalAmountWithInterest: totalAmountWithInterest ?? this.totalAmountWithInterest,
      productId: productId ?? this.productId,
      memberId: memberId ?? this.memberId,
      agentId: agentId ?? this.agentId,
    );
  }
}

class PaymentSchedule {
  final int? id;
  final int scheduleNumber;
  final DateTime dueDate;
  final double amountDue;
  final double? amountPaid;
  final String status;
  final DateTime? paidDate;

  PaymentSchedule({
    this.id,
    required this.scheduleNumber,
    required this.dueDate,
    required this.amountDue,
    this.amountPaid,
    required this.status,
    this.paidDate,
  });

  factory PaymentSchedule.fromJson(Map<String, dynamic> json) {
    return PaymentSchedule(
      id: json['id'],
      scheduleNumber: json['scheduleNumber'] ?? 0,
      dueDate: DateTime.parse(json['dueDate']),
      amountDue: (json['amountDue'] ?? 0).toDouble(),
      amountPaid: json['amountPaid'] != null 
          ? (json['amountPaid']).toDouble() 
          : null,
      status: json['status'] ?? 'PENDING',
      paidDate: json['paidDate'] != null 
          ? DateTime.parse(json['paidDate']) 
          : null,
    );
  }
}