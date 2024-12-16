import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/common_widgets/junto_stream_builder.dart';
import 'package:junto/services/firestore/firestore_utils.dart';
import 'package:junto/services/services.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto_models/firestore/junto.dart';

class FeaturedToggleButton extends StatefulWidget {
  final String? juntoId;
  final String label;
  final String? documentId;
  final String? documentPath;
  final FeaturedType? featuredType;
  final ListTileControlAffinity? controlAffinity;
  final BoxDecoration? decoration;
  final Color? textColor;

  const FeaturedToggleButton({
    required this.label,
    this.juntoId,
    this.documentId,
    this.documentPath,
    this.featuredType,
    this.controlAffinity,
    this.decoration,
    this.textColor,
  });

  @override
  _FeaturedToggleButtonState createState() => _FeaturedToggleButtonState();
}

class _FeaturedToggleButtonState extends State<FeaturedToggleButton> {
  BehaviorSubjectWrapper<List<Featured>>? _featuredStream;

  @override
  void dispose() {
    super.dispose();
    _featuredStream?.dispose();
  }

  Future<void> _changeFeatured({required bool isFeatured}) async {
    await firestoreDatabase.updateFeaturedItem(
      juntoId: widget.juntoId!,
      documentId: widget.documentId!,
      featured: Featured(
        documentPath: widget.documentPath,
        featuredType: widget.featuredType,
      ),
      isFeatured: isFeatured,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 12),
      child: JuntoStreamBuilder<List<Featured>>(
        entryFrom: '_FeaturedToggleButtonState.build',
        stream: _featuredStream ??= firestoreDatabase.getJuntoFeaturedItems(widget.juntoId!),
        showLoading: false,
        builder: (_, featuredItems) {
          return Tooltip(
            message: 'Featured Templates and Events will show up at the top of the Home page.',
            child: Container(
              decoration: widget.decoration ??
                  BoxDecoration(
                    color: AppColor.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
              child: FormBuilderSwitch(
                title: Text(
                  widget.label,
                  style: TextStyle(
                    color: widget.textColor ?? AppColor.darkBlue,
                    fontSize: 15,
                  ),
                ),
                controlAffinity: widget.controlAffinity ?? ListTileControlAffinity.trailing,
                name: 'featured',
                inactiveTrackColor: Colors.grey,
                activeColor: AppColor.white,
                activeTrackColor: Theme.of(context).colorScheme.secondary,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColor.darkBlue, width: 1),
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColor.darkBlue, width: 1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                initialValue: featuredItems == null
                    ? false
                    : featuredItems.any((f) => f.documentPath == widget.documentPath),
                onChanged: (featured) {
                  if (featured != null) {
                    alertOnError(context, () => _changeFeatured(isFeatured: featured));
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
