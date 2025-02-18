import 'package:flutter_test/flutter_test.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/models/agenda_item_poll_data.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/models/agenda_item_poll_model.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/presentation/agenda_item_poll_presenter.dart';
import 'package:mockito/mockito.dart';

import '../../../../../../../../mocked_classes.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final MockBuildContext mockBuildContext = MockBuildContext();
  final MockAgendaItemPollView mockView = MockAgendaItemPollView();
  final MockAgendaItemPollHelper mockAgendaItemPollHelper =
      MockAgendaItemPollHelper();
  final MockAgendaProvider mockAgendaProvider = MockAgendaProvider();
  late AgendaItemPollData agendaItemPollData;

  late AgendaItemPollModel model;
  late AgendaItemPollPresenter presenter;

  setUp(() {
    agendaItemPollData = AgendaItemPollData('', []);
    model = AgendaItemPollModel(true, agendaItemPollData, (_) {});
    presenter = AgendaItemPollPresenter(
      mockView,
      model,
      agendaItemPollHelper: mockAgendaItemPollHelper,
    );
  });

  tearDown(() {
    reset(mockBuildContext);
    reset(mockView);
    reset(mockAgendaItemPollHelper);
    reset(mockAgendaProvider);
  });

  test('removeAnswer', () {
    model.agendaItemPollData.answers = ['answer1', 'answer2'];
    model.pollStateKey = 0;

    presenter.removeAnswer(0);

    expect(model.agendaItemPollData.answers.length, 1);
    expect(model.agendaItemPollData.answers[0], 'answer2');
    expect(model.pollStateKey, 1);
    verify(mockView.updateView()).called(1);
    verify(mockAgendaItemPollHelper.updateParent(model)).called(1);
  });

  test('updateAnswer', () {
    model.agendaItemPollData.answers = ['answer1', 'answer2'];
    model.pollStateKey = 0;

    presenter.updateAnswer('answer3', 0);

    expect(model.agendaItemPollData.answers.length, 2);
    expect(model.agendaItemPollData.answers[0], 'answer3');
    expect(model.agendaItemPollData.answers[1], 'answer2');
    expect(model.pollStateKey, 0);
    verify(mockView.updateView()).called(1);
    verify(mockAgendaItemPollHelper.updateParent(model)).called(1);
  });

  test('addAnswer', () {
    model.agendaItemPollData.answers = ['answer1', 'answer2'];
    model.pollStateKey = 0;

    presenter.addAnswer('answer3');

    expect(model.agendaItemPollData.answers.length, 3);
    expect(model.agendaItemPollData.answers[0], 'answer1');
    expect(model.agendaItemPollData.answers[1], 'answer2');
    expect(model.agendaItemPollData.answers[2], 'answer3');
    expect(model.pollStateKey, 0);
    verify(mockView.updateView()).called(1);
    verify(mockAgendaItemPollHelper.updateParent(model)).called(1);
  });

  test('updatePollQuestion', () {
    model.agendaItemPollData.question = 'abc123';

    presenter.updatePollQuestion('12abc34');

    expect(model.agendaItemPollData.question, '12abc34');
    expect(model.agendaItemPollData.answers.isEmpty, isTrue);
    expect(model.pollStateKey, 0);
    verify(mockView.updateView()).called(1);
    verify(mockAgendaItemPollHelper.updateParent(model)).called(1);
  });
}
