package main

import (
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

func TestHealthHandler(t *testing.T) {
	app := &App{}
	req := httptest.NewRequest(http.MethodGet, "/health", nil)
	rr := httptest.NewRecorder()

	app.healthHandler(rr, req)

	if rr.Code != http.StatusOK {
		t.Fatalf("unexpected status code: got %d want %d", rr.Code, http.StatusOK)
	}
	if !strings.Contains(rr.Body.String(), `"status":"ok"`) {
		t.Fatalf("unexpected body: %s", rr.Body.String())
	}
}

func TestEvaluationHandlerMissingParams(t *testing.T) {
	app := &App{}
	req := httptest.NewRequest(http.MethodGet, "/evaluate", nil)
	rr := httptest.NewRecorder()

	app.evaluationHandler(rr, req)

	if rr.Code != http.StatusBadRequest {
		t.Fatalf("unexpected status code: got %d want %d", rr.Code, http.StatusBadRequest)
	}
}
