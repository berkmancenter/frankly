import 'dart:async';

import 'package:flutter/material.dart';
import 'package:junto/services/services.dart';
import 'package:junto_models/firestore/junto_tag_definition.dart';

/// holds logic for junto definition lookups
class FutureAndResult<T> {
  final Future<T?>? future;

  T? result;

  FutureAndResult(this.future) {
    _captureFutureResult();
  }

  Future<void> _captureFutureResult() async {
    result = await future;
  }
}

class TagDefinitionCache {
  /// Cache to hold previous lookups of tag definitions.
  final Map<String, FutureAndResult<JuntoTagDefinition>> _tagDefinitionFuture = {};

  // Returns the tag definition syncronously if it has been previously retrieved
  JuntoTagDefinition? getSync(String tagId) {
    return _tagDefinitionFuture[tagId]?.result;
  }

  Future<JuntoTagDefinition?>? getTag(String tagId) {
    var tagFuture = _tagDefinitionFuture[tagId]?.future;
    if (tagFuture == null) {
      tagFuture = firestoreTagService.getTagDefinition(tagId);
      _tagDefinitionFuture[tagId] = FutureAndResult(tagFuture);
    }
    return tagFuture;
  }
}

/// Creates a widget that fetches [JuntoTagDefinition]
///
/// the [builder] and [tagDefinitionId] parameters must not be null
class JuntoTagBuilder extends StatelessWidget {
  static final _tagDefinitionCache = TagDefinitionCache();

  final String tagDefinitionId;
  final Widget Function(BuildContext, bool, JuntoTagDefinition?) builder;

  const JuntoTagBuilder({required this.tagDefinitionId, required this.builder});

  @override
  Widget build(BuildContext context) {
    final tag = _tagDefinitionCache.getSync(tagDefinitionId);

    if (tag != null) {
      // If we already loaded this once then show it immediately without showing any loading indicator
      return builder(context, false, tag);
    }

    return FutureBuilder<JuntoTagDefinition?>(
      future: _tagDefinitionCache.getTag(tagDefinitionId),
      builder: (context, snapshot) {
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        return builder(context, isLoading, snapshot.data);
      },
    );
  }
}
