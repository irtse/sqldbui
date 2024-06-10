import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqldbui2/core/sections/menu.dart';
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/main.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/core/services/api_service.dart';


GlobalKey<RouterWidgetState> routerKey = GlobalKey<RouterWidgetState>();

class RouterWidget extends StatefulWidget {
  const RouterWidget({Key? key}) : super(key: key);
  @override RouterWidgetState createState() => RouterWidgetState();
}

class RouterWidgetState extends State<RouterWidget> {
  @override Widget build(BuildContext context) {
    return Padding( padding: const EdgeInsets.only(right: 20), child: Row(children: [
      IconButton(onPressed: () async => AppRouter.realHistory.length > 1 ? AppRouter.back() : null, icon: Icon(Icons.arrow_back, color: AppRouter.realHistory.length > 1 ? Colors.white : Theme.of(context).splashColor)),
      IconButton(onPressed: () async => AppRouter.canForward() ? AppRouter.forward() : null, icon: Icon(Icons.arrow_forward, color: AppRouter.canForward() ? Colors.white : Theme.of(context).splashColor)),
    ],));
  }
  
}

class AppRouter { 
  static List<String> history = [];
  static List<String> realHistory = [];
  static String? routedSubID;
  static final AppRouter _instance = AppRouter._internal();
  factory AppRouter() { return _instance; }
  AppRouter._internal() { /* logic*/}    


  static Future<String?> getRouteCookie() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("url");
  }

  static removeRouteCookie() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("url");
  }

  static setRouteCookie( String path , BuildContext context ) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("url", path);
    if (realHistory.isNotEmpty && realHistory.last != path || realHistory.isEmpty) {
      try {
        var index = history.indexOf(realHistory.last);
        history = history.sublist(0, index + 1);
      } catch (e) { /* */ }
      realHistory.add(path);
      history.add(path);
      routerKey.currentState?.setState(() { });
    }
  }

  static back() async {
    if (realHistory.length <= 1) { return; }
    realHistory.removeLast();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("url", realHistory.last);
    homeKey.currentState?.setState(() { });
  }
  static bool canForward() {
    try {
      var index = history.indexOf(realHistory.last);
      return (index + 1) < history.length;
    } catch (e) { return false; }
    
  }
  static forward() async {
    if (canForward()) { 
      var index = history.indexOf(realHistory.last);
      realHistory.add(history[index + 1]); 
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("url", realHistory.last);
      homeKey.currentState?.setState(() { });
    }
  }

  final APIService service = APIService(); 
  String currentRoute = "/home";    
  List<model.View>? views;
  List<RouteBase> get routes => <RouteBase>[      
   //HomeScreen is generated as HomeRoute because     
   //of the replaceInRouteName property    
    GoRoute(
      name: "home",
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return HomeScreen();
      },
    ),
    GoRoute(
      name: "view",
      path: '/:id',
      builder: (BuildContext context, GoRouterState state) {
        viewID = state.pathParameters['id'];
        subViewID = null;
        return HomeScreen(fromUrl: true,);
      },
    ),
    GoRoute(
          name: "subview",
          path: '/:id/:subid',
          builder: (BuildContext context, GoRouterState state) {
            viewID = state.pathParameters['id'];
            subViewID = state.pathParameters['subid'];
            return HomeScreen(fromUrl: true,);
          },
    ),
  ];  
  static void navigateWith(String path) {
    globalMainViewKey.currentState?.refreshUrl(path, subViewID, false);  
  }
  static void navigateTo(String path) {
    var splitted = path.replaceAll("#", "/").replaceAll(":", "/").split("/");
    viewID = splitted.length > 1 ? splitted[1] : null;
    routedSubID=splitted.length > 2 ? splitted[2] : null;
    currentView = null;
    globalMenuKey.currentState?.refresh(false);
  }
}   
// ROUTER SHOULD INVOKE MAIN TO ACCESS VIEW, VIEW ARE MENU SECTION