# Frankly Matching

This directory contains code related to Frankly's matching feature. This code is broadly aimed at providing functionality to match people in interesting/generative/etc. ways based on their responses to survey questions. 

### Contents [WIP]
* `/functions` contains Cloud Functions code which responds to matching requests. 
* `/lib/matching.dart`, which contains the original matching code developed by JuntoChat. This is imported by Frankly as a package in the main client.  
* `/client` contains a Flutter web app that serves as the frontend for the Frankly in-person matching application. 

### Legacy documentation
The following documentation was provided by the original JuntoChat team in their README for the matching algorithm. 

**For dart command line apps**
[Dart documentation here](https://dart.dev/tutorials/server/cmdline)

**Matching conversation participants**
For information on how parameters are stored, refer to `/client/shared/lib/firestore/discussion.dart#L109`. 

**Useful libraries for vectors**
[SciDart](https://github.com/scidart/scidart_examples)
[KDTree](https://pub.dev/packages/kdtree)
[KMeans](https://pub.dev/packages/kmeans)
[simple_cluster](https://pub.dev/packages/simple_cluster)