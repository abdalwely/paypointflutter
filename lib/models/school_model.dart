import 'package:cloud_firestore/cloud_firestore.dart';

class SchoolModel {
  final String id;
  final String name;
  final String code;
  final String address;
  final String phone;
  final String email;
  final bool isActive;
  final DateTime createdAt;

  SchoolModel({
    required this.id,
    required this.name,
    required this.code,
    required this.address,
    required this.phone,
    required this.email,
    this.isActive = true,
    required this.createdAt,
  });

  // Convert from Firebase Document
  factory SchoolModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SchoolModel(
      id: doc.id,
      name: data['name'] ?? '',
      code: data['code'] ?? '',
      address: data['address'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // Convert to Firebase Document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'code': code,
      'address': address,
      'phone': phone,
      'email': email,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Copy with modifications
  SchoolModel copyWith({
    String? name,
    String? code,
    String? address,
    String? phone,
    String? email,
    bool? isActive,
  }) {
    return SchoolModel(
      id: id,
      name: name ?? this.name,
      code: code ?? this.code,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
    );
  }
}
