import 'package:flutter_test/flutter_test.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/models/agenda_item_video_data.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/models/agenda_item_video_model.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/presentation/agenda_item_video_presenter.dart';
import 'package:client/core/utils/extensions.dart';
import 'package:mockito/mockito.dart';

import '../../../../../../../../../mocked_classes.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final MockFunction mockFunction = MockFunction();
  final AgendaItemVideoHelper helper = AgendaItemVideoHelper();

  test('updateParent', () {
    final model = AgendaItemVideoModel(
      true,
      AgendaItemVideoData('', AgendaItemVideoType.url, ''),
      mockFunction.call1,
    );

    helper.updateParent(model);

    verify(mockFunction.call1(any)).called(1);
  });
}
