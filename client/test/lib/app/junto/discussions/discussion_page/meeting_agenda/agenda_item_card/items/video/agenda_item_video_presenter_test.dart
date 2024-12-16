import 'package:flutter_test/flutter_test.dart';
import 'package:junto/app/junto/discussions/discussion_page/meeting_agenda/agenda_item_card/items/video/agenda_item_video_data.dart';
import 'package:junto/app/junto/discussions/discussion_page/meeting_agenda/agenda_item_card/items/video/agenda_item_video_model.dart';
import 'package:junto/app/junto/discussions/discussion_page/meeting_agenda/agenda_item_card/items/video/agenda_item_video_presenter.dart';
import 'package:junto/utils/extensions.dart';
import 'package:mockito/mockito.dart';

import '../../../../../../../../../mocked_classes.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final mockContext = MockBuildContext();
  final mockView = MockAgendaItemVideoView();
  final mockAgendaItemVideoHelper = MockAgendaItemVideoHelper();
  final mockMediaHelperService = MockMediaHelperService();
  final mockJuntoProvider = MockJuntoProvider();

  late AgendaItemVideoData agendaItemVideoData;
  late AgendaItemVideoModel model;
  late AgendaItemVideoPresenter presenter;

  setUp(() {
    agendaItemVideoData = AgendaItemVideoData('title', AgendaItemVideoType.url, 'url');
    model = AgendaItemVideoModel(true, agendaItemVideoData, (_) {});
    presenter = AgendaItemVideoPresenter(
      mockContext,
      mockView,
      model,
      agendaItemVideoHelper: mockAgendaItemVideoHelper,
      mediaHelperService: mockMediaHelperService,
      juntoProvider: mockJuntoProvider,
    );
  });

  tearDown(() {
    reset(mockContext);
    reset(mockView);
    reset(mockAgendaItemVideoHelper);
    reset(mockMediaHelperService);
    reset(mockJuntoProvider);
  });

  test('updateVideoUrl', () {
    presenter.updateVideoUrl('  someUrl  ');

    expect(model.agendaItemVideoData.url, 'someUrl');
    verify(mockView.updateView()).called(1);
    verify(mockAgendaItemVideoHelper.updateParent(model)).called(1);
  });

  group('isValidVideo', () {
    test('true', () {
      model.agendaItemVideoData.url = 'url.mp4';
      expect(presenter.isValidVideo(), isTrue);
    });

    test('false', () {
      model.agendaItemVideoData.url = 'url.mp4.mp3';
      expect(presenter.isValidVideo(), isFalse);
    });
  });

  test('getVideoUrl', () {
    expect(presenter.getVideoUrl(), 'url');
  });
}
