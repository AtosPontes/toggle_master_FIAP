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

func TestMasterKeyAuthMiddleware(t *testing.T) {
	app := &App{MasterKey: "segredo"}
	protected := app.masterKeyAuthMiddleware(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusNoContent)
	}))

	t.Run("forbidden without header", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodPost, "/admin/keys", nil)
		rr := httptest.NewRecorder()
		protected.ServeHTTP(rr, req)

		if rr.Code != http.StatusForbidden {
			t.Fatalf("unexpected status code: got %d want %d", rr.Code, http.StatusForbidden)
		}
	})

	t.Run("allows valid bearer token", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodPost, "/admin/keys", nil)
		req.Header.Set("Authorization", "Bearer segredo")
		rr := httptest.NewRecorder()
		protected.ServeHTTP(rr, req)

		if rr.Code != http.StatusNoContent {
			t.Fatalf("unexpected status code: got %d want %d", rr.Code, http.StatusNoContent)
		}
	})
}
