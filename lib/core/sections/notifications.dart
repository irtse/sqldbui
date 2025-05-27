import 'package:sqldbui2/main.dart';
import 'package:flutter/material.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/core/services/router.dart';
import 'package:sqldbui2/core/services/api_service.dart';
import 'package:sqldbui2/core/services/auth_service.dart';
import 'package:sqldbui2/page/translate.dart';
// ignore: must_be_immutable
class NotificationDrawerWidget extends StatefulWidget{
  const NotificationDrawerWidget ({ super.key });
  @override NotificationDrawerWidgetState createState() => NotificationDrawerWidgetState();
}
class NotificationDrawerWidgetState extends State<NotificationDrawerWidget> {
  @override Widget build(BuildContext context) {
  return FutureBuilder(future: futureBuild(context), builder: (b,a) {
      if (a.hasData && a.data != null) {
        return a.data!;
      }
      return Container();
    });
  }
  Future<Widget> futureBuild(BuildContext context) async {
    try{
    List<Widget> notifs = [
      Container( 
        width: currentWidth / 2,
        padding: const EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20), 
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Theme.of(context).splashColor ))
        ),
        child: Row( 
          mainAxisAlignment: MainAxisAlignment.center, 
          children : [ 
            Padding(
              padding: const EdgeInsets.only(right: 10), 
              child: Icon(Icons.notifications, color: Theme.of(context).splashColor, size: 20)
            ),
            Text(TranslateConstants.notifications.toUpperCase(), overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Theme.of(context).highlightColor, fontSize: 15)) 
          ]))
    ];
    for ( var notif in AuthService.user!.notifications ) {
        var name = notif.name;
        var desc = notif.description;
        try { name = await getOnFlow(notif.name);
        } catch(e) {}
        try { desc = await getOnFlow(notif.description);
        } catch(e) {}
        
        notifs.add(Stack( alignment: Alignment.center, children : [ 
          Padding(padding: const EdgeInsets.only(bottom: 10), 
          child: Row( mainAxisAlignment: MainAxisAlignment.center, children: [ Container(
          width: currentWidth / 1.2,
          padding: const EdgeInsets.only(bottom: 20, top: 15),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Theme.of(context).splashColor, ))),
          child: Column(children: [
          Padding(padding: const EdgeInsets.only(left: 20, right: 30), child: TextButton( onPressed: () { 
            var splitted = notif.ref.replaceAll(":", "/").split("/");
            viewID = splitted.length > 1 && splitted[1] == "" ? splitted[1] : null;
            subViewID=splitted.length > 2 && splitted[2] == "" ? splitted[2] : null;
            AppRouter.navigateTo(notif.ref); 
            Future.delayed(const Duration(seconds: 1), () => setState(() { APIService().delete<model.View>(notif.linkPath.replaceAll("rows=all", "rows=${notif.id}"), null); }));
          }, 
          child: Row(
            children: [
              Icon(Icons.message, color: Theme.of(context).splashColor), Padding( padding: const EdgeInsets.only(left: 10), 
                child: Text( name.toUpperCase()
                  , overflow: TextOverflow.ellipsis, style: TextStyle(color: Theme.of(context).highlightColor))),
            ]))),
          Padding( padding: const EdgeInsets.symmetric(horizontal: 40), 
            child: Row( children: [Text(desc == "" ? "" : desc.toLowerCase(), 
              style: TextStyle(color: Theme.of(context).splashColor), overflow: TextOverflow.ellipsis,)])),
        ]))])),
        Positioned(
          right: 10, 
          top: 11, 
          child: IconButton(
            icon: const Icon(Icons.close), 
            onPressed: () => { 
              APIService().delete<model.View>(notif.linkPath.replaceAll("rows=all", "rows=${notif.id}"), null).then((value) =>
                setState(() {
                  AuthService.user!.notifications.remove(notif);
                  appBarKey.currentState!.setState(() {});
                } ))
            }
          )) 
      ])); 
    }
    return Container(
        width: currentWidth / 1.2,
        height: currentHeigth,
        color: Theme.of(context).secondaryHeaderColor,
        child: SingleChildScrollView( child: Column(children: notifs) ));
    } catch(e, s) {
     print(e);
     print(s); 
     return Container();
    }
  }
}