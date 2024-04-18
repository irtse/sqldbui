import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:sqldbui2/core/widget/datagrid/grid.dart';
import 'package:sqldbui2/main.dart';
import 'package:sqldbui2/model/response.dart';
import 'package:sqldbui2/core/sections/menu.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/core/services/api_service.dart';
/// Flutter code sample for [FutureBuilder].
GlobalKey<PageWidgetState> globalPageKey = GlobalKey<PageWidgetState>();
class PageWidget extends StatefulWidget {
  const PageWidget({super.key});

  @override
  State<PageWidget> createState() => PageWidgetState();
}
class PageWidgetState extends State<PageWidget> {
  Future<APIResponse<model.View>> _items() async {
    return APIService().get<model.View>(APIConstants.mainEndpost, true, null);    
  }

  @override Widget build(BuildContext context) {
    return Stack( alignment: Alignment.topCenter,
      children: [
        FutureBuilder<APIResponse<model.View>>(
          future: _items(), // a previously-obtained Future<String> or null
          builder: (BuildContext context, AsyncSnapshot<APIResponse<model.View>> snapshot) {
          if (snapshot.hasData && snapshot.data!.data != null) { return MenuWidget(key: globalMenuKey, views: snapshot.data!.data); }
          return MenuWidget(key: globalMenuKey, views: null);
      }
    ), Positioned(
      bottom: 6,
      child: MediaQuery.of(context).size.width > 600 ? Text("Copyright © 2024 IRT Saint Exupéry. All rights reserved.",
        style: TextStyle(color: Theme.of(context).splashColor, fontSize: 11)) : const Text("")), 
    AnimatedPositioned(
      duration: const Duration(milliseconds: 200), left: isMenu ? 80 : -10, bottom: 0,
      child: CircleAvatar(
        radius: 30, backgroundColor: Theme.of(context).secondaryHeaderColor,
        child: IconButton( iconSize: 30, color: Theme.of(context).splashColor,
          icon: Icon(isMenu ? Icons.close :  Icons.menu), 
      onPressed: () { setState(() {
        isMenu = !isMenu;
        rects.remove(viewID);
      });  },)
    ))],
    );
    
  }
}