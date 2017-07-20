SQLGOPATH=/usr/share/gocode/
PWD1UP=$(shell dirname $$PWD)
PKG=com/consupedia/backend
SRCS=db.go webserver.go json.go
MORESRCS=main/main.go

#	for s in $(SRCS); do GOPATH=$(PWD1UP):$(SQLGOPATH) go build $(PKG)/$$s; done

all:	clean main test

main:
	GOPATH=$(PWD1UP):$(SQLGOPATH) go build $(PKG)
	for s in $(MORESRCS); do GOPATH=$(PWD1UP):$(SQLGOPATH) go build $(PKG)/$$s; done


fmt:
	for s in $(SRCS) $(MORESRCS); do GOPATH=$(PWD1UP):$(SQLGOPATH) go fmt $(PKG)/$$s; done

test:	./main
	./main

clean:
	rm -f ./main
