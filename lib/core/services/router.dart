import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqldbui2/core/sections/menu/menu.dart';
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/core/widget/actionbar.dart';
import 'package:sqldbui2/core/widget/dialog/confirm_box.dart';
import 'package:sqldbui2/core/widget/form/convertors/consent.dart';
import 'package:sqldbui2/core/widget/form/convertors/convertor.dart';
import 'package:sqldbui2/core/widget/datagrid/datagrid.dart';
import 'package:sqldbui2/core/widget/form/form.dart';
import 'package:sqldbui2/core/widget/utils/fork/multi_dropdown/multi_dropdown.dart';
import 'package:sqldbui2/main.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/core/services/api_service.dart';
import 'package:sqldbui2/page/translate.dart';

GlobalKey<RouterWidgetState> routerKey = GlobalKey<RouterWidgetState>();

class RouterWidget extends StatefulWidget {
  const RouterWidget({super.key});
  @override RouterWidgetState createState() => RouterWidgetState();
}

class RouterWidgetState extends State<RouterWidget> {
  @override Widget build(BuildContext context) {
  return FutureBuilder(future: futureBuild(context), builder: (b,a) {
      if (a.hasData && a.data != null) {
        return a.data!;
      }
      return Container();
    });
  }
  Future<Widget> futureBuild(BuildContext context) async {
    return Padding( padding: const EdgeInsets.only(right: 20), child: Row(children: [
      Tooltip( 
        message: (await getOnFlow(TranslateConstants.back)).toLowerCase(),
        child: IconButton(onPressed: () async => AppRouter.realHistory.length > 1 ? AppRouter.back() : null, icon: Icon(Icons.arrow_back, color: AppRouter.realHistory.length > 1 ? Colors.white : Theme.of(context).splashColor))),
      Tooltip( 
        message: (await getOnFlow(TranslateConstants.forward)).toLowerCase(),
        child: IconButton(onPressed: () async => AppRouter.canForward() ? AppRouter.forward() : null, icon: Icon(Icons.arrow_forward, color: AppRouter.canForward() ? Colors.white : Theme.of(context).splashColor))),
    ],));
  } 
}

class AppRouter { 
  static List<String> history = [];
  static List<String> realHistory = [];
  static final AppRouter _instance = AppRouter._internal();
  factory AppRouter() { return _instance; }
  AppRouter._internal() { 
    SharedPreferences.getInstance().then((prefs) {
      if (prefs.containsKey("history")) {
        realHistory = prefs.getString("history")!.split(",");
        history = prefs.getString("history")!.split(",");
        routerKey.currentState?.setState(() { });
      }
    });
  }    

