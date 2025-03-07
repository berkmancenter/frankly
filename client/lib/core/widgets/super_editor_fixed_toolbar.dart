import 'dart:math';

import 'package:flutter/material.dart';
import 'package:super_editor/super_editor.dart';

/// A fixed toolbar to accompany a SuperEditor widget. Much of this code was derived from SuperEditor's mobile KeyboardEditingToolbar,
/// which uses an OverlayPortal to share focus between the toolbar and editor.
/// This toolbar adds refocusing of editor and selection retention to allow for placement anywhere in the widget tree.
/// It also removes the option to close the toolbar and supports toggling Bold and Italics when no text is selected.
class SuperEditorFixedToolbar extends StatefulWidget {
  const SuperEditorFixedToolbar({
    Key? key,
    required this.editor,
    required this.document,
    required this.composer,
    required this.commonOps,
    required this.editorFocusNode,
  }) : super(key: key);

  final Editor editor;
  final Document document;
  final DocumentComposer composer;
  final CommonEditorOperations commonOps;

  /// The [FocusNode] attached to the editor to which this toolbar applies.
  final FocusNode editorFocusNode;

  @override
  State<SuperEditorFixedToolbar> createState() =>
      _SuperEditorFixedToolbarState();
}

class _SuperEditorFixedToolbarState extends State<SuperEditorFixedToolbar>
    with WidgetsBindingObserver {
  bool _showUrlField = false;
  late FocusNode _urlFocusNode;
  ImeAttributedTextEditingController? _urlController;
  DocumentSelection? lastSelection;

  @override
  void initState() {
    super.initState();
    _urlFocusNode = FocusNode();
    _urlController = ImeAttributedTextEditingController(
      controller: SingleLineAttributedTextEditingController(_applyLink),
    ) //
      ..onPerformActionPressed = _onPerformAction
      ..text = AttributedText('https://');
    // Listen for focus changes and update the UI
    widget.editorFocusNode.addListener(_onEditorFocusChange);
  }

  void _onEditorFocusChange() {
    setState(() {}); // Trigger a rebuild when focus changes
  }

  @override
  void dispose() {
    _urlFocusNode.dispose();
    _urlController!.dispose();
    widget.editorFocusNode.removeListener(_onEditorFocusChange);
    super.dispose();
  }

  void _onPerformAction(TextInputAction action) {
    if (action == TextInputAction.done) {
      _applyLink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Builder(
          // Add a Builder so that _buildToolbar() uses theming from _buildTheming().
          builder: (themedContext) {
            return _buildToolbar(themedContext);
          },
        ),
        if (_showUrlField) ...[
          const SizedBox(height: 8),
          _buildUrlField(),
        ],
      ],
    );
    /**return _buildTheming(
      child: Builder(
        // Add a Builder so that _buildToolbar() uses theming from _buildTheming().
        builder: (themedContext) {
          return _buildToolbar(themedContext);
        },
      ),
    );**/
  }

  Widget _buildTheming({
    required Widget child,
  }) {
    final brightness = MediaQuery.of(context).platformBrightness;

    return Theme(
      data: Theme.of(context).copyWith(
        brightness: brightness,
        disabledColor: brightness == Brightness.light
            ? Colors.black.withValues(alpha: 0.5)
            : Colors.white.withValues(alpha: 0.5),
      ),
      child: IconTheme(
        data: IconThemeData(
          color: brightness == Brightness.light ? Colors.black : Colors.white,
        ),
        child: child,
      ),
    );
  }

  Widget _buildToolbar(BuildContext context) {
    final isEditorFocused = widget.editorFocusNode.hasFocus;
    final selection = widget.composer.selection;
    final selectedNode = selection != null
        ? widget.document.getNodeById(selection.extent.nodeId)
        : null;

    // Enable buttons when editor is focused, even if selection is null
    bool isToolbarEnabled = isEditorFocused || selection != null;

    final isSingleNodeSelected =
        selection != null ? selection.isCollapsed : false;

    return Material(
      child: Container(
        width: double.infinity,
        height: 48,
        color: Theme.of(context).brightness == Brightness.light
            ? const Color(0xFFDDDDDD)
            : const Color(0xFF222222),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ListenableBuilder(
                      listenable: widget.composer,
                      builder: (context, _) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed:
                                  isToolbarEnabled ? () => toggleBold() : null,
                              icon: const Icon(Icons.format_bold),
                              color: isBoldActive
                                  ? Theme.of(context).primaryColor
                                  : null,
                            ),
                            IconButton(
                              onPressed: isToolbarEnabled
                                  ? () => toggleItalics()
                                  : null,
                              icon: const Icon(Icons.format_italic),
                              color: isItalicsActive
                                  ? Theme.of(context).primaryColor
                                  : null,
                            ),
                            IconButton(
                              onPressed: !isToolbarEnabled ||
                                      _areMultipleLinksSelected()
                                  ? null
                                  : _onLinkPressed,
                              icon: const Icon(Icons.link),
                              color: _isSingleLinkSelected()
                                  ? const Color(0xFF007AFF)
                                  : IconTheme.of(context).color,
                              splashRadius: 16,
                              tooltip: 'Link',
                            ),
                            IconButton(
                              onPressed: isToolbarEnabled &&
                                      isSingleNodeSelected &&
                                      (selectedNode is TextNode &&
                                          selectedNode.getMetadataValue(
                                                'blockType',
                                              ) !=
                                              header1Attribution)
                                  ? _convertToHeader1
                                  : null,
                              icon: const Icon(Icons.title),
                            ),
                            IconButton(
                              onPressed: isToolbarEnabled &&
                                      isSingleNodeSelected &&
                                      (selectedNode is TextNode &&
                                          selectedNode.getMetadataValue(
                                                'blockType',
                                              ) !=
                                              header2Attribution)
                                  ? _convertToHeader2
                                  : null,
                              icon: const Icon(Icons.title),
                              iconSize: 18,
                            ),
                            IconButton(
                              onPressed: isToolbarEnabled &&
                                      isSingleNodeSelected &&
                                      ((selectedNode is ParagraphNode &&
                                              selectedNode.hasMetadataValue(
                                                'blockType',
                                              )) ||
                                          (selectedNode is TextNode &&
                                              selectedNode is! ParagraphNode))
                                  ? _convertToParagraph
                                  : null,
                              icon: const Icon(Icons.wrap_text),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: 32,
                  color: const Color(0xFFCCCCCC),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildUrlField() {
    return Material(
      shape: const StadiumBorder(),
      elevation: 5,
      clipBehavior: Clip.hardEdge,
      child: Container(
        width: 400,
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: SuperTextField(
                focusNode: _urlFocusNode,
                textController: _urlController,
                minLines: 1,
                maxLines: 1,
                inputSource: TextInputSource.ime,
                hintBehavior: HintBehavior.displayHintUntilTextEntered,
                hintBuilder: (context) {
                  return const Text(
                    'enter a url...',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  );
                },
                textStyleBuilder: (_) {
                  return const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  );
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              iconSize: 20,
              splashRadius: 16,
              padding: EdgeInsets.zero,
              onPressed: () {
                setState(() {
                  _urlFocusNode.unfocus();
                  _showUrlField = false;
                  _urlController!.clearTextAndSelection();
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  bool get isBoldActive => _doesSelectionHaveAttributions({boldAttribution});

  void toggleBold() => _toggleAttributions({boldAttribution});

  bool get isItalicsActive =>
      _doesSelectionHaveAttributions({italicsAttribution});
  void toggleItalics() => _toggleAttributions({italicsAttribution});

  bool _doesSelectionHaveAttributions(Set<Attribution> attributions) {
    final selection = widget.composer.selection;
    if (selection == null) {
      return false;
    }

    if (selection.isCollapsed) {
      return widget.composer.preferences.currentAttributions
          .containsAll(attributions);
    }

    return widget.document.doesSelectedTextContainAttributions(
      selection,
      attributions,
    );
  }

  void _toggleAttributions(Set<Attribution> attributions) {
    final selection = widget.composer.selection!;

    if (selection.isCollapsed) {
      // Toggle attribution in composer for future typing
      widget.commonOps.toggleComposerAttributions(attributions);
    } else {
      // Toggle attribution on selected text
      widget.commonOps.toggleAttributionsOnSelection(attributions);
    }
    _restoreFocusAndSelection();
  }

  void _restoreFocusAndSelection() {
    // TODO this method was necessary before I set the selection and ime policies on the supereditor
    // to never clear the selection when focus is lost. Leaving it here in case you figure out
    // a way to not use that (so the selection actually does go away when you are focused on something completely different)
    /**final selection = widget.composer.selection!;

    if (!selection.isCollapsed) {
      widget.editor.execute([
        ChangeSelectionRequest(
          DocumentSelection(
            base: selection.base,
            extent: selection.extent,
          ),
          SelectionChangeType
              .expandSelection, // Ensures selection remains visible
          SelectionReason.userInteraction,
        ),
      ]);
    }
    widget.editorFocusNode.requestFocus();**/
  }

  bool _isSingleLinkSelected() {
    return _getSelectedLinkSpans().length == 1;
  }

  /// Returns true if the current text selection includes 2+
  /// links, returns false otherwise.
  bool _areMultipleLinksSelected() {
    return _getSelectedLinkSpans().length >= 2;
  }

  /// Returns any link-based [AttributionSpan]s that appear partially
  /// or wholly within the current text selection.
  Set<AttributionSpan> _getSelectedLinkSpans() {
    final selection = widget.composer.selection;
    if (selection == null) {
      return <AttributionSpan>{};
    }
    final baseOffset = (selection.base.nodePosition as TextPosition).offset;
    final extentOffset = (selection.extent.nodePosition as TextPosition).offset;
    final selectionStart = min(baseOffset, extentOffset);
    final selectionEnd = max(baseOffset, extentOffset);
    final selectionRange = SpanRange(selectionStart, selectionEnd - 1);

    final textNode =
        widget.document.getNodeById(selection.extent.nodeId) as TextNode;
    final text = textNode.text;

    final overlappingLinkAttributions = text.getAttributionSpansInRange(
      attributionFilter: (Attribution attribution) =>
          attribution is LinkAttribution,
      range: selectionRange,
    );

    return overlappingLinkAttributions;
  }

  void _onLinkPressed() {
    final selection = widget.composer.selection;
    if (selection == null || selection.isCollapsed) {
      return;
    }
    lastSelection = selection;
    final baseOffset = (selection.base.nodePosition as TextPosition).offset;
    final extentOffset = (selection.extent.nodePosition as TextPosition).offset;
    final selectionStart = min(baseOffset, extentOffset);
    final selectionEnd = max(baseOffset, extentOffset);
    final selectionRange = SpanRange(selectionStart, selectionEnd - 1);

    final textNode =
        widget.document.getNodeById(selection.extent.nodeId) as TextNode;
    final text = textNode.text;

    final overlappingLinkAttributions = text.getAttributionSpansInRange(
      attributionFilter: (Attribution attribution) =>
          attribution is LinkAttribution,
      range: selectionRange,
    );

    if (overlappingLinkAttributions.length >= 2) {
      // Do nothing when multiple links are selected.
      return;
    }

    if (overlappingLinkAttributions.isNotEmpty) {
      // The selected text contains one other link.
      final overlappingLinkSpan = overlappingLinkAttributions.first;
      final isLinkSelectionOnTrailingEdge =
          (overlappingLinkSpan.start >= selectionRange.start &&
                  overlappingLinkSpan.start <= selectionRange.end) ||
              (overlappingLinkSpan.end >= selectionRange.start &&
                  overlappingLinkSpan.end <= selectionRange.end);

      if (isLinkSelectionOnTrailingEdge) {
        // The selected text covers the beginning, or the end, or the entire
        // existing link. Remove the link attribution from the selected text.
        text.removeAttribution(overlappingLinkSpan.attribution, selectionRange);
      } else {
        // The selected text sits somewhere within the existing link. Remove
        // the entire link attribution.
        text.removeAttribution(
          overlappingLinkSpan.attribution,
          overlappingLinkSpan.range,
        );
      }
      // Ensure the editor regains focus
      widget.editorFocusNode.requestFocus();
    } else {
      // There are no other links in the selection. Show the URL text field.
      setState(() {
        _showUrlField = true;
        _urlFocusNode.requestFocus();
      });
    }
  }

  /// Takes the text from the [urlController] and applies it as a link
  /// attribution to the currently selected text.
  void _applyLink() {
    //Reselect text that was selected before URL input shown
    if (!lastSelection!.isCollapsed) {
      widget.editor.execute([
        ChangeSelectionRequest(
          DocumentSelection(
            base: lastSelection!.base,
            extent: lastSelection!.extent,
          ),
          SelectionChangeType
              .expandSelection, // Ensures selection remains visible
          SelectionReason.userInteraction,
        ),
      ]);
    }
    final url = _urlController!.text.toPlainText(includePlaceholders: false);

    final selection = widget.composer.selection!;
    final baseOffset = (selection.base.nodePosition as TextPosition).offset;
    final extentOffset = (selection.extent.nodePosition as TextPosition).offset;
    final selectionStart = min(baseOffset, extentOffset);
    final selectionEnd = max(baseOffset, extentOffset);
    final selectionRange =
        TextRange(start: selectionStart, end: selectionEnd - 1);

    final textNode =
        widget.document.getNodeById(selection.extent.nodeId) as TextNode;
    final text = textNode.text;

    final trimmedRange = _trimTextRangeWhitespace(text, selectionRange);

    final linkAttribution = LinkAttribution.fromUri(Uri.parse(url));

    widget.editor.execute([
      AddTextAttributionsRequest(
        documentRange: DocumentRange(
          start: DocumentPosition(
            nodeId: textNode.id,
            nodePosition: TextNodePosition(offset: trimmedRange.start),
          ),
          end: DocumentPosition(
            nodeId: textNode.id,
            nodePosition: TextNodePosition(offset: trimmedRange.end),
          ),
        ),
        attributions: {linkAttribution},
      ),
    ]);

    // Clear the field and hide the URL bar
    _urlController!.clearTextAndSelection();
    setState(() {
      _showUrlField = false;
      _urlFocusNode.unfocus(
        disposition: UnfocusDisposition.previouslyFocusedChild,
      );
    });
  }

  /// Given [text] and a [range] within the [text], the [range] is
  /// shortened on both sides to remove any trailing whitespace and
  /// the new range is returned.
  SpanRange _trimTextRangeWhitespace(AttributedText text, TextRange range) {
    int startOffset = range.start;
    int endOffset = range.end;

    final plainText = text.toPlainText();
    while (startOffset < range.end && plainText[startOffset] == ' ') {
      startOffset += 1;
    }
    while (endOffset > startOffset && plainText[endOffset] == ' ') {
      endOffset -= 1;
    }

    // Add 1 to the end offset because SpanRange treats the end offset to be exclusive.
    return SpanRange(startOffset, endOffset + 1);
  }

  void _convertToHeader1() {
    final selectedNode =
        widget.document.getNodeById(widget.composer.selection!.extent.nodeId);

    widget.editor.execute([
      ChangeParagraphBlockTypeRequest(
        nodeId: selectedNode!.id,
        blockType: header1Attribution,
      ),
    ]);
    _restoreFocusAndSelection();
  }

  void _convertToHeader2() {
    final selectedNode =
        widget.document.getNodeById(widget.composer.selection!.extent.nodeId);

    widget.editor.execute([
      ChangeParagraphBlockTypeRequest(
        nodeId: selectedNode!.id,
        blockType: header2Attribution,
      ),
    ]);
    _restoreFocusAndSelection();
  }

  void _convertToParagraph() {
    widget.commonOps.convertToParagraph();
    _restoreFocusAndSelection();
  }
}

class SingleLineAttributedTextEditingController
    extends AttributedTextEditingController {
  SingleLineAttributedTextEditingController(this.onSubmit);

  final VoidCallback onSubmit;

  @override
  void insertNewline() {
    // Don't insert newline in a single-line text field.

    // Invoke callback to take action on enter.
    onSubmit();

    // TODO: this is a hack. SuperTextField shouldn't insert newlines in a single
    // line field (#697).
  }
}
