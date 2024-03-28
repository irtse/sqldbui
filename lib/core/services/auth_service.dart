import 'dart:io';

import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/core/services/api_service.dart';
import 'package:sqldbui2/core/widget/datagrid/grid.dart';
import 'package:sqldbui2/model/response.dart';
import 'package:sqldbui2/model/user.dart';
import 'dart:developer' as developer;

import 'package:sqldbui2/main.dart';

@lazySingleton
class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  final service = APIService();
  factory AuthService() { return _instance; }
  AuthService._internal() { refresh(); }

  static bool _isAuthenticated = false;
  static User? user;
  String? error;
  static bool get isLoggedIn => _isAuthenticated;

  Future<void> login(String name, String password) async {
    await service.post<User>("/auth/login", User(name: name.trim(), password: password.trim()).serialize(), null
                      ).then((value) { authenticate(value.data![0]); }
                      ).catchError( (e) {
                        return err(e.toString());
                      }); 
  }

  Future<void> logOut(BuildContext context) async {
    await service.get<User>("/auth/logout", true, context).then((value) => unAuthenticate(context)
                                                    ).catchError((e) => unAuthenticate(context));
  }
  
  err(String err) {
    error = err;
    return null;
  }
  void unAuthenticate(BuildContext context) {
    _isAuthenticated = false; 
    user = null;
    error = null;
    resetAllFilter();
    homeKey.currentState!.setState(() { 
      APIService.cache = <String, APIResponse<dynamic>>{};
      currentView = null;
      beforeView = null;
    });
  }

  void authenticate(User logUser) {
    authenticateShallow(logUser);
    homeKey.currentState!.setState(() {});
  }
  void authenticateShallow(User logUser) {
    _isAuthenticated = true; 
    if (logUser.token == "") { throw Exception("Not authorized"); }
    user = logUser;
    error = null;
    APIService.auth = logUser.token;
    refresh();
  }

  Future<void> refresh() async {
    if(AuthService.isLoggedIn) {
      await service.get<User>("/auth/refresh", true, null).then((value) { 
        if (value.data != null && value.data!.isNotEmpty) {
          appBarKey.currentState!.setState(() {
            user!.token = value.data![0].token;
            user!.notifications = value.data![0].notifications;
          });
        }
      }).catchError( (e) { return err(e.toString()); }); 
      await Future.delayed(const Duration(seconds: 30), () => refresh());
    }
  }
}