.PHONY: clean

FUNCTION_TARGET = function
PORT = 8080

# bin/server.dart is the generated target for lib/functions.dart
bin/server.dart:
	dart run build_runner build --delete-conflicting-outputs

build: 
	dart run build_runner build --delete-conflicting-outputs

test: clean build
	dart test

clean:
	dart run build_runner clean
	rm -rf bin/server.dart
  
serve: build