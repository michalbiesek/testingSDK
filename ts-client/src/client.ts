import * as path from 'path';
import * as dotenv from 'dotenv';
// Load root .env
dotenv.config({ path: path.resolve(__dirname, '..', '..', '.env') });
import { CriblControlPlane } from "cribl-control-plane";

const criblControlPlane = new CriblControlPlane({
  serverURL: `https://${process.env.WORKSPACE_NAME}-${process.env.ORG_ID}.${process.env.CRIBL_DOMAIN}/api/v1`,
  security: {
    clientOauth: {
      clientID : process.env.CLIENT_ID as string,
      clientSecret:process.env.CLIENT_SECRET as string,
      tokenURL: `https://login.${process.env.CRIBL_DOMAIN}/oauth/token`
    },
  },
});
(async () => {
  const result = await criblControlPlane.diag.getHealthInfo();

  console.log(result);
})();
