import * as path from 'path';
import * as dotenv from 'dotenv';
import { CriblControlPlane } from 'cribl-control-plane';

dotenv.config({
  path: path.resolve(__dirname, '..', '..', '.env'),
  quiet: true,
});

const {
  WORKSPACE_NAME,
  ORG_ID,
  CRIBL_DOMAIN,
  CRIBL_AUDIENCE,
  CLIENT_ID,
  CLIENT_SECRET,
  DEBUG_CLIENT,
} = process.env;

const baseUrl = `https://${WORKSPACE_NAME}-${ORG_ID}.${CRIBL_DOMAIN}/api/v1`;
const wgUrl   = `${baseUrl}/m/default`;
process.env.CRIBLCONTROLPLANE_AUDIENCE = CRIBL_AUDIENCE;

const cribl = new CriblControlPlane({
  serverURL: `https://${process.env.WORKSPACE_NAME}-${process.env.ORG_ID}.${process.env.CRIBL_DOMAIN}/api/v1`,
  security: {
    clientOauth: {
      clientID: CLIENT_ID as string,
      clientSecret: CLIENT_SECRET as string,
      tokenURL: `https://login.${process.env.CRIBL_DOMAIN}/oauth/token`
    },
  },
  ...(DEBUG_CLIENT === 'true' && { debugLogger: console }),
});

(async () => {
  const health = await cribl.health.getHealthInfo();
  console.log('Health Info:', health);

  const inputs = await cribl.sources.listSource({serverURL:wgUrl });
  inputs.items?.forEach((inp, idx) => {
    console.log(`#${idx}:`, inp.type);
  });
  const source = await cribl.sources.createSource({
    type: "tcp",
    disabled: false,
    sendToRoutes: true,
    pqEnabled: false,
    host: "0.0.0.0",
    port: 301.76,
    ipWhitelistRegex: "/.*/",
    maxActiveCxn: 1000,
    socketIdleTimeout: 0,
    socketEndingMaxWait: 30,
    socketMaxLifespan: 0,
    enableProxyHeader: false,
    staleChannelFlushMs: 10000,
    enableHeader: false,
    authType: "manual",
  } , { serverURL: wgUrl })
  console.log('Created Source', source);
})();
