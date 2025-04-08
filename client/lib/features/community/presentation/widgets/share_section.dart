import 'dart:math';

import 'package:client/core/utils/navigation_utils.dart';
import 'package:client/core/utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/custom_ink_well.dart';
import 'package:client/services.dart';
import 'package:client/styles/app_styles.dart';
import 'package:data_models/utils/share_type.dart';

class ShareSection extends StatefulWidget {
  final String url;
  final String? body;
  final String? subject;
  final bool wrapIcons;
  final double buttonPadding;
  final double? size;
  final double? iconSize;
  final Color iconColor;
  final Color? iconBackgroundColor;
  final void Function()? onItemTap;
  final void Function(ShareType type)? shareCallback;

  const ShareSection({
    Key? key,
    required this.url,
    this.body,
    this.subject,
    this.wrapIcons = true,
    this.buttonPadding = 10.0,
    this.size,
    this.iconSize,
    this.iconColor = context.theme.colorScheme.primary,
    this.iconBackgroundColor,
    this.onItemTap,
    this.shareCallback,
  }) : super(key: key);

  @override
  State<ShareSection> createState() => _ShareSectionState();
}

class _ShareSectionState extends State<ShareSection> {
  void _shareCallback(ShareType type) {
    final callback = widget.shareCallback;
    if (callback != null) {
      callback(type);
    }
  }

  String _withCacheBuster(String url) {
    final uri = Uri.parse(url);
    final rand = Random.secure().nextInt(999999);
    final newUri = uri.replace(
      queryParameters: {'b': rand.toString(), ...uri.queryParameters},
    );
    return newUri.toString();
  }

  void _tapFacebook() {
    final query =
        Uri(queryParameters: {'u': _withCacheBuster(widget.url)}).query;

    launch('http://www.facebook.com/share.php?$query');
    _shareCallback(ShareType.facebook);
  }

  void _tapTwitter() {
    final query = Uri(
      queryParameters: {
        'url': _withCacheBuster(widget.url),
        'text': widget.body,
      },
    ).query;

    launch('https://twitter.com/intent/tweet?$query');
    _shareCallback(ShareType.twitter);
  }

  void _tapLinkedIn() {
    final query =
        Uri(queryParameters: {'url': _withCacheBuster(widget.url)}).query;

    launch('https://www.linkedin.com/sharing/share-offsite/?$query');
    _shareCallback(ShareType.linkedin);
  }

  void _tapEmail() {
    final link = Uri(
      scheme: 'mailto',
      queryParameters: {
        'subject': widget.subject,
        'body': '${widget.body} ${_withCacheBuster(widget.url)}',
      },
    );

    launch(
      link.toString().replaceAll('+', '%20'),
      isWeb: false,
    );
    _shareCallback(ShareType.email);
  }

  void _tapLink() {
    Clipboard.setData(ClipboardData(text: _withCacheBuster(widget.url)));
    showRegularToast(context, 'Link Copied!', toastType: ToastType.success);
    _shareCallback(ShareType.link);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.wrapIcons) {
      return Wrap(
        children: _buildIconChildren(),
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _buildIconChildren(),
      );
    }
  }

  Widget _buildFAIcon(
    IconData icon, {
    required void Function() onTap,
  }) {
    final size =
        widget.size ?? responsiveLayoutService.getDynamicSize(context, 40.0);
    final iconSize = widget.iconSize ??
        responsiveLayoutService.getDynamicSize(context, 20.0);
    return Padding(
      padding: const EdgeInsets.all(2),
      child: CustomInkWell(
        onTap: () {
          onTap();
          if (widget.onItemTap != null) widget.onItemTap!();
        },
        boxShape: BoxShape.circle,
        child: AnimatedContainer(
          margin: EdgeInsets.all(widget.buttonPadding),
          height: size,
          width: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.iconBackgroundColor,
            border: Border.all(color: widget.iconColor),
          ),
          duration: kTabScrollDuration,
          child: Padding(
            padding: EdgeInsets.all(6.0),
            child: Icon(
              icon,
              color: widget.iconColor,
              size: iconSize,
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildIconChildren() {
    return [
      _buildFAIcon(FontAwesomeIcons.facebookF, onTap: _tapFacebook),
      _buildFAIcon(FontAwesomeIcons.twitter, onTap: _tapTwitter),
      _buildFAIcon(FontAwesomeIcons.linkedinIn, onTap: _tapLinkedIn),
      _buildFAIcon(FontAwesomeIcons.envelope, onTap: _tapEmail),
      _buildFAIcon(FontAwesomeIcons.link, onTap: _tapLink),
    ];
  }
}
