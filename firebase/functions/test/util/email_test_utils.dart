import 'package:data_models/cloud_functions/requests.dart';
import 'package:functions/utils/notifications_utils.dart';
import 'package:functions/utils/send_email_client.dart';
import 'package:mocktail/mocktail.dart';

class MockSendEmailClient extends Mock implements SendEmailClient {}

// Create mock classes for SendGridEmail and SendGridEmailMessage
class MockSendGridEmail extends Mock implements SendGridEmail {}

class MockSendGridEmailMessage extends Mock implements SendGridEmailMessage {}

class MockNotificationsUtils extends Mock implements NotificationsUtils {}
