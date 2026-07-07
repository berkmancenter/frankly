## 0.1.0

Initial pub.dev release of the Frankly Match diversity matching algorithm!

Publishes three functions:
- `bucketMatch` — pair matching via direct Hamming distance maximization
- `groupMatch` — group matching via BFS cluster-then-compose
- `randomGroups` — random assignment baseline

Previously this code lived as a path dependency inside the Frankly monorepo (`firebase/functions`).