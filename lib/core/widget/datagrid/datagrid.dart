import 'dart:async';
import 'package:sqldbui2/core/services/api_service.dart';
import 'package:sqldbui2/core/widget/datagrid/buttons/popup_button.dart';
import 'package:sqldbui2/core/widget/datagrid/buttons/save_button.dart';
import 'package:sqldbui2/core/widget/datagrid/main_grid.dart';
import 'package:sqldbui2/core/widget/datagrid/widget/row.dart';
import 'package:sqldbui2/core/widget/dialog/mapping_popup.dart';
import 'package:sqldbui2/core/widget/form/convertors/dropdown.dart';
import 'package:sqldbui2/core/widget/utils/fork/multi_dropdown/multi_dropdown.dart';
import 'package:sqldbui2/main.dart';
import 'package:flutter/material.dart';
import 'package:sqldbui2/model/filter.dart';
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/core/sections/menu/menu.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/core/widget/datagrid/grid.dart';
import 'package:sqldbui2/core/widget/dialog/filter_cols_popup.dart';
import 'package:sqldbui2/core/widget/datagrid/filter/filterRow.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:sqldbui2/core/widget/datagrid/filter/filterSelector.dart';
import 'package:sqldbui2/core/widget/datagrid/functions/function_math_row.dart';
import 'package:sqldbui2/core/widget/datagrid/functions/functions_selector.dart';
import 'package:sqldbui2/page/translate.dart';

Map<String, List<DropdownMenuItem<String>>> schemeItems = {};
Map<String, Map<String,String>> fastTranslation = {};

bool isFilter() {
  return currentView != null && globalOrder.containsKey(viewID) && globalFilter.containsKey(viewID)
  && (globalOrder[viewID]!.isNotEmpty || (globalFilter[viewID] != null && globalFilter[viewID]!.size() > 0));
}
class Value {
  Map<String, model.SchemaField> schema = {};
  String cellID;
  bool isDraft = false;
  bool isLink = false;
  bool readOnly = false;
  model.Sharing? sharing;
  
