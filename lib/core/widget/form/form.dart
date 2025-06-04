import 'package:sqldbui2/core/services/api_service.dart';
import 'package:sqldbui2/core/widget/datagrid/main_grid.dart';
import 'package:sqldbui2/core/widget/form/convertors/dropdown.dart';
import 'package:sqldbui2/core/widget/form/widget/empty_formulary.dart';
import 'package:sqldbui2/core/widget/form/widget/formulary.dart';
import 'package:sqldbui2/core/widget/form/widget/formulary_action_bar.dart';
import 'package:sqldbui2/core/widget/form/widget/formulary_comment.dart';
import 'package:sqldbui2/core/widget/form/widget/formulary_header.dart';
import 'package:sqldbui2/core/widget/form/widget/subformulary.dart';
import 'package:sqldbui2/core/widget/utils/fork/multi_dropdown/multi_dropdown.dart';
import 'package:sqldbui2/main.dart';
import 'package:flutter/material.dart';
import 'package:sqldbui2/page/translate.dart';
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/core/sections/menu/menu.dart';
import 'package:sqldbui2/core/widget/form/convertors/onetomany.dart';

GlobalKey<FormWidgetState> mainForm = GlobalKey<FormWidgetState>();
Map<String, List<Map<String, dynamic>>> flashedForm = <String, List<Map<String, dynamic>>>{};
// ignore: must_be_immutable
class DataFormWidget extends StatefulWidget {
  GlobalKey<SubFormularyWidgetState> subKey = GlobalKey<SubFormularyWidgetState>(); 
  bool reloadWorkflow = true;
  List<String> hideField = [];
  bool formIsEmpty = false;
  final model.View? view;
  bool detectChange = false;
  String superFormSchemaName;
  Map<String, dynamic> cacheForm = {};
  bool scroll, subForm, subSubForm, isSplitted;
  List<DataFormWidget>wrappers = <DataFormWidget>[];
  List<DataFormWidget> oneToManiesForm = <DataFormWidget>[];
  List<DataFormWidget> oneToManiesFormDelete = <DataFormWidget>[];
  List<DataFormWidget> existingOneToManiesForm = <DataFormWidget>[];
  GlobalKey<FormularyHeaderWidgetState> headerKey = GlobalKey<FormularyHeaderWidgetState>();
  Map<DataFormWidget, OneToManyState> oneToManiesStateForm = <DataFormWidget, OneToManyState>{};
  List<GlobalKey<SubFormularyWidgetState>>wrappersGlobalKey = <GlobalKey<SubFormularyWidgetState>>[];

