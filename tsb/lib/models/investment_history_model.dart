// lib/models/investment_history_model.dart
class InvestmentHistoryModel {
  final int id;
  final int shareholderId;
  final double amount;
  final DateTime investmentDate;
  final String description;
  final String performedBy;
  final DateTime createdAt;

  InvestmentHistoryModel({
    required this.id,
    required this.shareholderId,
    required this.amount,
    required this.investmentDate,
    required this.description,
    required this.performedBy,
    required this.createdAt,
  });

  factory InvestmentHistoryModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDateTime(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (e) {
          return DateTime.now();
        }
      }
      return DateTime.now();
    }

    return InvestmentHistoryModel(
      id: json['id'] ?? 0,
      shareholderId: json['shareholderId'] ?? 0,
      amount: (json['amount'] ?? 0.0).toDouble(),
      investmentDate: parseDateTime(json['investmentDate']),
      description: json['description'] ?? '',
      performedBy: json['performedBy'] ?? 'system',
      createdAt: parseDateTime(json['createdAt']),
    );
  }

  String getFormattedAmount() {
    return '৳${amount.toStringAsFixed(2)}';
  }

  String getFormattedDate() {
    return '${investmentDate.day.toString().padLeft(2, '0')}/${investmentDate.month.toString().padLeft(2, '0')}/${investmentDate.year}';
  }
}