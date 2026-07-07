/// Diversity-maximizing group matching for deliberative conversations.
///
/// Assigns participants into groups that maximise Hamming distance across
/// binary survey-response masks.
///
/// API methods:
/// - [bucketMatch] — pair / small-group matching (low participant count).
/// - [groupMatch] — BFS-cluster matching (larger groups).
/// - [randomGroups] — random assignment baseline (no survey data needed).
///
library;

import 'dart:collection';
import 'dart:math';

const _minDistance = 3;
const _idealDistance = 4;

/// Assigns [items] into random groups of [targetGroupSize]. No survey data
/// required. Mutates [items] in place.
List<List<String>> randomGroups(List<String> items, int targetGroupSize) {
  items.shuffle();
  final groups = <List<String>>[];
  while (items.length >= targetGroupSize) {
    groups
        .add([for (var i = 0; i < targetGroupSize; i += 1) items.removeLast()]);
  }
  final int r = items.length;
  for (var i = 0; i < r; i++) {
    groups[i % groups.length].add(items.removeLast());
  }
  return groups;
}

/// Matches participants into pairs or small groups, maximizing the direct
/// Hamming distance between pairs of samples. This method breaks down for
/// large groups as the number of potential pairings to check grows
/// exponentially. For group sizes greater than 3, use [groupMatch].
///
/// Expects an input Map of samples that are userID => a binary string
/// representing answers to yes/no questions.
/// - [samples]: `participantId → binaryAnswerMask` (e.g. `"01001"`)
/// - [idealDistance]: target Hamming distance between partners (default 4)
/// - [minDistance]: minimum acceptable distance before random fallback (default 3)
///
/// The response is lists with user IDs that have been matched.
///
List<List<String>> bucketMatch({
  required Map<String, String> samples,
  int idealDistance = _idealDistance,
  int minDistance = _minDistance,
}) {
  // Match samples into pairs.  If odd, last pair will be a singleton.
  final pairs = <List<String>>[];
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

/// Creates diversity-maximised groups by first using BFS clustering to create
/// groups of similar binary answer masks. Groups vary by ±1 when participant
/// count is not evenly divisible by [targetGroupSize].
/// [bucketMatch] is recommended for groups of 3 or less participants for
/// efficiency and the fact that it is designed to maximize direct distance
/// between participants.
///
/// - [participantResponses]: `participantId → binaryAnswerMask`
/// - [targetGroupSize]: desired participants per group (≥ 2)
/// - [logclusters]: Whether to print cluster debug info
///
List<List<String>> groupMatch({
  required Map<String, String> participantResponses,
  required int targetGroupSize,
  bool logclusters = false,
}) {
  final buckets = _bucketSamples(participantResponses);
  final distances = _distanceMatrix(buckets.keys.toList());
  final Map<String, List<String>> G = _createGraph(buckets, distances);

  // Return simple value if not enough participants or single participant.
  final numParticipants = participantResponses.length;
  if (numParticipants <= targetGroupSize || numParticipants <= 1) {
    return [participantResponses.keys.toList()];
  }

  final int clusterSize = numParticipants ~/ targetGroupSize;
  final int remainder = numParticipants - (clusterSize * targetGroupSize);
  final clusters = <List<String>>[];
  print(
      'numParticipants=${numParticipants}, targetGroupSize=${targetGroupSize}, clusterSize=${clusterSize}, remainder =${remainder}');

  for (int i = 0; i < targetGroupSize; i++) {
    if (i < remainder) {
      clusters.add(_getNextCluster(buckets, G, clusterSize + 1));
    } else {
      clusters.add(_getNextCluster(buckets, G, clusterSize));
    }
  }

  if (logclusters) {
    // Use to check that makeup of clusters makes sense.
    clusters.forEach((cluster) {
      print(
          '\nCluster Size: ${cluster.length}\n${cluster.map((c) => participantResponses[c]).toSet()}');
    });
  }
  final groups = [
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

/// *** HELPER/UTIL METHODS ***

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
  final List<List<String>> pairs = [];
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
    final String k1 = sortedBucketKeys[0]; // Largest bucket
    String? k2 = null;
    for (int i = 1; i < sortedBucketKeys.length; i++) {
      final String bk = sortedBucketKeys[i];
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

List<String> _getNextCluster(Map<String, List<String>> buckets,
    Map<String, List<String>> G, int clusterSize) {
  // Make a graph --> BFS from largest bucket until cluster is full
  final List<String> cluster = [];
  final List<String> sortedBucketKeys = buckets.keys // Sort remaining by size
      .toList()
    ..sort((a, b) => -buckets[a]!.length.compareTo(buckets[b]!.length));

  String? node;
  final Queue<String> Q = Queue.from([sortedBucketKeys[0]]);
  final Set<String> qSet = Set.from(Q);
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

Map<String, List<String>> _createGraph(
    Map<String, List<String>> buckets, Map<String, int> distances) {
  // Returns a graph G specified by a mapping of bucket key --> neighbors
  final List<String> bucketKeys = buckets.keys.toList();

  return <String, List<String>>{
    for (final b1 in bucketKeys)
      b1: <String>[
        for (final b2 in bucketKeys) // Neighbor if only 1 answer is different
          if (distances[b1 + b2] == 1) b2
      ]
  };
}
