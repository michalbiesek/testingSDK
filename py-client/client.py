import os
from pathlib import Path
from dotenv import load_dotenv
from cribl_control_plane import CriblControlPlane, models

# Load .env from repo root (two levels up from this file)
env_path = Path(__file__).parent.parent / ".env"
load_dotenv(dotenv_path=env_path)

if __name__ == "__main__":
    workspace = os.getenv("WORKSPACE_NAME", "")
    org_id = os.getenv("ORG_ID", "")
    domain = os.getenv("CRIBL_DOMAIN", "")
    server_url = f"https://{workspace}-{org_id}.{domain}/api/v1"

    with CriblControlPlane(
        server_url=server_url,
        security=models.Security(
            client_oauth={
                "client_id": os.getenv("CLIENT_ID", ""),
                "client_secret": os.getenv("CLIENT_SECRET", ""),
                "token_url": f"https://login.{domain}/oauth/token",
            }
        ),
    ) as ccp_client:

        res = ccp_client.health.get_health_info()
        print(res)
