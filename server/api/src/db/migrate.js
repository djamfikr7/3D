import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { Pool } from 'pg';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const MIGRATIONS_DIR = path.resolve(__dirname, '../../migrations');

const pool = new Pool({ connectionString: process.env.DATABASE_URL || 'postgres://postgres:postgres@localhost:5432/capture3d' });

async function ensureMigrationsTable(client) {
  await client.query(`CREATE TABLE IF NOT EXISTS schema_migrations (version TEXT PRIMARY KEY, applied_at TIMESTAMPTZ NOT NULL DEFAULT now())`);
}

async function appliedVersions(client) {
  const res = await client.query('SELECT version FROM schema_migrations');
  return new Set(res.rows.map(r => r.version));
}

async function applyMigration(client, version, sql) {
  await client.query('BEGIN');
  try {
    await client.query(sql);
    await client.query('INSERT INTO schema_migrations(version) VALUES($1)', [version]);
    await client.query('COMMIT');
    console.log(`Applied migration ${version}`);
  } catch (e) {
    await client.query('ROLLBACK');
    throw e;
  }
}

export async function runMigrations() {
  const client = await pool.connect();
  try {
    await ensureMigrationsTable(client);
    const files = fs.readdirSync(MIGRATIONS_DIR).filter(f => f.endsWith('.sql')).sort();
    const done = await appliedVersions(client);
    for (const f of files) {
      const version = f.replace('.sql','');
      if (done.has(version)) { continue; }
      const sql = fs.readFileSync(path.join(MIGRATIONS_DIR, f), 'utf8');
      await applyMigration(client, version, sql);
    }
  } finally {
    client.release();
  }
}

if (process.argv[1] && process.argv[1].endsWith('migrate.js')) {
  runMigrations().then(() => { console.log('Migrations complete'); process.exit(0); }).catch(err => { console.error(err); process.exit(1); });
}
