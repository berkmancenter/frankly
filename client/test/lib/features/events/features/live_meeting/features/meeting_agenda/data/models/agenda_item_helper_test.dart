import 'package:flutter_test/flutter_test.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/models/agenda_item_model.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/presentation/agenda_item_presenter.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/models/agenda_item_image_data.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/models/agenda_item_poll_data.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/models/agenda_item_text_data.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/models/agenda_item_user_suggestions_data.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/models/agenda_item_video_data.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/models/agenda_item_word_cloud_data.dart';
import 'package:data_models/events/event.dart';
import 'package:mockito/mockito.dart';

import '../../../../../../../../../mocked_classes.mocks.dart';

void main() {
  final MockMeetingGuideCardStore mockMeetingGuideCardStore =
      MockMeetingGuideCardStore();
  final MockAgendaProvider mockAgendaProvider = MockAgendaProvider();

  final AgendaItemHelper helper = AgendaItemHelper();

  tearDown(() {
    reset(mockMeetingGuideCardStore);
    reset(mockAgendaProvider);
  });

  group('isBrandNew', () {
    test('true', () {
      final model = AgendaItemModel(AgendaItem(id: ''));
      model.agendaItemTextData = AgendaItemTextData('', '');
      model.agendaItemVideoData =
          AgendaItemVideoData('', AgendaItemVideoType.url, '');
      model.agendaItemImageData = AgendaItemImageData('', '');
      model.agendaItemPollData = AgendaItemPollData('', []);
      model.agendaItemWordCloudData = AgendaItemWordCloudData('');
      model.agendaItemUserSuggestionsData = AgendaItemUserSuggestionsData('');

      expect(helper.isBrandNew(model), isTrue);
    });

    test('false, text', () {
      final model = AgendaItemModel(AgendaItem(id: ''));
      model.agendaItemTextData = AgendaItemTextData('', 'content');
      model.agendaItemVideoData =
          AgendaItemVideoData('', AgendaItemVideoType.url, '');
      model.agendaItemImageData = AgendaItemImageData('', '');
      model.agendaItemPollData = AgendaItemPollData('', []);
      model.agendaItemWordCloudData = AgendaItemWordCloudData('');
      model.agendaItemUserSuggestionsData = AgendaItemUserSuggestionsData('');

      expect(helper.isBrandNew(model), isFalse);
    });

    test('false, video', () {
      final model = AgendaItemModel(AgendaItem(id: ''));
      model.agendaItemTextData = AgendaItemTextData('', '');
      model.agendaItemVideoData =
          AgendaItemVideoData('', AgendaItemVideoType.url, 'video');
      model.agendaItemImageData = AgendaItemImageData('', '');
      model.agendaItemPollData = AgendaItemPollData('', []);
      model.agendaItemWordCloudData = AgendaItemWordCloudData('');
      model.agendaItemUserSuggestionsData = AgendaItemUserSuggestionsData('');

      expect(helper.isBrandNew(model), isFalse);
    });

    test('false, image', () {
      final model = AgendaItemModel(AgendaItem(id: ''));
      model.agendaItemTextData = AgendaItemTextData('', '');
      model.agendaItemVideoData =
          AgendaItemVideoData('', AgendaItemVideoType.url, '');
      model.agendaItemImageData = AgendaItemImageData('', 'image');
      model.agendaItemPollData = AgendaItemPollData('', []);
      model.agendaItemWordCloudData = AgendaItemWordCloudData('');
      model.agendaItemUserSuggestionsData = AgendaItemUserSuggestionsData('');

      expect(helper.isBrandNew(model), isFalse);
    });

    group('false, poll', () {
      test('question', () {
        final model = AgendaItemModel(AgendaItem(id: ''));
        model.agendaItemTextData = AgendaItemTextData('', '');
        model.agendaItemVideoData =
            AgendaItemVideoData('', AgendaItemVideoType.url, '');
        model.agendaItemImageData = AgendaItemImageData('', '');
        model.agendaItemPollData = AgendaItemPollData('question', []);
        model.agendaItemWordCloudData = AgendaItemWordCloudData('');
        model.agendaItemUserSuggestionsData = AgendaItemUserSuggestionsData('');

        expect(helper.isBrandNew(model), isFalse);
      });

      test('answer', () {
        final model = AgendaItemModel(AgendaItem(id: ''));
        model.agendaItemTextData = AgendaItemTextData('', '');
        model.agendaItemVideoData =
            AgendaItemVideoData('', AgendaItemVideoType.url, '');
        model.agendaItemImageData = AgendaItemImageData('', '');
        model.agendaItemPollData = AgendaItemPollData('', ['answer']);
        model.agendaItemWordCloudData = AgendaItemWordCloudData('');
        model.agendaItemUserSuggestionsData = AgendaItemUserSuggestionsData('');

        expect(helper.isBrandNew(model), isFalse);
      });

      test('both', () {
        final model = AgendaItemModel(AgendaItem(id: ''));
        model.agendaItemTextData = AgendaItemTextData('', '');
        model.agendaItemVideoData =
            AgendaItemVideoData('', AgendaItemVideoType.url, '');
        model.agendaItemImageData = AgendaItemImageData('', '');
        model.agendaItemPollData = AgendaItemPollData('question', ['answer']);
        model.agendaItemWordCloudData = AgendaItemWordCloudData('');
        model.agendaItemUserSuggestionsData = AgendaItemUserSuggestionsData('');

        expect(helper.isBrandNew(model), isFalse);
      });
    });

    test('false, word cloud', () {
      final model = AgendaItemModel(AgendaItem(id: ''));
      model.agendaItemTextData = AgendaItemTextData('', '');
      model.agendaItemVideoData =
          AgendaItemVideoData('', AgendaItemVideoType.url, '');
      model.agendaItemImageData = AgendaItemImageData('', '');
      model.agendaItemPollData = AgendaItemPollData('', []);
      model.agendaItemWordCloudData = AgendaItemWordCloudData('prompt');
      model.agendaItemUserSuggestionsData = AgendaItemUserSuggestionsData('');

      expect(helper.isBrandNew(model), isFalse);
    });

    test('false, suggestions', () {
      final model = AgendaItemModel(AgendaItem(id: ''));
      model.agendaItemTextData = AgendaItemTextData('', '');
      model.agendaItemVideoData =
          AgendaItemVideoData('', AgendaItemVideoType.url, '');
      model.agendaItemImageData = AgendaItemImageData('', '');
      model.agendaItemPollData = AgendaItemPollData('', []);
      model.agendaItemWordCloudData = AgendaItemWordCloudData('');
      model.agendaItemUserSuggestionsData =
          AgendaItemUserSuggestionsData('suggestion');

      expect(helper.isBrandNew(model), isFalse);
    });
  });

  group('isPlayingVideo', () {
    test('mockMeetingGuideCardModel is null', () {
      expect(helper.isPlayingVideo(null, mockAgendaProvider), isFalse);
    });

    test('playingVideo && inLiveMeeting', () {
      when(mockMeetingGuideCardStore.isPlayingVideo).thenReturn(true);
      when(mockAgendaProvider.inLiveMeeting).thenReturn(true);

      expect(
        helper.isPlayingVideo(mockMeetingGuideCardStore, mockAgendaProvider),
        isTrue,
      );
    });

    test('playingVideo && !inLiveMeeting', () {
      when(mockMeetingGuideCardStore.isPlayingVideo).thenReturn(true);
      when(mockAgendaProvider.inLiveMeeting).thenReturn(false);

      expect(
        helper.isPlayingVideo(mockMeetingGuideCardStore, mockAgendaProvider),
        isFalse,
      );
    });

    test('!playingVideo && inLiveMeeting', () {
      when(mockMeetingGuideCardStore.isPlayingVideo).thenReturn(false);
      when(mockAgendaProvider.inLiveMeeting).thenReturn(true);

      expect(
        helper.isPlayingVideo(mockMeetingGuideCardStore, mockAgendaProvider),
        isFalse,
      );
    });

    test('!playingVideo && !inLiveMeeting', () {
      when(mockMeetingGuideCardStore.isPlayingVideo).thenReturn(false);
      when(mockAgendaProvider.inLiveMeeting).thenReturn(false);

      expect(
        helper.isPlayingVideo(mockMeetingGuideCardStore, mockAgendaProvider),
        isFalse,
      );
    });
  });

  group('initialiseFields', () {
    test('regular', () {
      final answers = ['answer1', 'answer2'];
      final model = AgendaItemModel(
        AgendaItem(
          id: '',
          nullableType: AgendaItemType.image,
          title: 'title',
          content: 'content',
          videoUrl: 'videoUrl',
          imageUrl: 'imageUrl',
          pollAnswers: answers,
        ),
      );

      helper.initialiseFields(model);

      expect(model.agendaItemTextData.content, 'content');
      expect(model.agendaItemVideoData.url, 'videoUrl');
      expect(model.agendaItemImageData.url, 'imageUrl');
      expect(model.agendaItemPollData.question, 'content');
      expect(model.agendaItemPollData.answers, answers);
      expect(model.agendaItemWordCloudData.prompt, 'content');
    });

    test('nullables', () {
      final model = AgendaItemModel(AgendaItem(id: ''));

      helper.initialiseFields(model);

      expect(model.agendaItemTextData.content, '');
      expect(model.agendaItemVideoData.url, '');
      expect(model.agendaItemImageData.url, '');
      expect(model.agendaItemPollData.question, '');
      expect(model.agendaItemPollData.answers, []);
      expect(model.agendaItemWordCloudData.prompt, '');
    });
  });

  group('hasBeenEdited', () {
    group('timeInSeconds', () {
      test('true', () {
        final model = AgendaItemModel(
          AgendaItem(
            id: '',
            nullableType: AgendaItemType.text,
            title: '',
            content: '',
            timeInSeconds: 0,
          ),
        );
        model.timeInSeconds = 1;
        model.agendaItemTextData = AgendaItemTextData('', '');

        expect(helper.hasBeenEdited(model), isTrue);
      });

      test('false', () {
        final model = AgendaItemModel(
          AgendaItem(
            id: '',
            nullableType: AgendaItemType.text,
            title: '',
            content: '',
            timeInSeconds: 0,
          ),
        );
        model.timeInSeconds = 0;
        model.agendaItemTextData = AgendaItemTextData('', '');

        expect(helper.hasBeenEdited(model), isFalse);
      });
    });

    group('text', () {
      group('title', () {
        test('true', () {
          final model = AgendaItemModel(
            AgendaItem(
              id: '',
              nullableType: AgendaItemType.text,
              title: 'title',
              content: '',
            ),
          );
          model.agendaItemTextData = AgendaItemTextData('', '');

          expect(helper.hasBeenEdited(model), isTrue);
        });

        test('false', () {
          final model = AgendaItemModel(
            AgendaItem(
              id: '',
              nullableType: AgendaItemType.text,
              title: 'title',
              content: '',
            ),
          );
          model.agendaItemTextData = AgendaItemTextData('title', '');

          expect(helper.hasBeenEdited(model), isFalse);
        });
      });

      group('content', () {
        test('true', () {
          final model = AgendaItemModel(
            AgendaItem(
              id: '',
              nullableType: AgendaItemType.text,
              title: '',
              content: 'content',
            ),
          );
          model.agendaItemTextData = AgendaItemTextData('', '');

          expect(helper.hasBeenEdited(model), isTrue);
        });

        test('false', () {
          final model = AgendaItemModel(
            AgendaItem(
              id: '',
              nullableType: AgendaItemType.text,
              title: '',
              content: 'content',
            ),
          );
          model.agendaItemTextData = AgendaItemTextData('', 'content');

          expect(helper.hasBeenEdited(model), isFalse);
        });
      });
    });

    group('video', () {
      group('title', () {
        test('true', () {
          final model = AgendaItemModel(
            AgendaItem(
              id: '',
              nullableType: AgendaItemType.video,
              title: 'title',
              videoUrl: '',
            ),
          );
          model.agendaItemVideoData =
              AgendaItemVideoData('', AgendaItemVideoType.url, '');

          expect(helper.hasBeenEdited(model), isTrue);
        });

        test('false', () {
          final model = AgendaItemModel(
            AgendaItem(
              id: '',
              nullableType: AgendaItemType.video,
              title: 'title',
              videoUrl: '',
            ),
          );
          model.agendaItemVideoData =
              AgendaItemVideoData('title', AgendaItemVideoType.url, '');

          expect(helper.hasBeenEdited(model), isFalse);
        });
      });

      group('videoType', () {
        test('true', () {
          final model = AgendaItemModel(
            AgendaItem(
              id: '',
              nullableType: AgendaItemType.video,
              title: '',
              videoUrl: '',
            ),
          );
          model.agendaItemVideoData =
              AgendaItemVideoData('', AgendaItemVideoType.vimeo, '');

          expect(helper.hasBeenEdited(model), isTrue);
        });

        test('false', () {
          final model = AgendaItemModel(
            AgendaItem(
              id: '',
              nullableType: AgendaItemType.video,
              title: '',
              videoUrl: '',
            ),
          );
          model.agendaItemVideoData =
              AgendaItemVideoData('', AgendaItemVideoType.url, '');

          expect(helper.hasBeenEdited(model), isFalse);
        });
      });

      group('url', () {
        test('true', () {
          final model = AgendaItemModel(
            AgendaItem(
              id: '',
              nullableType: AgendaItemType.video,
              title: '',
              videoUrl: 'videoUrl',
            ),
          );
          model.agendaItemVideoData =
              AgendaItemVideoData('', AgendaItemVideoType.url, '');

          expect(helper.hasBeenEdited(model), isTrue);
        });

        test('false', () {
          final model = AgendaItemModel(
            AgendaItem(
              id: '',
              nullableType: AgendaItemType.video,
              title: '',
              videoUrl: 'videoUrl',
            ),
          );
          model.agendaItemVideoData =
              AgendaItemVideoData('', AgendaItemVideoType.url, 'videoUrl');

          expect(helper.hasBeenEdited(model), isFalse);
        });
      });
    });

    group('image', () {
      group('title', () {
        test('true', () {
          final model = AgendaItemModel(
            AgendaItem(
              id: '',
              nullableType: AgendaItemType.image,
              title: 'title',
              imageUrl: '',
            ),
          );
          model.agendaItemImageData = AgendaItemImageData('', '');

          expect(helper.hasBeenEdited(model), isTrue);
        });

        test('false', () {
          final model = AgendaItemModel(
            AgendaItem(
              id: '',
              nullableType: AgendaItemType.image,
              title: 'title',
              imageUrl: '',
            ),
          );
          model.agendaItemImageData = AgendaItemImageData('title', '');

          expect(helper.hasBeenEdited(model), isFalse);
        });
      });

      group('url', () {
        test('true', () {
          final model = AgendaItemModel(
            AgendaItem(
              id: '',
              nullableType: AgendaItemType.image,
              title: '',
              imageUrl: 'imageUrl',
            ),
          );
          model.agendaItemImageData = AgendaItemImageData('', '');

          expect(helper.hasBeenEdited(model), isTrue);
        });

        test('false', () {
          final model = AgendaItemModel(
            AgendaItem(
              id: '',
              nullableType: AgendaItemType.image,
              title: '',
              imageUrl: 'imageUrl',
            ),
          );
          model.agendaItemImageData = AgendaItemImageData('', 'imageUrl');

          expect(helper.hasBeenEdited(model), isFalse);
        });
      });
    });

    group('poll', () {
      group('question', () {
        test('true', () {
          final model = AgendaItemModel(
            AgendaItem(
              id: '',
              nullableType: AgendaItemType.poll,
              content: 'question',
              pollAnswers: [],
            ),
          );
          model.agendaItemPollData = AgendaItemPollData('', []);

          expect(helper.hasBeenEdited(model), isTrue);
        });

        test('false', () {
          final model = AgendaItemModel(
            AgendaItem(
              id: '',
              nullableType: AgendaItemType.poll,
              content: 'question',
              pollAnswers: [],
            ),
          );
          model.agendaItemPollData = AgendaItemPollData('question', []);

          expect(helper.hasBeenEdited(model), isFalse);
        });
      });

      group('answers', () {
        test('true', () {
          final model = AgendaItemModel(
            AgendaItem(
              id: '',
              nullableType: AgendaItemType.poll,
              content: '',
              pollAnswers: ['answer'],
            ),
          );
          model.agendaItemPollData = AgendaItemPollData('', []);

          expect(helper.hasBeenEdited(model), isTrue);
        });

        test('false', () {
          final model = AgendaItemModel(
            AgendaItem(
              id: '',
              nullableType: AgendaItemType.poll,
              content: '',
              pollAnswers: ['answer'],
            ),
          );
          model.agendaItemPollData = AgendaItemPollData('', ['answer']);

          expect(helper.hasBeenEdited(model), isFalse);
        });
      });
    });

    group('worldCloud', () {
      test('true', () {
        final model = AgendaItemModel(
          AgendaItem(
            id: '',
            nullableType: AgendaItemType.wordCloud,
            content: 'prompt',
          ),
        );
        model.agendaItemWordCloudData = AgendaItemWordCloudData('');

        expect(helper.hasBeenEdited(model), isTrue);
      });

      test('false', () {
        final model = AgendaItemModel(
          AgendaItem(
            id: '',
            nullableType: AgendaItemType.wordCloud,
            content: 'prompt',
          ),
        );
        model.agendaItemWordCloudData = AgendaItemWordCloudData('prompt');

        expect(helper.hasBeenEdited(model), isFalse);
      });
    });
  });

  group('areRequiredFieldsInput', () {
    group('text', () {
      test('input', () {
        final model = AgendaItemModel(
          AgendaItem(id: '', nullableType: AgendaItemType.text),
        );
        model.agendaItemTextData = AgendaItemTextData('title', 'content');

        final result = helper.areRequiredFieldsInput(model);

        expect(result, isNull);
      });

      group('not input', () {
        test('title', () {
          final model = AgendaItemModel(
            AgendaItem(id: '', nullableType: AgendaItemType.text),
          );
          model.agendaItemTextData = AgendaItemTextData('', 'content');

          final result = helper.areRequiredFieldsInput(model);

          expect(result, 'Title is required');
        });

        test('content', () {
          final model = AgendaItemModel(
            AgendaItem(id: '', nullableType: AgendaItemType.text),
          );
          model.agendaItemTextData = AgendaItemTextData('title', '');

          final result = helper.areRequiredFieldsInput(model);

          expect(result, 'Message is required');
        });
      });
    });

    group('video', () {
      test('input', () {
        final model = AgendaItemModel(
          AgendaItem(id: '', nullableType: AgendaItemType.video),
        );
        model.agendaItemVideoData =
            AgendaItemVideoData('title', AgendaItemVideoType.youtube, 'url');

        final result = helper.areRequiredFieldsInput(model);

        expect(result, isNull);
      });

      group('not input', () {
        test('title', () {
          final model = AgendaItemModel(
            AgendaItem(id: '', nullableType: AgendaItemType.video),
          );
          model.agendaItemVideoData =
              AgendaItemVideoData('', AgendaItemVideoType.url, 'url');

          final result = helper.areRequiredFieldsInput(model);

          expect(result, 'Title is required');
        });

        test('content', () {
          final model = AgendaItemModel(
            AgendaItem(id: '', nullableType: AgendaItemType.video),
          );
          model.agendaItemVideoData =
              AgendaItemVideoData('title', AgendaItemVideoType.url, '');

          final result = helper.areRequiredFieldsInput(model);

          expect(result, 'Video URL is required');
        });
      });
    });

    group('image', () {
      test('input', () {
        final model = AgendaItemModel(
          AgendaItem(id: '', nullableType: AgendaItemType.image),
        );
        model.agendaItemImageData = AgendaItemImageData('title', 'url');

        final result = helper.areRequiredFieldsInput(model);

        expect(result, isNull);
      });

      group('not input', () {
        test('title', () {
          final model = AgendaItemModel(
            AgendaItem(id: '', nullableType: AgendaItemType.image),
          );
          model.agendaItemImageData = AgendaItemImageData('', 'url');

          final result = helper.areRequiredFieldsInput(model);

          expect(result, 'Title is required');
        });

        test('url', () {
          final model = AgendaItemModel(
            AgendaItem(id: '', nullableType: AgendaItemType.image),
          );
          model.agendaItemImageData = AgendaItemImageData('title', '');

          final result = helper.areRequiredFieldsInput(model);

          expect(result, 'Image URL is required');
        });
      });
    });

    group('poll', () {
      test('input', () {
        final model = AgendaItemModel(
          AgendaItem(id: '', nullableType: AgendaItemType.poll),
        );
        model.agendaItemPollData = AgendaItemPollData('question', ['answer']);

        final result = helper.areRequiredFieldsInput(model);

        expect(result, isNull);
      });

      group('not input', () {
        test('question', () {
          final model = AgendaItemModel(
            AgendaItem(id: '', nullableType: AgendaItemType.poll),
          );
          model.agendaItemPollData = AgendaItemPollData('', ['answer']);

          final result = helper.areRequiredFieldsInput(model);

          expect(result, 'Question is required');
        });

        test('answers', () {
          final model = AgendaItemModel(
            AgendaItem(id: '', nullableType: AgendaItemType.poll),
          );
          model.agendaItemPollData = AgendaItemPollData('question', []);

          final result = helper.areRequiredFieldsInput(model);

          expect(result, 'Please add some answers');
        });
      });
    });

    group('word cloud', () {
      test('input', () {
        final model = AgendaItemModel(
          AgendaItem(id: '', nullableType: AgendaItemType.wordCloud),
        );
        model.agendaItemWordCloudData = AgendaItemWordCloudData('prompt');

        final result = helper.areRequiredFieldsInput(model);

        expect(result, isNull);
      });

      test('not input', () {
        final model = AgendaItemModel(
          AgendaItem(id: '', nullableType: AgendaItemType.wordCloud),
        );
        model.agendaItemWordCloudData = AgendaItemWordCloudData('');

        final result = helper.areRequiredFieldsInput(model);

        expect(result, 'Word Cloud prompt is required');
      });
    });
  });
}
