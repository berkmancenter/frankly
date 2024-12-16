import 'dart:collection';
import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'dart:math';
import 'package:csv/csv.dart';
import 'package:args/args.dart';

const _minDistance = 3;
const _idealDistance = 4;

Random? _rnd;
Random get random => _rnd ??= Random();

String _strkey(List<int> arr) {
  // Converts list of ints to a string
  return arr.map((e) => e.toString()).join();
}

// ignore: unused_element
List<int> _strkeyToInts(String strkey) {
  // Convert a string key to a list of ints
  return strkey.split('').map(int.parse).toList();
}

int _hamming(String s1, String s2) {
  if (s1.length != s2.length) return (s1.length - s2.length).abs();
  // Number of different characters
  int dist = 0;
  for (int n = 0; n < (s1.length); n++) if (s1[n] != s2[n]) dist += 1;
  return dist;
}

Map<String, List<String>> _bucketSamples(Map<String, String> samples) {
  // Bucket participantIds by answer pattern
  final buckets = <String, List<String>>{};
  samples.forEach((pid, x) {
    buckets[x] ??= [];
    buckets[x]!.add(pid);
  });
  return buckets;
}

List<List<int>> _randomBinaryData(int rows, int cols, double p) {
  // Generate rowsxcols of binary data with probability p of being 1 (else 0)
  return [
    for (int i = 0; i < rows; i++)
      <int>[
        for (int j = 0; j < cols; j++) random.nextDouble() < p ? 1 : 0,
      ],
  ];
}

Map<String, int> _distanceMatrix(List<String> samples) {
  // Calculate allpairs hamming distance between samples
  return <String, int>{
    for (int i = 0; i < samples.length; i++)
      for (int j = 0; j < samples.length; j++)
        samples[i] + samples[j]: _hamming(samples[i], samples[j]),
  };
}

List<List<String>> _pairsAtThreshold(Map<String, int> distances,
    Map<String, List<String>> buckets, int threshold) {
  List<List<String>> pairs = [];
  List<String> sortedBucketKeys =
      buckets.keys.toList().where((k) => (buckets[k]!.length > 0)).toList();

  int countRemaining =
      sortedBucketKeys.fold(0, (s, bk) => s + buckets[bk]!.length);
  final skipBuckets = <String>{};
  bool finished() {
    // Helper fn for end conditions
    if (countRemaining <= 1) {
      return true;
    }
    if (sortedBucketKeys.length - skipBuckets.length <= 1) {
      return true;
    }
    return false;
  }

  while (!finished()) {
    sortedBucketKeys = sortedBucketKeys // Sort remaining by size
        .where((k) => (!skipBuckets.contains(k) && buckets[k]!.length > 0))
        .toList()
      ..sort((a, b) => -buckets[a]!.length.compareTo(buckets[b]!.length));
    String k1 = sortedBucketKeys[0]; // Largest bucket
    String? k2 = null;
    for (int i = 1; i < sortedBucketKeys.length; i++) {
      String bk = sortedBucketKeys[i];
      if (distances[k1 + bk]! >= threshold) {
        k2 = bk; // Largest bucket that can be paired with k1
        break;
      }
    }
    if (k2 == null) {
      skipBuckets.add(k1); // No solutions for k1
    } else {
      final matchcount = min(
          1 + buckets[k1]!.length - buckets[sortedBucketKeys[1]]!.length,
          buckets[k2]!.length);
      for (var i = 0; i < matchcount; i++) {
        pairs.add([buckets[k1]!.removeLast(), buckets[k2]!.removeLast()]);
        countRemaining -= 2;
      }
    }
  }
  return pairs;
}

