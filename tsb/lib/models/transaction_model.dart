// lib/models/transaction_model.dart
import 'package:intl/intl.dart';

class TransactionModel {
  final int id;
  final String type;
  final double amount;
  final String description;
  final DateTime timestamp;
  final int? shareholderId;
  final String? shareholderName;
  final int? memberId;
  final String? memberName;

  TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.timestamp,
    this.shareholderId,
    this.shareholderName,
    this.memberId,
    this.memberName,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    DateTime parseTimestamp(dynamic ts) {
      try {
        if (ts == null) return DateTime.now();

        // case: ISO string
        if (ts is String) {
          return DateTime.parse(ts);
        }

        // case: list like [2025,11,15,16,28,31]
        if (ts is List) {
          final parts = ts.cast<int>();
          final y = parts.isNotEmpty ? parts[0] : 1970;
          final mo = parts.length > 1 ? parts[1] : 1;
          final d = parts.length > 2 ? parts[2] : 1;
          final hh = parts.length > 3 ? parts[3] : 0;
          final mm = parts.length > 4 ? parts[4] : 0;
          final ss = parts.length > 5 ? parts[5] : 0;
          return DateTime(y, mo, d, hh, mm, ss);
        }

        // case: millis since epoch
        if (ts is int) {
          return DateTime.fromMillisecondsSinceEpoch(ts);
        }
      } catch (_) {}
      return DateTime.now();
    }

    double parseDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    }

    int? parseInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is double) return v.toInt();
      if (v is String) return int.tryParse(v);
      return null;
    }

    // Helper function to parse and clean string fields
    String? parseString(dynamic value) {
      if (value == null) return null;
      final str = value.toString().trim();
      return str.isEmpty ? null : str;
    }

    return TransactionModel(
      id: (json['id'] is int)
          ? json['id']
          : (json['id'] is String ? int.tryParse(json['id']) ?? 0 : 0),
      type: (json['type'] ?? '').toString(),
      amount: parseDouble(json['amount']),
      description: (json['description'] ?? '').toString(),
      timestamp: parseTimestamp(json['timestamp']),
      shareholderId: parseInt(json['shareholderId']),
      shareholderName: parseString(json['shareholderName']),
      memberId: parseInt(json['memberId']),
      memberName: parseString(json['memberName']),
    );
  }

  // ---------------------------------------------------------
  // FIXED DISPLAY NAME LOGIC
  // ---------------------------------------------------------
  String get displayName {
    // Priority 1: Use actual names from API if available
    if (memberName != null && memberName!.trim().isNotEmpty) {
      return memberName!;
    }
    
    if (shareholderName != null && shareholderName!.trim().isNotEmpty) {
      return shareholderName!;
    }
    
    // Priority 2: Smart fallbacks based on transaction type and IDs
    switch (type) {
      case 'INVESTMENT':
      case 'WITHDRAWAL':
        // For shareholder transactions, check if we at least have an ID
        if (shareholderId != null) {
          return 'Shareholder #$shareholderId';
        }
        return type == 'INVESTMENT' ? 'Investment' : 'Withdrawal';
        
      case 'INSTALLMENT_RETURN':
      case 'ADVANCED_PAYMENT':
        // For member transactions, check if we at least have an ID
        if (memberId != null) {
          return 'Customer #$memberId';
        }
        return 'Customer Payment';
        
      case 'PRODUCT_COST':
        return 'Product Purchase';
        
      case 'MAINTENANCE':
        return 'Maintenance';
        
      case 'EARNINGS':
        return 'Interest Earnings';
        
      default:
        return 'Transaction';
    }
  }

  // Check if this is a shareholder transaction
  bool get isShareholderTransaction {
    return type == 'INVESTMENT' || type == 'WITHDRAWAL';
  }

  // Check if this is a member transaction  
  bool get isMemberTransaction {
    return type == 'INSTALLMENT_RETURN' || type == 'ADVANCED_PAYMENT';
  }

  // Positive or negative amount
  bool get isPositive {
    return type == 'INVESTMENT' ||
        type == 'INSTALLMENT_RETURN' ||
        type == 'ADVANCED_PAYMENT' ||
        type == 'EARNINGS';
  }

  // Amount formatting
  String get formattedAmount {
    final sign = isPositive ? '+' : '-';
    return '$sign৳${amount.abs().toStringAsFixed(2)}';
  }

  // Date formatting
  String get formattedDate {
    try {
      return DateFormat('dd/MM/yyyy').format(timestamp);
    } catch (_) {
      return timestamp.toIso8601String();
    }
  }

  // Time formatting
  String get formattedTime {
    try {
      return DateFormat('HH:mm').format(timestamp);
    } catch (_) {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }

  // Display text for type
  String get typeDisplayName {
    switch (type) {
      case 'INVESTMENT':
        return 'Investment';
      case 'WITHDRAWAL':
        return 'Withdrawal';
      case 'PRODUCT_COST':
        return 'Product Cost';
      case 'MAINTENANCE':
        return 'Maintenance';
      case 'INSTALLMENT_RETURN':
        return 'Installment Return';
      case 'ADVANCED_PAYMENT':
        return 'Advanced Payment';
      case 'EARNINGS':
        return 'Interest Earnings';
      default:
        return type.replaceAll('_', ' ');
    }
  }

  // Debug info to understand missing names
  String get debugNameInfo {
    return 'Type: $type, '
        'MemberID: $memberId, MemberName: $memberName, '
        'ShareholderID: $shareholderId, ShareholderName: $shareholderName';
  }

  @override
  String toString() {
    return 'TransactionModel(id: $id, type: $type, amount: $amount, timestamp: $timestamp)';
  }

  // Convert to map for debugging
  Map<String, dynamic> toDebugMap() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
      'description': description,
      'timestamp': timestamp.toString(),
      'shareholderId': shareholderId,
      'shareholderName': shareholderName,
      'memberId': memberId,
      'memberName': memberName,
      'displayName': displayName,
      'isPositive': isPositive,
    };
  }
}