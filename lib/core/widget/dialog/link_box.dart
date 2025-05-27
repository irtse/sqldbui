import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/core/services/api_service.dart';
import 'package:sqldbui2/page/translate.dart';
import 'package:sqldbui2/model/view.dart' as model;

// ignore: must_be_immutable
class LinkBoxWidget extends StatefulWidget {
  model.Sharing? sharing;
  String path;
  Color? color;
  bool success = false;
  String? value;
  Map<String,String> values = {};
  LinkBoxWidget ({ super.key, required this.path, required this.sharing, this.color, });
  @override LinkBoxWidgetState createState() => LinkBoxWidgetState();
}
bool forceUser = false;
class LinkBoxWidgetState extends State<LinkBoxWidget> {
  @override Widget build(BuildContext context) {
    List<Widget> d = [];
    List<Widget> drops = [];
    if (widget.sharing != null) {
      var len = 0;
      d.add(FutureBuilder(future: APIService().get<model.Shallowed>("${widget.sharing?.sharedWithPath ?? ""}&scope=enable", forceUser, context), builder: (a,s) {
          forceUser = false;
          List<DropdownMenuItem<String>> dpItems = [];
          if (s.data?.data != null) {
            for (var data in s.data!.data!) {
                dpItems.add(DropdownMenuItem<String>(
                value: "${data.id}",
                child: Text(data.label ?? data.name ?? "", overflow: TextOverflow.ellipsis),
              ));
            }
          }
          return Row( children : [  SizedBox( 
                      width: 166, 
                      height: 25, 
                      child: DropdownButtonFormField<String>( 
                        items: dpItems, 
                        hint: Text(TranslateConstants.filterPlaceholder.toLowerCase(), overflow: TextOverflow.ellipsis, 
                          style: TextStyle(color: Colors.grey)),
                        isExpanded: true, 
                        style: TextStyle(fontSize: 12, color: Colors.black),
                        onChanged: (value) {
                          if (value == null) { return; }
                            setState(() {
                                widget.value = value;
                            });
                          }, dropdownColor: Colors.white,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(top: 0, left: 10.0, right: 10.0, bottom: 0),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey, width: 1.0)),
                          border: const OutlineInputBorder(),
                          filled: true, 
                          fillColor: Theme.of(context).splashColor),
                      )), len == widget.sharing!.shallowPath.length ? Padding( 
                    padding: const EdgeInsets.only(left: 10), 
                    child: IconButton(
                      enableFeedback: widget.value != null,
                      onPressed: () {
                        if (widget.value == null) {
                          return;
                        }
                        APIService().delete<model.Shallowed>(
                          widget.sharing!.sharePath!, context
                        ).then( (value) { 
                          forceUser = true;
                          setState(() { Navigator.pop(context); }); 
                        });
                    }, icon: Icon(Icons.delete, size: 20, color: widget.value != null ? Colors.grey.shade200 :Colors.grey))
                  ) : Container(), 
                ]);
        }));
      for (var m in widget.sharing!.shallowPath.entries) {
        len++;
        
        drops.add(FutureBuilder(future: APIService().get<model.Shallowed>("${m.value}&scope=enable", forceUser, context), builder: (a,s) {
          forceUser = false;
          List<DropdownMenuItem<String>> dpItems = [];
          if (s.data?.data != null) {
            for (var data in s.data!.data!) {
                dpItems.add(DropdownMenuItem<String>(
                value: "${m.key}~${data.id}",
                child: Text(data.label ?? data.name ?? "", overflow: TextOverflow.ellipsis),
              ));
            }
          }
          return Row( children : [  SizedBox( 
                      width: 166, 
                      height: 25, 
                      child: DropdownButtonFormField<String>( 
                        items: dpItems, 
                        hint: Text(TranslateConstants.filterPlaceholder.toLowerCase(), overflow: TextOverflow.ellipsis, 
                          style: TextStyle(color: Colors.grey)),
                        isExpanded: true, 
                        style: TextStyle(fontSize: 12, color: Colors.black),
                        onChanged: (value) {
                          if (value == null) { return; }
                            setState(() {
                                widget.values[m.key] = value;
                            });
                          }, dropdownColor: Colors.white,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(top: 0, left: 10.0, right: 10.0, bottom: 0),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey, width: 1.0)),
                          border: const OutlineInputBorder(),
                          filled: true, 
                          fillColor: Theme.of(context).splashColor),
                      )), len == widget.sharing!.shallowPath.length ? Padding( 
                    padding: const EdgeInsets.only(left: 10), 
                    child: IconButton(
                      enableFeedback: widget.values[m.key] != null,
                      onPressed: () {
                        if (widget.values[m.key] == null) {
                          return;
                        }
                        for (var k in widget.values.values) {
                          var last = k.split("~");
                          if (last.length == 2) {
                            widget.sharing!.body[last[0]] = int.parse(last[1]);
                          }
                        }
                        APIService().post<model.Shallowed>(
                          widget.sharing!.sharePath!, 
                          widget.sharing!.body, context
                        ).then( (value) { 
                          forceUser = true;
                          setState(() { Navigator.pop(context); }); 
                        });
                    }, icon: Icon(Icons.share, size: 20, color: widget.values[m.key] != null ? Colors.grey.shade200 :Colors.grey))
                  ) : Container(), 
                ]);
        }));
        
      }
    }
    return PopupMenuButton(
      color: Colors.white,
      tooltip: TranslateConstants.share.toLowerCase(),
      icon: Icon(size: 18, Icons.share, color: widget.color ?? Theme.of(context).primaryColor),
      itemBuilder: (BuildContext bc) { 
        return [ 
          PopupMenuItem(enabled: false, 
            child: Padding( 
              padding: EdgeInsets.all(20), 
              child: Column(children: [ 
                Text(TranslateConstants.pathToCopy.toLowerCase(), style: TextStyle(fontSize: 12.5, color: Colors.grey)),
                Row( children : [ 
                  SizedBox( 
                    width: 166, 
                    height: 20, 
                    child: TextFormField(
                      enabled: false, 
                      initialValue: widget.path,
                      style: TextStyle( fontSize: 12),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(top: 0, left: 10.0, right: 10.0, bottom: 0),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).splashColor, width: 1.0)),
                        border: const OutlineInputBorder(),
                        filled: true, 
                        fillColor: Theme.of(context).splashColor
                      )
                    )
                  ),
                  Padding( padding: const EdgeInsets.only(left: 10), child: IconButton(onPressed: () {
                      setState(() {
                        widget.success = true;
                        Future.delayed(const Duration(seconds: 5), () { widget.success = false; });
                      });
                      Clipboard.setData(ClipboardData(text: widget.path));
                    }, icon: const Icon(Icons.copy, size: 20, color: Colors.grey))
                  ),
                ]),
                Text(TranslateConstants.userShared.toLowerCase(), style: TextStyle(fontSize: 12.5, color: Colors.grey)),
                ...(widget.sharing != null ? d : []),
                Text(TranslateConstants.shareToUser.toLowerCase(), style: TextStyle(fontSize: 12.5, color: Colors.grey)),
                ...(widget.sharing != null ? drops : []),
                Column(children: [
                currentView?.actions.contains("put") ?? false ?  Padding( padding: EdgeInsets.only(top: 10), child: AdvancedSwitch(
                  initialValue: widget.sharing?.body["update_access"] ?? false,
                  activeColor: Theme.of(context).primaryColor,  inactiveColor: Colors.grey,
                  borderRadius:  const BorderRadius.all(Radius.circular(15)),
                  activeChild: Text("update"), inactiveChild: Text("update"), 
                  width: 130.0, height: 25.0, disabledOpacity: 0.5,
                  onChanged: (value) =>  widget.sharing?.body["update_access"] = value)): Container(),
                currentView?.actions.contains("delete") ?? false ? Padding( padding: EdgeInsets.only(top: 10), child: AdvancedSwitch(
                  initialValue: widget.sharing?.body["delete_access"] ?? false,
                  activeColor: Theme.of(context).primaryColor,  inactiveColor: Colors.grey,
                  borderRadius:  const BorderRadius.all(Radius.circular(15)),
                  activeChild: Text("delete"), inactiveChild: Text("delete"), 
                  width: 130.0, height: 25.0, disabledOpacity: 0.5,
                  onChanged: (value) =>  widget.sharing?.body["delete_access"] = value)) : Container()
                ],)
            ]))) ]; 
        });
  }
}