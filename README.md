# Capture3D Pro – Dev Quickstart

Prereqs: Docker Desktop, docker-compose.

Run dev stack with Docker:
- macOS/Linux: `bash scripts/run_dev.sh`
- Windows (PowerShell): `./scripts/run_dev.ps1`

Run without Docker (local dev):
- Start Postgres (Docker-only): `./scripts/db_only.ps1` (Windows) or `bash scripts/db_only.sh` (macOS/Linux)
- API: `./scripts/dev_api.ps1` (Windows) or `bash scripts/dev_api.sh` (macOS/Linux)
- Worker: `./scripts/dev_worker.ps1` (Windows) or `bash scripts/dev_worker.sh` (macOS/Linux)
  - This uses dev in-memory queue and disables storage (presigns return local placeholders).

Generate API TypeScript SDK types:
- Windows: `./scripts/gen_sdk.ps1`
- macOS/Linux: `bash scripts/gen_sdk.sh`
  - Output: server/api/src/types/api.d.ts

Services:
- API: http://localhost:8080/health
- Dashboard Auth (optional): set DASHBOARD_BASIC_USER/DASHBOARD_BASIC_PASS; or set DISABLE_DASHBOARD_AUTH=true for local dev
- API env: see server/api/.env.example
- API TypeScript types: scripts/gen_sdk.* generate to server/api/src/types/api.d.ts

- Dashboard: http://localhost:8080/public/dashboard.html
- Job detail: http://localhost:8080/public/job.html
- Upload UI: http://localhost:8080/public/upload.html
- Viewer: http://localhost:8080/public/viewer.html
- Metrics: http://localhost:8080/metrics
- MinIO Console: http://localhost:9001 (user: minioadmin / pass: minioadmin)

Flow:
1) Upload images via Upload UI (or skip for now).
2) Create a job:
   curl -X POST http://localhost:8080/process -H "Content-Type: application/json" -d '{"project_id":"p1","images_manifest":["img1.jpg"],"preset":"ecommerce"}'
3) Watch live progress in Dashboard; see events in Job detail.
4) Export:
   curl -X POST http://localhost:8080/export -H "Content-Type: application/json" -d '{"job_id":"<JOB_ID>","format":"glb"}'
   Open Viewer and paste the presigned URL.

Notes:
- The worker uploads a dummy GLB to MinIO after completion; replace with real pipeline artifacts as stages are implemented.
- Postgres schema migrates automatically on API startup in dev.
