/// This file contains data processing functions used for the
/// modular Frankly Smart Matching product.
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:gsheets/gsheets.dart';

const kRowNumberIdKey = 'GOOGLE_SHEET_ROW_NUMBER';

Map<String, dynamic> getGoogleSheetCredentials() {
  final base64key = Platform.environment['GOOGLE_SHEETS_CREDENTIAL'];
  if (base64key == null) {
    throw Exception(
        'No Google sheet credentials found in environment variables.');
  }
  String jsonCredentials = utf8.decode(base64.decode(base64key));
  return jsonDecode(jsonCredentials);
}

/// Gets a list of all responses to a survey, formatted as a list of rows on Google Sheets
/// where each row is a map of column names to values.
Future<List<Map<String, dynamic>>> getGoogleSheetAnswers({
  required Spreadsheet spreadsheet,
}) async {
  try {
    final keySheet = spreadsheet.worksheetByTitle('Responses');
    if (keySheet == null) {
      throw Exception('No "Responses" tab found in Google Sheet.');
    }

    final keyRows = await keySheet.values.allRows();
    if (keyRows.isEmpty) {
      throw Exception('No responses found in Google Sheet.');
    }

    final headers = keyRows.first;
    final responses = <Map<String, dynamic>>[];

    for (var i = 1; i < keyRows.length; i++) {
      final row = keyRows[i];

      final response = <String, dynamic>{};
      for (var j = 0; j < row.length; j++) {
        response[headers[j]] = row[j];
      }

      // The actual row number is 1-based, so we add 1 to the index.
      response[kRowNumberIdKey] = (i + 1).toString();
      responses.add(response);
    }

    return responses;
  } catch (e) {
    print('Error getting Google Sheets responses: $e');
    return [];
  }
}

Future<Map<String, Set<String>>?> getGoogleSheetAnswerKeys({
  required Spreadsheet spreadsheet,
  bool includeFalseAnswers = false,
}) async {
  try {
    final keySheet = spreadsheet.worksheetByTitle('Keys');
    if (keySheet == null) {
      throw Exception('No "Keys" tab found in Google Sheet.');
    }

    // Skip the first row, which we assume is the header.
    final keyRows = await keySheet.values.allRows(fromRow: 2);
    if (keyRows.isEmpty) {
      throw Exception('No rows found in Keys tab of Google Sheet.');
    }

    final keys = <String, Set<String>>{};
    // Get "true"-ish answers, going a comma separated value to a set of "true" strings.
    for (var i = 0; i < keyRows.length; i++) {
      final row = keyRows[i];
      keys[row[0]] = row[1].split(',').map((e) => e.trim()).toSet();
      if (includeFalseAnswers && row.length > 2) {
        final falseAnswers = row[2].split(',').map((e) => e.trim()).toSet();
        keys[row[0]]!.addAll(falseAnswers);
      }
    }

    return keys.isNotEmpty ? keys : null;
  } catch (e) {
    print('Error getting Google Sheets answer keys: $e');
    return null;
  }
}

// Return the written row number.
Future<int?> writeResponseToGoogleSheet({
  required Spreadsheet spreadsheet,
  required Map<String, dynamic> response,
}) async {
  try {
    final responsesSheet = spreadsheet.worksheetByTitle('Responses');
    if (responsesSheet == null) {
      throw Exception('No "Submissions" tab found in Google Sheet.');
    }

    final rowToAppend = {
      'Timestamp': DateTime.now().toIso8601String(),
      ...response,
    };

    await responsesSheet.values.appendRow(rowToAppend.values.toList());

    final allRows = await responsesSheet.values.allRows();
    return allRows.length;
  } catch (e) {
    print('Error writing submission to Google Sheets: $e');
    return null;
  }
}

Future<bool> writeMatchResultsToGoogleSheet({
  required Spreadsheet spreadsheet,
  required List<List<String>> smartMatches,
  String nameColumn = 'B',
}) async {
  try {
    final matchSheet = spreadsheet.worksheetByTitle('Results');
    if (matchSheet == null) {
      throw Exception('No "Results" tab found in Google Sheet.');
    }

    List<List<dynamic>> matchRows = [];
    for (var i = 0; i < smartMatches.length; i++) {
      final group = smartMatches[i];
      matchRows.add(
        [
          'Group ${i + 1}',
          for (var i = 0; i < group.length; i++)
            '=Responses!$nameColumn${group[i]}',
        ],
      );
    }

    await matchSheet.values.appendRows(matchRows);

    return true;
  } catch (e) {
    print('Error writing match results to Google Sheets: $e');
    return false;
  }
}

