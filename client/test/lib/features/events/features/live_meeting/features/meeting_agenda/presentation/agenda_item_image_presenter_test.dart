import 'package:flutter_test/flutter_test.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/models/agenda_item_image_data.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/models/agenda_item_image_model.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/presentation/agenda_item_image_presenter.dart';
import 'package:mockito/mockito.dart';

import '../../../../../../../../mocked_classes.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final mockBuildContext = MockBuildContext();
  final mockView = MockAgendaItemImageView();
  final mockAgendaItemImageHelper = MockAgendaItemImageHelper();
  final mockAgendaProvider = MockAgendaProvider();
  final mockMediaHelperService = MockMediaHelperService();
  final mockEventPermissionsProvider = MockEventPermissionsProvider();
  final agendaItemImageData = AgendaItemImageData('title', 'url');

  late AgendaItemImageModel model;
  late AgendaItemImagePresenter presenter;

  setUp(() {
    model = AgendaItemImageModel(true, agendaItemImageData, (_) {});
    presenter = AgendaItemImagePresenter(
      mockBuildContext,
      mockView,
      model,
      agendaItemImageHelper: mockAgendaItemImageHelper,
      agendaProvider: mockAgendaProvider,
      mediaHelperService: mockMediaHelperService,
      eventPermissionsProvider: mockEventPermissionsProvider,
    );
  });

  tearDown(() {
    reset(mockBuildContext);
    reset(mockView);
    reset(mockAgendaItemImageHelper);
    reset(mockAgendaProvider);
    reset(mockMediaHelperService);
    reset(mockEventPermissionsProvider);
  });

  test('getImageUrl', () {
    expect(presenter.getImageUrl(), 'url');
  });

  test('updateImageUrl', () {
    presenter.updateImageUrl('  someUrl  ');

    expect(model.agendaItemImageData.url, 'someUrl');
    verify(mockView.updateView()).called(1);
    verify(mockAgendaItemImageHelper.updateParent(model)).called(1);
  });

  group('isValidImage', () {
    test('true', () {
      model.agendaItemImageData.url = 'url';
      expect(presenter.isValidImage(), isTrue);
    });

    test('false', () {
      model.agendaItemImageData.url = '';
      expect(presenter.isValidImage(), isFalse);
    });
  });
}
