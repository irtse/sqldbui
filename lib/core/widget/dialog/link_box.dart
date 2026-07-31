import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

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
  bool isDelete = false;
  bool success = false;
  LinkBoxWidget ({ super.key, required this.isDelete, required this.path, required this.sharing, this.color, });
  @override LinkBoxWidgetState createState() => LinkBoxWidgetState();
}
class LinkBoxWidgetState extends State<LinkBoxWidget> {
  bool forceShared = true;
  @override Widget build(BuildContext context) {
    return FutureBuilder(future: futureBuild(context), builder: (b,a) {
      if (a.hasData && a.data != null) {
        return a.data!;
      }
      return Container();
    });
  }
  Future<Widget> futureBuild(BuildContext context) async {
    List<Widget> d = [];
    if (widget.isDelete) {
      d.add(LinkDropWidget(isDelete: true, name: "all",
        url: widget.sharing?.sharedWithPath ?? "", sharing: widget.sharing ));
    } else {
      for (var m in (widget.sharing?.shallowPath?? {}).entries ) {
        List<Widget> additionnal = [];
        for (var add in widget.sharing!.additionnalBool) {
          var isValid = false;
          for (var act in currentView?.actions ?? []) {
            if (add.contains("all") || add.contains(act)) {
              isValid = true;
              break;
            }
          }
          if (!isValid) {
            continue;
          }
          additionnal.add(Padding( padding: EdgeInsets.only(top: 10), child: AdvancedSwitch(
                  initialValue: widget.sharing?.body[add] ?? false,
                  activeColor: Theme.of(context).primaryColor,  inactiveColor: Colors.grey,
                  // borderRadius:  const BorderRadius.all(Radius.circular(15)),
                  activeChild: FutureBuilder(future: getOnFlow(add.replaceAll("_", " ")), builder: (a,s) {
                    if (s.data != null) {
                      return Text(s.data!.toLowerCase());
                    }
                    return Text(add.toLowerCase());
                  }), 
                  inactiveChild: FutureBuilder(future: getOnFlow(add.split("_")[0]), builder: (a,s) {
                    if (s.data != null) {
                      return Text(s.data!.toLowerCase());
                    }
                    return Text(add.toLowerCase());
                  }), 
                  width: 150.0, height: 25.0, disabledOpacity: 0.5,
                  onChanged: (value) =>  widget.sharing?.body[add] = value)));
        }
        for (var add in widget.sharing!.additionnalDate) {
          additionnal.add(SizedBox( 
            width: 250,   
            height: 40, 
            child: Padding( padding: EdgeInsets.only(top: 15), child: DateTimeField(
            textAlign: TextAlign.start,
            validator: (DateTime? value) {
              if (value == null) { return ""; }
              return null;
            },
            format: intl.DateFormat('y-M-dd'),
            // mode: widget.type == "time" ? DateTimeFieldPickerMode.time : DateTimeFieldPickerMode.date,
            style: TextStyle(fontSize: 14, color: Theme.of(context).secondaryHeaderColor ),
            decoration: InputDecoration(
                alignLabelWithHint: false,
                label: FutureBuilder(future: getOnFlow(add.replaceAll("_", " ")), builder: (a,s) {
                    if (s.data != null) {
                      return Text(s.data!.toLowerCase());
                    }
                    return Text(add.toLowerCase());
                }),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(color: Theme.of(context).splashColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(color: Theme.of(context).splashColor),
                ),
                labelStyle: TextStyle(color: Colors.grey),
                hintText: (await getOnFlow(TranslateConstants.selectDate)).toLowerCase(),
                hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
                suffixIcon: const Icon(Icons.calendar_month, size: 18,),
                suffixIconColor: Theme.of(context).splashColor,
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).secondaryHeaderColor, width: 1.0)),
                helperStyle: const TextStyle(fontSize: 0),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                filled: true,
                prefixIcon: Icon(Icons.calendar_month, color: Colors.grey.shade200),
                errorStyle: const TextStyle(fontSize: 0),
                border: OutlineInputBorder( borderSide: BorderSide(color: Theme.of(context).splashColor, width: 0) ),
                fillColor:Colors.white,
                contentPadding: const EdgeInsets.only(top: 1, left: 20.0, right: 20.0, bottom: 20),
              ),
            onShowPicker: (context, currentValue) { return showDatePicker(
                  context: context,
                  firstDate: add.contains("end") && widget.sharing?.body[add.replaceAll("end", "start")] != null ? DateTime.parse(widget.sharing?.body[add.replaceAll("end", "start")]) : DateTime(1900),
                  initialDate: currentValue,
                  lastDate: add.contains("start") && widget.sharing?.body[add.replaceAll("start", "end")] != null ? DateTime.parse(widget.sharing?.body[add.replaceAll("start", "end")]) : DateTime(2100));
            },
            onChanged: (DateTime? value) { 
                widget.sharing?.body[add] = value?.toIso8601String(); 
            },
          ))));
        }
        d.add(LinkDropWidget(url:"${m.value}", name: m.key.toLowerCase(), sharing: widget.sharing ));
        d.add(Column(children: additionnal));
      }
    }
    final tradBase = await Future.wait([
      getOnFlow(widget.isDelete ? TranslateConstants.userShared : TranslateConstants.shareToUser),
      getOnFlow(widget.isDelete ? TranslateConstants.unshare : TranslateConstants.share),
    ]);
    var title = tradBase[0];
    var tooltip = tradBase[1];
    if (widget.sharing != null && widget.sharing!.shallowPath.isNotEmpty && !widget.sharing!.shallowPath.keys.first.contains("share")) {
      final tradDelegate = await Future.wait([
        getOnFlow(widget.isDelete ? TranslateConstants.undelegate : TranslateConstants.delegate),
        getOnFlow(widget.isDelete ? TranslateConstants.userDelegated : TranslateConstants.delegateToUser),
      ]);
      tooltip = tradDelegate[0];
      title = tradDelegate[1];
    }

    return PopupMenuButton(
      constraints: const BoxConstraints.tightFor(width: 364),
      color: Colors.white,
      tooltip: (tooltip).toLowerCase(),
      icon: Icon(
        size: 18, (widget.isDelete ? Icons.cancel : Icons.share), 
        color: widget.color ?? Theme.of(context).primaryColor),
      itemBuilder: (BuildContext bc) { 
        return [ 
          PopupMenuItem(enabled: false, 
            child: Padding( 
              padding: EdgeInsets.all(20), 
              child: Column(children: [                 
                Text((title).toLowerCase(), style: TextStyle(fontSize: 12.5, color: Colors.grey)),
                ...(widget.sharing != null ? d : []),                   
            ]))) ]; 
        }
      );
    }
}


