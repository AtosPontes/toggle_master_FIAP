package main

import "testing"

func TestBuildServiceURL(t *testing.T) {
	got, err := buildServiceURL("http://flag-service:8002", "flags", "enable-new-dashboard")
	if err != nil {
		t.Fatalf("buildServiceURL returned error: %v", err)
	}

	want := "http://flag-service:8002/flags/enable-new-dashboard"
	if got != want {
		t.Fatalf("unexpected url: got %q want %q", got, want)
	}
}

func TestBuildServiceURLInvalidBase(t *testing.T) {
	if _, err := buildServiceURL("flag-service:8002", "flags", "x"); err == nil {
		t.Fatalf("expected error for invalid base URL")
	}
}

func TestGetDeterministicBucket(t *testing.T) {
	a := getDeterministicBucket("user-1:flag-a")
	b := getDeterministicBucket("user-1:flag-a")

	if a != b {
		t.Fatalf("bucket must be deterministic: %d != %d", a, b)
	}
	if a < 0 || a > 99 {
		t.Fatalf("bucket out of range: %d", a)
	}
}

func TestRunEvaluationLogic(t *testing.T) {
	app := &App{}

	t.Run("flag disabled returns false", func(t *testing.T) {
		info := &CombinedFlagInfo{
			Flag: &Flag{Name: "f1", IsEnabled: false},
		}
		if got := app.runEvaluationLogic(info, "u1"); got {
			t.Fatalf("expected false when flag is disabled")
		}
	})

	t.Run("flag enabled without rule returns true", func(t *testing.T) {
		info := &CombinedFlagInfo{
			Flag: &Flag{Name: "f1", IsEnabled: true},
			Rule: nil,
		}
		if got := app.runEvaluationLogic(info, "u1"); !got {
			t.Fatalf("expected true when flag enabled and no rule")
		}
	})

	t.Run("percentage 100 always true", func(t *testing.T) {
		info := &CombinedFlagInfo{
			Flag: &Flag{Name: "f1", IsEnabled: true},
			Rule: &TargetingRule{
				IsEnabled: true,
				Rules: Rule{
					Type:  "PERCENTAGE",
					Value: float64(100),
				},
			},
		}
		if got := app.runEvaluationLogic(info, "u1"); !got {
			t.Fatalf("expected true for 100%% rollout")
		}
	})
}
