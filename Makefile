all: generate
	swift build
	cp -r stdlib .build/debug/

.PHONY: all release zip test lint generate

release: generate
	swift build	-c release --static-swift-stdlib
	cp -r stdlib .build/release/

zip: release
	cp .build/release/flintc flintc
	zip -r flintc.zip flintc stdlib
	rm flintc

test: lint release
	cd Tests/Integration/BehaviorTests && ./compile_behavior_tests.sh
	swift run -c release lite

lint:
	swiftlint lint --strict

generate:
	./utils/codegen/codegen.js
