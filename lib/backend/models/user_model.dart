import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String name;
  final String surname;
  final DateTime? birthdate;
  final String email;
  // final UserSettings settings;
  // final SubscriptionType subscriptionType;
  final DateTime createdAt;
  final bool active;
  final DateTime lastModified;
  final bool profileComplete;

  const UserModel({
    required this.id,
    required this.name,
    required this.surname,
    this.birthdate,
    required this.email,
    // required this.settings,
    // required this.subscriptionType,
    required this.createdAt,
    required this.active,
    required this.lastModified,
    this.profileComplete = true
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      surname: json['surname'] as String,
      birthdate: json['birthdate'] != null
          ? (json['birthdate'] as Timestamp).toDate()
          : null,  // Gestisci il caso null
      email: json['email'] as String,
      // settings: UserSettings.fromJson(json['settings'] as Map<String, dynamic>),
      // subscriptionType: SubscriptionType.fromString(json['subscription_type'] as String),
      createdAt: (json['created_at'] as Timestamp).toDate(),
      active: json['active'] as bool,
      lastModified: (json['last_modified'] as Timestamp).toDate(),
      profileComplete: json['profile_complete'] as bool? ?? true,  // AGGIUNGI
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'surname': surname,
      'birthdate': birthdate != null ? Timestamp.fromDate(birthdate!) : null,  // Gestisci null
      'email': email,
      // 'settings': settings.toJson(),
      // 'subscription_type': subscriptionType.value,
      'created_at': Timestamp.fromDate(createdAt),
      'active': active,
      'last_modified': Timestamp.fromDate(lastModified),
      'profile_complete': profileComplete,  // AGGIUNGI
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? surname,
    DateTime? birthdate,
    String? email,
    // UserSettings? settings,
    // SubscriptionType? subscriptionType,
    DateTime? createdAt,
    bool? active,
    DateTime? lastModified,
    bool? profileComplete,  // AGGIUNGI
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      birthdate: birthdate ?? this.birthdate,
      email: email ?? this.email,
      // settings: settings ?? this.settings,
      // subscriptionType: subscriptionType ?? this.subscriptionType,
      createdAt: createdAt ?? this.createdAt,
      active: active ?? this.active,
      lastModified: lastModified ?? this.lastModified,
      profileComplete: profileComplete ?? this.profileComplete,  // AGGIUNGI
    );
  }

  String get fullName => '$name $surname';

  // bool get isSubscriptionActive =>
  //     subscriptionType != SubscriptionType.free && active;

  @override
  List<Object?> get props => [
    id,
    name,
    surname,
    birthdate,
    email,
    // settings,
    // subscriptionType,
    createdAt,
    active,
    lastModified,
    profileComplete,  // AGGIUNGI
  ];
}