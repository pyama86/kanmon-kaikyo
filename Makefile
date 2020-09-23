VERSION=0.0.13
build:
	docker build -t pyama/kanmon-kaikyo:$(VERSION)  .
	docker push pyama/kanmon-kaikyo:$(VERSION)