  static Future<String?> getRouteCookie() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("url") != "" ? prefs.getString("url") : null;
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
      if (history.length > 10) { 
        try {
          realHistory.removeAt(0); 
          history.removeAt(0);
        } catch(e) {}
      }
      prefs.setString("history", realHistory.join(","));
      routerKey.currentState?.setState(() { });
    }
  }

  static back() async {
    if (realHistory.length <= 1) { return; }
    cacheForm = {};
    consentCache = {};
    oneToManiesForm = {};
    oneToManiesStateForm= {};
    cacheChanges = {};
    detectChanges = {};
    globalLoading = true;
    selectedGrid = []; 
    unselectedGrid = [];
    realHistory.removeLast();
    navigate = true;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("url", realHistory.last);
    prefs.setString("history", realHistory.join(","));
    var splitted = realHistory.last.split(":");
    viewID = splitted.isNotEmpty && splitted[0] != "" ? splitted[0] : null;
    subViewID = splitted.length > 1 && splitted[1] != "" ? splitted[1] : null;
    routerKey.currentState?.setState(() { });
    globalMainViewKey.currentState?.refresh(viewID, subViewID, null, true);
    Future.delayed(Duration(seconds: 1), () async {
      bool ok = false;
      var key = "$viewID";
      if ((subViewID ?? "") != "") {
        subViewID = "@${viewID?.replaceAll("#", "")}:$subViewID";
      }
      for (var e in navigatorCtrls.items) {
        e.selected = e.value == key;
        if (e.selected) {
          ok = true;
        }
      }
      if (!ok) {
        navigatorCtrls.items.add(DropdownItem<String>( 
          selected: true,
          value: key, 
          label: "${await getOnFlow(currentView!.label ?? currentView!.name.replaceAll("_", "").replaceAll("db", ""))} -> ${ 
            await getOnFlow(currentView!.items.isNotEmpty ?currentView!.items.first.values["name"] ?? "data" : "")}".toLowerCase()));
      }
      navigatorCtrls.openDropdown("", "", true);
      navigatorCtrls.closeDropdown();
    });
  }
  static bool canForward() {
    try {
      var index = history.indexOf(realHistory.last);
      return (index + 1) < history.length;
    } catch (e) { return false; }
    
  }
  static forward() async {
    if (canForward()) { 
      cacheForm = {};
      consentCache = {};
      oneToManiesForm = {};
      oneToManiesStateForm= {};
      cacheChanges = {};
      detectChanges = {};
      globalLoading = true;
      navigate = true;
      selectedGrid = []; unselectedGrid = [];
      var index = history.indexOf(realHistory.last);
      realHistory.add(history[index + 1]); 
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("url", realHistory.last);
      var splitted = realHistory.last.split(":");
      viewID = splitted.isNotEmpty && splitted[0] != "" ? splitted[0] : null;
      subViewID = splitted.length > 1 && splitted[1] != "" ? splitted[1] : null;
      prefs.setString("history", realHistory.join(","));
      
      routerKey.currentState?.setState(() { });
      globalMainViewKey.currentState?.refresh(viewID, subViewID, null, true);

      Future.delayed(Duration(seconds: 1), () async {
        bool ok = false;
        var key = "$viewID";
        if ((subViewID ?? "") != "") {
          subViewID = "@${viewID?.replaceAll("#", "")}:$subViewID";
        }
        for (var e in navigatorCtrls.items) {
          e.selected = e.value == key;
          if (e.selected) {
            ok = true;
          }
        }
        if (!ok) {
          navigatorCtrls.items.add(DropdownItem<String>( selected: true,
            value: key, 
            label: "${(await getOnFlow(currentView?.label ?? currentView!.name.replaceAll("_", "").replaceAll("db", "")))} -> ${ 
                      await getOnFlow(currentView?.items.isNotEmpty ?? false ? currentView!.items.first.values["name"] ?? "data" : "")
                    }".toLowerCase()));
          }
      });
      navigatorCtrls.openDropdown("", "", true);
      navigatorCtrls.closeDropdown();
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
        final id = state.uri.queryParameters['view_id'];
        if ((id ?? "") != "") {
          viewID = id;
        }
        final subid = state.uri.queryParameters['sub_id'];
        if ((subid ?? "") != "") {
          subViewID = subid;
        }
        final filterLine = state.uri.queryParameters['filter_line'];
        if ((filterLine ?? "") != "") {
          APIConstants.filterLine = filterLine!;
        }
        return HomeScreen();
      },
    )
  ];  
  static void navigateTo(String path) {
    setRouteCookie(path, globalMainViewKey.currentContext!);
    var splitted = path.split(":");
    viewID = splitted.isNotEmpty && splitted[0] != "" ? splitted[0] : null;
    subViewID=splitted.length > 1 && splitted[1] != "" ? splitted[1] : null;
    cacheForm = {};
    consentCache = {};
    oneToManiesForm = {};
    oneToManiesStateForm = {};
    cacheChanges = {};
    detectChanges = {};
    currentView = null;
    globalLoading = true;
    selectedGrid = []; 
    unselectedGrid = [];
    confirmCache = {};
    navigate = true;
    globalMainViewKey.currentState?.refresh(viewID, subViewID, null, true);
  }
}   
// ROUTER SHOULD INVOKE MAIN TO ACCESS VIEW, VIEW ARE MENU SECTION