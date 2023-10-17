// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class UserData {
  final uid;
  final name;
  final phone;
  final email;
  UserData({
    required this.uid,
    required this.name,
    required this.phone,
    required this.email,
  });

  UserData copyWith({
    String? uid,
    String? name,
    String? phone,
    String? email,
  }) {
    return UserData(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'name': name,
      'phone': phone,
      'email': email,
    };
  }

  factory UserData.fromMap(DocumentSnapshot snapshot) {
    return UserData(
      uid: snapshot['uid'] as String,
      name: snapshot['name'] as String,
      phone: snapshot['phone'] as String,
      email: snapshot['email'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserData.fromJson(DocumentSnapshot snapshot) {
    return UserData(
      uid: snapshot.id,
      name: snapshot['name'],
      phone: snapshot['phone'],
      email: snapshot['email'],
    );
  }

  @override
  String toString() {
    return 'UserData(uid: $uid, name: $name, phone: $phone, email: $email)';
  }

  @override
  bool operator ==(covariant UserData other) {
    if (identical(this, other)) return true;

    return other.uid == uid &&
        other.name == name &&
        other.phone == phone &&
        other.email == email;
  }

  @override
  int get hashCode {
    return uid.hashCode ^ name.hashCode ^ phone.hashCode ^ email.hashCode;
  }
}
