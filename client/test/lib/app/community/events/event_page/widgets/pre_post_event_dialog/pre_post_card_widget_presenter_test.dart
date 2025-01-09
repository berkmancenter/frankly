import 'package:flutter_test/flutter_test.dart';
import 'package:client/features/events/features/event_page/data/models/pre_post_card_widget_model.dart';
import 'package:client/features/events/features/event_page/presentation/views/pre_post_card_widget_page.dart';
import 'package:client/features/events/features/event_page/presentation/pre_post_card_widget_presenter.dart';
import 'package:data_models/events/pre_post_card.dart';
import 'package:data_models/events/pre_post_card_attribute.dart';
import 'package:data_models/events/pre_post_url_params.dart';
import 'package:mockito/mockito.dart';

import '../../../../../../../mocked_classes.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final MockBuildContext mockBuildContext = MockBuildContext();
  final MockPrePostCardWidgetView mockView = MockPrePostCardWidgetView();
  final MockCloudFunctionsCommunityService mockCloudFunctionsService =
      MockCloudFunctionsCommunityService();
  final MockPrePostCardWidgetPresenterHelper mockHelper =
      MockPrePostCardWidgetPresenterHelper();
  final MockUserService mockUserService = MockUserService();
  final MockEvent mockEvent = MockEvent();
  late PrePostCardWidgetModel model = PrePostCardWidgetModel(
    PrePostCardType.preEvent,
    mockEvent,
    false,
    null,
  );
  late PrePostCardWidgetPresenter presenter;

  setUp(() {
    model = PrePostCardWidgetModel(
      PrePostCardType.preEvent,
      mockEvent,
      false,
      null,
    );
    presenter = PrePostCardWidgetPresenter(
      mockBuildContext,
      mockView,
      model,
      prePostCardWidgetPresenterHelper: mockHelper,
      testCloudFunctionsService: mockCloudFunctionsService,
      userService: mockUserService,
    );
  });

  tearDown(() {
    reset(mockBuildContext);
    reset(mockView);
    reset(mockEvent);
    reset(mockHelper);
    reset(mockCloudFunctionsService);
    reset(mockUserService);
  });

  group('validateHeadline', () {
    test('text is null', () {
      expect(presenter.validateHeadline(null), 'Headline cannot be empty');
    });

    test('text is empty', () {
      expect(presenter.validateHeadline(''), 'Headline cannot be empty');
      expect(presenter.validateHeadline('      '), 'Headline cannot be empty');
    });

    test('other cases', () {
      expect(presenter.validateHeadline('text'), isNull);
      expect(presenter.validateHeadline(' text'), isNull);
      expect(presenter.validateHeadline(' text '), isNull);
      expect(presenter.validateHeadline('text '), isNull);
      expect(presenter.validateHeadline('text text'), isNull);
    });
  });

  group('validateMessage', () {
    test('text is null', () {
      expect(presenter.validateMessage(null), 'Message cannot be empty');
    });

    test('text is empty', () {
      expect(presenter.validateMessage(''), 'Message cannot be empty');
      expect(presenter.validateMessage('      '), 'Message cannot be empty');
    });

    test('other cases', () {
      expect(presenter.validateMessage('text'), isNull);
      expect(presenter.validateMessage(' text'), isNull);
      expect(presenter.validateMessage(' text '), isNull);
      expect(presenter.validateMessage('text '), isNull);
      expect(presenter.validateMessage('text text'), isNull);
    });
  });

  group('validateButtonText', () {
    group('surveyUrl is null', () {
      final prePostCard = PrePostCard(
        type: PrePostCardType.preEvent,
        headline: 'headline',
        message: 'message',
        prePostUrls: [
          PrePostUrlParams(buttonText: 'buttonText', attributes: []),
        ],
      );

      test('text is null', () {
        model.prePostCard = prePostCard;

        expect(presenter.validateButtonText(null, 0), isNull);
      });

      test('text is empty', () {
        model.prePostCard = prePostCard;

        expect(presenter.validateButtonText('', 0), isNull);
        expect(presenter.validateButtonText('      ', 0), isNull);
      });

      test('other cases', () {
        model.prePostCard = prePostCard;

        expect(presenter.validateButtonText('text', 0), isNull);
        expect(presenter.validateButtonText(' text', 0), isNull);
        expect(presenter.validateButtonText(' text ', 0), isNull);
        expect(presenter.validateButtonText('text ', 0), isNull);
        expect(presenter.validateButtonText('text text', 0), isNull);
      });
    });

    group('surveyUrl is not null', () {
      final prePostCard = PrePostCard(
        type: PrePostCardType.preEvent,
        headline: 'headline',
        message: 'message',
        prePostUrls: [PrePostUrlParams(surveyUrl: 'surveyUrl', attributes: [])],
      );

      test('text is null', () {
        model.prePostCard = prePostCard;

        expect(
          presenter.validateButtonText(null, 0),
          'Button text cannot be empty',
        );
      });

      test('text is empty', () {
        model.prePostCard = prePostCard;

        expect(
          presenter.validateButtonText('', 0),
          'Button text cannot be empty',
        );
        expect(
          presenter.validateButtonText('      ', 0),
          'Button text cannot be empty',
        );
      });

      test('other cases', () {
        model.prePostCard = prePostCard;

        expect(presenter.validateButtonText('text', 0), isNull);
        expect(presenter.validateButtonText(' text', 0), isNull);
        expect(presenter.validateButtonText(' text ', 0), isNull);
        expect(presenter.validateButtonText('text ', 0), isNull);
        expect(presenter.validateButtonText('text text', 0), isNull);
      });
    });
  });

  group('validateUrl', () {
    test('survey URL does not exist and additional attributes are added', () {
      final prePostCard = PrePostCard(
        type: PrePostCardType.preEvent,
        headline: 'headline',
        message: 'message',
        prePostUrls: [
          PrePostUrlParams(
            buttonText: 'buttonText',
            attributes: [
              PrePostCardAttribute(
                type: PrePostCardAttributeType.email,
                queryParam: 'email',
              ),
            ],
          ),
        ],
      );

      model.prePostCard = prePostCard;

      expect(
        presenter.validateUrl(null, 0),
        'URL cannot be empty if some attributes are entered',
      );
      expect(
        presenter.validateUrl('', 0),
        'URL cannot be empty if some attributes are entered',
      );
    });

    group('buttonText is null', () {
      final prePostCard = PrePostCard(
        type: PrePostCardType.preEvent,
        headline: 'headline',
        message: 'message',
        prePostUrls: [PrePostUrlParams(surveyUrl: 'surveyUrl', attributes: [])],
      );

      test('text is null', () {
        model.prePostCard = prePostCard;

        expect(presenter.validateUrl(null, 0), isNull);
      });

      test('text is empty', () {
        model.prePostCard = prePostCard;

        expect(presenter.validateUrl('', 0), isNull);
        expect(presenter.validateUrl('      ', 0), isNull);
      });

      test('other cases', () {
        model.prePostCard = prePostCard;

        expect(presenter.validateUrl('1', 0), isNull);
        expect(presenter.validateUrl(' http', 0), isNull);
        expect(presenter.validateUrl(' https ', 0), isNull);
        expect(presenter.validateUrl('https://google.com ', 0), isNull);
        expect(presenter.validateUrl('<tag>text</tag>', 0), isNull);
      });
    });

    group('buttonText is not null', () {
      final prePostCard = PrePostCard(
        type: PrePostCardType.preEvent,
        headline: 'headline',
        message: 'message',
        prePostUrls: [
          PrePostUrlParams(
            buttonText: 'buttonText',
            surveyUrl: 'surveyUrl',
            attributes: [],
          ),
        ],
      );

      test('text is null', () {
        model.prePostCard = prePostCard;

        expect(presenter.validateUrl(null, 0), 'URL is not valid');
      });

      test('text is empty', () {
        model.prePostCard = prePostCard;

        expect(presenter.validateUrl('', 0), 'URL is not valid');
        expect(presenter.validateUrl('      ', 0), 'URL is not valid');
      });

      test('other cases', () {
        model.prePostCard = prePostCard;

        expect(presenter.validateUrl('1', 0), isNull);
        expect(presenter.validateUrl(' http', 0), isNull);
        expect(presenter.validateUrl(' https ', 0), isNull);
        expect(presenter.validateUrl('https://google.com ', 0), isNull);
        expect(presenter.validateUrl('<tag>text</tag>', 0), isNull);
      });
    });
  });

  group('getAvailableAttributeTypes', () {
    test('0/3 selected, 3 retrieved', () {
      expect(presenter.getAvailableAttributeTypes([]), [
        PrePostCardAttributeType.userId,
        PrePostCardAttributeType.eventId,
        PrePostCardAttributeType.email,
      ]);
    });

    test('1/3 selected, 2 retrieved', () {
      final selectedAttributes = [
        PrePostCardAttribute(
          type: PrePostCardAttributeType.userId,
          queryParam: '',
        ),
      ];

      expect(presenter.getAvailableAttributeTypes(selectedAttributes), [
        PrePostCardAttributeType.eventId,
        PrePostCardAttributeType.email,
      ]);
    });

    test('2/3 selected, 1 retrieved', () {
      final selectedAttributes = [
        PrePostCardAttribute(
          type: PrePostCardAttributeType.userId,
          queryParam: '',
        ),
        PrePostCardAttribute(
          type: PrePostCardAttributeType.eventId,
          queryParam: '',
        ),
      ];

      expect(
        presenter.getAvailableAttributeTypes(selectedAttributes),
        [PrePostCardAttributeType.email],
      );
    });

    test('3/3 selected, 0 retrieved', () {
      final selectedAttributes = [
        PrePostCardAttribute(
          type: PrePostCardAttributeType.userId,
          queryParam: '',
        ),
        PrePostCardAttribute(
          type: PrePostCardAttributeType.eventId,
          queryParam: '',
        ),
        PrePostCardAttribute(
          type: PrePostCardAttributeType.email,
          queryParam: '',
        ),
      ];

      expect(presenter.getAvailableAttributeTypes(selectedAttributes), []);
    });
  });

  group('isEditIconShown', () {
    test('isEditable and type is overview', () {
      model.isEditable = true;
      model.prePostCardWidgetType = PrePostCardWidgetType.overview;

      expect(presenter.isEditIconShown(), isTrue);
    });

    test('isEditable and type is not overview', () {
      model.isEditable = true;
      model.prePostCardWidgetType = PrePostCardWidgetType.edit;

      expect(presenter.isEditIconShown(), isFalse);
    });

    test('not isEditable and type is overview', () {
      model.isEditable = false;
      model.prePostCardWidgetType = PrePostCardWidgetType.overview;

      expect(presenter.isEditIconShown(), isFalse);
    });

    test('not isEditable and type is not overview', () {
      model.isEditable = false;
      model.prePostCardWidgetType = PrePostCardWidgetType.edit;

      expect(presenter.isEditIconShown(), isFalse);
    });
  });

  group('addNewURLParamRow', () {
    test(
        'something went wrong, no available attributes after clicking to add new row',
        () {
      final prePostCard = PrePostCard(
        type: PrePostCardType.preEvent,
        headline: 'headline',
        message: 'message',
        prePostUrls: [
          PrePostUrlParams(
            attributes: [
              PrePostCardAttribute(
                type: PrePostCardAttributeType.userId,
                queryParam: '',
              ),
              PrePostCardAttribute(
                type: PrePostCardAttributeType.eventId,
                queryParam: '',
              ),
              PrePostCardAttribute(
                type: PrePostCardAttributeType.email,
                queryParam: '',
              ),
            ],
          ),
        ],
      );
      model.prePostCard = prePostCard;

      presenter.addNewURLParamRow(0);

      expect(model.prePostCard.toJson(), prePostCard.toJson());
      verifyNever(mockView.updateView());
    });

    group('adding next available attribute type as new row default', () {
      test('very first time', () {
        final prePostCard = PrePostCard(
          type: PrePostCardType.preEvent,
          headline: 'headline',
          message: 'message',
          prePostUrls: [PrePostUrlParams(attributes: [])],
        );
        model.prePostCard = prePostCard;

        presenter.addNewURLParamRow(0);

        expect(
          model.prePostCard.toJson(),
          PrePostCard(
            type: PrePostCardType.preEvent,
            headline: 'headline',
            message: 'message',
            prePostUrls: [
              PrePostUrlParams(
                attributes: [
                  PrePostCardAttribute(
                    type: PrePostCardAttributeType.userId,
                    queryParam: '',
                  ),
                ],
              ),
            ],
          ).toJson(),
        );
        verify(mockView.updateView()).called(1);
      });

      test('very last time', () {
        final prePostCard = PrePostCard(
          type: PrePostCardType.preEvent,
          headline: 'headline',
          message: 'message',
          prePostUrls: [
            PrePostUrlParams(
              attributes: [
                PrePostCardAttribute(
                  type: PrePostCardAttributeType.userId,
                  queryParam: '',
                ),
                PrePostCardAttribute(
                  type: PrePostCardAttributeType.eventId,
                  queryParam: '',
                ),
              ],
            ),
          ],
        );
        model.prePostCard = prePostCard;

        presenter.addNewURLParamRow(0);

        expect(
          model.prePostCard.toJson(),
          PrePostCard(
            type: PrePostCardType.preEvent,
            headline: 'headline',
            message: 'message',
            prePostUrls: [
              PrePostUrlParams(
                attributes: [
                  PrePostCardAttribute(
                    type: PrePostCardAttributeType.userId,
                    queryParam: '',
                  ),
                  PrePostCardAttribute(
                    type: PrePostCardAttributeType.eventId,
                    queryParam: '',
                  ),
                  PrePostCardAttribute(
                    type: PrePostCardAttributeType.email,
                    queryParam: '',
                  ),
                ],
              ),
            ],
          ).toJson(),
        );
        verify(mockView.updateView()).called(1);
      });
    });
  });

  test('launchUrl', () async {
    final mockPrePostCard = MockPrePostCard();
    final mockEvent = MockEvent();
    final mockPrePostUrlParams = MockPrePostUrlParams();
    when(mockUserService.currentUserId).thenReturn('userId');
    model.prePostCard = mockPrePostCard;
    model.event = mockEvent;
    model.email = 'email';
    when(
      mockPrePostCard.getFinalisedUrl(
        userId: 'userId',
        event: mockEvent,
        email: 'email',
        urlInfo: mockPrePostUrlParams,
      ),
    ).thenReturn('url');

    await presenter.launchUrl(mockPrePostUrlParams);

    verify(mockHelper.launchUrlFromUtils('url')).called(1);
  });

  test('updateCard', () {
    final prePostCard = PrePostCard(
      type: PrePostCardType.preEvent,
      headline: 'headline',
      message: 'message',
      prePostUrls: [
        PrePostUrlParams(
          attributes: [
            PrePostCardAttribute(
              type: PrePostCardAttributeType.userId,
              queryParam: 'userId',
            ),
            PrePostCardAttribute(
              type: PrePostCardAttributeType.eventId,
              queryParam: '',
            ),
            PrePostCardAttribute(
              type: PrePostCardAttributeType.email,
              queryParam: 'email',
            ),
          ],
        ),
      ],
    );
    model.prePostCard = prePostCard;
    model.prePostCardWidgetType = PrePostCardWidgetType.edit;

    presenter.updateCard(0);

    expect(
      model.prePostCard.toJson(),
      PrePostCard(
        type: PrePostCardType.preEvent,
        headline: 'headline',
        message: 'message',
        prePostUrls: [
          PrePostUrlParams(
            attributes: [
              PrePostCardAttribute(
                type: PrePostCardAttributeType.userId,
                queryParam: 'userId',
              ),
              PrePostCardAttribute(
                type: PrePostCardAttributeType.email,
                queryParam: 'email',
              ),
            ],
          ),
        ],
      ).toJson(),
    );
    expect(model.prePostCardWidgetType, PrePostCardWidgetType.overview);
    verify(mockView.updateView()).called(1);
  });

  group('updateAttributeTypeSelection', () {
    test('selectedType is null', () {
      final prePostCard = PrePostCard(
        type: PrePostCardType.preEvent,
        headline: 'headline',
        message: 'message',
        prePostUrls: [
          PrePostUrlParams(
            attributes: [
              PrePostCardAttribute(
                type: PrePostCardAttributeType.email,
                queryParam: 'email',
              ),
            ],
          ),
        ],
      );
      model.prePostCard = prePostCard;

      presenter.updateAttributeTypeSelection(null, 0, 0);

      expect(model.prePostCard.toJson(), prePostCard.toJson());
      verifyNever(mockView.updateView());
    });
    test('selectedType is not null', () {
      final prePostCard = PrePostCard(
        type: PrePostCardType.preEvent,
        headline: 'headline',
        message: 'message',
        prePostUrls: [
          PrePostUrlParams(
            attributes: [
              PrePostCardAttribute(
                type: PrePostCardAttributeType.userId,
                queryParam: 'userId',
              ),
              PrePostCardAttribute(
                type: PrePostCardAttributeType.eventId,
                queryParam: 'email',
              ),
            ],
          ),
        ],
      );
      model.prePostCard = prePostCard;

      presenter.updateAttributeTypeSelection(
        PrePostCardAttributeType.email,
        0,
        1,
      );

      expect(
        model.prePostCard.toJson(),
        PrePostCard(
          type: PrePostCardType.preEvent,
          headline: 'headline',
          message: 'message',
          prePostUrls: [
            PrePostUrlParams(
              attributes: [
                PrePostCardAttribute(
                  type: PrePostCardAttributeType.userId,
                  queryParam: 'userId',
                ),
                PrePostCardAttribute(
                  type: PrePostCardAttributeType.email,
                  queryParam: 'email',
                ),
              ],
            ),
          ],
        ).toJson(),
      );
      verify(mockView.updateView()).called(1);
    });
  });

  test('updateEnteredQueryName', () {
    final prePostCard = PrePostCard(
      type: PrePostCardType.preEvent,
      headline: 'headline',
      message: 'message',
      prePostUrls: [
        PrePostUrlParams(
          attributes: [
            PrePostCardAttribute(
              type: PrePostCardAttributeType.userId,
              queryParam: 'userId',
            ),
            PrePostCardAttribute(
              type: PrePostCardAttributeType.email,
              queryParam: 'email',
            ),
          ],
        ),
      ],
    );
    model.prePostCard = prePostCard;

    presenter.updateEnteredQueryName(
      0,
      0,
      PrePostCardAttribute(
        type: PrePostCardAttributeType.userId,
        queryParam: 'userId',
      ),
      'newUserId',
    );

    expect(
      model.prePostCard.toJson(),
      PrePostCard(
        type: PrePostCardType.preEvent,
        headline: 'headline',
        message: 'message',
        prePostUrls: [
          PrePostUrlParams(
            attributes: [
              PrePostCardAttribute(
                type: PrePostCardAttributeType.userId,
                queryParam: 'newUserId',
              ),
              PrePostCardAttribute(
                type: PrePostCardAttributeType.email,
                queryParam: 'email',
              ),
            ],
          ),
        ],
      ).toJson(),
    );
    verify(mockView.updateView()).called(1);
  });

  group('updateEnteredUrl', () {
    test('text is empty', () {
      final prePostCard = PrePostCard(
        type: PrePostCardType.preEvent,
        headline: 'headline',
        message: 'message',
        prePostUrls: [PrePostUrlParams(surveyUrl: 'surveyUrl')],
      );
      model.prePostCard = prePostCard;

      presenter.updateEnteredUrl('', 0);

      expect(
        model.prePostCard.toJson(),
        PrePostCard(
          type: PrePostCardType.preEvent,
          headline: 'headline',
          message: 'message',
          prePostUrls: [PrePostUrlParams(surveyUrl: null)],
        ).toJson(),
      );
      verify(mockView.updateView()).called(1);
    });

    test('text is not empty', () {
      final prePostCard = PrePostCard(
        type: PrePostCardType.preEvent,
        headline: 'headline',
        message: 'message',
        prePostUrls: [PrePostUrlParams(surveyUrl: 'surveyUrl')],
      );
      model.prePostCard = prePostCard;

      presenter.updateEnteredUrl('new surveyUrl', 0);

      expect(
        model.prePostCard.toJson(),
        PrePostCard(
          type: PrePostCardType.preEvent,
          headline: 'headline',
          message: 'message',
          prePostUrls: [PrePostUrlParams(surveyUrl: 'new surveyUrl')],
        ).toJson(),
      );
      verify(mockView.updateView()).called(1);
    });
  });

  group('updateEnteredButtonText', () {
    test('text is empty', () {
      final prePostCard = PrePostCard(
        type: PrePostCardType.preEvent,
        headline: 'headline',
        message: 'message',
        prePostUrls: [PrePostUrlParams(buttonText: 'buttonText')],
      );
      model.prePostCard = prePostCard;

      presenter.updateEnteredButtonText(0, '');

      expect(
        model.prePostCard.toJson(),
        PrePostCard(
          type: PrePostCardType.preEvent,
          headline: 'headline',
          message: 'message',
          prePostUrls: [PrePostUrlParams(buttonText: null)],
        ).toJson(),
      );
      verify(mockView.updateView());
    });

    test('text is not empty', () {
      final prePostCard = PrePostCard(
        type: PrePostCardType.preEvent,
        headline: 'headline',
        message: 'message',
        prePostUrls: [PrePostUrlParams(buttonText: 'buttonText')],
      );
      model.prePostCard = prePostCard;

      presenter.updateEnteredButtonText(0, 'new buttonText');

      expect(
        model.prePostCard.toJson(),
        PrePostCard(
          type: PrePostCardType.preEvent,
          headline: 'headline',
          message: 'message',
          prePostUrls: [PrePostUrlParams(buttonText: 'new buttonText')],
        ).toJson(),
      );
      verify(mockView.updateView());
    });
  });

  test('updateEnteredMessage', () {
    final prePostCard = PrePostCard(
      type: PrePostCardType.preEvent,
      headline: 'headline',
      message: 'message',
      prePostUrls: [],
    );
    model.prePostCard = prePostCard;

    presenter.updateEnteredMessage('new message');

    expect(
      model.prePostCard.toJson(),
      PrePostCard(
        type: PrePostCardType.preEvent,
        headline: 'headline',
        message: 'new message',
        prePostUrls: [],
      ).toJson(),
    );
    verify(mockView.updateView());
  });

  test('updateEnteredHeadline', () {
    final prePostCard = PrePostCard(
      type: PrePostCardType.preEvent,
      headline: 'headline',
      message: 'message',
      prePostUrls: [],
    );
    model.prePostCard = prePostCard;

    presenter.updateEnteredHeadline('new headline');

    expect(
      model.prePostCard.toJson(),
      PrePostCard(
        type: PrePostCardType.preEvent,
        headline: 'new headline',
        message: 'message',
        prePostUrls: [],
      ).toJson(),
    );
    verify(mockView.updateView());
  });

  group('toggleExpansion', () {
    test('expand', () {
      model.isExpanded = false;

      presenter.toggleExpansion();

      expect(model.isExpanded, isTrue);
    });

    test('collapse', () {
      model.isExpanded = true;

      presenter.toggleExpansion();

      expect(model.isExpanded, isFalse);
    });
  });

  group('updateCardType', () {
    test('change to overview', () {
      model.prePostCardWidgetType = PrePostCardWidgetType.edit;

      presenter.toggleCardType();

      expect(model.prePostCardWidgetType, PrePostCardWidgetType.overview);
      verify(mockView.updateView()).called(1);
    });

    test('change to edit', () {
      model.prePostCardWidgetType = PrePostCardWidgetType.overview;

      presenter.toggleCardType();

      expect(model.prePostCardWidgetType, PrePostCardWidgetType.edit);
      verify(mockView.updateView()).called(1);
    });
  });

  test('getInnerAvailableAttributeTypes', () {
    final attributeTypes = [
      PrePostCardAttributeType.eventId,
      PrePostCardAttributeType.email,
    ];
    const type = PrePostCardAttributeType.userId;

    expect(presenter.getInnerAvailableAttributeTypes(attributeTypes, type), [
      PrePostCardAttributeType.eventId,
      PrePostCardAttributeType.email,
      PrePostCardAttributeType.userId,
    ]);
  });

  test('initProfile', () async {
    model.email = null;
    when(mockHelper.getEmail(mockUserService, mockCloudFunctionsService))
        .thenAnswer(
      (_) async => 'email',
    );

    await presenter.initProfile();

    expect(model.email, 'email');
    verify(mockView.updateView()).called(1);
  });

  test('deleteQueryParamRow', () {
    final prePostCard = PrePostCard(
      type: PrePostCardType.preEvent,
      headline: 'headline',
      message: 'message',
      prePostUrls: [
        PrePostUrlParams(
          attributes: [
            PrePostCardAttribute(
              type: PrePostCardAttributeType.userId,
              queryParam: 'userId',
            ),
            PrePostCardAttribute(
              type: PrePostCardAttributeType.eventId,
              queryParam: 'eventId',
            ),
            PrePostCardAttribute(
              type: PrePostCardAttributeType.email,
              queryParam: 'email',
            ),
          ],
        ),
      ],
    );
    model.prePostCard = prePostCard;

    presenter.deleteQueryParamRow(0, 1);

    expect(
      model.prePostCard.toJson(),
      PrePostCard(
        type: PrePostCardType.preEvent,
        headline: 'headline',
        message: 'message',
        prePostUrls: [
          PrePostUrlParams(
            attributes: [
              PrePostCardAttribute(
                type: PrePostCardAttributeType.userId,
                queryParam: 'userId',
              ),
              PrePostCardAttribute(
                type: PrePostCardAttributeType.email,
                queryParam: 'email',
              ),
            ],
          ),
        ],
      ).toJson(),
    );
    verify(mockView.updateView()).called(1);
  });

  test('getFinalisedUrl', () {
    final mockEvent = MockEvent();
    when(mockUserService.currentUserId).thenReturn('userId');
    model.event = mockEvent;
    model.email = 'email';
    model.prePostCard = PrePostCard.newCard(PrePostCardType.preEvent);

    expect(
      presenter.getFinalisedUrl(PrePostUrlParams(surveyUrl: 'url')),
      'url',
    );
  });

  group('getTitle', () {
    test('pre event', () {
      model.prePostCardType = PrePostCardType.preEvent;
      expect(presenter.getTitle(), 'Pre-event');
    });

    test('post event', () {
      model.prePostCardType = PrePostCardType.postEvent;
      expect(presenter.getTitle(), 'Post-event');
    });
  });
}
