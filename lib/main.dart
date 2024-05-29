// import 'package:cookie_consent/cookie_consent.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sqldbui2/core/widget/dialog/tutorial.dart';
import 'package:sqldbui2/model/response.dart';
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/core/services/router.dart';
import 'package:sqldbui2/core/widget/utils/grid.dart';
import 'package:sqldbui2/core/services/api_service.dart';
import 'package:sqldbui2/core/services/auth_service.dart';

import 'package:sqldbui2/core/sections/notifications.dart';
import 'package:sqldbui2/page/login.dart';
import 'package:sqldbui2/page/page.dart';

final ThemeData myTheme = ThemeData(
  secondaryHeaderColor: const Color.fromRGBO(40, 42, 54, 1),
  primaryColorLight: const Color.fromRGBO(68, 71, 90, 1),
  highlightColor: const Color.fromRGBO(248, 248, 242 , 1),
  shadowColor: const Color.fromRGBO(98, 114, 164  , 1),
);

void main() { runApp(const MyApp()); }
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
String? viewID;
String? subViewID;
String? category;
GlobalKey<HomeScreenState> homeKey = GlobalKey<HomeScreenState>();
// ignore: must_be_immutable
class HomeScreen extends StatefulWidget {
  
  HomeScreen({ Key? key }): super(key: homeKey);
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
  void refresh(String? id, bool isHome) {
    viewID = id;
    subViewID = null;
    APIService.cache = <String, APIResponse<dynamic>>{};
    currentView = null;
    beforeView = null;
    resetAllFilter();
    notNew = {};
    setState(() {});
    if (isHome) { AppRouter.setRouteCookie(""); }
  }
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    AuthService();
    if (!AuthService.isLoggedIn) { return const LoginScreen(); }
    
    AppRouter.getRouteCookie().then((value) {
      print("Route cookie $value");
        if (value != null && value != "") {
          var splitted = value.replaceAll("#", "/").replaceAll(":", "/").split("/");
          viewID = splitted.length > 1 ? splitted[1] : null;
          subViewID = splitted.length > 2 ? splitted[2] : null;
        } 
        AppRouter.navigateTo("#$viewID${subViewID != null ? ":$subViewID" : ""}");
    });
    var scaffoldKey = GlobalKey<ScaffoldState>();
    // showCookieConsent(context, cookiePolicyUrl: Uri.parse('https://www.irt-saintexupery.com/fr/credits-legal-notice/') );
    return Scaffold(
      key: scaffoldKey,
      floatingActionButton: FloatingActionButton(backgroundColor: Theme.of(context).primaryColor,
        onPressed: () => showDialog(context: context, builder: (BuildContext context) { return TutorialPopUpWidget(); },), child: Icon(Icons.question_mark, color: Colors.white,)),
      endDrawer: const NotificationDrawerWidget(),
      appBar: AppBar(
        elevation: 3,
        automaticallyImplyLeading: false,
        shadowColor: Theme.of(context).secondaryHeaderColor,
        backgroundColor: Theme.of(context).secondaryHeaderColor,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Padding(padding: const EdgeInsets.only(left: 50, right: 50), 
          child: SizedBox(child: Row(children: [
            InkWell( onTap: () {
              viewID = "";
              subViewID = null;
              setState(() {});
            }, child: Image(image: const AssetImage('assets/images/logo.png'), width: MediaQuery.of(context).size.width > 600 ? 60 : 0,)),
            Flexible( child: Container(padding: const EdgeInsets.only(left: 30), 
              child: MediaQuery.of(context).size.width > 600 ? Text("SOFTWARE NAME", overflow: TextOverflow.ellipsis,
                style: TextStyle( color: Theme.of(context).highlightColor,),) : null)),
                Padding(padding: const EdgeInsets.only(left: 50, right: 10), 
                child: MediaQuery.of(context).size.width > 600 ? Icon(Icons.verified_user, color: Theme.of(context).splashColor) : null),
                Flexible(child: Container(padding: const EdgeInsets.only(left: 0, right: 0), 
                  child: MediaQuery.of(context).size.width > 600 ? Text("${AuthService.user != null ? AuthService.user!.name : "unknown"} - ${AuthService.user != null ? AuthService.user!.email : ""}",
                  overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, color: Theme.of(context).splashColor)) : null)),
              ],)
        )),         
        toolbarHeight: 40,
        actions: <Widget>[
          Stack( children: [
             IconButton(icon: const Icon(Icons.notifications, color: Colors.white, size: 25,),
             onPressed: () { 
              if (AuthService.user!.notifications.isNotEmpty) { scaffoldKey.currentState!.openEndDrawer(); }
             },),
             NotificationWidget(key: appBarKey,),
          ],),
          Padding(padding: const EdgeInsets.only(left: 25, right: 50), 
            child: IconButton(icon: const Icon( Icons.logout_outlined, color: Colors.white, ), tooltip: "logout",
                              onPressed: () async { await _authProvider.logOut(context); }, )
          )
        ],
      ),
      body: PageWidget(key: globalPageKey),
      backgroundColor: Theme.of(context).secondaryHeaderColor,
    );
  }
}
class NotificationWidget extends StatefulWidget {
  const NotificationWidget({ Key? key }): super(key: key);
  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".
  @override
  NotificationWidgetState createState() => NotificationWidgetState();
}
GlobalKey<NotificationWidgetState> appBarKey = GlobalKey<NotificationWidgetState>();
class NotificationWidgetState extends State<NotificationWidget> {
  @override
  Widget build(BuildContext context) {
    return Positioned( left: 10, child: Container(
      height: 20, alignment: Alignment.bottomRight,
      child: Container( width: 15, height: 20,
        decoration: BoxDecoration( shape: BoxShape.circle,
          color: const Color(0xffc32c37),
          border: Border.all(color: Colors.white, width: 1)),
        child: Padding( padding: const EdgeInsets.all(0.0),
          child: Center( child: Text( overflow: TextOverflow.ellipsis,
            AuthService.user!.notifications.length > 9 ? "+" : AuthService.user!.notifications.length.toString(),
            style: const TextStyle(fontSize: 9, color: Colors.white),
    ))))));
  }
}