/// Expects an input Map of samples that are userID => a binary string
/// representing answers to yes/no questions.
///
/// These users will then be matched together based on an ideal distance
/// threshold in their answers.
///
/// The response is lists with user IDs that have been matched.
List<List<String>> bucketMatch({
  required Map<String, String> samples,
  int idealDistance = _idealDistance,
  int minDistance = _minDistance,
}) {
  // Match samples into pairs.  If odd, last pair will be a singleton.
  var pairs = <List<String>>[];
  final buckets = _bucketSamples(samples);
  final distances = _distanceMatrix(buckets.keys.toList());

  final thresholds = [idealDistance] +
      List<int>.generate(minDistance, (idx) => minDistance - idx);

  thresholds.forEach((threshold) {
    if (pairs.length * 2 < samples.length) {
      final newPairs = _pairsAtThreshold(distances, buckets, threshold);
      // print("Threshold $threshold: ${newPairs.length}");
      pairs..addAll(newPairs);
    }
  });
  final unmatchedUsers = buckets.values.expand((e) => e).toList();
  while (unmatchedUsers.length >= 2) {
    // Pair remaining participants together at random
    pairs.add([unmatchedUsers.removeLast(), unmatchedUsers.removeLast()]);
  }

  if (unmatchedUsers.isNotEmpty) {
    pairs.add(unmatchedUsers);
  }

  return pairs;
}

// Assign groups randomly, with no smart matching

List<List<String>> randomGroups(List<String> items, int targetGroupSize) {
  items.shuffle();
  var groups = <List<String>>[];
  while (items.length >= targetGroupSize) {
    groups
        .add([for (var i = 0; i < targetGroupSize; i += 1) items.removeLast()]);
  }
  int r = items.length;
  for (var i = 0; i < r; i++) {
    groups[i % groups.length].add(items.removeLast());
  }
  return groups;
}

Map<String, List<String>> createGraph(
    Map<String, List<String>> buckets, Map<String, int> distances) {
  // Returns a graph G specified by a mapping of bucket key --> neighbors
  List<String> bucketKeys = buckets.keys.toList();

  return <String, List<String>>{
    for (final b1 in bucketKeys)
      b1: <String>[
        for (final b2 in bucketKeys) // Neighbor if only 1 answer is different
          if (distances[b1 + b2] == 1) b2
      ]
  };
}

List<String> getNextCluster(Map<String, List<String>> buckets,
    Map<String, List<String>> G, int clusterSize) {
  // Make a graph --> BFS from largest bucket until cluster is full
  List<String> cluster = [];
  List<String> sortedBucketKeys = buckets.keys // Sort remaining by size
      .toList()
    ..sort((a, b) => -buckets[a]!.length.compareTo(buckets[b]!.length));

  String? node = null;
  Queue Q = Queue.from([sortedBucketKeys[0]]);
  Set qSet = Set.from(Q);
  while (cluster.length < clusterSize) {
    if (node != null && buckets[node]!.isNotEmpty) {
      cluster.add(buckets[node]!.removeLast());
    } else {
      // Move to next node and add neighbors to Q
      if (Q.isNotEmpty) {
        node = Q.removeFirst();
      } else {
        // Only happens in extremely rare cases of sparse data
        node = sortedBucketKeys.firstWhere((b) => !qSet.contains(b));
      }
      qSet.add(node);
      Q.addAll(G[node]!.where((k) => (!qSet.contains(k))).toList()
        ..sort((a, b) => -buckets[a]!.length.compareTo(buckets[b]!.length)));
      qSet.addAll(Q);
    }
  }
  return cluster;
}

// Matching for groups
List<List<String>> groupMatch({
  required Map<String, String> participantResponses,
  required int targetGroupSize,
  bool logclusters = false,
}) {
  final buckets = _bucketSamples(participantResponses);
  final distances = _distanceMatrix(buckets.keys.toList());
  Map<String, List<String>> G = createGraph(buckets, distances);

  // Return simple value if not enough participants or single participant.
  final numParticipants = participantResponses.length;
  if (numParticipants <= targetGroupSize || numParticipants <= 1) {
    return [participantResponses.keys.toList()];
  }

  int clusterSize = numParticipants ~/ targetGroupSize;
  int remainder = numParticipants - (clusterSize * targetGroupSize);
  final clusters = <List<String>>[];
  print(
      'numParticipants=${numParticipants}, targetGroupSize=${targetGroupSize}, clusterSize=${clusterSize}, remainder =${remainder}');

  for (int i = 0; i < targetGroupSize; i++) {
    if (i < remainder) {
      clusters.add(getNextCluster(buckets, G, clusterSize + 1));
    } else {
      clusters.add(getNextCluster(buckets, G, clusterSize));
    }
  }

  if (logclusters) {
    // Use to check that makeup of clusters makes sense.
    clusters.forEach((cluster) {
      print(
          '\nCluster Size: ${cluster.length}\n${cluster.map((c) => participantResponses[c]).toSet()}');
    });
  }
  var groups = [
    // Each group is composed to contain 1 p from each cluster
    for (var i = 0; i < clusterSize; i++)
      clusters.map((c) => c.removeLast()).toList()
  ];
  for (int i = 0; i < remainder; i++) {
    // Remainders are added as extras to existing groups
    groups[i % groups.length].add(clusters[i].removeLast());
  }
  return groups;
}

