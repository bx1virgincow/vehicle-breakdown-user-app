import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceModel {
  String name;
  String address;
  String description;
  String email;
  String lat;
  String lng;
  String location;
  String service;
  String contact;

  ServiceModel({
    required this.name,
    required this.address,
    required this.description,
    required this.email,
    required this.lat,
    required this.lng,
    required this.location,
    required this.service,
    required this.contact,
  });

  factory ServiceModel.fromJson(DocumentSnapshot snapshot) {
    return ServiceModel(
      name: snapshot['name'],
      address: snapshot['address'],
      description: snapshot['description'],
      email: snapshot['email'],
      lat: snapshot['lat'],
      lng: snapshot['lng'],
      location: snapshot['location'],
      service: snapshot['service'],
      contact: snapshot['contact'],
    );
  }

  factory ServiceModel.fromMap(DocumentSnapshot snapshot) {
    return ServiceModel(
        name: snapshot['name'],
        address: snapshot['address'],
        description: snapshot['description'],
        email: snapshot['email'],
        lat: snapshot['lat'],
        lng: snapshot['lng'],
        location: snapshot['location'],
        service: snapshot['service'],
        contact: snapshot['contact']);
  }
}
