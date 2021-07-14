import 'dart:convert';
List<ContactModel> dataModelFromJson(String str) => List<ContactModel>.from(json.decode(str).map((x) => ContactModel.fromJson(x)));

String dataModelToJson(List<ContactModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ContactModel {
  ContactModel({
    required this.phoneNumbers,
    required this.id,
    required this.lastName,
    required this.firstName,
    required this.v,
  });

  final List<dynamic> phoneNumbers;
  final String id;
  final String lastName;
  final String firstName;
  final int v;

  factory ContactModel.fromJson(Map<String, dynamic> json) => ContactModel(
    phoneNumbers: List<String>.from(json["phone_numbers"].map((x) => x)),
    id: json["_id"],
    lastName: json["last_name"],
    firstName: json["first_name"],
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "phone_numbers": List<dynamic>.from(phoneNumbers.map((x) => x)),
    "_id": id,
    "last_name": lastName,
    "first_name": firstName,
    "__v": v,
  };
}
