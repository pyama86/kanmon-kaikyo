VERSION=0.0.21
build:
	docker build -t pyama/kanmon-kaikyo:$(VERSION)  .
	docker push pyama/kanmon-kaikyo:$(VERSION)
	docker tag pyama/kanmon-kaikyo:$(VERSION) pyama/kanmon-kaikyo:latest
	docker push pyama/kanmon-kaikyo:latest
