import 'package:client/services.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/utils/utils.dart';

class CloudFunctionsEventService {
  Future<void> sendEventMessage(
    SendEventMessageRequest request,
  ) async {
    loggingService.log(
      'CloudFunctionsService.sendEventMessage: Data: ${request.toJson()}',
    );

    await cloudFunctions.callFunction('sendEventMessage', request.toJson());
  }

  Future<void> createEvent(Event event) async {
    await cloudFunctions.callFunction(
      CreateEventRequest.functionName,
      CreateEventRequest(eventPath: event.fullPath).toJson(),
    );
  }

  Future<void> joinEvent(Event event) async {
    final data = event.toJson()
      ..remove('createdDate')
      ..remove('eventEmailLog')
      ..['scheduledTime'] = encodeDateTimeForJson(
        event.scheduledTime,
      );

    await cloudFunctions.callFunction('joinEvent', data);
  }

  Future<void> eventEnded(EventEndedRequest request) async {
    loggingService.log(
      'CloudFunctionsService.eventEnded: Data: ${request.toJson()}',
    );
    await cloudFunctions.callFunction('eventEnded', request.toJson());
  }

  Future<GetCommunityCalendarLinkResponse> getCommunityCalendarLink(
    GetCommunityCalendarLinkRequest request,
  ) async {
    final result = await cloudFunctions.callFunction(
        'getCommunityCalendarLink', request.toJson());
    return GetCommunityCalendarLinkResponse.fromJson(result);
  }
}
