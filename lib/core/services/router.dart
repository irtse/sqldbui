import 'package:flutter/material.dart';
import 'package:sqldbui2/core/sections/menu.dart';
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:go_router/go_router.dart';
import 'package:sqldbui2/core/services/api_service.dart';
import 'package:sqldbui2/main.dart';
import 'package:sqldbui2/page/page.dart';

class AppRouter { 
  static final AppRouter _instance = AppRouter._internal();
  factory AppRouter() { return _instance; }
  AppRouter._internal() { /* logic*/}    

  final APIService service = APIService(); 
  String currentRoute = "/home";    
  List<model.View>? views;
  @override      
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
        return HomeScreen(viewID: state.pathParameters['id'],);
      },
    ),
    GoRoute(
          name: "subview",
          path: '/:id/:subid',
          builder: (BuildContext context, GoRouterState state) {
            return HomeScreen(viewID: state.pathParameters['id'], subViewID: state.pathParameters['subid'],);
          },
    ),
  ];  
  static void navigateTo(String path) {
    globalMenuKey.currentState!.setState(() {
      var splitted = path.replaceAll("#", "/").replaceAll(":", "/").split("/");
      currentView = null;
      homeKey.currentState!.widget.viewID= splitted.length > 1 ? splitted[1] : null;
      homeKey.currentState!.widget.subViewID=splitted.length > 2 ? splitted[2] : null;
    });
  }
}   
// ROUTER SHOULD INVOKE MAIN TO ACCESS VIEW, VIEW ARE MENU SECTION