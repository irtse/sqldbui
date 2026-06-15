import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqldbui2/core/widget/form/convertors/convertor.dart';
import 'package:sqldbui2/core/widget/form/form.dart';
import 'package:sqldbui2/page/translate.dart';
import 'package:flutter_quill_delta_from_html/flutter_quill_delta_from_html.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:delta_to_html/delta_to_html.dart';import 'package:flutter_quill/flutter_quill.dart';// ignore: must_be_immutable
class HTMLWidget extends StatefulWidget {
  final FormWidgetState? component;
  final Map<String, dynamic> form;
  final String schemaName;
  final dynamic name;
  final bool readOnly;
  final bool require;
  final bool translatable;
  dynamic value;
  final String type;
  final String label;
  final dynamic autofill;
  bool isDark = false;
  HTMLWidget ({ 
    required this.form, 
    required this.schemaName, 
    required this.name,
    required this.readOnly, 
    required this.require, 
    required this.type, 
    required this.component,
    required this.label,
    required this.translatable,
    this.value,
    this.autofill,
    this.isDark = false}): super(key: GlobalKey<State<HTMLWidget>>());
  @override
  // ignore: library_private_types_in_public_api
  HTMLState createState() => HTMLState();
}
class HTMLState extends State<HTMLWidget> {
    ///[controller] create a QuillEditorController to access the editor methods
 final QuillController _controller = () {
    return QuillController.basic(
        config: QuillControllerConfig( ));
  }();
  final FocusNode _editorFocusNode = FocusNode();
  final ScrollController _editorScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.value != null) {
      final delta = HtmlToDelta().convert("${widget.value}");
      _controller.document = Document.fromDelta(delta);
    }
  }
  @override Widget build(BuildContext context) {
    if ((widget.component?.widget.view?.rules ?? []).where( (r) => r.trigger == widget.name).isNotEmpty) {
      for (var r in (widget.component?.widget.view?.rules ?? [])) {
        if (r.trigger == widget.name) {
          r.key = widget.key as GlobalKey<State<HTMLWidget>>;
        }
      }
    }
    _controller.addListener(_onEditorChanged);
    return FutureBuilder(future: futureBuild(context), builder: (b,a) {
      if (a.hasData && a.data != null) {
        return a.data!;
      }
      return Container();
    });
  }
  Future<Widget> futureBuild(BuildContext context) async {
    widget.value = widget.form[widget.name] ?? widget.value ?? widget.autofill; 
    if ((widget.type.contains("time") || widget.type.contains("date")) && widget.value != null) {
      widget.value = '${widget.value}'.substring(0, widget.value.length > 10 ? 10 : widget.value.length);
    }
    var val = widget.value  ?? widget.autofill;
    if (widget.value != null) {
      saveChange(widget.component?.widget.view, widget.form, widget.name, widget.value);
    }
    val = val?.replaceAll("''", "'");
    final htmlTrad = await Future.wait([
      getOnFlow(TranslateConstants.empty),
      getOnFlow('Start writing your notes...'),
    ]);
    if (val == null) {
      val = widget.readOnly ? htmlTrad[0] : null;
    } else if (widget.translatable) {
      val = await getOnFlow(val);
    }
    var placeholder = htmlTrad[1];
    return FormField<String>(
      validator: (value) {
        value = _controller.document.toPlainText().trim();
        if (value.isEmpty && widget.require && !widget.readOnly) {
            return "";
          }
          for (var r in (widget.component?.widget.view?.rules ?? [])) {
            if (r.trigger == widget.name) {
              if (r.operator.toLowerCase().contains("in")) {
                if (r.operator.toLowerCase().contains("not") && r.value.contains(value)) {
                  return "";
                } else if (!r.value.contains(value)) {
                  return "";
                }
                return null;
              }
              for (var v in r.value.where( (e) => e != null )) {
                var s = v.toString().split("(").last.replaceAll("'", "").replaceAll(")", "");
                var val = widget.form[s] ?? v?.toString() ?? "";
                if (r.operator.toLowerCase().contains("like")) {
                  if (r.operator.toLowerCase().contains("not")) {
                    if (value.contains(val)) {
                      return "";
                    }
                  } else {
                    if (!value.contains(val)) {
                      return "";
                    } 
                  }
                } else if (r.operator.contains("=")) {
                  if (r.operator.contains("!")) {
                    if (value != val) {
                      return "";
                    }
                  } else {
                    if (value == val) {
                      return "";
                    }
                  }
                }
              }
            }
          }
          return null;
      },
      builder: (state) {
        return Container( 
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10)),
          border: Border.all( color: Theme.of(context).splashColor, )),
        width: MediaQuery.of(context).size.width, height: 300, child: Column(
        children: [
              QuillSimpleToolbar(
                controller: _controller,
                config: QuillSimpleToolbarConfig(
                  showClipboardPaste: true,
                  embedButtons: FlutterQuillEmbeds.toolbarButtons(),
                  customButtons: [ ],
                  buttonOptions: QuillSimpleToolbarButtonOptions(
                    base: QuillToolbarBaseButtonOptions(
                      afterButtonPressed: () {
                        final isDesktop = {
                          TargetPlatform.linux,
                          TargetPlatform.windows,
                          TargetPlatform.macOS
                        }.contains(defaultTargetPlatform);
                        if (isDesktop) {
                          _editorFocusNode.requestFocus();
                        }
                      },
                    ),
                    linkStyle: QuillToolbarLinkStyleButtonOptions(),
                  ),
                ),
              ),
              Expanded(
                child: QuillEditor(
                  focusNode: _editorFocusNode,
                  scrollController: _editorScrollController,
                  controller: _controller,
                  config: QuillEditorConfig(
                    placeholder:placeholder.toLowerCase(),
                    padding: const EdgeInsets.all(16),
                    embedBuilders: kIsWeb ? FlutterQuillEmbeds.editorWebBuilders() : FlutterQuillEmbeds.editorBuilders(),
                  ),
                ),
              ),
            ],
      ));
    });
  }
  _onEditorChanged() {
    List deltaJson = _controller.document.toDelta().toJson();
    var html = DeltaToHTML.encodeJson(deltaJson);
    saveChange(widget.component?.widget.view, widget.form, widget.name, html);
  }
}