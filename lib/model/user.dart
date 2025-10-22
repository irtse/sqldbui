import 'package:sqldbui2/model/abstract.dart';

class Notification extends SerializerDeserializer<Notification> {
  Notification({
    this.id = "",
    this.name = "",
    this.description = "",
    this.ref = "", // todo something at least protected
    this.linkPath = "",
  });
  String id;
  String name;
  String description;
  String ref;
  String linkPath;

  @override deserialize(Map<String, dynamic> json) => Notification(
    id: json.containsKey("id") ? json["id"] : "", 
    name: json.containsKey("name") ? json["name"] : "unknown user", 
    description: json.containsKey("description") ? json["description"] : "", 
    ref: json.containsKey("data_ref") ? json["data_ref"] : "", 
    linkPath: json.containsKey("link_path") ? json["link_path"] : "",  );
  @override Map<String, dynamic> serialize() => {};
}

class User extends SerializerDeserializer<User> {
  User({
    this.name = "",
    this.email = "",
    this.password = "", // todo something at least protected
    this.token = "",
    this.notifications = const <Notification>[],
    this.isSuperAdmin = false,
  });

  String name;
  String email;
  String password;
  String token;
  bool isSuperAdmin;
  List<Notification> notifications = <Notification>[];

  @override deserialize(Map<String, dynamic> json) => User(
    isSuperAdmin: json.containsKey("super_admin") ? bool.parse("${json["super_admin"]}") : false, 
    name: json.containsKey("name") ? json["name"] : "unknown user", 
    email: json.containsKey("email") ? json["email"] : "", 
    token: json.containsKey("token") ? json["token"] : "",  
    notifications: json.containsKey("notifications") ? fromListJson(json["notifications"], Notification()) : <Notification>[],  );

  @override Map<String, dynamic> serialize() => {
    "login" : name,
    "password" : password,
  };
}

class DataAccess extends SerializerDeserializer<DataAccess> {
  DataAccess({
    this.user = "",
    this.write = false,
    this.update = false, // todo something at least protected
    this.accessDate,
  });

  String user;
  bool write;
  bool update;
  DateTime? accessDate;

  @override deserialize(Map<String, dynamic> json) {
    return DataAccess(
    user: json.containsKey("user") ? json["user"] : "unknown user", 
    update: json.containsKey("update") ? bool.parse("${json["update"]}") : false, 
    write: json.containsKey("write") ? bool.parse("${json["write"]}") : false,  
    accessDate: json.containsKey("access_date") ? DateTime.parse("${json["access_date"]}") : null,  );
  }

  @override Map<String, dynamic> serialize() => { };
}