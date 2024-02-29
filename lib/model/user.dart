import 'package:sqldbui2/model/abstract.dart';

class User extends SerializerDeserializer<User> {
  User({
    this.name = "",
    this.email = "",
    this.password = "", // todo something at least protected
    this.token = "",
  });

  String name;
  String email;
  String password;
  String token;

  @override deserialize(Map<String, dynamic> json) => User(
    name: json.containsKey("name") ? json["name"] : "unknown user", 
    email: json.containsKey("email") ? json["email"] : "", 
    token: json.containsKey("token") ? json["token"] : "",  );

  @override Map<String, dynamic> serialize() => {
    "login" : name,
    "password" : password,
  };
}