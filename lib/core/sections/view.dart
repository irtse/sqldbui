import 'package:sqldbui2/core/sections/menu.dart';
import 'package:sqldbui2/core/widget/actionbar.dart';
import 'package:sqldbui2/core/widget/datagrid.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/core/widget/form.dart';
import 'package:flutter/material.dart';
import 'package:sqldbui2/main.dart';

model.View? beforeView;
model.View? currentView;
GlobalKey<ViewWidgetState> globalViewKey = GlobalKey<ViewWidgetState>();
// ignore: must_be_immutable
class ViewWidget extends StatefulWidget{
  MenuWidgetState menu;
  ViewWidget ({ Key? key, required this.menu}): super(key: key);
  @override ViewWidgetState createState() => ViewWidgetState();
}
class ViewWidgetState extends State<ViewWidget> {
  @override Widget build(BuildContext context) {
    if (currentView != null) {
      if (currentView!.isList == true && homeKey.currentState!.widget.subViewID == null) { 
        DatagridWidget w = DatagridWidget(key: globalGridWidgetKey, view: currentView, viewKey: globalViewKey,);
        return Column( children: [ ActionBarWidget(key: globalActionBar, menu: widget.menu, view: currentView, grid: w, gridKey: globalGridKey, viewKey: globalViewKey), w]);
      } else { 
        DataFormWidget w =  DataFormWidget(key: mainForm, view: currentView);
        return Column( children: [ ActionBarWidget(key: globalActionBar, menu: widget.menu, view: currentView, viewKey: globalViewKey, form: w ), w ] ); }
    }
    return Column( children: [ ActionBarWidget(key: globalActionBar, menu: widget.menu, view: currentView, ) ], );
  }
}