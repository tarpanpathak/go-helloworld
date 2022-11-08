package main

import (
	"fmt"
	"net/http"
)

func handler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "hello world!\n")
}

func main() {
	http.HandleFunc("/", handler)
	fmt.Println("Application started on port 8080")
	http.ListenAndServe(":8080", nil)
}
