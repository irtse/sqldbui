import 'dart:async';
import 'package:sqldbui2/main.dart';
import 'package:flutter/material.dart';
import 'package:sqldbui2/model/filter.dart';
import 'package:sqldbui2/page/translate.dart';
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/core/sections/menu/menu.dart';
import 'package:sqldbui2/core/widget/datagrid/grid.dart';
import 'package:sqldbui2/core/services/api_service.dart';
import 'package:sqldbui2/core/widget/datagrid/main_grid.dart';
import 'package:sqldbui2/core/widget/dialog/mapping_popup.dart';
import 'package:sqldbui2/core/widget/dialog/filter_cols_popup.dart';
import 'package:sqldbui2/core/widget/datagrid/filter/filterRow.dart';
import 'package:sqldbui2/core/widget/datagrid/buttons/popup_button.dart';
import 'package:sqldbui2/core/widget/datagrid/filter/filterSelector.dart';
import 'package:sqldbui2/core/widget/datagrid/buttons/datagrid_button.dart';
import 'package:sqldbui2/core/widget/datagrid/functions/function_math_row.dart';
import 'package:sqldbui2/core/widget/datagrid/functions/functions_selector.dart';
import 'package:sqldbui2/core/widget/utils/fork/multi_dropdown/multi_dropdown.dart';

Map<String, List<DropdownMenuItem<String>>> schemeItems = {};
Map<String, Map<String,String>> fastTranslation = {};

bool isFilter() {
  return currentView != null && globalOrder.containsKey(viewID) && globalFilter.containsKey(viewID)
  && (globalOrder[viewID]!.isNotEmpty || (globalFilter[viewID] != null && globalFilter[viewID]!.size() > 0));
}
class Value {
  Map<String, model.SchemaField> schema = {};
  String cellID;
  String? dataRef;
  bool isNew = false;
  bool isDraft = false;
  bool isLink = false;
  bool readOnly = false;
  String schemaID;
  model.Sharing? sharing;
  
  Map<String, dynamic> valuesMany = {};
  Map<String, dynamic> values = {};
  Value({ 
    required this.dataRef,
    required this.cellID, 
    required this.isDraft, 
    required this.schemaID,
    this.valuesMany = const {},
    this.values = const {}, 
    this.isLink = true, 
    this.readOnly = false, 
    this.sharing, 
    this.isNew = false,
    required this.schema,
  });
}
bool tempRemoval = false;
bool noFilterRetrieval = false;
int globalLimit = 5;
int globalOffset = 0;
List<String> unselectedGrid = [];
List<String> selectedGrid = []; 
bool allSelected = true;
Map<String?, int> filterIDName = <String, int>{};
Map<String?, String> filterRestr = <String, String>{};
GlobalKey<GridWidgetState> globalGridKey = GlobalKey<GridWidgetState>();
GlobalKey<DatagridWidgetState> globalGridWidgetKey = GlobalKey<DatagridWidgetState>();
// ignore: must_be_immutable
List<FunctionMathRowWidget> functionMathRowsWidget = [];
List<FilterRowWidget> filterRowsWidget = [];
// ignore: must_be_immutable
class DatagridWidget extends StatefulWidget {
  final model.View? view; 
  bool isSelected = true;
  Map<String, dynamic> lines = {};
  GlobalKey<ViewWidgetState>? viewKey;
  Map<String, Map<String, dynamic>> cache = <String, Map<String, dynamic>>{};

  DatagridWidget ({ super.key, this.view, this.viewKey });
  @override
  DatagridWidgetState createState() => DatagridWidgetState();
}
bool showMore = true;
class DatagridWidgetState extends State<DatagridWidget> {
  List<DropdownMenuItem<String>> dpItems = <DropdownMenuItem<String>>[];

