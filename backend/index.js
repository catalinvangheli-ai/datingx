console.log('[index.js] Starting...');
console.log('[index.js] Node version:', process.version);
console.log('[index.js] PORT:', process.env.PORT);
try {
  require('./server.js');
  console.log('[index.js] server.js loaded OK');
} catch(e) {
  console.error('[index.js] CRASH:', e.message);
  console.error(e.stack);
  process.exit(1);
}
