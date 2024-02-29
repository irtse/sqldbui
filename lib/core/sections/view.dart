import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:sqldbui2/core/widget/actionbar.dart';
import 'package:sqldbui2/core/widget/convertors/manytomany.dart';
import 'package:sqldbui2/core/widget/convertors/onetomany.dart';
import 'package:sqldbui2/core/widget/datagrid.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/core/widget/form.dart';
import 'package:flutter/material.dart';
import 'package:sqldbui2/main.dart';

model.View? beforeView;
model.View? currentView;
GlobalKey<ViewWidgetState> globalViewKey = GlobalKey<ViewWidgetState>();
class ViewWidget extends StatefulWidget{
  const ViewWidget ({ Key? key}): super(key: key);
  @override ViewWidgetState createState() => ViewWidgetState();
}
class ViewWidgetState extends State<ViewWidget> {
  @override Widget build(BuildContext context) {
    if (currentView != null) {
      if (currentView!.isList == true && homeKey.currentState!.widget.subViewID == null) { 
        DatagridWidget w = DatagridWidget(key: globalGridWidgetKey, view: currentView, viewKey: globalViewKey,);
        return Column( children: [ ActionBarWidget(view: currentView, grid: w, gridKey: globalGridKey, viewKey: globalViewKey), w]);
      } else { 
        cacheForm = <String, List<Map<String, dynamic>>>{};
        DataFormWidget w =  DataFormWidget(key: mainForm, view: currentView);
        return Column( children: [ ActionBarWidget(view: currentView, viewKey: globalViewKey, form: w ), w ] ); }
    }
    return Column( children: [ ActionBarWidget(view: currentView, ) ], );
  }
}