class LinkDropWidget extends StatefulWidget {
  String url;
  String? name;
  bool isDelete = false;
  model.Sharing? sharing;
  Map<String,String> values = {};
  LinkDropWidget ({ super.key, this.isDelete = false,
  required this.name, required this.url, required this.sharing });
  @override LinkDropWidgetState createState() => LinkDropWidgetState();
}

class LinkDropWidgetState extends State<LinkDropWidget> {
  bool forceShared = true;
  @override Widget build(BuildContext context) {
    return FutureBuilder(future: futureBuild(context), builder: (b,a) {
      if (a.hasData && a.data != null) {
        return a.data!;
      }
      return Container();
    });
  }
  Future<Widget> futureBuild(BuildContext context) async {
    List<DropdownItem<String>> dpItems = [];
    MultiSelectController<String> ctrls = MultiSelectController<String>();
    final tradDrop = await Future.wait([
      getOnFlow(widget.isDelete ? TranslateConstants.userShared : TranslateConstants.filterPlaceholder),
      getOnFlow(TranslateConstants.search),
      getOnFlow(TranslateConstants.selectValue),
    ]);
    var shared = tradDrop[0];
    var search = tradDrop[1];
    var select = tradDrop[2];
    if (!context.mounted) return Container();
    return FutureBuilder(
        future: APIService().get<model.Shallowed>("${widget.url}&shallow=enable", true, context),
        builder: (a,s) {
          int max = 0;
          if (s.data?.data != null) {
            for (var data in s.data!.data!) {
              max = data.max;
              if (dpItems.where( (e) => e.value.toString() == data.id.toString()).isEmpty) {
                dpItems.add(DropdownItem<String>(
                  value: "${data.id}",
                  label: (data.label ?? data.name ?? "").toLowerCase(),
                ));
                ctrls.addItem(dpItems.last);
              }
            }
          }
          var gk = GlobalKey<OptionsListState>();
          return Row( children : [  
            SizedBox( 
            width: 250,   
            height: 25, 
            child: MultiDropdown<String>(
              gk: gk,
              max: max,
              changeFunction: (dynamic value) async {
                if (value == "") {
                  return;
                }
                var filters = Filters();
                filters.add("name", Filter(value: value, column: "name"));
                load("${widget.url}&shallow=enable", 0, 10, APIService().getFilter("${widget.sharing?.sharedWithPath ?? ""}&shallow=enable", true, filters), value, dpItems, ctrls, gk);
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
                  hintText: shared.toLowerCase(),
                    hintStyle: TextStyle(overflow: TextOverflow.ellipsis, fontSize: 12, color: Colors.grey),
                      prefixIcon: Icon(Icons.list, color: Colors.grey.shade200),
                      showClearIcon: false,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide(color: Theme.of(context).splashColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide(color: Theme.of(context).primaryColor),
                      ),
                    ),
                    searchDecoration: SearchFieldDecoration(
                      hintText: "       ${search.toLowerCase()}",
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
                        maxHeight: 600,
                        header: Padding(
                          padding: EdgeInsets.all(8),
                          child: Text("       ${select.toLowerCase()}",
                            textAlign: TextAlign.start,
                            style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      dropdownItemDecoration: DropdownItemDecoration(
                        backgroundColor: Theme.of(context).highlightColor,
                        selectedIcon: const Icon(Icons.check_box, color: Colors.green),
                        disabledIcon: Icon(Icons.lock, color: Colors.grey.shade300),
                      ),
                      validator: (value) {
                        return null;
                      },
                      onSelectionChange: (values) {
                        if (values.isEmpty) { return; }
                        widget.values[widget.name ?? ""] = values[0];
                      },
                    )
                  ), 
                  Padding( 
                    padding: const EdgeInsets.only(left: 10), 
                    child: IconButton(
                      enableFeedback: widget.values[widget.name] != null,
                      onPressed: () {
                        if (widget.values[widget.name] == null) {
                          return;
                        }
                        var key = widget.sharing!.shallowPath.isNotEmpty ? widget.sharing!.shallowPath.keys.first : "";
                        if (key == "") {
                          return;
                        }
                        widget.sharing!.body[key] = int.parse(widget.values[widget.name] ?? "");
                        (widget.isDelete ? APIService().delete<model.Shallowed>(
                          "${widget.sharing!.sharePath!}&$key=${widget.values[widget.name] ?? ""}", context
                        ) : APIService().post<model.Shallowed>(
                            widget.sharing!.sharePath!, 
                            widget.sharing!.body, context
                        )).then( (value) { 
                          setState(() { Navigator.pop(context); }); 
                          Future.delayed(Duration(seconds: 1), () {
                            globalMainViewKey.currentState?.setState(() {});
                          });
                          
                        });
                      }, icon: Icon(
                        widget.isDelete ? Icons.delete : Icons.share, 
                          size: 20, color: Colors.grey))
                    ), 
                  ]
                );
              }
            );
  }

  Future<void> load(String url, int start, int interval, String filter, String value, List<DropdownItem<String>> items, MultiSelectController<String> ctrls,  GlobalKey<OptionsListState> gk) async {
    if (filter == "") { return; }
    if (url.contains("&filter_line=")) {
      url.replaceAll("&filter_line=", "$filter+");
      filter = "";
    }
      var e = await APIService().get<model.Shallowed>("$url$filter&offset=$start&limit=$interval", filter != "", null);
        if (e.data != null) {
          for (var item in e.data!) {
            if (items.where( (e) => e.value == "${item.id}").isEmpty) {
              var v = (item.label ?? item.name ?? "${item.id}").replaceAll("db", "").replaceAll("_", " ");
              try {
                if (item.translatable) {
                  v = await getOnFlow(v);
                }
              } catch(e) { /* ignore */ }
              items.add(DropdownItem<String>(value: "${item.id}", label: v, selected: false));
              ctrls.addItem(items.last);
            }
          }
    } 
    gk.currentState?.setState(() {
      gk.currentState?.widget.items = ctrls.items;
    });
  }
}