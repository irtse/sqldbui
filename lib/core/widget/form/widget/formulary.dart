import 'package:sqldbui2/core/widget/form/widget/error_formulary.dart';
import 'package:sqldbui2/core/widget/form/widget/subformulary.dart';
import 'package:flutter/material.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/core/widget/form/form.dart';
import 'package:sqldbui2/core/widget/form/convertors/consent.dart';
import 'package:sqldbui2/core/widget/form/convertors/convertor.dart';
Map<Key, bool> formularyRef = {};
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
  Map<String,dynamic> newCacheEntry;
  Map<String, dynamic> cacheForm = {};
  bool formIsEmpty = false;
  Map<String, model.SchemaField> schema;
  List<Widget> additionnalWidgets;
  GlobalKey<FormWidgetState> state;
  GlobalKey<SubFormularyWidgetState>? wrappers;
  
  GlobalKey<FormState> formKey;
  FormularyWidget ({ 
    super.key, 
    this.error = "",
    required this.state,
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
    required this.newCacheEntry,
    required this.additionnalWidgets,
    required this.superFormSchemaName    
  });
  @override FormularyWidgetState createState() => FormularyWidgetState();
}
var count = 0;
class FormularyWidgetState extends State<FormularyWidget> {
    @override Widget build(BuildContext context) {
    try {
      widget.component.widget.oneToManiesForm = {};
      List<Widget> fields = <Widget>[];
      List<Widget> bottomFields = <Widget>[];
      for (var fieldName in widget.view.order) {
          fieldName = "$fieldName";
          if (widget.schema[fieldName] == null || ["id", "description"].contains(fieldName) ||
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
            value = readOnly ? v.label ?? v.name : "${v.id}";
            path = v.ref ?? "";
          }
          if (widget.refItem.valuesMany.containsKey(fieldName)) { value = widget.refItem.valuesMany[fieldName]!; }
          if (widget.refItem.valuesManyPath.containsKey(fieldName)) { value = widget.refItem.valuesManyPath[fieldName]!; }

          widget.newCacheEntry[fieldName] = widget.newCacheEntry[fieldName] ?? value;
          if ((fieldName == "name" && field.readonly && (widget.refItem.values.containsKey("name") && widget.refItem.values["name"] != null))) { 
            continue; 
          }
          
          String? mainUrl, url;
          if (!readOnly && field.actionPath != "") { mainUrl = field.actionPath; }
          if (!readOnly && field.valuesPath != "") { url = field.valuesPath; }
          value = value == "" ? null : value;
          if (readOnly && value == null) {
            continue;
          }
          double max = widget.width - 100 > 0 ? widget.width - 100 : 1;
          var f = FutureBuilder( future: Convertor.formFieldByType(
              widget.newCacheEntry, 
              context, 
              widget.view.schemaName, 
              widget.view.schema,
              field.type, 
              fieldName, 
              field.label, 
              field.description, 
              field.require, 
              readOnly || (value != null && widget.view.isEmpty) || fieldName == "state", 
              value == "" ? null : value, 
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
              if (field.type.contains("manytomany") && readOnly) {
                fields.add(f);
              } else {
                var w = Padding( padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 10, bottom: 10),
                child: SizedBox( 
                  width: field.type.contains("bool") ? 200 : (widget.subForm ? max - 50 : max), 
                  height: field.type.contains("text") ? 100 : 40, child: f));
                fields.add(w);
              }
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
                    child: Padding(padding: const EdgeInsets.all(10), child: f)
                  )
                )
              ); 
            }
      }
      for (var consent in widget.view.consents) {
        fields.add(ConsentWidget(state: widget.state, consent: consent, value: false));
      }
      if (widget.key != null) {
        formularyRef[widget.key!] = fields.length == widget.hideField.length;
      }
      if (fields.length == widget.hideField.length) {
        return Container();
      }
      if (fields.isNotEmpty) {
        errorFormKey = GlobalKey<ErrorFormularyWidgetState>();
        fields = [ ErrorFormularyWidget(), ...fields];
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
    }catch (e,s) {
    print(e);
    print(s);
    return Container();
  }
  } 
}