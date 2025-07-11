package main

import (
	"context"
	"fmt"
	"log"
	"os"
	"path/filepath"

	criblcontrolplanesdkgo "github.com/criblio/cribl-control-plane-sdk-go"
	"github.com/criblio/cribl-control-plane-sdk-go/models/components"
	"github.com/joho/godotenv"
)

func main() {
	// Determine path to root .env (one level up)
	rootEnv := filepath.Join("..", ".env")

	// Load environment variables from that file
	if err := godotenv.Load(rootEnv); err != nil {
		log.Fatalf("Error loading .env from %s: %v", rootEnv, err)
	}
	ctx := context.Background()
	workspace := os.Getenv("WORKSPACE_NAME")
	orgID := os.Getenv("ORG_ID")
	domain := os.Getenv("CRIBL_DOMAIN")
	clientID := os.Getenv("CLIENT_ID")
	clientSecret := os.Getenv("CLIENT_SECRET")

	serverURL := fmt.Sprintf(
		"https://%s-%s.%s/api/v1",
		workspace,
		orgID,
		domain,
	)
	tokenURL := fmt.Sprintf(
		"https://login.%s/oauth/token",
		domain,
	)

	s := criblcontrolplanesdkgo.New(
		serverURL,
		criblcontrolplanesdkgo.WithSecurity(components.Security{
			ClientOauth: &components.SchemeClientOauth{
				ClientID:     clientID,
				ClientSecret: clientSecret,
				TokenURL:     tokenURL,
			},
		}),
	)

	res, err := s.Diag.GetHealthInfo(ctx)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println()
	if hs := res.HealthStatus; hs != nil {
		fmt.Printf("Role:      %v\n", *hs.Role)
		fmt.Printf("Status:    %s\n", hs.Status)
		fmt.Printf("StartTime: %v\n", hs.StartTime)
	}
}
