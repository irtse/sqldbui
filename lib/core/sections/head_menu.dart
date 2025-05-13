import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/main.dart';
import 'package:flutter/material.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/core/services/router.dart';
import 'package:sqldbui2/core/services/api_service.dart';
import 'package:sqldbui2/core/services/auth_service.dart';
import 'package:sqldbui2/page/page.dart';
import 'package:sqldbui2/page/translate.dart';
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
  Future<Widget> futureBuild(BuildContext context) async {
    return Padding(padding: EdgeInsets.only(left: noMenu ? 0 : 50, right: 50), 
          child: SizedBox(child: Row(children: [
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
          ],)
        ));
  }
  void clear() {
    homeKey.currentState?.setState(() {
      currentView = null;
      viewID = TranslateConstants.dashboard.toLowerCase();
      subViewID = null;
    });
  }
}
