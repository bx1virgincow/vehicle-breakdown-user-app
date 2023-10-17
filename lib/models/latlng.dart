// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:geolocator/geolocator.dart';

class CordPosition {
  Position lat;
  Position lng;
  CordPosition({
    required this.lat,
    required this.lng,
  });

  CordPosition copyWith({
    Position? lat,
    Position? lng,
  }) {
    return CordPosition(
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
    );
  }

  factory CordPosition.fromMap(Map<String, dynamic> map) {
    return CordPosition(
      lat: Position.fromMap(map['lat'] as Map<String, dynamic>),
      lng: Position.fromMap(map['lng'] as Map<String, dynamic>),
    );
  }

  factory CordPosition.fromJson(String source) =>
      CordPosition.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'CordPosition(lat: $lat, lng: $lng)';

  @override
  bool operator ==(covariant CordPosition other) {
    if (identical(this, other)) return true;

    return other.lat == lat && other.lng == lng;
  }

  @override
  int get hashCode => lat.hashCode ^ lng.hashCode;
}
