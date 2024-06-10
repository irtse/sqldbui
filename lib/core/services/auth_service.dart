import 'dart:developer' as developer;
import 'package:sqldbui2/main.dart';
import 'package:flutter/material.dart';
import 'package:sqldbui2/model/user.dart';
import 'package:injectable/injectable.dart';
import 'package:sqldbui2/core/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

var timeBomb = 10;
@lazySingleton
class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  final service = APIService();
  factory AuthService() { return _instance; }
  AuthService._internal() { 
    if (timeBomb == 10) {
      refresh(true).then((value) {
        if (AuthService.isLoggedIn) {  homeKey.currentState!.refresh(null, null, false); }
      }); 
    } else { timer(); }
  }

  static bool _isAuthenticated = false;
  static User? user;
  String? error;
  static bool get isLoggedIn => _isAuthenticated;

  Future<void> login(String name, String password) async {
    await service.post<User>("/auth/login", User(name: name.trim(), password: password.trim()).serialize(), null
                      ).then((value) { authenticate(value.data![0]); }
                      ).catchError( (e) { return err(e.toString()); }); 
  }

  Future<void> logOut(BuildContext context) async {
    await service.get<User>("/auth/logout", true, context).then((value) => unAuthenticate()
                                                         ).catchError((e) => unAuthenticate());
  }
  
  err(String err) {
    error = err;
    return null;
  }
  void unAuthenticate() {
    _isAuthenticated = false; 
    user = null;
    error = null;
    SharedPreferences.getInstance().then((value) => value.setString("token", ""));
    homeKey.currentState!.refresh(null, null, true);
  }

  void authenticate(User logUser) {
    authenticateShallow(logUser);
    homeKey.currentState!.refresh(null, null, false);
  }
  void authenticateShallow(User logUser) {
    _isAuthenticated = true; 
    if (logUser.token == "") { throw Exception("Not authorized"); }
    user = logUser;
    error = null;
    APIService.auth = logUser.token;
    SharedPreferences.getInstance().then((value) => value.setString("token", logUser.token));
    refresh(false);
  }

  Future<String?> getTokenCookie() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }
  Future<void> refresh(bool auth) async {
    String? cookie = await getTokenCookie();
    if (cookie != null) { APIService.auth = cookie; }
    if (APIService.auth != "") {
      await service.get<User>("/auth/refresh", true, null).then((value) async { 
        if (value.data != null && value.data!.isNotEmpty) {
          var d = value.data;
          SharedPreferences.getInstance().then((value) => value.setString("token", d![0].token));
          if (isLoggedIn) {
              appBarKey.currentState?.setState(() {
              user!.token = d![0].token;
              user!.notifications = value.data![0].notifications;
            });
          } else {  authenticate(value.data![0]); } 
          timer();
        }
      }).catchError( (e) { auth && isLoggedIn ? unAuthenticate() : null; }); 
    }
  }
  timer() {
    if (timeBomb > 0) {
      timeBomb--;  Future.delayed(const Duration(seconds: 1), () => timer());
    } else { 
      timeBomb = 10; 
      refresh(false);
    }
  }
}