import 'package:flutter_test/flutter_test.dart';
import 'package:junto/app/junto/discussions/discussion_page/meeting_agenda/agenda_item_card/items/video/agenda_item_video_data.dart';
import 'package:junto/app/junto/discussions/discussion_page/meeting_agenda/agenda_item_card/items/video/agenda_item_video_model.dart';
import 'package:junto/app/junto/discussions/discussion_page/meeting_agenda/agenda_item_card/items/video/agenda_item_video_presenter.dart';
import 'package:junto/utils/extensions.dart';
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
