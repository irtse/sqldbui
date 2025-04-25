import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqldbui2/core/widget/form/form.dart';
import 'package:sqldbui2/main.dart';
import 'package:sqldbui2/page/translate.dart';
import 'package:path/path.dart' as path;
import 'dart:io' as io show Directory, File;
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:flutter_quill/flutter_quill.dart';// ignore: must_be_immutable
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
    super.key, 
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
    this.isDark = false});
  @override
  // ignore: library_private_types_in_public_api
  HTMLState createState() => HTMLState();
}
class HTMLState extends State<HTMLWidget> {
    ///[controller] create a QuillEditorController to access the editor methods
 final QuillController _controller = () {
    return QuillController.basic(
        configurations: QuillControllerConfigurations( ));
  }();
  final FocusNode _editorFocusNode = FocusNode();
  final ScrollController _editorScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.value != null) {
      _controller.document.insert(0, "${widget.value}");
    }
  }
  @override Widget build(BuildContext context) {
    return FutureBuilder(future: futureBuild(context), builder: (b,a) {
      if (a.hasData && a.data != null) {
        return a.data!;
      }
      return Container();
    });
  }
  Future<Widget> futureBuild(BuildContext context) async {
    if (widget.form[widget.name] != null) { widget.value = widget.form[widget.name]; }
    if ((widget.type.contains("time") || widget.type.contains("date")) && widget.value != null) {
      widget.value = '${widget.value}'.substring(0, widget.value.length > 10 ? 10 : widget.value.length);
    }
    var val = widget.value  ?? widget.autofill;
    if (val == null) {
      val = widget.readOnly ? TranslateConstants.empty : null;
    } else if (widget.translatable) {
      val = await getOnFlow(val);
    }
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
              configurations: QuillSimpleToolbarConfigurations(
                embedButtons: FlutterQuillEmbeds.toolbarButtons(),
                showClipboardPaste: true,
                customButtons: [
                  QuillToolbarCustomButtonOptions(
                    icon: const Icon(Icons.add_alarm_rounded),
                    onPressed: () {
                      _controller.updateSelection(
                        TextSelection.collapsed(
                          offset: _controller.selection.extentOffset + 1,
                        ),
                        ChangeSource.local,
                      );
                    },
                  ),
                ],
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
                configurations: QuillEditorConfigurations(
                  placeholder: 'Start writing your notes...',
                  padding: const EdgeInsets.all(16),
                  embedBuilders: [],
                ),
              ),
            ),
          ],
    ));
  }
}