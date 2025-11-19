import 'package:client/config/environment.dart';
import 'package:flutter/material.dart';
import 'package:client/core/widgets/custom_text_field.dart';
import 'package:data_models/community/community.dart';
import 'package:client/core/localization/localization_helper.dart';
import 'package:flutter/services.dart';

class CreateCommunityTextFields extends StatefulWidget {
  final bool showChooseCustomDisplayId;
  final void Function(String) onNameChanged;
  final void Function(String) onCustomDisplayIdChanged;
  final void Function(String)? onTaglineChanged;
  final void Function(String)? onAboutChanged;
  final void Function(String)? onWebsiteUrlChanged;
  final void Function(String)? onEmailChanged;
  final void Function(String)? onFacebookUrlChanged;
  final void Function(String)? onLinkedinUrlChanged;
  final void Function(String)? onTwitterUrlChanged;
  final void Function(String)? onBlueskyUrlChanged;
  final FocusNode? nameFocus;
  final FocusNode? aboutFocus;
  final FocusNode? taglineFocus;
  final Community community;
  final bool compact;
  final bool showAllFields;
  final bool autoGenerateUrl;
  final BorderType borderType;
  const CreateCommunityTextFields({
    this.showChooseCustomDisplayId = false,
    Key? key,
    required this.onNameChanged,
    required this.onCustomDisplayIdChanged,
    this.onTaglineChanged,
    this.onAboutChanged,
    this.nameFocus,
    this.aboutFocus,
    this.taglineFocus,
    this.onWebsiteUrlChanged,
    this.onEmailChanged,
    this.onFacebookUrlChanged,
    this.onLinkedinUrlChanged,
    this.onTwitterUrlChanged,
    this.onBlueskyUrlChanged,
    required this.community,
    this.compact = false,
    this.showAllFields = false,
    this.autoGenerateUrl = true,
    this.borderType = BorderType.underline,
  }) : super(key: key);

  @override
  State<CreateCommunityTextFields> createState() =>
      _CreateCommunityTextFieldsState();
}

class _CreateCommunityTextFieldsState extends State<CreateCommunityTextFields> {
  final int titleMaxCharactersLength = 80;
  final int customIdMaxCharactersLength = 80;
  final int taglineMaxCharactersLength = 100;

