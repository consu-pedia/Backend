SQLGOPATH=/usr/share/gocode/
PWD1UP=$(shell dirname $$PWD)
PKG=com/consupedia/backend
SRCS=db.go webserver.go main/main.go

all:
	for s in $(SRCS); do GOPATH=$(PWD1UP):$(SQLGOPATH) go build $(PKG)/$$s; done

fmt:
	for s in $(SRCS); do GOPATH=$(PWD1UP):$(SQLGOPATH) go fmt $(PKG)/$$s; done

clean:
	rm -f ./main
