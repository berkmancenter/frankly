import 'package:flutter_test/flutter_test.dart';
import 'package:junto/app/junto/discussions/discussion_page/meeting_agenda/agenda_item_card/items/image/agenda_item_image_data.dart';
import 'package:junto/app/junto/discussions/discussion_page/meeting_agenda/agenda_item_card/items/image/agenda_item_image_model.dart';
import 'package:junto/app/junto/discussions/discussion_page/meeting_agenda/agenda_item_card/items/image/agenda_item_image_presenter.dart';
import 'package:mockito/mockito.dart';

import '../../../../../../../../../mocked_classes.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final MockFunction mockFunction = MockFunction();
  final AgendaItemImageHelper helper = AgendaItemImageHelper();

  test('updateParent', () {
    final model = AgendaItemImageModel(true, AgendaItemImageData('', ''), mockFunction.call1);

    helper.updateParent(model);

    verify(mockFunction.call1(any)).called(1);
  });

  test('uploadFile', () {},
      skip:
          'If we will continue using this method, will need to update the logic so we could easily test it');
}
