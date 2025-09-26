import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class CategoryModel extends Equatable {
  final String id;
  final String description;
  final IconData icon;
  final Color color;

  const CategoryModel({
    required this.id,
    required this.description,
    required this.icon,
    required this.color,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      description: json['description'] as String,
      icon: IconData(
        json['icon_code'] as int,
        fontFamily: 'MaterialIcons',
      ),
      color: Color(json['color'] as int),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'icon_code': icon.codePoint,
      'color': color.value,
    };
  }

  CategoryModel copyWith({
    String? id,
    String? description,
    IconData? icon,
    Color? color,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
    );
  }

  @override
  List<Object?> get props => [id, description, icon, color];

  // Metodo helper per creare categorie predefinite
  static List<CategoryModel> getDefaultIncomeCategories() {
    return [
      CategoryModel(
        id: 'salary',
        description: 'Stipendio',
        icon: Icons.account_balance,
        color: Colors.blue,
      ),
      CategoryModel(
        id: 'freelance',
        description: 'Freelance',
        icon: Icons.web,
        color: Colors.purple,
      ),
      CategoryModel(
        id: 'investments',
        description: 'Investimenti',
        icon: Icons.trending_up,
        color: Colors.orange,
      ),
      CategoryModel(
        id: 'bonus',
        description: 'Bonus',
        icon: Icons.star,
        color: Colors.amber,
      ),
      CategoryModel(
        id: 'rental',
        description: 'Affitti',
        icon: Icons.home,
        color: Colors.green,
      ),
      CategoryModel(
        id: 'business',
        description: 'Business',
        icon: Icons.business,
        color: Colors.indigo,
      ),
      CategoryModel(
        id: 'other',
        description: 'Altro',
        icon: Icons.more_horiz,
        color: Colors.grey,
      ),
    ];
  }

  // Metodo helper per creare categorie predefinite per le spese
  static List<CategoryModel> getDefaultExpenseCategories() {
    return [
      CategoryModel(
        id: 'groceries',
        description: 'Spesa',
        icon: Icons.shopping_cart,
        color: Colors.blue,
      ),
      CategoryModel(
        id: 'fuel',
        description: 'Carburante',
        icon: Icons.local_gas_station,
        color: Colors.orange,
      ),
      CategoryModel(
        id: 'restaurant',
        description: 'Ristorante',
        icon: Icons.restaurant,
        color: Colors.red,
      ),
      CategoryModel(
        id: 'health',
        description: 'Salute',
        icon: Icons.medical_services,
        color: Colors.green,
      ),
      CategoryModel(
        id: 'education',
        description: 'Istruzione',
        icon: Icons.school,
        color: Colors.purple,
      ),
      CategoryModel(
        id: 'transport',
        description: 'Trasporti',
        icon: Icons.directions_bus,
        color: Colors.teal,
      ),
      CategoryModel(
        id: 'utilities',
        description: 'Utenze',
        icon: Icons.electrical_services,
        color: Colors.yellow,
      ),
      CategoryModel(
        id: 'entertainment',
        description: 'Svago',
        icon: Icons.movie,
        color: Colors.pink,
      ),
      CategoryModel(
        id: 'shopping',
        description: 'Acquisti',
        icon: Icons.shopping_bag,
        color: Colors.deepPurple,
      ),
      CategoryModel(
        id: 'other',
        description: 'Altro',
        icon: Icons.more_horiz,
        color: Colors.grey,
      ),
    ];
  }
}