import 'package:flutter/material.dart';
import 'package:sqldbui2/core/widget/utils/fork/login/flutter_login.dart';
import 'package:go_router/go_router.dart';
import 'package:sqldbui2/core/services/auth_service.dart';
import 'package:sqldbui2/main.dart';
import 'package:sqldbui2/page/translate.dart';

// @RoutePage<bool>()
class LoginScreen extends StatefulWidget {
    // final Function(bool?) onResult;
    const LoginScreen({super.key});
    @override
    // ignore: library_private_types_in_public_api
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
    return Future.delayed(loginTime).then((_) async {
      await service.login(data.name, data.password);
      if (service.error != null) { return service.error; }
      return null;
    });
  }

  @override Widget build(BuildContext context) {
    return FutureBuilder(future: futureBuild(context), builder: (b,a) {
        if (a.hasData && a.data != null) {
          return a.data!;
        }
        return Container();
      });
  }
  Future<Widget> futureBuild(BuildContext context) async {
    return Stack( children: [ FlutterLogin(
        title: '',
        userValidator: (value) {
          if (value == null || value == "") { return "Must not be empty";}
          return null;
        },
        hideForgotPasswordButton: true,
        userType: LoginUserType.name,
        logo: const AssetImage('assets/images/logo.png'),
        onLogin: _authUser,
        onSignup: null,
        messages: LoginMessages(
          userHint: (await getOnFlow('username/email')).toLowerCase(),
          passwordHint: (await getOnFlow('password')).toLowerCase(),
          loginButton: (await getOnFlow('LOGIN')).toUpperCase(),
          forgotPasswordButton: '',
          recoverPasswordButton: '',
        ),
        onSubmitAnimationCompleted: () {
          if (AuthService.isLoggedIn) {  setState(() { context.go("/"); }); }   
        },
        onRecoverPassword: null,
      ), 
      Positioned( bottom: 20, right: 50, child: Text("build ${BuildInfo.buildId} ~ ${BuildInfo.buildDate}", 
        style: TextStyle(
          fontFamily: "arial", decoration: TextDecoration.none, fontWeight: FontWeight.normal,
          fontSize: 12, color: Colors.white))),
    ]);
  }
}
