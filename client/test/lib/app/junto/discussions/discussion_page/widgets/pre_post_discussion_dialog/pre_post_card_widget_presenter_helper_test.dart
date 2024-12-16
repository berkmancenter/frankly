import 'package:flutter_test/flutter_test.dart';
import 'package:junto/app/junto/discussions/discussion_page/widgets/pre_post_card_widget/pre_post_card_widget_presenter.dart';
import 'package:junto_models/cloud_functions/requests.dart';
import 'package:mockito/mockito.dart';

import '../../../../../../../mocked_classes.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final MockCloudFunctionsService mockCloudFunctionsService = MockCloudFunctionsService();
  final MockUserService mockUserService = MockUserService();
  final PrePostCardWidgetPresenterHelper helper = PrePostCardWidgetPresenterHelper();

  setUp(() {
    when(mockUserService.currentUserId).thenReturn('userId');
  });

  tearDown(() {
    reset(mockCloudFunctionsService);
    reset(mockUserService);
  });

  group('getEmail', () {
    test('userId is null', () async {
      when(mockUserService.currentUserId).thenReturn(null);

      final result = await helper.getEmail(mockUserService, mockCloudFunctionsService);

      expect(result, isNull);
    });

    test('response list is empty', () async {
      when(mockUserService.currentUserId).thenReturn('userId');
      when(mockCloudFunctionsService.getUserAdminDetails(any))
          .thenAnswer((_) async => GetUserAdminDetailsResponse(userAdminDetails: []));

      final result = await helper.getEmail(mockUserService, mockCloudFunctionsService);

      expect(result, isNull);
    });

    test('success', () async {
      when(mockUserService.currentUserId).thenReturn('userId');
      when(mockCloudFunctionsService.getUserAdminDetails(any))
          .thenAnswer((_) async => GetUserAdminDetailsResponse(userAdminDetails: [
                UserAdminDetails(email: 'email'),
              ]));

      final result = await helper.getEmail(mockUserService, mockCloudFunctionsService);

      expect(result, 'email');
    });
  });
}
