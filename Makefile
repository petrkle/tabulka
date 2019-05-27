NTAG := $(shell git describe --abbrev=0 | awk '{print $$1"+0.1"}' | bc)

help:
	@echo "help          - this help"
	@echo "apk           - create apk file"
	@echo "tag           - add new tag"
	@echo "clean         - remove temporary files"

apk:
	gradle assembleRelease

tag:
	git tag -a -s -m "Version $(NTAG)" $(NTAG)

clean:
	gradle clean
