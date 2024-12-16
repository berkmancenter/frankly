import 'dart:async';
import 'dart:convert';

import 'package:functions/matching/data_processing.dart';
import 'package:functions/matching/matching.dart' as matching;

// Export api_types so builder can use them when generating `bin/server.dart`.
export 'package:functions/models.dart';
import 'package:functions/models.dart';

import 'package:functions_framework/functions_framework.dart';
import 'package:gsheets/gsheets.dart';
import 'package:quiver/iterables.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf_router/shelf_router.dart';

// How many left-most columns to skip when reading the Google Sheet
const _kSkipColumns = 2;

Router app = Router()
  ..post('/form-options', (Request request) async {
    // Gets form questions from Google Sheet.
    final body = await request.readAsString();
    final googleSheetId = jsonDecode(body)['spreadsheetId'] as String?;
    if (googleSheetId == null) {
      return Response.badRequest(body: 'No spreadsheet ID provided.');
    }

    final options = await formOptions(spreadsheetId: googleSheetId);
    // Convert to list instead of set for JSON serialization
    final listOptions =
        options.map((key, value) => MapEntry(key, value.toList()));

    return Response.ok(jsonEncode(listOptions));
  })
  ..post('/submit-form', (Request request) async {
    // Post the form and return the row number so we can easily look it up
    // when we need to get the results.
    final body = await request.readAsString();
    final jsonDecoded = jsonDecode(body);
    final response = jsonDecoded['answers'] as Map<String, dynamic>?;
    final spreadsheetId = jsonDecoded['spreadsheetId'] as String?;

    if (response == null) {
      return Response.badRequest(body: 'No answers provided.');
    } else if (spreadsheetId == null) {
      return Response.badRequest(body: 'No spreadsheet ID provided.');
    }

    final returnedRowNumber = await submitForm(
      spreadsheetId: spreadsheetId,
      response: response,
    );

    if (returnedRowNumber == null) {
      return Response.internalServerError(body: 'Failed to submit form.');
    }
    return Response.ok(returnedRowNumber.toString());
  })
  ..post('/process-matches', (Request request) async {
    final body = await request.readAsString();
    final matchingRequest = MatchingRequest.fromJson(jsonDecode(body));

    final results = await processMatches(matchingRequest);
    return Response.ok(results.toString());
  })
  ..post('/get-results', (Request request) async {
    // When the results are ready, get all results so users can fall back on them
    // if their ID is not found.
    final body = await request.readAsString();
    final spreadsheetId = jsonDecode(body)['spreadsheetId'] as String?;

    if (spreadsheetId == null) {
      return Response.badRequest(body: 'No spreadsheet ID provided.');
    }

    final results = await getResults(spreadsheetId: spreadsheetId);
    return Response.ok(jsonEncode(results));
  });

@CloudFunction()
Future<Response> function(Request request) async {
  var handler = const Pipeline()
      .addMiddleware(
        corsHeaders(
          // Allow specific headers expected by my app
          headers: {'Access-Control-Allow-Headers': 'Token, Content-Type'},
        ),
      )
      .addHandler(functionRouter);

  return handler(request);
}

Future<Response> functionRouter(Request request) => app.call(request);

Future<int?> submitForm({
  required String spreadsheetId,
  required Map<String, dynamic> response,
}) async {
  try {
    final googleSheetsCredential = getGoogleSheetCredentials();
    final gsheets = GSheets(googleSheetsCredential);
    final spreadsheet = await gsheets.spreadsheet(spreadsheetId);

    final returnedRowNumber = await writeResponseToGoogleSheet(
        spreadsheet: spreadsheet, response: response);

    if (returnedRowNumber == null) {
      throw Exception('Failed to submit response.');
    }
    return returnedRowNumber;
  } catch (e) {
    print('Error submitting response: $e');
    return null;
  }
}

Future<Map<String, Set<String>>> formOptions(
    {required String spreadsheetId}) async {
  try {
    final googleSheetsCredential = getGoogleSheetCredentials();
    final gsheets = GSheets(googleSheetsCredential);
    final spreadsheet = await gsheets.spreadsheet(spreadsheetId);

    final allFormOptions = await getGoogleSheetAnswerKeys(
      spreadsheet: spreadsheet,
      includeFalseAnswers: true,
    );

    if (allFormOptions == null) {
      throw Exception('No form options found in Google Sheet.');
    }

    return allFormOptions;
  } catch (e) {
    print('Error getting Google Sheets answer keys: $e');
    return {};
  }
}

