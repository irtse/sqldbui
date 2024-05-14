import 'dart:developer' as developer;
import 'package:sqldbui2/main.dart';
import 'package:flutter/material.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/core/services/router.dart';
import 'package:sqldbui2/core/services/api_service.dart';
import 'package:sqldbui2/core/services/auth_service.dart';
// ignore: must_be_immutable
class NotificationDrawerWidget extends StatefulWidget{
  const NotificationDrawerWidget ({ Key? key }): super(key: key);
  @override NotificationDrawerWidgetState createState() => NotificationDrawerWidgetState();
}
class NotificationDrawerWidgetState extends State<NotificationDrawerWidget> {
  @override Widget build(BuildContext context) {
    var len = MediaQuery.of(context).size.width > 430 ? 40 : ((MediaQuery.of(context).size.width ~/ 11));
    List<Widget> notifs = [Container( padding: const EdgeInsets.only(top: 10, bottom: 10), 
      width: 430 < MediaQuery.of(context).size.width ? 430 : MediaQuery.of(context).size.width,
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Theme.of(context).splashColor, ))),
      child: Row( mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children : [ Padding(padding: const EdgeInsets.only(right: 10), 
      child: Icon(Icons.notifications, color: Theme.of(context).splashColor, size: 20,)),
        Text("Notifications", style: TextStyle(color: Theme.of(context).highlightColor, fontSize: 15,),) ]))];
    for ( var notif in AuthService.user!.notifications ) {
        notifs.add(Stack( children : [ 
          Padding(padding: const EdgeInsets.only(bottom: 10), 
          child: Row( mainAxisSize: MainAxisSize.min, children: [ Container(
          padding: const EdgeInsets.only(bottom: 20, top: 15),
          width: 430 < MediaQuery.of(context).size.width ? 430 : MediaQuery.of(context).size.width,
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Theme.of(context).splashColor, ))),
          child: Column(children: [
          Padding(padding: const EdgeInsets.only(left: 20, right: 30), child: TextButton( onPressed: () { 
            AppRouter.navigateTo(notif.ref); 
            Future.delayed(const Duration(seconds: 1), () => setState(() { APIService().delete<model.View>(notif.linkPath.replaceAll("rows=all", "rows=${notif.id}"), null); }));
          }, 
          child: Row(
                  children: [Icon(Icons.message, color: Theme.of(context).splashColor), Padding( padding: const EdgeInsets.only(left: 10), 
                  child: Text(notif.name[0].toUpperCase()
                  + notif.name.substring(1, len > notif.name.length ? notif.name.length : len).toLowerCase() 
                  + (len > notif.name.length ? "" : "...")
                  , overflow: TextOverflow.ellipsis, style: TextStyle(color: Theme.of(context).highlightColor))),
                ],))),
          Padding( padding: const EdgeInsets.symmetric(horizontal: 40), 
            child: Row( children: [Text(notif.description == "" ? "" : notif.description[0] 
            + notif.description.substring(1, len > notif.description.length ? notif.description.length : len).toLowerCase() 
            + (len > notif.description.length ? "" : "..."), 
              style: TextStyle(color: Theme.of(context).splashColor), overflow: TextOverflow.ellipsis,)])),
        ]))])),
        Positioned(right: 10, top: 11, child: IconButton(icon: const Icon(Icons.close), 
          onPressed: () => { 
            APIService().delete<model.View>(notif.linkPath.replaceAll("rows=all", "rows=${notif.id}"), null).then((value) =>
              setState(() {
                AuthService.user!.notifications.remove(notif);
                appBarKey.currentState!.setState(() {});
              } ))
          },)) ]));
    }
    return Container(
        constraints: const BoxConstraints(minWidth: 200),
        height: MediaQuery.of(context).size.height,
        color: Theme.of(context).secondaryHeaderColor,
        child: SingleChildScrollView( child: Column(children: notifs) ));
  }
}