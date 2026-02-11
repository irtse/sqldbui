import 'package:flutter/material.dart';
import 'package:sqldbui2/page/translate.dart';
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/core/widget/form/form.dart';
import 'package:sqldbui2/core/widget/form/convertors/consent.dart';
import 'package:sqldbui2/core/widget/form/widget/subformulary.dart';
import 'package:sqldbui2/core/widget/form/convertors/convertor.dart';
import 'package:sqldbui2/core/widget/form/widget/error_formulary.dart';

// ignore: must_be_immutable
class FormularyWidget extends StatefulWidget {
  String error = "";
  bool show;
  double width;
  bool subForm;
  model.View view;
  bool isSplitted;
  model.Item refItem;
  FormWidgetState component;
  String superFormSchemaName;
  List<String> hideField = [];
  bool formIsEmpty = false;
  Map<String, model.SchemaField> schema;
  List<Widget> additionnalWidgets;
  GlobalKey<SubFormularyWidgetState>? wrappers;
  
  GlobalKey<FormState> formKey;
  FormularyWidget ({ 
    super.key, 
    this.error = "",
    required this.show,
    required this.view, 
    required this.width,
    required this.schema,
    required this.formKey,
    required this.refItem,
    required this.subForm,
    required this.wrappers, 
    required this.component,
    required this.hideField,
    required this.isSplitted,
    required this.formIsEmpty,
    required this.additionnalWidgets,
    required this.superFormSchemaName    
  });
  @override FormularyWidgetState createState() => FormularyWidgetState();
}
var count = 0;
class FormularyWidgetState extends State<FormularyWidget> {
    @override Widget build(BuildContext context) {
    try {
      List<Widget> fields = <Widget>[];
      List<Widget> bottomFields = <Widget>[];

      if (!(currentView?.isEmpty ?? true)) {
        try {
          for (var consent in (widget.view.consents)) {
            fields.add(ConsentWidget(state: widget.component, consent: consent, value: false));
          }
          if ((widget.view.consents).isNotEmpty) {
            fields.add(Padding( padding: EdgeInsets.only(top: 20, bottom: 20),
              child : const Divider(height: 0.5, thickness: 0.5, color: Colors.grey)));
          }
        } catch(e) { print("ERR $e"); }
      }
      List<String> categories = [];
      for (var v in widget.view.schema.values) {
        if ((v.subsection ?? "") != "" && !categories.contains(v.subsection)) {
          categories.add(v.subsection!.toLowerCase());
        }
      }
      categories.sort( (a, b) {
        return a.toLowerCase().compareTo(b.toLowerCase());
      });
      categories.add("");
      for (var c in categories) {
        if ( widget.view.order.where( (e) => widget.schema[e] != null && !widget.schema[e]!.hidden && (widget.schema[e]?.subsection ?? "") == c && !["id", "description"].contains(e) &&
          !(widget.superFormSchemaName != "" && e.contains(widget.superFormSchemaName))).isEmpty ) {
            continue;
        }
        if (categories.length > 1) {
          fields.add(Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Row( children: [ 
            FutureBuilder(future: getOnFlow(c == "" ? "general" : c), builder: (a,s) {
              if (s.data != null) {
                return Text("${s.data!.toUpperCase()} :", style: TextStyle( fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor));
              }
              return Text("${(c == "" ? "general" : c).toUpperCase()} :", style: TextStyle( fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor));
            }),
          ])
         ));
        }
        for (var fieldName in widget.view.order) {
          fieldName = "$fieldName";
          if (widget.schema[fieldName] == null || widget.schema[fieldName]!.hidden 
          || (widget.schema[fieldName]?.subsection ?? "") != c || ["id", "description"].contains(fieldName) ||
          (widget.superFormSchemaName != "" && fieldName.contains(widget.superFormSchemaName))) { 
            continue; 
          }
          var field = widget.schema[fieldName]!; 
          var value = widget.refItem.values.containsKey(fieldName) ? widget.refItem.values[fieldName] : null;
          var readOnly = (field.readonly || widget.view.readOnly || widget.refItem.readonly) && !widget.view.isEmpty;
          readOnly = readOnly || !((widget.view.actions.contains("post") && widget.view.isEmpty) || widget.view.actions.contains("put")); // to remove if change its mind
          String path = "";
          if (widget.refItem.valuesShallow.containsKey(fieldName)) { 
            var v = widget.refItem.valuesShallow[fieldName]!;
            value = (readOnly || (value != null && widget.view.isEmpty) || fieldName == "state") && !field.forceNotReadOnly ? v.label ?? v.name : "${v.id}";
            cacheForm[widget.view.name]?[fieldName] = v.id;
            path = v.ref ?? "";
          }
          if (widget.refItem.valuesMany.containsKey(fieldName)) { 
            value = widget.refItem.valuesMany[fieldName]!; 
          }
          if (widget.refItem.valuesManyPath.containsKey(fieldName)) { 
            value = widget.refItem.valuesManyPath[fieldName]!; }
          if ((fieldName == "name" && field.readonly && (widget.refItem.values.containsKey("name") && widget.refItem.values["name"] != null))) { 
            continue; 
          }
          
          String? mainUrl, url;
          if (field.actionPath != "") { mainUrl = field.actionPath; }
          if (field.valuesPath != "") { 
            url = field.valuesPath; 
          }
          
          value = value == "" ? null : value;
          if (fieldName == "state") {
            value = "$value".replaceAll(" (pending)", "").replaceAll(" (completed)", "").replaceAll(" (refused)", "").replaceAll(" (running)", "");
          }
          if (readOnly && value == null) {
            continue;
          }
          double max = widget.width - 100 > 0 ? widget.width - 100 : 1;
          var f = FutureBuilder( future: Convertor.formFieldByType(
              cacheForm[widget.view.name]!, 
              context, 
              widget.view.schemaName, 
              widget.view.schema,
              field.type, 
              fieldName, 
              field.label, 
              field.description, 
              field.require, 
              (readOnly || (value != null && widget.view.isEmpty) || fieldName == "state") && !field.forceNotReadOnly, 
              (value == "" ? null : value), 
              mainUrl,
              url, 
              path, 
              widget.component, 
              widget.view.isEmpty,
              field.autoFill,
              field.translatable,
              widget.wrappers,
            ), builder: (a,b) {
              if (b.data != null) {
                return b.data!;
              }
              return Container();
            });
            if (!field.type.contains("onetomany") && widget.show) {
                var w = Padding( padding: EdgeInsets.only(left: 10.0, right: 10.0, top: field.type.contains("bool") && field.label.length > 10 ? 0 : 10, bottom: 10),
                child: (field.info ?? "") != "" ? 
                Stack(children: [  
                      Padding(padding: EdgeInsetsGeometry.only(top: 8), child:
                      SizedBox( 
                        width: field.type.contains("bool") && field.label.length <= 10 ? 200 : (widget.subForm ? max - 50 : max), 
                        height: field.type.contains("text") ? 100 : ( 
                          field.type.contains("bool") && field.label.length > 10 ? 30 : 40), child: f)
                      ),
                      if (field.info != null)
                        Positioned(
                          top: field.type.contains("bool") ? 19 : 0, 
                          right:field.type.contains("bool") ? null : 10,
                          left:field.type.contains("bool") ? 0 : null,
                          child: FutureBuilder(future: getOnFlow(field.info!), builder: (a,s) {
                            return Tooltip( 
                            constraints: BoxConstraints(maxWidth: 250),
                            richMessage: TextSpan(
                              children: [
                                TextSpan(
                                  text: s.data ?? field.info,
                                ),
                              ],
                            ),
                            child: Icon(Icons.info, size: 18, color: Colors.grey)
                          );
                    })),
                  ])
                : SizedBox( 
                  width: field.type.contains("bool") && field.label.length <= 10 ? 200 : (widget.subForm ? max - 50 : max), 
                  height: field.type.contains("text") ? 100 : ( 
                    field.type.contains("bool") && field.label.length > 10 ? 30 : 40), child: f));
                fields.add(w);
            }
            if ((field.type.contains("onetomany") && widget.show) 
            && !(widget.view.isEmpty && !widget.view.actions.contains("post"))) { 
              fields.add(
                Padding(
                  padding: const EdgeInsets.only(bottom: 10, top: 10, left: 10, right: 10), 
                  child: Container( 
                    decoration: BoxDecoration(  borderRadius: BorderRadius.circular(5), 
                      // ignore: use_build_context_synchronously
                      color: Theme.of(context).splashColor,
                    ), 
                    child: Padding(padding: const EdgeInsets.all(10), 
                      child: f)
                  )
                )
              ); 
            }
        }
      }

      if (fields.length == widget.hideField.length) {
        return Container();
      }
      if (fields.isNotEmpty) {
        errorFormKey[widget.formKey] = GlobalKey<ErrorFormularyWidgetState>();
        fields = [ ErrorFormularyWidget(key: errorFormKey[widget.formKey]), ...fields];
      }
      return Form( key: widget.formKey, 
        autovalidateMode: AutovalidateMode.always, 
        child: Wrap( 
          alignment: WrapAlignment.center,
          children: [ 
            fields.isNotEmpty ? Padding( padding: const EdgeInsets.only(left: 30, right: 30, bottom: 10), 
              child: Container( 
                padding: EdgeInsets.only(top: widget.subForm || (!widget.subForm && widget.isSplitted) ? 0 : 30), 
                child: Wrap( alignment: WrapAlignment.center, children : fields))
            ) : Container(height: 30),
            ...bottomFields, 
            ...(widget.isSplitted ? [] : widget.additionnalWidgets)
          ]
        )
      );
    }catch (e) {
    return Container();
  }
  } 
}