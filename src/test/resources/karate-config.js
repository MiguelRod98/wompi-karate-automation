function fn() {
  karate.configure('connectTimeout', 200000);
  karate.configure('readTimeout', 200000);
  karate.configure('ssl', true);

  const config = karate.callSingle('classpath:setup.feature');
  const env = karate.env || 'sandbox';

  let api;
  if (env === 'uat') {
    api = 'https://api.co.uat.wompi.dev/v1';
  } else {
    api = 'https://api-sandbox.co.uat.wompi.dev/v1';
  }

  const endPoints = {
    api: api,
    publicKey: 'pub_stagtest_g2u0HQd3ZMh05hsSgTS2lUV8t3s4mOt7',
    privateKey: 'prv_stagtest_5i0ZGIGiFcDQifYsXxvsny7Y37tKqFWg',
    integrityKey: 'stagtest_integrity_nAIBuqayW70XpUqJS4qf4STYiISd89Fp'
  }

  const path = {
    pathAcceptanceToken: 'merchants/',
    pathPaymentSource: 'payment_sources',
    pathTransaction: 'transactions',
    pathNequiToken: 'tokens/nequi'
  }

  Object.assign(config, endPoints);
  Object.assign(config, path);
  return config;
}