Future<List<List<String>>> processMatches(MatchingRequest request) async {
  final targetGroupSize = request.targetGroupSize ?? 3;

  try {
    final googleSheetsCredential = getGoogleSheetCredentials();
    final gsheets = GSheets(googleSheetsCredential);
    final spreadsheet = await gsheets.spreadsheet(request.googleSheetId);

    final userResponses = await getGoogleSheetAnswers(spreadsheet: spreadsheet);
    final answerKeys = await getGoogleSheetAnswerKeys(spreadsheet: spreadsheet);

    print('Unmatched: ${userResponses.length}.');
    print('Target participants: $targetGroupSize.');

    final participantSurveyResponsesLookup = <String, String>{};
    for (final response in userResponses) {
      final joinParameters = getBinaryStringFromResponse(
        participantResponse: response,
        skipColumns: _kSkipColumns,
        answerKeys: answerKeys,
      );
      participantSurveyResponsesLookup[response[kRowNumberIdKey]] =
          joinParameters;
    }

    final allParticipantIds = participantSurveyResponsesLookup.keys.toSet();

    normalizeSurveyAnswerStrings(
        surveyAnswerStrings: participantSurveyResponsesLookup);

    final nonNullSurveyResponsesLength = participantSurveyResponsesLookup
        .entries
        .where((e) => e.value.isNotEmpty)
        .length;

    print(
        'Starting smart matching with $nonNullSurveyResponsesLength participants...');

    // Smart match users who had valid survey responses
    List<List<String>> smartMatches;
    if (targetGroupSize <= 2 || participantSurveyResponsesLookup.length <= 2) {
      smartMatches =
          matching.bucketMatch(samples: participantSurveyResponsesLookup);
    } else {
      final adjustedTargetParticipants = calculateAdjustedTargetParticipants(
          participantSurveyResponsesLookup.length, targetGroupSize);

      smartMatches = matching.groupMatch(
        participantResponses: participantSurveyResponsesLookup,
        targetGroupSize: adjustedTargetParticipants,
      );
    }

    print('Total smart matches before filtering: ${smartMatches.length}.');

    if (smartMatches.isNotEmpty && smartMatches.last.length < targetGroupSize) {
      smartMatches.removeLast();
    }

    // Flatten the smart matched IDs for checking against all participants.
    final smartMatchedIds = smartMatches.expand((p) => p).toSet();
    allParticipantIds.removeWhere((id) => smartMatchedIds.contains(id));
    print(
        'Smart matches: ${smartMatches.length}. Unmatched: ${allParticipantIds.length}');

    // Match any leftover unmatched participants.
    print('Beginning leftover matching...');
    final leftoverMatches = partition(allParticipantIds, targetGroupSize);
    print('Leftover matches: ${leftoverMatches.length}.');

    List<List<String>> matches = [
      ...smartMatches,
      ...leftoverMatches,
    ];

    if (matches.length > 1 && matches.last.length == 1) {
      final loneUser = matches.last.single;
      matches.removeLast();
      matches.last.add(loneUser);
    }
    print('Matching complete. Total matches: ${matches.length}.');

    final didWriteSucceed = await writeMatchResultsToGoogleSheet(
      spreadsheet: spreadsheet,
      smartMatches: matches,
    );
    print('Wrote matches to Google Sheets: $didWriteSucceed');

    return matches;
  } catch (e) {
    print('Error: $e');
    return [[]];
  }
}

Future<Map<String, List<String>>> getResults({
  required String spreadsheetId,
}) async {
  try {
    final googleSheetsCredential = getGoogleSheetCredentials();
    final gsheets = GSheets(googleSheetsCredential);
    final spreadsheet = await gsheets.spreadsheet(spreadsheetId);

    final matchResults = await getMatchDisplayResultsFromSheet(
      spreadsheet: spreadsheet,
    );

    return matchResults;
  } catch (e) {
    print('Error getting Google Sheets answer keys: $e');
    return {};
  }
}
