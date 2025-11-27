import 'package:sqldbui2/core/sections/menu/menu.dart';
import 'package:sqldbui2/core/services/api_service.dart';
import 'package:sqldbui2/core/widget/form/convertors/consent.dart';
import 'package:sqldbui2/core/widget/form/form.dart';
import 'package:sqldbui2/main.dart';
import 'package:flutter/material.dart';
import 'package:sqldbui2/model/user.dart';
import 'package:sqldbui2/page/page.dart';
import 'package:sqldbui2/page/translate.dart';
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/core/services/router.dart';
import 'package:sqldbui2/core/services/auth_service.dart';
import 'package:toggle_switch/toggle_switch.dart';

// ignore: must_be_immutable
class HeadMenuWidget extends StatefulWidget{
  const HeadMenuWidget ({ super.key });
  @override HeadMenuWidgetState createState() => HeadMenuWidgetState();
}
class HeadMenuWidgetState extends State<HeadMenuWidget> {
  @override Widget build(BuildContext context) {
  return FutureBuilder(future: futureBuild(context), builder: (b,a) {
      if (a.hasData && a.data != null) {
        return a.data!;
      }
      return Container();
    });
  }
  bool? isMaintenance;
  Future<Widget> futureBuild(BuildContext context) async {
    var toggles = [
        Icons.close,
        Icons.check,
    ];
    
    return Padding(
      padding: EdgeInsets.only(left: noMenu ? 0 : 50, right: 50), 
      child: SizedBox(
        child: Row(children: [
          currentWidth > 400 ? RouterWidget(key: routerKey) : Container(),
          Tooltip( message: (await getOnFlow(TranslateConstants.home)).toLowerCase(), child: InkWell( onTap: () { clear(); },  
            child: Image(image: const AssetImage('assets/images/logo.png'), width: currentWidth > 600 ? 60 : 0,))),
          Tooltip( message: (await getOnFlow(TranslateConstants.home)).toLowerCase(), child:  InkWell( onTap: () { clear(); }, 
            child:Container(
              padding: EdgeInsets.only(left: currentWidth > 600 ? 30 : 0), 
              child: currentWidth > 1000 ? Text("OPPS", overflow: TextOverflow.ellipsis,
                style: TextStyle( color: Theme.of(context).highlightColor)) : null))),
          Padding(
            padding: EdgeInsets.only(left: currentWidth > 600 ?  50 : 0, 
              right: currentWidth > 600 ?  10 : 0), 
            child: currentWidth > 600 ? Icon(Icons.verified_user, color: Theme.of(context).splashColor) : null),
          Flexible(child: Container(padding: const EdgeInsets.only(left: 0, right: 0), 
            child: currentWidth > 600 ? Text("${AuthService.user != null ? "${AuthService.user!.name} - " : "unknown" }${AuthService.user != null ? AuthService.user!.email : ""}",
              overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, color: Theme.of(context).splashColor)) : null)),
          if (AuthService.user?.isSuperAdmin ?? false)
              FutureBuilder(future: APIService().get<Server>("/auth/maintenance", true, context), builder: (a,s) {
                if (s.data != null && (s.data!.data ?? []).isNotEmpty) {
                  return FutureBuilder<String>(future: getOnFlow("maintenance mode ${ s.data!.data!.first.isMaintenance ? ": in maintenance" : ": running"}"), builder: (a,d) {
                      if (d.data != null) {
                      return Padding( 
                        padding: const EdgeInsets.only(left: 20), 
                        child: Tooltip( message: d.data , child: ToggleSwitch( 
                          icons: toggles, 
                          minHeight: 20, 
                          minWidth: 40, 
                          fontSize: 11, 
                          cornerRadius: 5,
                          initialLabelIndex: isMaintenance != null ? ( isMaintenance == true ? 1 : 0 ) : ( s.data!.data!.first.isMaintenance ? 1 : 0),
                          dividerColor: Colors.white, 
                          inactiveFgColor: Theme.of(context).splashColor,
                          totalSwitches: toggles.length, 
                          inactiveBgColor: Theme.of(context).secondaryHeaderColor,
                          onToggle: (index) async {
                            await APIService().post<Server>("/auth/maintenance", {
                              "is_maintenance": index == 1,
                            }, context);
                            isMaintenance = index == 1;
                            setState(() {});
                          }
                        )));
                    }
                    return Padding( 
                        padding: const EdgeInsets.only(left: 10), 
                        child: Tooltip( message: "maintenance mode ${ s.data!.data!.first.isMaintenance ? ": in maintenance" : ": running"}",
                         child: ToggleSwitch( 
                          icons: toggles, 
                          minHeight: 20, 
                          minWidth: 40, 
                          fontSize: 11, 
                          cornerRadius: 5,
                          initialLabelIndex: isMaintenance != null ? ( isMaintenance == true ? 1 : 0 ) : (s.data!.data!.first.isMaintenance ? 1 : 0),
                          dividerColor: Colors.white, 
                          inactiveFgColor: Theme.of(context).splashColor,
                          totalSwitches: toggles.length, 
                          inactiveBgColor: Theme.of(context).secondaryHeaderColor,
                          onToggle: (index) async {
                            await APIService().post<Server>("/auth/maintenance", {
                              "is_maintenance": index == 1,
                            }, context);
                            isMaintenance = index == 1;
                            setState(() {});
                          }
                        )));
                  });                   
                }
                return Container();
              }),
        ])
      )
    );
  }
  void clear() {
    cacheForm = {};
    consentCache = {};
    oneToManiesForm = {};
    oneToManiesStateForm = {};
    globalMainViewKey.currentState?.setState(() {
      currentView = null;
      viewID = "dashboard";
      subViewID = null;
      globalMenuKey.currentState?.setState(() { });
    });
  }
}
