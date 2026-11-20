export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
nvm use
npm run routes:flutter
cd ../
flutter build web --release --source-maps --web-renderer html -t lib/main.dart --dart-define-from-file=.env
cd new/
npm run build:proxied
node scripts/assembleHosting.ts