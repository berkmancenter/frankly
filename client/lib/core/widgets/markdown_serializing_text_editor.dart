import 'package:client/styles/app_styles.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:super_editor/super_editor.dart';
import 'package:super_editor_markdown/super_editor_markdown.dart';

import 'super_editor_fixed_toolbar.dart';

class MarkdownSerializingTextEditor extends StatefulWidget {
  final String? initialValue;
  final Function(String)? onChanged;

  const MarkdownSerializingTextEditor({
    this.initialValue,
    this.onChanged,
  }) : super();

  @override
  State<MarkdownSerializingTextEditor> createState() =>
      _MarkdownSerializingTextEditorState();
}

class _MarkdownSerializingTextEditorState
    extends State<MarkdownSerializingTextEditor> {
  final GlobalKey _viewportKey = GlobalKey();
  final GlobalKey _docLayoutKey = GlobalKey();
  late MutableDocument _doc;
  late MutableDocumentComposer _composer;
  late Editor _docEditor;
  late CommonEditorOperations _docOps;
  late FocusNode _editorFocusNode;
  // TODO (from SuperEditor example): get rid of overlay controller once Android is refactored to use a control scope (as follow up to: https://github.com/superlistapp/super_editor/pull/1470)
  final _overlayController = MagnifierAndToolbarController() //
    ..screenPadding = const EdgeInsets.all(20.0);
  late final SuperEditorIosControlsController _iosControlsController;
  String _markdown = '';

  @override
  void initState() {
    super.initState();
    _doc = createInitialDocument()..addListener(_onDocumentChange);
    _composer = MutableDocumentComposer();
    _docEditor = createDefaultDocumentEditor(
      document: _doc,
      composer: _composer,
      isHistoryEnabled: true,
    );
    _docOps = CommonEditorOperations(
      editor: _docEditor,
      document: _doc,
      composer: _composer,
      documentLayoutResolver: () =>
          _docLayoutKey.currentState as DocumentLayout,
    );
    _editorFocusNode = FocusNode();
    _iosControlsController = SuperEditorIosControlsController();
  }

  void _updateMarkdown() {
    _markdown = serializeDocumentToMarkdown(_doc);
  }

  MutableDocument createInitialDocument() {
    return deserializeMarkdownToDocument(widget.initialValue ?? '');
  }

  void _onDocumentChange(_) {
    _updateMarkdown();
    final onChanged = widget.onChanged;
    if (onChanged != null) {
      onChanged(_markdown);
    }
  }

  @override
  void dispose() {
    _iosControlsController.dispose();
    _editorFocusNode.dispose();
    _composer.dispose();
    super.dispose();
  }

  DocumentGestureMode get _gestureMode {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return DocumentGestureMode.android;
      case TargetPlatform.iOS:
        return DocumentGestureMode.iOS;
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return DocumentGestureMode.mouse;
    }
  }

  Widget _buildToolbar() {
    return SuperEditorFixedToolbar(
      editor: _docEditor,
      document: _doc,
      composer: _composer,
      commonOps: _docOps,
      editorFocusNode: _editorFocusNode,
    );
  }

  TextInputSource get _inputSource {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return TextInputSource.ime;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildToolbar(),
        SizedBox(height: 2),
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: _editorFocusNode.hasFocus
                  ? AppColor.accentBlue
                  : AppColor.gray4,
              width: 1,
            ),
          ),
          child: SizedBox(
            height:
                200, // fixed dimensions a requirement to contain customscrollview
            child: CustomScrollView(
              //scrollview a requirement to contain SuperEditor b/c they use Sliver
              // See https://github.com/superlistapp/super_editor/issues/2266
              slivers: [
                KeyedSubtree(
                  key: _viewportKey,
                  child: SuperEditorIosControlsScope(
                    controller:
                        _iosControlsController, //not clear this is needed
                    child: SuperEditor(
                      editor: _docEditor,
                      gestureMode: _gestureMode,
                      focusNode: _editorFocusNode,
                      documentLayoutKey: _docLayoutKey,
                      documentOverlayBuilders: [
                        DefaultCaretOverlayBuilder(
                          caretStyle: const CaretStyle().copyWith(
                            color: Colors.black,
                          ),
                        ),
                        if (defaultTargetPlatform == TargetPlatform.iOS) ...[
                          SuperEditorIosHandlesDocumentLayerBuilder(),
                          SuperEditorIosToolbarFocalPointDocumentLayerBuilder(),
                        ],
                        if (defaultTargetPlatform ==
                            TargetPlatform.android) ...[
                          SuperEditorAndroidToolbarFocalPointDocumentLayerBuilder(),
                          SuperEditorAndroidHandlesDocumentLayerBuilder(),
                        ],
                      ],
                      inputSource: _inputSource,
                      keyboardActions: _inputSource == TextInputSource.ime
                          ? defaultImeKeyboardActions
                          : defaultKeyboardActions,
                      //androidToolbarBuilder: (_) => _buildAndroidFloatingToolbar(), TODO needed?
                      //overlayController: _overlayController,  TODO needed for Android?
                      plugins: {
                        MarkdownInlineUpstreamSyntaxPlugin(),
                      },
                      /**The selection and IME policies are set here to make sure we don't lose 
                       * selection on keyboard mouse up. This seems to be required because of the
                       * CustomScrollView, which I'm guessing is gaining focus on mouse up.
                       * Unfortunately this leaves text selected all the time, even when you
                       * put focus on a different element, but not sure how else to solve.
                       */
                      selectionPolicies: SuperEditorSelectionPolicies(
                        clearSelectionWhenEditorLosesFocus: false,
                      ),
                      imePolicies: SuperEditorImePolicies(
                        closeImeOnNonPrimaryFocusLost: false,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