int _countUnfit(samples, pairs, minDistance) {
  // Count pairs with difference < minDistance
  int unfit = 0;
  pairs.forEach((p) {
    if (p.length != 2) {
      unfit += 1;
    } else if (_hamming(samples[p[0]], samples[p[1]]) < minDistance) {
      unfit += 1;
    }
  });
  return unfit;
}

void _printPairs(List<List<String>> pairs, Map<String, String> samples) {
  pairs.forEach((p) {
    String s = p.map((e) => samples[e]).join(' ');
    if (p.length == 2) {
      s += " dist: ${_hamming(samples[p[0]]!, samples[p[1]]!)}";
    }
    print(s);
  });
}

void _printPairsDistribution(
    List<List<String>> pairs, Map<String, String> samples) {
  int maxDist = samples[pairs[0][0]]!.length;
  final dists = List<int>.filled(maxDist + 1, 0);
  int nonPairs = 0;
  String s = '';
  pairs.forEach((p) {
    if (p.length != 2) {
      if (p.length > 3) {
        print('WARNING: Room with ${p.length} participants.');
      }
      nonPairs += 1;
    } else {
      dists[_hamming(samples[p[0]]!, samples[p[1]]!)] += 1;
    }
  });
  dists.asMap().forEach((index, value) => s += "\n\tDist ${index}:  ${value}");
  s += "\n\tNonpairs:  ${nonPairs}";
  print(s);
}

void _printGroupsDistribution(
    List<List<String>> groups, Map<String, String> samples) {
  Map<int, int> groupCounts = {};
  groups.forEach((g) {
    groupCounts[g.length] ??= 0;
    groupCounts[g.length] = groupCounts[g.length]! + 1;
  });
  groupCounts.forEach((k, v) => print('${k}: ${v} groups'));
}

List<List<String>> _runExperiment(
    Map<String, String> samples, int idealDistance, int minDistance) {
  // Run experiment on samples, log results and time
  String logstring =
      'n:${samples.length}, q:${samples[samples.keys.toList()[0]]!.length}';

  final stopwatch = Stopwatch()..start();
  List<List<String>> pairs = bucketMatch(
    samples: samples,
    idealDistance: idealDistance,
    minDistance: minDistance,
  );

  Duration matchtime = stopwatch.elapsed;
  int unfit = _countUnfit(samples, pairs, minDistance);
  logstring +=
      "\t${((100.0 * 2 * unfit) / (samples.length)).toStringAsFixed(2)}% ($unfit pairs) unfit";
  logstring += "\t${matchtime}s";
  print(logstring);
  return pairs;
}

void _runSimulation(
    int nParticipants, int nQuestions, double pDeviation, double pFlipped,
    {bool printPairs = false,
    bool printDistribution = false,
    int targetGroupSize = 2}) {
  print(
      '\nn:${nParticipants}, q:${nQuestions}, gs:${targetGroupSize}, r:${nParticipants % targetGroupSize}, pDev:${pDeviation.toStringAsFixed(2)}, pFlipped:${pFlipped.toStringAsFixed(2)}');

  // Simulate data and run matching experiment
  int flipCount = (pFlipped * nParticipants).toInt(); // Number of R rows

  // Create data
  List<List<int>> X = _randomBinaryData(nParticipants, nQuestions, pDeviation);
  for (int i = 0; i < flipCount; i++) {
    X[i] = X[i].map((e) => 1 - e).toList();
  }
  Map<String, String> samples = Map.fromIterable(X.asMap().entries,
      key: (e) => 'pid_' + e.key.toString(), value: (e) => _strkey(e.value));

  if (targetGroupSize == 2) {
    // Run matching
    List<List<String>> pairs =
        _runExperiment(samples, _idealDistance, _minDistance);

    if (printPairs) {
      _printPairs(pairs, samples);
    }
    if (printDistribution) {
      _printPairsDistribution(pairs, samples);
    }
  } else {
    List<List<String>> groups = groupMatch(
        participantResponses: samples,
        targetGroupSize: targetGroupSize,
        logclusters: false);

    if (printDistribution) {
      _printGroupsDistribution(groups, samples);
    }
  }
}