  int subMenuIndex = 0;
  final formKey = GlobalKey<FormState>();
  DataFormWidget ({ super.key, 
    this.view, 
    this.scroll = true, 
    this.subForm = false, 
    this.subSubForm = false,
    this.isSplitted = false,
    this.superFormSchemaName = "" });
  @override FormWidgetState createState() => FormWidgetState();
}
class FormWidgetState extends State<DataFormWidget> {
    bool show = true;
    model.Workflow? workflow;
    List<Widget> additionnal = <Widget>[];
    @override Widget build(BuildContext context) {
      return FutureBuilder(future: futureBuild(context), builder: (b,a) {
      if (a.data != null) {
        return a.data!;
      }
      return Container();
    });
  }
  Future<Widget> futureBuild(BuildContext context) async {
      newDropDownValue = {};
      searchCtrl = {};

      widget.detectChange = false;
      additionnal = [];
      List<Widget> fields = <Widget>[];
      List<Widget> subMenu = [];
      
      bool isSplitted = (widget.isSplitted || (widget.view?.isWrapper ?? false)) && !currentView!.isEmpty && widget.subMenuIndex == 0;
      bool isLower = currentWidth < 1200;
      double ratioSplit = isSplitted && !isLower ? 0.75 : 1;
      Widget? content;
      if (widget.view != null && widget.view!.items.isNotEmpty) {
        double mainWidth = ((currentWidth - menuSize) * ratioSplit) > 0 ?  ((currentWidth - menuSize) * ratioSplit) : 0;
        double wfSize = (workflow == null && !(widget.view?.isEmpty ?? false) ? 112 : ( workflow?.currentHub ?? false ? 200 :  152));
        double mainHeight =  currentHeigth - wfSize > 0 ? currentHeigth - wfSize : 0;

        var refItem = widget.view!.items[0];
        workflow = refItem.workflow;
        var schema = widget.view!.schema;
        widget.wrappers = [];
        additionnal = [];
        widget.wrappersGlobalKey = [];
        
        additionnal.add(SubFormularyWidget( key: widget.subKey, item: refItem,
          component: widget, isEmpty: widget.view?.isEmpty ?? false, relatedDatas: refItem.dataPath)); 
        var newCacheEntry = <String,dynamic>{"id" : refItem.values["id"]};
        
      
        widget.cacheForm = newCacheEntry;
        switch (widget.subMenuIndex) {
          case 0: 
          GlobalKey<FormularyWidgetState> key = GlobalKey<FormularyWidgetState>();
          content = FormularyWidget(   
              key: key,
              show: show, 
              schema: schema,
              component: this, 
              width: mainWidth, 
              refItem: refItem, 
              view: widget.view!,
              formKey: widget.formKey,       
              isSplitted: isSplitted,
              subForm: widget.subForm,
              wrappers: widget.subKey,
              hideField: widget.hideField, 
              newCacheEntry: newCacheEntry,
              additionnalWidgets: additionnal,
              formIsEmpty: widget.formIsEmpty,
              superFormSchemaName: widget.superFormSchemaName,
            );
          case 1: content = FormularyCommentsWidget(
            height: mainHeight,
            width: widget.view!.isEmpty ? mainWidth : (mainWidth - 200 > (mainWidth / 2) ? mainWidth - 200 : mainWidth - 40),
            view: widget.view!);
          case 2:
            content = getSynthesis(refItem.synthesisPath ?? "", mainHeight);
        }
        var menuItems = [TranslateConstants.formulary, TranslateConstants.comments];
        if ((refItem.synthesisPath ?? "") != "") {
          menuItems.add(TranslateConstants.synthesis);
        }
        for (var (i, menu) in menuItems.indexed) {
        subMenu.add(InkWell(
          onTap: () => setState(() {
              widget.subMenuIndex = i;
            }),
            child: Container( margin: EdgeInsets.only(top: 10, right: subMenu.length == widget.subMenuIndex ? 0 : 10),
              decoration: BoxDecoration( 
                // ignore: use_build_context_synchronously
                color: Theme.of(context).
                highlightColor, borderRadius: subMenu.length == widget.subMenuIndex ? 
                  BorderRadius.only(topLeft: Radius.circular(5), bottomLeft: Radius.circular(5))
                  : BorderRadius.all(Radius.circular(5))
              ),
              height: 40, width: subMenu.length == widget.subMenuIndex ? 190 : 180,  
              child: Center( child: Text((await getOnFlow(menu)).toLowerCase(), overflow: TextOverflow.ellipsis, style: TextStyle( 
                // ignore: use_build_context_synchronously
                color: subMenu.length == widget.subMenuIndex ? Theme.of(context).primaryColor : Colors.grey)) )),
            )
          );
      }
        if (!widget.scroll) {
          if (widget.subSubForm) {
            return Container( 
              padding: EdgeInsets.only(top: 20),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Theme.of(context).splashColor)),
                color: Colors.white,
              ),
              child: Column( children: [
                fields.isEmpty && content == null ? EmptyFormularyWidget() : content!
            ]));
          } else {
            return Container( 
              padding: EdgeInsets.symmetric(vertical: 20),
              margin: EdgeInsets.only(left: widget.subForm ? 30 : 0, right: widget.subForm ? 30 : 0),
              decoration: BoxDecoration(
                boxShadow: [ BoxShadow( color: Colors.grey.withOpacity(0.5), spreadRadius: 0, blurRadius: 3, offset: const Offset(0, 3)) ],
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(widget.subForm ? 10 : 0))
              ),
              child: Column( children: [
                FormularyHeaderWidget(
                  key: widget.headerKey,
                  show: show,
                  schema: schema,
                  refItem: refItem,
                  view: widget.view!,
                  workflow: workflow,
                  subForm: widget.subForm,
                  canUpdate: widget.view!.actions.contains("put") && widget.view!.actions.contains("delete"),
                ),
                fields.isEmpty && content == null ? EmptyFormularyWidget() : content!
            ]));
          } 
        }
        
        Widget formWrap = Container( 
          // ignore: use_build_context_synchronously
          decoration: BoxDecoration(color: Theme.of(context).highlightColor ),
          width: mainWidth,
          child: Container(
            margin: EdgeInsets.only(top: workflow == null ? 112 : ( workflow!.currentHub ? 200 :  152)), 
            height: isLower ? null : mainHeight,
            child: Row( children: [
              Container(
                width: widget.view!.isEmpty ? 0 : (mainWidth - 200 > (mainWidth / 2) ? 200 : 40), 
                height: mainHeight, color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Row(children:[Container( margin: EdgeInsets.only(top: 20, left: 30, bottom: 5), 
                    child: Text(
                      (await getOnFlow(TranslateConstants.formularyMenu)).toUpperCase()))]),
                    ...( widget.view!.isEmpty ? [] : subMenu)
                  ])
              ),
              Container(
                padding: EdgeInsets.only(top: widget.view?.isEmpty ?? false ? 40 : 0),
                width: widget.view!.isEmpty ? mainWidth : (mainWidth - 200 > (mainWidth / 2) ? mainWidth - 200 : mainWidth - 40), 
                height: mainHeight,
                child: SingleChildScrollView(scrollDirection: Axis.vertical, 
                  child: Column( children: [ 
                  isSplitted  ? Wrap( alignment: WrapAlignment.center, children:[
                    isLower ? content! : Container(), ...additionnal
                  ]) : content!, ]) )
              )
            ]) 
          )
        );
        return Stack( children: [ 
          Row(children: [
            widget.formIsEmpty ? Container() : formWrap,
            ...(isSplitted && !isLower ? [
              Container( 
                margin: EdgeInsets.only(top: workflow == null && !(widget.view?.isEmpty ?? false) ? 112 
                : ( workflow?.currentHub ?? false  ? 198 :  148)), 
                height: mainHeight,
                // ignore: use_build_context_synchronously
                decoration: BoxDecoration(color: Theme.of(context).highlightColor, 
                  // ignore: use_build_context_synchronously
                  border: Border( left: BorderSide(color: Theme.of(context).splashColor, width: 1))),
                width: ((currentWidth - menuSize) * (1 - ratioSplit)) > 0 ? 
                  ((currentWidth - menuSize) * (1 - ratioSplit)) : 0,
                child: SingleChildScrollView(  scrollDirection: Axis.vertical,  
                  child : Column( children: [
                    Padding( padding: const EdgeInsets.only(top: 25, bottom: 5),
                      child: Text((await getOnFlow(currentView?.schemaName.replaceAll("db", "") ?? "")).toUpperCase(),
                        // ignore: use_build_context_synchronously
                        style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold, fontSize: 20),
                      )), 
                    Padding( padding: const EdgeInsets.only(bottom: 60), child: content),
                ] )
              ))
            ] : [])
          ]), 
          FormularyHeaderWidget(
                key: widget.headerKey,
                show: show,
                schema: schema,
                refItem: refItem,
                view: widget.view!,
                workflow: workflow,
                subForm: widget.subForm,
                canUpdate: widget.view!.actions.contains("put") && widget.view!.actions.contains("delete"),
              ), 
          FormularyActionBarWidget(
            isFirst: int.parse(workflow?.current ?? "0") <= 1,
            show: show, 
            schema: schema,
            component: this, 
            refItem: refItem, 
            view: widget.view!, 
            isSplitted: isSplitted
          )
        ]);
    }
    return EmptyFormularyWidget();
  }

   Widget? getSynthesis(String synthesisPath, double height) {
      if (synthesisPath == "") {
        return null;
      } 
      return Column( children: [
              Container(
                height: 40,
                color: Theme.of(context).primaryColor,
                width: currentWidth - menuSize - 200 > 0 ? currentWidth - menuSize  - 200 : 0,
                child: Center( child: Text( TranslateConstants.synthesis.toLowerCase(), 
                  style: TextStyle( color: Colors.white, fontSize: 18 ) ) )
              ),
              Container( 
                height: height - 110,
                decoration: BoxDecoration( 
                  borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(7), bottomRight: Radius.circular(7)),
                  border: Border(
                    left: BorderSide(color: Colors.grey.shade300, width: 1.0),
                ) ),
                child: FutureBuilder(
                  future: APIService().get<model.View>(synthesisPath, true, context), 
                  builder: (a,s) {
                    if (s.data?.data != null && s.data!.data!.isNotEmpty) {
                      return MainGridWidget(view: s.data!.data![0], viewKey: null, subTable: true, 
                            forceOrder: s.data!.data?[0].order ?? [],
                            links: {}, subSize: 0, subWidthSize: 100);
                    }
                    return Container( 
                      height: height - 80,
                      decoration: BoxDecoration( color: Theme.of(context).splashColor), 
                        width: currentWidth - menuSize > 0 ? currentWidth - menuSize : 0,
                        child: Center(
                          child: Text(TranslateConstants.emptyData, 
                            style: TextStyle(fontSize: 70, color: Theme.of(context).highlightColor))
                        ));
              })
    )]);
  }    
}