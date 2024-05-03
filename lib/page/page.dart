import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:sqldbui2/model/response.dart';
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/core/sections/menu.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/core/sections/homeview.dart';
import 'package:sqldbui2/core/services/api_service.dart';
/// Flutter code sample for [FutureBuilder].
GlobalKey<PageWidgetState> globalPageKey = GlobalKey<PageWidgetState>();
class PageWidget extends StatefulWidget {
  const PageWidget({super.key});

  @override
  State<PageWidget> createState() => PageWidgetState();
}
class PageWidgetState extends State<PageWidget> {
  @override Widget build(BuildContext context) {
    menuSize = isMenu ? (MediaQuery.of(context).size.width <= 250 ? MediaQuery.of(context).size.width : 250) : 0;
    return Stack( alignment: Alignment.topCenter,
      children: [
        FutureBuilder<APIResponse<model.View>>(
          future: APIService().get<model.View>(APIConstants.mainEndpost, false, null), // a previously-obtained Future<String> or null
          builder: (BuildContext context, AsyncSnapshot<APIResponse<model.View>> snapshot) {
          var c = <Widget>[];
          if (snapshot.hasData && snapshot.data!.data != null) { 
            List<model.View> views = snapshot.data!.data!;
            List<Widget> c = menuSize == 0 ? [] : <Widget>[Container(
              color: Theme.of(context).secondaryHeaderColor,
              width: menuSize, child: MenuWidget(key: globalMenuKey, views: views))];
            try { c.add(MainViewWidget(key: globalMainViewKey, views: views));  } catch (e) { /* */ }
            return Row(crossAxisAlignment: CrossAxisAlignment.start, children: c);
          }
          return Row(crossAxisAlignment: CrossAxisAlignment.start, children: c);
      }
    ),
    AnimatedPositioned(
      duration: const Duration(milliseconds: 200), 
      left: isMenu ? 80 : -10, bottom: -8,
      child: CircleAvatar(
        radius: 30, backgroundColor: Theme.of(context).secondaryHeaderColor,
        child: IconButton( iconSize: 30, color: Theme.of(context).splashColor,
          icon: Icon(isMenu ? Icons.close :  Icons.menu), 
      onPressed: () { 
        globalHomeViewKey.currentState?.setState(() {});
        setState(() { isMenu = !isMenu;  });
      })
    ))],
    );
    
  }
}