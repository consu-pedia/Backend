SQLGOPATH=/usr/share/gocode/
PWD=$(shell pwd)
PKG=com/consupedia/backend
SRCS=main.go

all:
	GOPATH=$(PWD):$(SQLGOPATH) go build com/consupedia/backend/main.go 

fmt:
	for s in $(SRCS); do GOPATH=$(PWD):$(SQLGOPATH) go fmt $(PKG)/$$s; done

clean:
	rm -f ./main
