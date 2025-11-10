export const config = {
  port: Number(process.env.PORT || 8080),
  jwtSecret: process.env.JWT_SECRET || 'dev-secret',
  databaseUrl: process.env.DATABASE_URL || 'postgres://postgres:postgres@localhost:5432/capture3d',
  env: process.env.NODE_ENV || 'development'
};
