package main

import (
	_ "go.uber.org/automaxprocs"
	"log"
	"os"
	"os/signal"
	"runtime"
	"syscall"
)

var build = "develop"

func main() {
	g := runtime.GOMAXPROCS(0)

	log.Printf("starting service [%s], CPU [%d]", build, g)
	defer log.Println("service ended")

	shutdown := make(chan os.Signal, 1)
	signal.Notify(shutdown, syscall.SIGINT, syscall.SIGTERM)
	<-shutdown

	log.Println("stopping service")
}