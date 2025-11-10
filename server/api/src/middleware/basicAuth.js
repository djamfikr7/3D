export function dashboardAuth(req, res, next) {
  const disable = String(process.env.DISABLE_DASHBOARD_AUTH || '').toLowerCase() === 'true';
  if (disable) return next();
  const user = process.env.DASHBOARD_BASIC_USER || '';
  const pass = process.env.DASHBOARD_BASIC_PASS || '';
  if (!user || !pass) return next();
  const hdr = req.headers.authorization || '';
  if (!hdr.startsWith('Basic ')) return unauthorized(res);
  const decoded = Buffer.from(hdr.slice(6), 'base64').toString('utf8');
  const [u, p] = decoded.split(':');
  if (u === user && p === pass) return next();
  return unauthorized(res);
}

function unauthorized(res) {
  res.set('WWW-Authenticate', 'Basic realm="Dashboard"');
  return res.status(401).send('Authentication required');
}
