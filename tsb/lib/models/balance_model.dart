// lib/models/balance_model.dart
class BalanceModel {
  final double totalBalance;
  final double totalInvestment;
  final double totalProductCost;
  final double totalMaintenanceCost;
  final double totalInstallmentReturn;
  final double totalEarnings;
  final double totalExpenses;
  final double netProfit;
  final DateTime lastUpdated;

  BalanceModel({
    required this.totalBalance,
    required this.totalInvestment,
    required this.totalProductCost,
    required this.totalMaintenanceCost,
    required this.totalInstallmentReturn,
    required this.totalEarnings,
    required this.totalExpenses,
    required this.netProfit,
    required this.lastUpdated,
  });

  factory BalanceModel.fromJson(Map<String, dynamic> json) {
    DateTime parseLastUpdated(dynamic v) {
      if (v == null) return DateTime.now();
      if (v is String) {
        try {
          return DateTime.parse(v);
        } catch (_) {
          return DateTime.now();
        }
      }
      if (v is List) {
        // if backend accidentally returns list-like date parts (not expected here but safe)
        try {
          return DateTime(
            v.isNotEmpty ? v[0] as int : 1970,
            v.length > 1 ? v[1] as int : 1,
            v.length > 2 ? v[2] as int : 1,
            v.length > 3 ? v[3] as int : 0,
            v.length > 4 ? v[4] as int : 0,
            v.length > 5 ? v[5] as int : 0,
          );
        } catch (_) {
          return DateTime.now();
        }
      }
      return DateTime.now();
    }

    double toDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    }

    return BalanceModel(
      totalBalance: toDouble(json['totalBalance']),
      totalInvestment: toDouble(json['totalInvestment']),
      totalProductCost: toDouble(json['totalProductCost']),
      totalMaintenanceCost: toDouble(json['totalMaintenanceCost']),
      totalInstallmentReturn: toDouble(json['totalInstallmentReturn']),
      totalEarnings: toDouble(json['totalEarnings']),
      totalExpenses: toDouble(json['totalExpenses']),
      netProfit: toDouble(json['netProfit']),
      lastUpdated: parseLastUpdated(json['lastUpdated']),
    );
  }
}
