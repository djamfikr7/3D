import pkg from 'pg';
const { Pool } = pkg;

const pool = new Pool({ connectionString: process.env.DATABASE_URL || 'postgres://postgres:postgres@localhost:5432/capture3d' });

export async function query(text, params) {
  const res = await pool.query(text, params);
  return res.rows;
}
