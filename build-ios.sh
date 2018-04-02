#!/bin/bash

flutter build ios --release --no-codesign
cd ios
bundle exec fastlane beta