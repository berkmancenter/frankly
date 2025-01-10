import 'package:flutter_test/flutter_test.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/models/agenda_item_poll_data.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/models/agenda_item_poll_model.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/presentation/agenda_item_poll_presenter.dart';
import 'package:mockito/mockito.dart';

import '../../../../../../../../../mocked_classes.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final MockFunction mockFunction = MockFunction();
  final AgendaItemPollHelper helper = AgendaItemPollHelper();

  test('updateParent', () {
    final model = AgendaItemPollModel(
      true,
      AgendaItemPollData('', []),
      mockFunction.call1,
    );

    helper.updateParent(model);

    verify(mockFunction.call1(any)).called(1);
  });
}
