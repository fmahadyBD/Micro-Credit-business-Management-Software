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
  final List<String> imageFilePaths;
  final AgentModel? givenProductAgent;
  final DateTime? createdTime;
  final List<PaymentSchedule> paymentSchedules;
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
    this.imageFilePaths = const [],
    this.givenProductAgent,
    this.createdTime,
    this.paymentSchedules = const [],
    this.monthlyInstallmentAmount,
    this.totalAmountWithInterest,
    this.productId,
    this.memberId,
    this.agentId,
  });

  factory InstallmentModel.fromJson(Map<String, dynamic> json) {
    print('Parsing installment JSON: ${json.keys.toList()}');
    
    // Safe status parsing
    String safeStatus = 'ACTIVE';
    if (json['status'] != null) {
      if (json['status'] is String) {
        safeStatus = json['status'] as String;
      } else if (json['status'] is Map) {
        safeStatus = (json['status']['name'] ?? 'ACTIVE').toString();
      }
    }

    // Safe date parsing for createdTime
    DateTime? parsedCreatedTime;
    if (json['createdTime'] != null) {
      if (json['createdTime'] is String) {
        try {
          parsedCreatedTime = DateTime.parse(json['createdTime']);
        } catch (e) {
          print('Error parsing createdTime string: $e');
        }
      } else if (json['createdTime'] is List) {
        final dateList = json['createdTime'] as List;
        if (dateList.length >= 3) {
          try {
            parsedCreatedTime = DateTime(
              (dateList[0] ?? DateTime.now().year).toInt(),
              (dateList[1] ?? 1).toInt(),
              (dateList[2] ?? 1).toInt(),
              dateList.length > 3 ? (dateList[3] ?? 0).toInt() : 0,
              dateList.length > 4 ? (dateList[4] ?? 0).toInt() : 0,
              dateList.length > 5 ? (dateList[5] ?? 0).toInt() : 0,
            );
          } catch (e) {
            print('Error parsing createdTime list: $e');
          }
        }
      }
    } else {
      print('createdTime is null or missing in JSON');
    }

    // Safe parsing for imageFilePaths
    List<String> parsedImageFilePaths = [];
    if (json['imageFilePaths'] != null && json['imageFilePaths'] is List) {
      try {
        parsedImageFilePaths = List<String>.from(
          json['imageFilePaths'].map((x) => x?.toString() ?? '')
        );
      } catch (e) {
        print('Error parsing imageFilePaths: $e');
      }
    }

    // Safe parsing for paymentSchedules
    List<PaymentSchedule> parsedPaymentSchedules = [];
    if (json['paymentSchedules'] != null && json['paymentSchedules'] is List) {
      try {
        parsedPaymentSchedules = (json['paymentSchedules'] as List)
            .map((e) => PaymentSchedule.fromJson(e))
            .toList();
      } catch (e) {
        print('Error parsing paymentSchedules: $e');
      }
    }

    // Safe parsing for given_product_agent
    AgentModel? parsedGivenProductAgent;
    if (json['given_product_agent'] != null) {
      try {
        parsedGivenProductAgent = AgentModel.fromJson(json['given_product_agent']);
      } catch (e) {
        print('Error parsing given_product_agent: $e');
      }
    }

    return InstallmentModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      product: json['product'] != null 
          ? ProductModel.fromJson(json['product']) 
          : null,
      member: json['member'] != null 
          ? MemberModel.fromJson(json['member']) 
          : null,
      totalAmountOfProduct: ((json['totalAmountOfProduct'] ?? 0.0) as num).toDouble(),
      otherCost: ((json['otherCost'] ?? 0.0) as num).toDouble(),
      advancedPaid: ((json['advanced_paid'] ?? json['advancedPaid'] ?? 0.0) as num).toDouble(),
      needPaidAmount: json['needPaidAmount'] != null 
          ? (json['needPaidAmount'] as num).toDouble() 
          : null,
      installmentMonths: (json['installmentMonths'] ?? 0).toInt(),
      interestRate: ((json['interestRate'] ?? 0.0) as num).toDouble(),
      status: safeStatus,
      imageFilePaths: parsedImageFilePaths,
      givenProductAgent: parsedGivenProductAgent,
      createdTime: parsedCreatedTime,
      paymentSchedules: parsedPaymentSchedules,
      monthlyInstallmentAmount: json['monthlyInstallmentAmount'] != null
          ? (json['monthlyInstallmentAmount'] as num).toDouble()
          : null,
      totalAmountWithInterest: json['totalAmountWithInterest'] != null
          ? (json['totalAmountWithInterest'] as num).toDouble()
          : null,
      productId: json['productId'] is int ? json['productId'] : int.tryParse(json['productId']?.toString() ?? ''),
      memberId: json['memberId'] is int ? json['memberId'] : int.tryParse(json['memberId']?.toString() ?? ''),
      agentId: json['agentId'] is int ? json['agentId'] : int.tryParse(json['agentId']?.toString() ?? ''),
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
      if (imageFilePaths.isNotEmpty) 'imageFilePaths': imageFilePaths,
      if (createdTime != null) 'createdTime': createdTime?.toIso8601String(),
      if (needPaidAmount != null) 'needPaidAmount': needPaidAmount,
      if (monthlyInstallmentAmount != null) 'monthlyInstallmentAmount': monthlyInstallmentAmount,
      if (totalAmountWithInterest != null) 'totalAmountWithInterest': totalAmountWithInterest,
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

  @override
  String toString() {
    return 'InstallmentModel(id: $id, productId: $productId, memberId: $memberId, totalAmount: $totalAmountOfProduct, status: $status, createdTime: $createdTime)';
  }
}

