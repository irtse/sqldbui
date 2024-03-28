import 'package:sqldbui2/model/abstract.dart';

class Notification extends SerializerDeserializer<Notification> {
  Notification({
    this.name = "",
    this.description = "",
    this.ref = "", // todo something at least protected
  });

  String name;
  String description;
  String ref;

  @override deserialize(Map<String, dynamic> json) => Notification(
    name: json.containsKey("name") ? json["name"] : "unknown user", 
    description: json.containsKey("description") ? json["description"] : "", 
    ref: json.containsKey("data_ref") ? json["data_ref"] : "",  );
  
  @override Map<String, dynamic> serialize() => {};
}

class User extends SerializerDeserializer<User> {
  User({
    this.name = "",
    this.email = "",
    this.password = "", // todo something at least protected
    this.token = "",
    this.notifications = const <Notification>[],
  });

  String name;
  String email;
  String password;
  String token;
  List<Notification> notifications = <Notification>[];

  @override deserialize(Map<String, dynamic> json) => User(
    name: json.containsKey("name") ? json["name"] : "unknown user", 
    email: json.containsKey("email") ? json["email"] : "", 
    token: json.containsKey("token") ? json["token"] : "",  
    notifications: json.containsKey("notifications") ? fromListJson(json["notifications"], Notification()) : <Notification>[],  );

  @override Map<String, dynamic> serialize() => {
    "login" : name,
    "password" : password,
  };
}