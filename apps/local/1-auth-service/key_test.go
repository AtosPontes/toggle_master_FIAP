package main

import "testing"

func TestGenerateAPIKey(t *testing.T) {
	key, err := generateAPIKey()
	if err != nil {
		t.Fatalf("generateAPIKey returned error: %v", err)
	}

	if len(key) != 71 {
		t.Fatalf("unexpected key length: got %d want 71", len(key))
	}

	if key[:7] != "tm_key_" {
		t.Fatalf("key must start with tm_key_, got %q", key)
	}
}

func TestHashAPIKey(t *testing.T) {
	const input = "minha-chave"
	got := hashAPIKey(input)

	if len(got) != 64 {
		t.Fatalf("hash length must be 64, got %d", len(got))
	}

	if got != hashAPIKey(input) {
		t.Fatalf("hash must be deterministic")
	}
}