class PaymentSchedule {
  final int? id;
  final int scheduleNumber;
  final DateTime? dueDate;
  final double amountDue;
  final double? amountPaid;
  final String status;
  final DateTime? paidDate;
  final double? totalAmount;
  final double? remainingAmount;
  final AgentModel? collectingAgent;
  final String? notes;

  PaymentSchedule({
    this.id,
    required this.scheduleNumber,
    this.dueDate,
    required this.amountDue,
    this.amountPaid,
    required this.status,
    this.paidDate,
    this.totalAmount,
    this.remainingAmount,
    this.collectingAgent,
    this.notes,
  });

  factory PaymentSchedule.fromJson(Map<String, dynamic> json) {
    print('Parsing payment schedule JSON: ${json.keys.toList()}');
    
    // Safe date parsing for dueDate
    DateTime? parsedDueDate;
    if (json['dueDate'] != null) {
      if (json['dueDate'] is String) {
        try {
          parsedDueDate = DateTime.parse(json['dueDate']);
        } catch (e) {
          print('Error parsing dueDate string: $e');
        }
      } else if (json['dueDate'] is List) {
        final dateList = json['dueDate'] as List;
        if (dateList.length >= 3) {
          try {
            parsedDueDate = DateTime(
              (dateList[0] ?? DateTime.now().year).toInt(),
              (dateList[1] ?? 1).toInt(),
              (dateList[2] ?? 1).toInt(),
            );
          } catch (e) {
            print('Error parsing dueDate list: $e');
          }
        }
      }
    } else {
      print('dueDate is null or missing in payment schedule');
    }

    // Safe date parsing for paidDate
    DateTime? parsedPaidDate;
    if (json['paidDate'] != null) {
      if (json['paidDate'] is String) {
        try {
          parsedPaidDate = DateTime.parse(json['paidDate']);
        } catch (e) {
          print('Error parsing paidDate string: $e');
        }
      } else if (json['paidDate'] is List) {
        final dateList = json['paidDate'] as List;
        if (dateList.length >= 3) {
          try {
            parsedPaidDate = DateTime(
              (dateList[0] ?? DateTime.now().year).toInt(),
              (dateList[1] ?? 1).toInt(),
              (dateList[2] ?? 1).toInt(),
              dateList.length > 3 ? (dateList[3] ?? 0).toInt() : 0,
              dateList.length > 4 ? (dateList[4] ?? 0).toInt() : 0,
              dateList.length > 5 ? (dateList[5] ?? 0).toInt() : 0,
            );
          } catch (e) {
            print('Error parsing paidDate list: $e');
          }
        }
      }
    }

    // Safe parsing for collectingAgent
    AgentModel? parsedCollectingAgent;
    if (json['collectingAgent'] != null) {
      try {
        parsedCollectingAgent = AgentModel.fromJson(json['collectingAgent']);
      } catch (e) {
        print('Error parsing collectingAgent: $e');
      }
    }

    return PaymentSchedule(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      scheduleNumber: (json['scheduleNumber'] ?? 0).toInt(),
      dueDate: parsedDueDate,
      amountDue: ((json['amountDue'] ?? json['paidAmount'] ?? 0.0) as num).toDouble(),
      amountPaid: json['amountPaid'] != null 
          ? (json['amountPaid'] as num).toDouble() 
          : null,
      status: (json['status'] ?? 'PENDING').toString(),
      paidDate: parsedPaidDate,
      totalAmount: json['totalAmount'] != null
          ? (json['totalAmount'] as num).toDouble()
          : null,
      remainingAmount: json['remainingAmount'] != null
          ? (json['remainingAmount'] as num).toDouble()
          : null,
      collectingAgent: parsedCollectingAgent,
      notes: json['notes']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'scheduleNumber': scheduleNumber,
      if (dueDate != null) 'dueDate': dueDate?.toIso8601String(),
      'amountDue': amountDue,
      if (amountPaid != null) 'amountPaid': amountPaid,
      'status': status,
      if (paidDate != null) 'paidDate': paidDate?.toIso8601String(),
      if (totalAmount != null) 'totalAmount': totalAmount,
      if (remainingAmount != null) 'remainingAmount': remainingAmount,
      if (notes != null) 'notes': notes,
    };
  }
}