import 'package:flutter_test/flutter_test.dart';
import 'package:client/app/community/events/event_page/meeting_agenda/agenda_item_card/items/poll/agenda_item_poll_data.dart';
import 'package:client/app/community/events/event_page/meeting_agenda/agenda_item_card/items/poll/agenda_item_poll_model.dart';
import 'package:client/app/community/events/event_page/meeting_agenda/agenda_item_card/items/poll/agenda_item_poll_presenter.dart';
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