Map<String, int> _groupsToMap(List<List<String>> groups) {
  // Calculate allpairs hamming distance between samples
  return <String, int>{
    for (int g = 0; g < groups.length; g++)
      for (int i = 0; i < groups[g].length; i++) groups[g][i]: g,
  };
}

void _testGroupMatchFromCsv(String csvpath, pidIdx, amIdx,
    {targetGroupSize = 6,
    bool printPairs = false,
    bool printDistribution = false}) async {
  // Read CSV
  final fields = await new File(csvpath)
      .openRead()
      .transform(utf8.decoder)
      .transform(new CsvToListConverter(shouldParseNumbers: false))
      .toList();
  fields.removeAt(0);
  // Format Data

  Map<String, String> samples = Map.fromIterable(fields,
      key: (e) => e[pidIdx].toString(), value: (e) => e[amIdx].toString());

  int nParticipants = samples.length;
  int nQuestions =
      samples[samples.keys.elementAt(new Random().nextInt(samples.length))]!
          .length;
  print(samples[samples.keys.elementAt(new Random().nextInt(samples.length))]);
  print(
      '\nn:${nParticipants}, q:${nQuestions}, gs:${targetGroupSize}, r:${nParticipants % targetGroupSize}');

  List<List<String>> groups = groupMatch(
      participantResponses: samples,
      targetGroupSize: targetGroupSize,
      logclusters: true);

  Map<String, int> pidToGroup = _groupsToMap(groups);
  if (printDistribution) {
    _printGroupsDistribution(groups, samples);
  }

  writeCsv(
      fields.map((r) => [r[pidIdx], r[amIdx], pidToGroup[r[pidIdx]]]).toList(),
      csvpath.split('.')[0] + '_results.csv');
}

void writeCsv(List<List<dynamic>> lines, String filepath) async {
  String csv = const ListToCsvConverter().convert(lines);
  File file = await File(filepath);
  file.writeAsString(csv);
}

void main(List<String> arguments) {
  const csvInput = 'csvInput';
  final parser = ArgParser()
    ..addFlag(csvInput, defaultsTo: false, negatable: true);

  ArgResults argResults = parser.parse(arguments);
  final paths = argResults.rest;

  if (argResults[csvInput]) {
    // Run a test over csvInputs instead
    for (String path in paths) {
      _testGroupMatchFromCsv(path, 7, 6,
          targetGroupSize: 6, printDistribution: true);
    }
  } else {
    int nQuestions = 7;
    double rPercent = .2; // Probability of aligning R
    double pDeviation = 0.15; // Probability of answering along party lines
    int targetGroupSize = 6;
    bool hammertime = true;

    // Testing groups
    _runSimulation(1000, nQuestions, pDeviation, rPercent,
        targetGroupSize: targetGroupSize);

    // Test with variable inputs
    print(
        "\nSimulate R vs D with ${rPercent} R and p(deviation) = ${pDeviation}...");
    [1001, 2005, 10311, 20001].forEach((n) {
      _runSimulation(n, nQuestions, pDeviation, rPercent,
          printDistribution: true, targetGroupSize: targetGroupSize);
    });
    if (hammertime) {
      print("\n100 simulations with random inputs...");
      var rnd = new Random();
      for (int i = 0; i < 100; i++) {
        // Test small numbers
        _runSimulation(rnd.nextInt(10), rnd.nextInt(10), rnd.nextDouble(),
            rnd.nextDouble(),
            printDistribution: true, targetGroupSize: rnd.nextInt(13) + 1);
      }
      for (int i = 0; i < 100; i++) {
        // Test bigger
        _runSimulation(rnd.nextInt(100000), rnd.nextInt(10), rnd.nextDouble(),
            rnd.nextDouble(),
            printDistribution: true, targetGroupSize: rnd.nextInt(13) + 1);
      }
    }
  }
}
