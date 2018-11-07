#!/bin/bash

# ./Support/Cuckoo/run generate --testable "flint" --output ".derived-sources" $FILES

# Locate Cuckoo
shopt -s nullglob
CUCKOO_DIR=(./.build/checkouts/Cuckoo.git-*)
shopt -u nullglob

if [ -z $CUCKOO_DIR ]; then
  echo "Can't find Cuckoo!"
  echo "Did you run \"swift package resolve\"?"
  exit -1
fi

pushd $CUCKOO_DIR
cd Generator
swift package resolve
swift build -c release --static-swift-stdlib
CUCKOO_BIN="$PWD/.build/release/cuckoo_generator"
stat "$CUCKOO_BIN" > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "Can't find Cuckoo generator!"
  exit -1
fi

echo "Found Cuckoo Generator at: $CUCKOO_BIN"
popd

echo "Generating Mocks..."
for f in Sources/*; do
  TESTABLE=`basename $f`
  OUT_DIRECTORY=".derived-tests/$TESTABLE"
  OUTPUT="$OUT_DIRECTORY/GeneratedMocks.swift"

  echo " -- Creating $OUT_DIRECTORY"
  mkdir -p "$OUT_DIRECTORY"

  SOURCES=(`find "$f" -name "*.swift" -not -name "*.template.swift"`)
  SOURCES_ONE_LINE=$(IFS=" "; echo "${SOURCES[*]}")

  set -x
  $CUCKOO_BIN generate --testable "$TESTABLE" --output "$OUTPUT" $SOURCES_ONE_LINE
  { set +x; } 2>/dev/null
done
