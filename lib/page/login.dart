import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:go_router/go_router.dart';
import 'package:sqldbui2/core/services/auth_service.dart';
import 'dart:developer' as developer;

// @RoutePage<bool>()
class LoginScreen extends StatefulWidget {
    // final Function(bool?) onResult;
    const LoginScreen({super.key});
    @override
    _LoginWidgetState createState() => _LoginWidgetState();
}
class _LoginWidgetState extends State<LoginScreen> {
  static final AuthService service = AuthService();
  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".
  Duration get loginTime => const Duration(milliseconds: 2250);

  Future<String?> _authUser(LoginData data) async {
    debugPrint('Name: ${data.name}, Password: ${data.password}');
    return Future.delayed(loginTime).then((_) async {
      await service.login(data.name, data.password);
      if (service.error != null) { return service.error; }
      return null;
    });
  }

  Future<String?> _signupUser(SignupData data) {
    debugPrint('Signup Name: ${data.name}, Password: ${data.password}');
    return Future.delayed(loginTime).then((_) {
      return null;
    });
  }

  Future<String> _recoverPassword(String name) {
    debugPrint('Name: $name');
    return Future.delayed(loginTime).then((_) {
      return "Not implemented";
    });
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: '',
      userValidator: (value) {
        if (value == null || value == "") { return "Must not be empty";}
        return null;
      },
      messages: LoginMessages(userHint: "Username/Email"),
      userType: LoginUserType.name,
      logo: const AssetImage('assets/images/logo.png'),
      onLogin: _authUser,
      onSignup: _signupUser,
      onSubmitAnimationCompleted: () {
        setState(() {
          if (AuthService.isLoggedIn) {  context.go("/"); } 
        });    
      },
      onRecoverPassword: _recoverPassword,
    );
  }
}
