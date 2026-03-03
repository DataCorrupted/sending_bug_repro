SWIFTC ?= swiftc
CLANG  ?= clang
SDK    := $(shell xcrun --show-sdk-path)

.PHONY: all clean run

all: sending_bug_repro

Legacy.o: Legacy.m Legacy.h
	$(CLANG) -fobjc-arc -isysroot $(SDK) -c Legacy.m -o Legacy.o

main.o: main.swift Legacy.h
	$(SWIFTC) -import-objc-header Legacy.h -sdk $(SDK) -disable-bridging-pch -c main.swift -o main.o

sending_bug_repro: Legacy.o main.o
	$(SWIFTC) -import-objc-header Legacy.h -sdk $(SDK) Legacy.o main.o -o sending_bug_repro

run: clean sending_bug_repro
	@echo ""
	@echo "=== ObjC handler (no crash expected) ==="
	NSZombieEnabled=YES MallocScribble=1 ./sending_bug_repro || true
	@echo ""
	@echo "=== Swift handler (crash expected without fix) ==="
	NSZombieEnabled=YES MallocScribble=1 ./sending_bug_repro --swift

clean:
	rm -f *.o sending_bug_repro
