const _kCommunityId = 'VALUE';
const _kTemplateId = 'VALUE';
const _kEventId = 'VALUE';

class ScaleTest {
  ScaleTest({
    required this.communityId,
    required this.templateId,
    required this.eventId,
  });

  final String communityId;
  final String templateId;
  final String eventId;
}

class ScaleTestService {
  ScaleTest getScaleTestInfo() {
    return ScaleTest(
      communityId: _kCommunityId,
      templateId: _kTemplateId,
      eventId: _kEventId,
    );
  }
}
