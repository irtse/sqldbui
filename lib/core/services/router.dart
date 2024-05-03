import 'package:sqldbui2/core/sections/menu.dart';
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/main.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/core/services/api_service.dart';

class AppRouter { 
  static String? routedSubID;
  static final AppRouter _instance = AppRouter._internal();
  factory AppRouter() { return _instance; }
  AppRouter._internal() { /* logic*/}    

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
        return HomeScreen();
      },
    ),
    GoRoute(
          name: "subview",
          path: '/:id/:subid',
          builder: (BuildContext context, GoRouterState state) {
            viewID = state.pathParameters['id'];
            subViewID = state.pathParameters['subid'];
            return HomeScreen();
          },
    ),
  ];  
  static void navigateWith(String path) {
    viewID = null;
    globalMainViewKey.currentState?.refreshUrl(path, null, false);  
  }
  static void navigateTo(String path) {
    var splitted = path.replaceAll("#", "/").replaceAll(":", "/").split("/");
    viewID = splitted.length > 1 ? splitted[1] : null;
    routedSubID=splitted.length > 2 ? splitted[2] : null;
    currentView = null;
    globalMenuKey.currentState?.refresh();
  }
}   
// ROUTER SHOULD INVOKE MAIN TO ACCESS VIEW, VIEW ARE MENU SECTION