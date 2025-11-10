import { RateLimiterMemory } from 'rate-limiter-flexible';

const points = {
  free: 5,
  creator: 20,
  pro: 50,
  enterprise: 200
};

const limiter = new RateLimiterMemory({ points: 100, duration: 1 });

export const rateLimiters = {
  tierLimiter: async (req, res, next) => {
    const tier = (req.user && req.user.tier) || 'free';
    const max = points[tier] || points.free;
    try {
      await limiter.consume(`${tier}:${req.ip}`, 1);
      next();
    } catch (e) {
      res.status(429).json({ error: 'rate limit exceeded' });
    }
  }
};