  Map<String, dynamic> values = {};
  Value({ 
    required this.cellID, required this.isDraft,
    this.values = const {}, this.isLink = true, 
    this.readOnly = false, this.sharing, 
    required this.schema,
  });
}
bool tempRemoval = false;
bool noFilterRetrieval = false;
int globalLimit = 10;
int globalOffset = 0;
List<GridRowWidget> unselectedGrid = [];
List<GridRowWidget> selectedGrid = []; 
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
bool show = true;
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
    newDropDownValue = {};
    searchCtrl.text = "";

    await fillSchemeItem();
    Map<String, model.SchemaField> schema = <String, model.SchemaField>{};
    List<Value> datas = <Value>[];
    Map<String, String> links = <String, String>{};
    dpItems = [];
    if (widget.view != null) {
      schema = widget.view!.schema;
      if (!filterTempOrderView.containsKey(viewID)) {
        filterTempOrderView[viewID] = [];
      }
    }
    if ( globalOrder[viewID] == null || globalOrder[viewID]!.isEmpty ) {
      datas.sort( (a, b) =>  (b.values["id"] != null ? int.parse( b.values["id"]) : 0) -  (a.values["id"] != null ? int.parse(a.values["id"]) : 0) );
    }
    
    var index = 0;
    Filters? filterMain = globalFilter[viewID];
    
    if (!(isEditMode[viewID] ?? false)) {
      if (filterRestr[viewID] != null && !tempRemoval) {
        filterRowsWidget = filterMain?.toRow(schema) ?? [];
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
    var subSize = show ? (filterRowsWidget.length * 45 < 138 ? filterRowsWidget.length * 45 : 138) : (!(isEditMode[viewID] ?? false) ? 0 : 138);
    if (currentWidth <= 1000) { subSize = 0; }
    return Column( children: [ 
      Container( 
        color: Theme.of(context).primaryColorLight, 
        constraints: const BoxConstraints(minHeight: 40), 
        width: currentWidth - menuSize > 0 ? currentWidth - menuSize : 0,
        child: Column( children: [
          Stack( children: [ 
            currentWidth > 1000 ? 
            Positioned( top: 3.5, left: 32, child: (isEditMode[viewID] ?? false) ? 
                FunctionsSelectorWidget(mathAllowed: realOrder(widget.view, false).length > 2)
              : FilterSelectorWidget(schema: schema, filterMain: filterMain, schemaName: widget.view?.schemaName ?? "")) 
            : Container(),
            Row( mainAxisAlignment: MainAxisAlignment.end, children : [ 
              Padding(padding: const EdgeInsets.symmetric(horizontal: 30), 
                child: Row(children: [ 
                  ...getButtons(), 
                  FilterColsPopUpWidget(key: filterColsPopUpKey, schema: schema) 
                ])) 
            ]) 
          ]), 
          currentWidth <= 1000 ? Container() 
            : Container( 
              constraints: BoxConstraints( maxHeight:  (currentHeigth > (120 + subSize) ? subSize 
                : currentHeigth - 120).toDouble()), 
              child: SingleChildScrollView( 
                child: Column( 
                  children : [  !(isEditMode[viewID] ?? false) ? (filterRowsWidget.isEmpty ? 
                Container() : Divider(height: 1, color: Theme.of(context).secondaryHeaderColor)) : ( 
                  editMode[viewID] != TranslateConstants.math.toLowerCase() || functionMathRowsWidget.isEmpty ? Container() : Divider(height: 1, color: Theme.of(context).secondaryHeaderColor)
                ),  
              ...(show && !(isEditMode[viewID] ?? false) ? filterRowsWidget : (editMode[viewID] == TranslateConstants.math.toLowerCase() ? functionMathRowsWidget : [])) ] 
            ))),
          MainGridWidget(links: links, view: widget.view, viewKey: widget.viewKey, 
            subSize: subSize,
            subWidthSize: menuSize,
            isSelected: widget.isSelected) 
        ])
      ),
    ]);
  }
  Future<void> fillSchemeItem() async {
    var order = realOrder(widget.view, false);
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
  List<Widget> getButtons() {
    var buttons = <Widget>[
      Padding( 
        padding: const EdgeInsets.only(right: 10), 
        child: AdvancedSwitch(
          initialValue: isEditMode[viewID] ?? false,
          activeColor: Theme.of(context).primaryColor,
          inactiveColor: Colors.grey,
          borderRadius:  const BorderRadius.all(Radius.circular(15)),
          activeChild: const Icon(Icons.edit, color: Colors.white, size: 15),
          inactiveChild: const Icon(Icons.remove_red_eye, color: Colors.white, size: 15),
          width: 50.0, height: 20.0, disabledOpacity: 0.5,
          onChanged: (value) => Future.delayed( const Duration(milliseconds: 500), 
            () => setState(() { 
              rects.remove(viewID);
              filterTempOrderView.remove(viewID);
              isEditMode[viewID] = value; 
            }) 
          ))) 
    ];
    if (widget.isSelected || selectedGrid.isNotEmpty) {
      if (isEditMode[viewID] ?? false) {
        buttons.add(SaveDatagridButtonWidget(selectedGrid: selectedGrid));
      } else {
        if (widget.view?.actions.contains("delete") ?? false) {
          buttons.add(Padding(padding: EdgeInsets.symmetric(horizontal: 10), 
          child: Tooltip( 
            message: (currentView!.isList ? TranslateConstants.rowsListDelete : TranslateConstants.rowsDelete).toLowerCase(),
            child: InkWell( 
              onTap: () { 
                if (selectedGrid.isEmpty) { return; }
                List<String> ids = [];
                String schemaID = selectedGrid[0].schemaID;
                for (var item in selectedGrid) { 
                  ids.add(item.cells[0].value?.toString() ?? ""); 
                }
                APIService().delete("${APIConstants.genericEndpost}$schemaID?rows=${ids.join(",")}", context);
              }, 
              child: Icon(Icons.delete, color: Theme.of(context).highlightColor, size: 20)
          ))));
        }
        buttons.addAll([
          PopupButtonWidget(
            tooltip: (currentView!.isList ? TranslateConstants.rowsListExport : TranslateConstants.rowsExport).toLowerCase(),
            icon: Icons.file_download,
            widget: MappingPopUpWidget(isExport: true, format: "csv")
          )
        ]);
      }
    }
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
