class ProductModel {
  final int id;
  final String name;
  final String category;
  final String description;
  final double price;
  final double costPrice;
  final double totalPrice;
  final bool isDeliveryRequired;
  final DateTime dateAdded;
  final List<String> imageFilePaths;
  final String? soldByAgentName;
  final int? soldByAgentId;
  final int? whoRequestId;
  final String? whoRequestName;
  final String? whoRequestPhone;
  final String? whoRequestNidCardNumber;
  final String? whoRequestVillage;
  final String? whoRequestZila;

  ProductModel({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    required this.costPrice,
    required this.totalPrice,
    required this.isDeliveryRequired,
    required this.dateAdded,
    required this.imageFilePaths,
    this.soldByAgentName,
    this.soldByAgentId,
    this.whoRequestId,
    this.whoRequestName,
    this.whoRequestPhone,
    this.whoRequestNidCardNumber,
    this.whoRequestVillage,
    this.whoRequestZila,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // Parse dateAdded which comes as [year, month, day] array from backend
    DateTime parsedDate = DateTime.now();
    if (json['dateAdded'] != null) {
      if (json['dateAdded'] is List) {
        // Backend sends [2025, 11, 13] format
        final dateList = json['dateAdded'] as List;
        if (dateList.length >= 3) {
          parsedDate = DateTime(
            dateList[0] as int,
            dateList[1] as int,
            dateList[2] as int,
          );
        }
      } else if (json['dateAdded'] is String) {
        // Fallback for string format
        parsedDate = DateTime.parse(json['dateAdded']);
      }
    }

    return ProductModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      costPrice: (json['costPrice'] ?? 0.0).toDouble(),
      totalPrice: (json['totalPrice'] ?? 0.0).toDouble(),
      isDeliveryRequired: json['isDeliveryRequired'] ?? false,
      dateAdded: parsedDate,
      imageFilePaths: json['imageFilePaths'] != null 
          ? List<String>.from(json['imageFilePaths'])
          : [],
      soldByAgentName: json['soldByAgentName'],
      soldByAgentId: json['soldByAgentId'],
      whoRequestId: json['whoRequestId'],
      whoRequestName: json['whoRequestName'],
      whoRequestPhone: json['whoRequestPhone'],
      whoRequestNidCardNumber: json['whoRequestNidCardNumber'],
      whoRequestVillage: json['whoRequestVillage'],
      whoRequestZila: json['whoRequestZila'],
    );
  }

  Map<String, dynamic> toJson({bool forCreate = false}) {
    final Map<String, dynamic> data = <String, dynamic>{
      'name': name,
      'category': category,
      'description': description,
      'price': price,
      'costPrice': costPrice,
      'isDeliveryRequired': isDeliveryRequired,
    };

    // Use the correct field names that match your backend DTO
    if (soldByAgentId != null) {
      data['soldByAgentId'] = soldByAgentId;
    }

    if (whoRequestId != null) {
      data['whoRequestId'] = whoRequestId;
    }

    return data;
  }

  ProductModel copyWith({
    int? id,
    String? name,
    String? category,
    String? description,
    double? price,
    double? costPrice,
    double? totalPrice,
    bool? isDeliveryRequired,
    DateTime? dateAdded,
    List<String>? imageFilePaths,
    String? soldByAgentName,
    int? soldByAgentId,
    int? whoRequestId,
    String? whoRequestName,
    String? whoRequestPhone,
    String? whoRequestNidCardNumber,
    String? whoRequestVillage,
    String? whoRequestZila,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      price: price ?? this.price,
      costPrice: costPrice ?? this.costPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      isDeliveryRequired: isDeliveryRequired ?? this.isDeliveryRequired,
      dateAdded: dateAdded ?? this.dateAdded,
      imageFilePaths: imageFilePaths ?? this.imageFilePaths,
      soldByAgentName: soldByAgentName ?? this.soldByAgentName,
      soldByAgentId: soldByAgentId ?? this.soldByAgentId,
      whoRequestId: whoRequestId ?? this.whoRequestId,
      whoRequestName: whoRequestName ?? this.whoRequestName,
      whoRequestPhone: whoRequestPhone ?? this.whoRequestPhone,
      whoRequestNidCardNumber: whoRequestNidCardNumber ?? this.whoRequestNidCardNumber,
      whoRequestVillage: whoRequestVillage ?? this.whoRequestVillage,
      whoRequestZila: whoRequestZila ?? this.whoRequestZila,
    );
  }

  String getFormattedPrice() {
    return '৳${price.toStringAsFixed(2)}';
  }

  String getFormattedCostPrice() {
    return '৳${costPrice.toStringAsFixed(2)}';
  }

  String getFormattedTotalPrice() {
    return '৳${totalPrice.toStringAsFixed(2)}';
  }

  String getFormattedDate() {
    return '${dateAdded.day.toString().padLeft(2, '0')}/${dateAdded.month.toString().padLeft(2, '0')}/${dateAdded.year}';
  }
}