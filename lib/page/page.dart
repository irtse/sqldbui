import 'dart:developer' as developer;
import 'package:sqldbui2/main.dart';
import 'package:flutter/material.dart';
import 'package:sqldbui2/model/response.dart';
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/core/sections/menu.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/core/sections/homeview.dart';
import 'package:sqldbui2/core/widget/utils/grid.dart';
import 'package:sqldbui2/core/services/api_service.dart';
import 'package:flutter_box_transform/flutter_box_transform.dart';
import 'package:sqldbui2/core/widget/fork/tranformablebox.dart' as fork;

/// Flutter code sample for [FutureBuilder].
GlobalKey<PageWidgetState> globalPageKey = GlobalKey<PageWidgetState>();
class PageWidget extends StatefulWidget {
  const PageWidget({super.key});

  @override
  State<PageWidget> createState() => PageWidgetState();
}
class PageWidgetState extends State<PageWidget> {
  @override Widget build(BuildContext context) {
    menuSize = isMenu ? (250 <= MediaQuery.of(context).size.width ? (menuSize == 0 ? 250 : (menuSize <= (MediaQuery.of(context).size.width / 2) ? menuSize : (MediaQuery.of(context).size.width / 2))) : MediaQuery.of(context).size.width) : 0;
    return Stack( alignment: Alignment.topCenter,
      children: [
        FutureBuilder<APIResponse<model.View>>(
          future: APIService().get<model.View>(APIConstants.mainEndpost, false, null), // a previously-obtained Future<String> or null
          builder: (BuildContext context, AsyncSnapshot<APIResponse<model.View>> snapshot) {
          var c = <Widget>[];
          if (snapshot.hasData && snapshot.data!.data != null) { 
            List<model.View> views = snapshot.data!.data!;
            Rect rect = Rect.fromCenter( center: MediaQuery.of(context).size.center(Offset.zero),
              width: menuSize, height: MediaQuery.of(context).size.height - 40 > 0 ? MediaQuery.of(context).size.height - 40 : 0);
            List<Widget> c = !isMenu ? [] : <Widget>[fork.TransformableBox(
              rect: rect, constraints: BoxConstraints(
                maxWidth: 250 <= (MediaQuery.of(context).size.width / 2) ? (MediaQuery.of(context).size.width / 2) : MediaQuery.of(context).size.width,
                minWidth: 250 <= MediaQuery.of(context).size.width ? 250 : MediaQuery.of(context).size.width),
              handleTapSize: 1, handleTapLeftSize: 0, allowFlippingWhileResizing: false, draggable: false, flip: null,
              resizeModeResolver: () => ResizeMode.freeform,
              visibleHandles: const {HandlePosition.right},
              enabledHandles: const {HandlePosition.right},
              clampingRect: Offset.zero & MediaQuery.sizeOf(context),
              handleAlignment: HandleAlignment.inside,
              onChanged: (result, event) { setState(() { menuSize = result.rect.width; }); },
              contentBuilder: (context, rect, flip) { return Container(
                color: Theme.of(context).secondaryHeaderColor, width: menuSize, child: MenuWidget(key: globalMenuKey, views: views)); } )];
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
        rects.remove(viewID);
        globalHomeViewKey.currentState?.setState(() {});
        setState(() { isMenu = !isMenu;  });
      })
    ))],
    );
    
  }
}