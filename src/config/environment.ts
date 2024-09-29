/* eslint-disable @typescript-eslint/restrict-template-expressions */
/* eslint-disable @typescript-eslint/no-unsafe-call */
/* eslint-disable @typescript-eslint/no-unsafe-member-access */

export const environment = {
  APP_TITLE: process.env.APP_TITLE,
  NODE_ENV: process.env.NODE_ENV,
  OBFUSCATE_KEYWORDS: ['*.Authorization', '*.access_token', '*.password', '*.senha'],
};

export const getEnv = () => environment;

async function resolveVariables() {
}

export { resolveVariables };
