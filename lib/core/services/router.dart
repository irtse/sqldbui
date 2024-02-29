import 'package:flutter/material.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:go_router/go_router.dart';
import 'package:sqldbui2/core/services/api_service.dart';
import 'package:sqldbui2/main.dart';

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
}   
// ROUTER SHOULD INVOKE MAIN TO ACCESS VIEW, VIEW ARE MENU SECTION