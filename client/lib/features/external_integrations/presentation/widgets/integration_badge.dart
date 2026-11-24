import 'package:client/core/widgets/proxied_image.dart';
import 'package:client/styles/styles.dart';
import 'package:data_models/external_integrations/external_integration.dart';
import 'package:flutter/material.dart';

/// Logo and name of an external integration.
class IntegrationBadge extends StatelessWidget {
  final ExternalIntegration integration;
  final double logoSize;
  final TextStyle? style;

  const IntegrationBadge({
    required this.integration,
    this.logoSize = 20,
    this.style,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final logoUrl = integration.logoUrl;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (logoUrl != null && logoUrl.isNotEmpty) ...[
          ProxiedImage(
            logoUrl,
            width: logoSize,
            height: logoSize,
            fit: BoxFit.contain,
            borderRadius: BorderRadius.circular(4),
          ),
          SizedBox(width: 6),
        ] else ...[
          Icon(Icons.link, size: logoSize),
          SizedBox(width: 6),
        ],
        Flexible(
          child: Text(
            integration.displayName,
            style: style ??
                context.theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
