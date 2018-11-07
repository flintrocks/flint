#!/bin/bash

# ./Support/Cuckoo/run generate --testable "flint" --output ".derived-sources" $FILES

echo "Generating Mocks..."
for f in Sources/*; do
  TESTABLE=`basename $f`
  OUT_DIRECTORY=".derived-tests/$TESTABLE"
  OUTPUT="$OUT_DIRECTORY/GeneratedMocks.swift"

  echo "Creating $OUT_DIRECTORY"
  mkdir -p "$OUT_DIRECTORY"

  SOURCES=(`find "$f" -name "*.swift"`)
  SOURCED=$(IFS=" "; echo "${SOURCES[*]}")

  ./Support/Cuckoo/run generate --testable "$TESTABLE" --output "$OUTPUT" $SOURCED
done
