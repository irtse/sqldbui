import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/core/services/api_service.dart';
import 'package:sqldbui2/core/widget/utils/fork/multi_dropdown/multi_dropdown.dart';
import 'package:sqldbui2/model/filter.dart';
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
bool forceSharedUser = true;
bool forceUser = true;
class LinkBoxWidgetState extends State<LinkBoxWidget> {
  @override Widget build(BuildContext context) {
    List<Widget> d = [];
    List<Widget> drops = [];
    if (widget.sharing != null) {
      var len = 0;
      MultiSelectController<String> ctrls = MultiSelectController<String>();
      MultiSelectController<String> ctrlsDP = MultiSelectController<String>();
      d.add(FutureBuilder(future: APIService().get<model.Shallowed>("${widget.sharing?.sharedWithPath ?? ""}&shallow=enable", forceSharedUser, context), builder: (a,s) {
          forceSharedUser = false;
          List<DropdownItem<String>> dpItems = [];
          int max = 0;
          if (s.data?.data != null) {
            for (var data in s.data!.data!) {
                max = data.max;
                dpItems.add(DropdownItem<String>(
                value: "${data.id}",
                label: data.label ?? data.name ?? "",
              ));
            }
          }
          return Row( children : [  SizedBox( 
                      width: 250,   
                      height: 25, 
                      child: MultiDropdown<String>(
                        formFieldKey: GlobalKey(),
        max: max,
        changeFunction: (dynamic value) async {
          if (value == "") {
            return;
          }
          var filters = Filters();
          filters.add("name", Filter(value: value, column: "name"));
          load("${widget.sharing?.sharedWithPath ?? ""}&shallow=enable", 0, 10, APIService().getFilter("${widget.sharing?.sharedWithPath ?? ""}&shallow=enable", true, filters), value, dpItems, ctrls);
        },
        enabled: true,
                        controller: ctrls,
                        singleSelect: true,
                        items: dpItems,
                        searchEnabled: true,
                        chipDecoration: ChipDecoration(
                          backgroundColor: Theme.of(context).primaryColor,
                          labelStyle: TextStyle(color: Colors.white),
                          wrap: true,
                          runSpacing: 2,
                          spacing: 10,
                        ),
                        fieldDecoration: FieldDecoration(
                          errorBorder: OutlineInputBorder(borderSide: BorderSide(color:Colors.red, width: 1.0)),
                          disabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).splashColor, width: 1.0)),
                          backgroundColor:Theme.of(context).splashColor,
                          hintText: TranslateConstants.userShared.toLowerCase(),
                          hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
                          prefixIcon: Icon(Icons.list, color: Colors.grey.shade200),
                          showClearIcon: false,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide(color: Theme.of(context).splashColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        searchDecoration: SearchFieldDecoration(
                          hintText: "       ${TranslateConstants.search.toLowerCase()}",
                          border : const OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFE0E0E0)),
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                          focusedBorder : const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                            borderRadius: BorderRadius.all(Radius.circular(5)))
                        ),
                        dropdownDecoration: DropdownDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          marginTop: 2,
                          maxHeight: 400,
                          header: Padding(
                            padding: EdgeInsets.all(8),
                            child: Text(
                              "       ${TranslateConstants.selectValue.toLowerCase()}",
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        dropdownItemDecoration: DropdownItemDecoration(
                          backgroundColor: Theme.of(context).highlightColor,
                          selectedIcon:
                              const Icon(Icons.check_box, color: Colors.green),
                          disabledIcon:
                              Icon(Icons.lock, color: Colors.grey.shade300),
                        ),
                        validator: (value) {
                          return null;
                        },
                        onSelectionChange: (values) {
                          if (values.isEmpty) { return; }
                            setState(() {
                                widget.value = values[0];
                            });
                        },
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
                          forceSharedUser = true;
                          setState(() { Navigator.pop(context); }); 
                        });
                    }, icon: Icon(Icons.delete, size: 20, color:  widget.value != null ? Colors.grey.shade200 :Colors.grey))
                  ) : Container(), 
                ]);
        }));
      for (var m in widget.sharing!.shallowPath.entries) {
        len++;
        
        drops.add(FutureBuilder(future: APIService().get<model.Shallowed>("${m.value}", forceUser, context), builder: (a,s) {
          
          forceUser = false;
          List<DropdownItem<String>> dpItems = [];
          int max = 0;
          if (s.data?.data != null) {
            for (var data in s.data!.data!) {
              max = data.max;
              dpItems.add(DropdownItem<String>(
                value: "${m.key}~${data.id}",
                label: data.label ?? data.name ?? "",
              ));
            }
          }
          return Row( children : [  SizedBox( 
                      width: 250,   
                      height: 25, 
                      child: MultiDropdown<String>(
                        formFieldKey: GlobalKey(),
                      max: max,
                      changeFunction: (dynamic value) async {
                        if (value == "") {
                          return;
                        }
                        var filters = Filters();
                        filters.add("name", Filter(value: value, column: "name"));
                        load("${m.value}", 0, 10, APIService().getFilter("${m.value}", true, filters), value, dpItems, ctrlsDP);
                      },
                      enabled: true,
                        controller: ctrlsDP,
                        singleSelect: true,
                        items: dpItems,
                        searchEnabled: true,
                        chipDecoration: ChipDecoration(
                          backgroundColor: Theme.of(context).primaryColor,
                          labelStyle: TextStyle(color: Colors.white),
                          wrap: true,
                          runSpacing: 2,
                          spacing: 10,
                        ),
                        fieldDecoration: FieldDecoration(
                          errorBorder: OutlineInputBorder(borderSide: BorderSide(color:Colors.red, width: 1.0)),
                          disabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).splashColor, width: 1.0)),
                          backgroundColor:Theme.of(context).splashColor,
                          hintText: TranslateConstants.filterPlaceholder.toLowerCase(),
                          hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
                          prefixIcon: Icon(Icons.list, color: Colors.grey.shade200),
                          showClearIcon: false,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide(color: Theme.of(context).splashColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        searchDecoration: SearchFieldDecoration(
                          hintText: "       ${TranslateConstants.search.toLowerCase()}",
                          border : const OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFE0E0E0)),
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                          focusedBorder : const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                            borderRadius: BorderRadius.all(Radius.circular(5)))
                        ),
                        dropdownDecoration: DropdownDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          marginTop: 2,
                          maxHeight: 400,
                          header: Padding(
                            padding: EdgeInsets.all(8),
                            child: Text(
                              "       ${TranslateConstants.selectValue.toLowerCase()}",
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        dropdownItemDecoration: DropdownItemDecoration(
                          backgroundColor: Theme.of(context).highlightColor,
                          selectedIcon:
                              const Icon(Icons.check_box, color: Colors.green),
                          disabledIcon:
                              Icon(Icons.lock, color: Colors.grey.shade300),
                        ),
                        validator: (value) {
                          return null;
                        },
                        onSelectionChange: (values) {
                          if (values.isEmpty) { return; }
                            setState(() {
                                widget.values[m.key] = values[0];
                            });
                        },
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
      constraints: const BoxConstraints.tightFor(width: 364),
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
                    width: 250,   
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

  Future<void> load(String url, int start, int interval, String filter, String value, List<DropdownItem<String>> items, MultiSelectController<String> ctrls) async {
    if (filter == "") { return; }
    var found = false;
      var e = await APIService().get<model.Shallowed>("$url$filter&offset=$start&limit=$interval", filter != "", null);
        if (e.data != null) {
          for (var item in e.data!) {
            if (items.where( (e) => e.value == "${item.id}").isEmpty) {
              found = true;
              var v = (item.label ?? item.name ?? "${item.id}").replaceAll("db", "").replaceAll("_", " ");
              try {
                if (item.translatable) {
                  v = await getOnFlow(v);
                }
              } catch(e) {}
              items.add(DropdownItem<String>(value: "${item.id}", label: v, selected: false));
              ctrls.addItem(items.last);
            }
          }
    } 
    if (ctrls.isOpen && found) {
      ctrls.closeDropdown();
      ctrls.openDropdown(value, "");
    }
  }
}