  late final TextEditingController _nameController;
  late final TextEditingController _displayIdController;
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.community.name ?? '',
    );
    _displayIdController =
        TextEditingController(text: widget.community.displayId);
  }

  String _formatDisplayIdFromName(String displayId) {
    final String formattedDisplayId = displayId
        .replaceAll(RegExp(r'[^a-zA-Z0-9-_]'), '-')
        .replaceAll(RegExp(r'--+'), '-')
        .replaceAll(RegExp(r'-+$'), '-')
        .toLowerCase();
    return formattedDisplayId;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildCreateCommunityTextField(
          controller: _nameController,
          maxLength: titleMaxCharactersLength,
          label: context.l10n.communityName,
          borderType: widget.borderType,
          onChanged: (String val) => {
            widget.onNameChanged.call(val),
            if (widget.autoGenerateUrl)
              {
                widget.onCustomDisplayIdChanged
                    .call(_formatDisplayIdFromName(val)),
                setState(() {
                  // Update the displayId when the name changes
                  _displayIdController.text = _formatDisplayIdFromName(val);
                }),
              },
          },
          focus: widget.nameFocus,
          helperText:
              !widget.showAllFields ? context.l10n.youCanChangeThisLater : null,
          // Allow only alphanumeric characters, spaces
          formatterRegex: r'[\s?\w?]',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return context.l10n.enterValidName;
            }
            return null;
          },
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
        SizedBox(
          height: 15,
        ),
        _buildCreateCommunityTextField(
          controller: _displayIdController,
          maxLength: customIdMaxCharactersLength,
          label: context.l10n.communityUrl,
          borderType: widget.borderType,
          initialValue: _nameController.text,
          onChanged: widget.onCustomDisplayIdChanged,
          helperText: _displayIdController.text.isNotEmpty
              ? '${Environment.appUrl}/space/${_displayIdController.text}'
              : null,
          // Allow only numbers, lowercase letters, and dashes
          formatterRegex: '[0-9a-z-+]',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return context.l10n.enterValidCommunityUrl;
            }
              return null;
          },
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
        SizedBox(
          height: 15,
        ),
        if (widget.showAllFields)
          Column(
            children: [
              _buildCreateCommunityTextField(
                label: context.l10n.communityTagline,
                hint: context.l10n.taglineHint,
                borderType: widget.borderType,
                initialValue: widget.community.tagLine,
                onChanged: widget.onTaglineChanged,
                maxLength: taglineMaxCharactersLength,
                counterText:
                    '${widget.community.tagLine?.length}/$taglineMaxCharactersLength',
                focus: widget.taglineFocus,
              ),
              SizedBox(
                height: 15,
              ),
              _buildCreateCommunityTextField(
                hint: context.l10n.communityDescriptionHint,
                label: context.l10n.communityDescription,
                borderType: widget.borderType,
                initialValue: widget.community.description,
                onChanged: widget.onAboutChanged,
                focus: widget.aboutFocus,
                isOptional: true,
                maxLines: null,
                minLines: 3,
                keyboardType: TextInputType.multiline,
              ),
              SizedBox(height: 15),
              _buildCreateCommunityTextField(
                label: 'Website URL',
                hint: 'https://yourwebsite.com',
                borderType: widget.borderType,
                initialValue: widget.community.websiteUrl,
                onChanged: widget.onWebsiteUrlChanged,
                keyboardType: TextInputType.url,
                isOptional: true,
              ),
              SizedBox(height: 15),
              _buildCreateCommunityTextField(
                label: 'Email',
                hint: 'contact@yourdomain.com',
                borderType: widget.borderType,
                initialValue: widget.community.contactEmail,
                onChanged: widget.onEmailChanged,
                keyboardType: TextInputType.emailAddress,
                isOptional: true,
              ),
              SizedBox(height: 15),
              _buildCreateCommunityTextField(
                label: 'Facebook',
                hint: 'facebook.com/yourpage',
                borderType: widget.borderType,
                initialValue: widget.community.facebookUrl,
                onChanged: widget.onFacebookUrlChanged,
                keyboardType: TextInputType.url,
                isOptional: true,
              ),
              SizedBox(height: 15),
              _buildCreateCommunityTextField(
                label: 'LinkedIn',
                hint: 'linkedin.com/in/yourprofile',
                borderType: widget.borderType,
                initialValue: widget.community.linkedinUrl,
                onChanged: widget.onLinkedinUrlChanged,
                keyboardType: TextInputType.url,
                isOptional: true,
              ),
              SizedBox(height: 15),
              _buildCreateCommunityTextField(
                label: 'Twitter',
                hint: 'twitter.com/yourhandle',
                borderType: widget.borderType,
                initialValue: widget.community.twitterUrl,
                onChanged: widget.onTwitterUrlChanged,
                keyboardType: TextInputType.url,
                isOptional: true,
              ),
              SizedBox(height: 15),
              _buildCreateCommunityTextField(
                label: 'Bluesky',
                hint: 'bsky.app/profile/yourhandle',
                borderType: widget.borderType,
                initialValue: widget.community.blueskyUrl,
                onChanged: widget.onBlueskyUrlChanged,
                keyboardType: TextInputType.url,
                isOptional: true,
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildCreateCommunityTextField({
    required String label,
    required void Function(String)? onChanged,
    String? formatterRegex,
    TextEditingController? controller,
    String? hint,
    String? helperText,
    String? initialValue,
    String? counterText,
    int? maxLength,
    int? maxLines = 1,
    int minLines = 1,
    FocusNode? focus,
    bool isOptional = false,
    TextInputType keyboardType = TextInputType.text,
    BorderType borderType = BorderType.underline,
    String? Function(String?)? validator,
    AutovalidateMode? autovalidateMode = AutovalidateMode.disabled,
  }) =>
      Container(
        alignment: Alignment.topCenter,
        child: CustomTextField(
          controller: controller,
          borderType: borderType,
          counterAlignment: Alignment.topRight,
          focusNode: focus,
          maxLength: maxLength,
          maxLines: maxLines,
          minLines: minLines,
          counterText: counterText,
          padding: EdgeInsets.zero,
          labelText: label,
          hintText: hint,
          helperText: helperText,
          initialValue: initialValue,
          onChanged: onChanged,
          isOptional: isOptional,
          optionalPadding: const EdgeInsets.only(top: 12, right: 12),
          inputFormatters: formatterRegex == null
              ? null
              : FilteringTextInputFormatter.allow(RegExp(formatterRegex)),
          keyboardType: keyboardType,
          validator: validator,
          autovalidateMode: autovalidateMode,
        ),
      );
}
