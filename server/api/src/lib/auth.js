import jwt from 'jsonwebtoken';

export function authMiddleware(req, res, next) {
  const header = req.headers.authorization || '';
  const token = header.startsWith('Bearer ') ? header.slice(7) : null;
  if (!token) {
    req.user = { tier: 'free', sub: 'anon' }; // allow anonymous for dev
    return next();
  }
  try {
    const payload = jwt.verify(token, process.env.JWT_SECRET || 'dev-secret');
    req.user = payload;
    return next();
  } catch (e) {
    return res.status(401).json({ error: 'invalid token' });
  }
}
