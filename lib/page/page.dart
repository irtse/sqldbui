import 'package:flutter/material.dart';
import 'package:sqldbui2/core/sections/menu.dart';
import 'package:sqldbui2/model/response.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/core/services/api_service.dart';
import 'dart:developer' as developer;
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
    return FutureBuilder<APIResponse<model.View>>(
          future: _items(), // a previously-obtained Future<String> or null
          builder: (BuildContext context, AsyncSnapshot<APIResponse<model.View>> snapshot) {
          if (snapshot.hasData && snapshot.data!.data != null) { return MenuWidget(key: globalMenuKey, views: snapshot.data!.data); }
          return MenuWidget(key: globalMenuKey);
      }
    );
  }
}