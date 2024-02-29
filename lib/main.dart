import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sqldbui2/core/services/auth_service.dart';
import 'package:sqldbui2/core/services/router.dart';
import 'package:sqldbui2/page/login.dart';
import 'package:sqldbui2/page/page.dart';

final ThemeData myTheme = ThemeData(
  secondaryHeaderColor: const Color.fromRGBO(40, 42, 54, 1),
  selectedRowColor: const Color.fromRGBO(68, 71, 90, 1),
  highlightColor: const Color.fromRGBO(248, 248, 242 , 1),
  shadowColor: const Color.fromRGBO(98, 114, 164  , 1),
);

void main() {
  runApp(const MyApp());
}
final _authProvider = AuthService();          
final _appRouter = AppRouter();   

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: myTheme,
      routerConfig: GoRouter(routes: _appRouter.routes),
    );
  }
}
GlobalKey<HomeScreenState> homeKey = GlobalKey<HomeScreenState>();
class HomeScreen extends StatefulWidget {
  String? viewID;
  String? subViewID;
  HomeScreen({ Key? key, this.viewID, this.subViewID }): super(key: homeKey);
  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".
  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    if (!AuthService().isLoggedIn) { return const LoginScreen(); }
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        shadowColor: Theme.of(context).secondaryHeaderColor,
        backgroundColor: Theme.of(context).secondaryHeaderColor,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Padding(padding: const EdgeInsets.only(left: 50, right: 50), 
                       child: SizedBox(
                        width: 700,
                        child: Row(children: [
                          const Image(image: AssetImage('assets/images/logo.png'), width: 60,),
                          Padding(
                            padding: const EdgeInsets.only(left: 30), 
                            child: Text("SOFTWARE NAME", 
                            style: TextStyle( color: Theme.of(context).highlightColor,),)),
                            
                            Padding(padding: const EdgeInsets.only(left: 50, right: 10), 
                              child: Icon(Icons.verified_user, color: Theme.of(context).splashColor),
                            ),
                            Padding(padding: const EdgeInsets.only(left: 0, right: 50), 
                              child: Text("${AuthService.user != null ? AuthService.user!.name : "unknown"} - ${AuthService.user != null ? AuthService.user!.email : ""}",
                                style: TextStyle(fontSize: 13, color: Theme.of(context).splashColor)),
                            ),
                        ],)
                       )),         
        toolbarHeight: 40,
        actions: <Widget>[

          Padding(padding: const EdgeInsets.only(left: 50, right: 50), 
                  child: IconButton(icon: const Icon( Icons.logout_outlined, color: Colors.white, ), tooltip: "logout",
                                    onPressed: () async { await _authProvider.logOut(context); }, )
          )
        ],
      ),
      body: const PageWidget(),
    );
  }
}