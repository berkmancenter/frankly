/// An unsaved change to one external integration's settings for an event.
///
/// Held by the event settings drawer and written when the drawer is saved.
class EventIntegrationChange {
  final bool enabled;
  final String externalReference;

  const EventIntegrationChange({
    required this.enabled,
    required this.externalReference,
  });

  @override
  bool operator ==(Object other) =>
      other is EventIntegrationChange &&
      other.enabled == enabled &&
      other.externalReference == externalReference;

  @override
  int get hashCode => Object.hash(enabled, externalReference);
}