/// Converts a single respondent's Google answers to a binary string.
/// All questions should be booleans in this early version.
/// Based on original _getJoinParametersOrNull function.
String getBinaryStringFromResponse({
  required Map<String, dynamic> participantResponse,
  Map<String, Set<String>>? answerKeys,
  int skipColumns = 2,
}) {
  var binarySurveyAnswers = '';
  participantResponse.keys.toList().sublist(skipColumns).forEach(
    (key) {
      if (key == kRowNumberIdKey) {
        return;
      }
      // First try looking up the answer in the answer key.
      // This enables multiple front-facing answers to be mapped
      // to a single binary answer.
      if (answerKeys != null && answerKeys.containsKey(key)) {
        final trueValues = answerKeys[key]!;
        final answer = participantResponse[key].toString();
        binarySurveyAnswers += trueValues.contains(answer) ? '1' : '0';
        return;
      } else {
        // If no key is provided, assume the answer is a boolean or else false.
        final boolParsed = bool.tryParse(participantResponse[key].toString());
        binarySurveyAnswers += boolParsed == null
            ? '0'
            : boolParsed
                ? '1'
                : '0';
      }
    },
  );
  return binarySurveyAnswers;
}

/// Normalizes all surveyAnswer binary strings to the same length.
/// Based on original _normalizeParticipantSurveyResponses function.
void normalizeSurveyAnswerStrings({
  required Map<String, String> surveyAnswerStrings,
  int? numTotalQuestions,
}) {
  // 9 was used in the original _normalizeParticipantSurveyResponses as a default length.
  int numQuestions = numTotalQuestions ?? 9;

  final hasQuestions = numTotalQuestions != null && numTotalQuestions > 0;

  if (!hasQuestions && surveyAnswerStrings.values.isNotEmpty) {
    // If breakouts didn't specify a number of questions, get the max answer mask length.
    numQuestions =
        surveyAnswerStrings.values.map((s) => s.length).reduce(math.max);
  }

  // Update all values to be numberOfQuestions in length.
  surveyAnswerStrings.updateAll(
    (key, value) {
      if (value.length > numQuestions) {
        return value.substring(0, numQuestions);
      } else if (value.length < numQuestions) {
        final paddingLength = numQuestions - value.length;

        final padding = [
          for (int i = 0; i < paddingLength; i++)
            math.Random().nextBool() ? 0 : 1
        ].join();

        return '$value$padding';
      }
      return value;
    },
  );
}

int calculateAdjustedTargetParticipants(
    int numParticipants, int targetGroupSize) {
  if (targetGroupSize < 4) {
    return targetGroupSize;
  }
  // Estimated rooms based on this targetNumber.
  final numRoomsDouble = numParticipants / targetGroupSize.toDouble();

  // Calculate some adjusted target group size examples.
  final higherTarget = numParticipants / numRoomsDouble.floor();
  final lowerTarget = numParticipants / numRoomsDouble.ceil();

  final higherTargetDiff = (higherTarget - targetGroupSize).abs();
  final lowerTargetDiff = (lowerTarget - targetGroupSize).abs();

  final int adjustedtargetGroupSize;
  // Pick the diff that is smallest, which is closest to the original target.
  if (higherTargetDiff < lowerTargetDiff) {
    adjustedtargetGroupSize = higherTarget.floor();
  } else {
    adjustedtargetGroupSize = lowerTarget.floor();
  }

  if (adjustedtargetGroupSize != targetGroupSize) {
    print(
        'Adjusting target participants to $adjustedtargetGroupSize to create better room distribution');
  }

  return adjustedtargetGroupSize;
}

Future<Map<String, List<String>>> getMatchDisplayResultsFromSheet({
  required Spreadsheet spreadsheet,
}) async {
  try {
    final matchSheet = spreadsheet.worksheetByTitle('Results');
    if (matchSheet == null) {
      throw Exception('No "Results" tab found in Google Sheet.');
    }

    final matchRows = await matchSheet.values.allRows();
    if (matchRows.isEmpty) {
      throw Exception('No match results found in Google Sheet.');
    }

    final matches = <String, List<String>>{};
    for (var row in matchRows) {
      matches[row[0]] = row.sublist(1);
    }

    return matches;
  } catch (e) {
    print('Error getting match results from Google Sheets: $e');
    return {};
  }
}
