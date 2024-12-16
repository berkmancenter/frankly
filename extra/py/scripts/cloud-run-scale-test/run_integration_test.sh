#!/bin/sh

cd /junto
echo 'This is the anthem'
echo 'Throw all your hands up'
echo $PWD

/chromedriver/chromedriver --whitelisted-ips --port=4444 &
FOO_PID=$!
# nohup sh -c /app/chromedriver --whitelisted-ips &

# run test
dart /custom-flutter/packages/flutter_tools/bin/flutter_tools.dart  drive --driver=test_driver/integration_test.dart --target=integration_test/$1 -d web-server --no-sound-null-safety --headless --web-renderer html --release --test-arguments=run --test-arguments="--define=myVar=dannyrocks"
kill $FOO_PID
