package main

import (
	"context"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
)

const (
	version = "v1.0.0"
)

func main() {
	log.Println("Starting helloworld application...")

	// Root endpoint returns hello world
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		log.Println("Hello World")
	})

	// Health endpoint returns health status
	http.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		log.Println("Healthy")
	})

	// Version endpoint returns the current version
	http.HandleFunc("/version", func(w http.ResponseWriter, r *http.Request) {
		log.Println(version)
	})

	// Start the HTTP server on a designated port and goroutine
	s := http.Server{Addr: ":8080"}
	go func() {
		log.Fatal(s.ListenAndServe())
	}()

	// Create a channel to listen for a shutdown signal
	signalChan := make(chan os.Signal, 1)
	signal.Notify(signalChan, syscall.SIGINT, syscall.SIGTERM)
	<-signalChan

	log.Println("Shutdown signal received, exiting...")

	s.Shutdown(context.Background())
}