  @override Widget build(BuildContext context) {
    return FutureBuilder(future: futureBuild(context), builder: (b,a) {
      if (a.hasData && a.data != null) {
        return a.data!;
      }
      return Container();
    });
  }
  Future<Widget> futureBuild(BuildContext context) async {
    searchCtrl = {};

    await fillSchemeItem();
    Map<String, model.SchemaField> schema = <String, model.SchemaField>{};
    List<Value> datas = <Value>[];
    Map<String, String> links = <String, String>{};
    dpItems = [];
    if (widget.view != null) {
      schema = widget.view!.schema;
    }
    if ( globalOrder[viewID] == null || globalOrder[viewID]!.isEmpty ) {
      datas.sort( (a, b) =>  (b.values["id"] != null ? int.parse( b.values["id"]) : 0) -  (a.values["id"] != null ? int.parse(a.values["id"]) : 0) );
    }
    
    var index = 0;    
    if (modeIndex != 1) {
      if (filterRestr[viewID] != null && !tempRemoval) {
        if ((globalFilter[viewID]?.filters ?? {}).isNotEmpty) {
          filterRowsWidget = globalFilter[viewID]?.toRow(schema) ?? [];
        } else {
          var resp = await APIService().get<model.Shallowed>("${currentView!.filterPath.replaceAll("rows=all", "rows=${filterRestr[viewID]}")}&is_view=false", true, null);
          if ((resp.data ?? []).isNotEmpty) {
            var i = resp.data![0];
            if ((i.selected && !noFilterRetrieval) || (filterRowsWidget.isEmpty && i.fields.isNotEmpty)) { 
                Future.delayed(const Duration(milliseconds: 500), () {
                  globalNew[viewID] = i.elder;
                  refreshFilter(i.fields);
                }); 
              }
          } else {
            filterRestr[viewID] = "";
          }
        }
        
      } else if (tempRemoval) { tempRemoval = false; }
      for (var i in filterRowsWidget) { 
        if (filterRowsWidget.length - 1 > index && i.connector == "") { 
          filterRowsWidget[index] = FilterRowWidget(
            schema: schema, 
            index: i.index, 
            connector: "and", 
            label: i.label, 
            type: i.type, 
            columnName: i.columnName, 
            value: i.value, 
            comparator: i.comparator, 
            dir: i.dir);
        }
        index++;
      }
    }
    var subSize = showMore ? (filterRowsWidget.length * 45 < 138 ? filterRowsWidget.length * 45 : 138) : (!(editMode[viewID] == "math") ? 0 : 138);
    if (currentWidth <= 1000) { subSize = 0; }
    return Column( children: [ 
      Container( 
        color: Theme.of(context).primaryColorLight, 
        constraints: const BoxConstraints(minHeight: 40), 
        width: currentWidth - menuSize > 0 ? currentWidth - menuSize : 0,
        child: Column( children: [
          Stack( children: [ 
            currentWidth > 1000 ? 
              Positioned( 
                top: 3.5, left: 32, 
                child: FilterSelectorWidget(schema: schema, filterMain: globalFilter[viewID], schemaName: widget.view?.schemaName ?? "")
              ) : Container(),
            Row( mainAxisAlignment: MainAxisAlignment.end, children : [ 
              Padding(padding: const EdgeInsets.symmetric(horizontal: 30), 
                child: FutureBuilder<List<Widget>>(future: getButtons(), builder: (a,s) {
                  if (s.data != null) {
                    return Row(children: [ 
                      ...s.data!, 
                      FilterColsPopUpWidget(key: filterColsPopUpKey, schema: schema) 
                    ]);
                  }
                 return Row(children: [ 
                    FilterColsPopUpWidget(key: filterColsPopUpKey, schema: schema) 
                 ]); 
              })) 
            ]) 
          ]), 
          currentWidth <= 1000 ? Container() 
            : Container( 
              constraints: BoxConstraints( 
                maxHeight:  (currentHeigth > (120 + subSize) ? subSize : currentHeigth - 120).toDouble()), 
              child: SingleChildScrollView( 
                child: Column( 
                  children : [  
                    modeIndex != 1 ? (filterRowsWidget.isEmpty ?  Container() 
                    : Divider(height: 1, color: Theme.of(context).secondaryHeaderColor)) : ( 
                  editMode[viewID] != "math" || functionMathRowsWidget.isEmpty ? 
                  Container() : Divider(height: 1, color: Theme.of(context).secondaryHeaderColor)
                ),  
              ...(showMore ? filterRowsWidget :  []) ,
              ...(editMode[viewID] == "math" ? functionMathRowsWidget : [])
            ] 
            ))),
          MainGridWidget(
            links: links, 
            view: widget.view, 
            viewKey: widget.viewKey, 
            subSize: subSize,
            subWidthSize: menuSize,
            schema: schema,
            isSelected: widget.isSelected) 
        ])
      ),
    ]);
  }
  Future<void> fillSchemeItem() async {
    var order = realOrder(widget.view, false, false, null, 5);
    if (!schemeItems.containsKey(viewID)) {
      schemeItems[viewID ?? ""] = [];
      fastTranslation[viewID ?? ""] = {};
      for (var o in ["id", ...order]) {
        var scheme = widget.view?.schema[o];
    
        var t = scheme?.label ?? o;
        if (scheme?.translatable ?? false) {
          t = (await getOnFlow(t)).toLowerCase();
        }
        fastTranslation[viewID ?? ""]?[scheme?.label ?? o] = t;
        if (schemeItems[viewID ?? ""]!.where( (e) => e.value == o ).isEmpty) {
          schemeItems[viewID ?? ""]?.add(DropdownMenuItem<String>(value: o, child: Text(t, overflow: TextOverflow.ellipsis)));
        }
      }
    }
  }

  Future<List<Widget>> getButtons() async {
    var buttons = <Widget>[];
    
    if (currentView != null && currentView!.isList && currentView!.actions.contains("import")) {
      buttons.add(
        PopupButtonWidget(
          tooltip: TranslateConstants.rowsImport,
          icon: Icons.upload,
          widget: MappingPopUpWidget(isExport: true, format: "csv")
        )
      );
    }
    return buttons;
  }

}
