import 'package:hive/hive.dart';

part 'subcategory.g.dart';

@HiveType(typeId: 1)
class SubCategory extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String categoryId;

  @HiveField(2)
  String name;

  @HiveField(3)
  String description;

  SubCategory({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.description,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      id: json['id'] as String,
      categoryId: json['categoryId'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'name': name,
      'description': description,
    };
  }
}

