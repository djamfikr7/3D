# Capture3D Pro – Architecture and Execution Plan (Single Source of Truth)

Status: Draft v0.2 (living document)
Document Owner: Jordan Lee (Platform Lead)
Last Updated: <auto-update per commit>

## 0. Purpose, Memory, and Rules of Engagement
- This is the ONLY authoritative design and execution document.
- All scope/architecture/process changes must be reflected here BEFORE implementation.
- This document is our memory: decisions, backlog, SLAs, and diagrams live here and are updated per commit.
- Decision hygiene: every material change adds/updates an ADR in Section 13 and an entry in Section 15 (Change Log).
- Single doc mandate: do not create parallel architecture docs elsewhere; if needed, link back here.

## 1. Vision Summary
Capture3D Pro converts guided photo captures into high-fidelity 3D models via a hybrid pipeline: classical photogrammetry for geometry + AI (NeRF/diffusion/ESRGAN) for refinement. Targets e-commerce, game dev, and VFX with fast turnaround, high fidelity, and low per‑model cost.

## 2. Principles and Constraints
- Quality first: hybrid pipeline; minimize manual cleanup.
- Performance: meet tiered SLAs through GPU scheduling, tiling, and caching.
- Cost efficiency: spot instances, autoscaling, downscaling >4K inputs, artifact lifecycle policies.
- Security & privacy: TLS 1.3, per-user S3 isolation, GDPR; SSO/OIDC for enterprise.
- Operability: metrics, logs, traces by default; error budgets drive release cadence.
- Extensibility: parameterized pipeline with presets and advanced/expert controls; API-first.

## 3. System Context and Actors
Actors: End User (mobile/web), Admin, Processing Cluster, Payment Provider, Shopify, Unity/Unreal/Blender.
Contexts: Mobile Capture (Flutter + ARKit/ARCore), Web Dashboard (Three.js), API Gateway (Node/Express), Processing Workers (PyTorch/AliceVision), Data Stores (Postgres, S3), Queue (SQS), Events (WebSocket), CDN (CloudFront).

## 4. High-Level Architecture
```mermaid
flowchart LR
  A[Mobile Capture (Flutter, ARKit/ARCore)] -->|Photos+EXIF| S3i((S3 Ingest))
  A -->|Auth| API[API Gateway (Node/Express)]
  W[Web Dashboard (Three.js)] --> API
  API -->|Create Job| Q[SQS Queue]
  Q --> W1[Worker: Photogrammetry (AliceVision)]
  Q --> W2[Worker: AI Enhance (PyTorch: NeRF/Diffusion/ESRGAN)]
  W1 --> S3[(S3 Artifacts)]
  W2 --> S3
  W1 -.->|Status| EVT[WebSocket Events]
  W2 -.->|Status| EVT
  API --> DB[(Postgres)]
  S3 --> CDN[CloudFront]
  W -->|View 3D| CDN
```

## 5. Component Design
### 5.1 Mobile Capture (Flutter)
- AR overlays: orbit path, coverage heatmap; auto-capture; voice prompts.
- Local validation: blur/noise/overlap heuristics; retry hints; multi-pass capture (orbit/elevation/detail).
- Offline queue and resumable uploads to S3 via pre-signed URLs; EXIF validation.

### 5.2 Web Dashboard (Three.js)
- Project gallery; job status via WebSocket; quality score badges.
- 3D viewer: wireframe/UV/normal toggles; measurement tools; basic brush/select for cleanup.

### 5.3 API Gateway (Node/Express)
- JWT auth/refresh; tier-based rate limiting and quotas.
- Endpoints: /upload, /process, /status/:job_id, /export, /webhook.
- Orchestration: create job, enqueue SQS task, stream progress/events, handle retries.

### 5.4 Processing Workers (GPU, PyTorch)
- Containerized workers with AliceVision + PyTorch 2.1/CUDA 12.1.
- Stages: Preprocess → SfM/MVS → Meshing → AI Enhance → QA → Export.
- Config via presets and advanced/expert YAML; artifact caching between stages.

### 5.5 Data Layer
- Postgres: users, projects, jobs, exports, usage_events (+vector extension optional for embeddings).
- S3 buckets: raw, intermediates, outputs; lifecycle policies (7-day images, 30-day models; enterprise overrides allowed).

### 5.6 Observability
- Metrics: job durations by stage, GPU utilization, cache hit rates, quality score distribution.
- Logs: structured JSON with trace IDs; distributed tracing across API and workers.
- Alerts: SLA breach, queue backlog thresholds, GPU pool capacity, error spikes.

### 5.7 Security & Compliance
- TLS 1.3; SSO (SAML/OIDC) for enterprise; KMS per-tenant keys as needed.
- GDPR data subject flows; data minimization and retention controls.
- Compliance target: SOC 2 Type I in Phase 2, Type II post-GA.

## 6. Data Model (Initial Schema)
- users(id, email, name, role, sso_id, created_at)
- projects(id, user_id, name, preset, created_at)
- jobs(id, project_id, status, tier, params_json, started_at, finished_at, metrics_json)
- exports(id, job_id, format, url, size, created_at)
- usage_events(id, user_id, type, payload_json, ts)

## 7. API Contract (Stub)
- POST /process: {project_id, images_manifest, preset, params?} → 202 {job_id, events_url}
- GET /status/:job_id → {state, progressPct, estimates, defects?}
- POST /export: {job_id, format, options} → 200 {export_id, url}
- WebSocket events: job.started, stage.updated, qa.flag, job.completed, job.failed.

## 8. Deployment Topology
- Environments: dev / staging / prod.
- GPU node groups (A10G 24GB) autoscaled; worker images versioned and pinned.
- API + Web in containers; S3+CloudFront for assets; WAF on public edges.
- IaC: Terraform modules (network, compute, data, observability, security).

### 8.1 Runtime Topology per Environment (Mermaid)

Dev (single-node, minimal):
```mermaid
flowchart LR
  DevUser-->DevAPI[API (Docker Compose)]
  DevAPI-->DevDB[(Postgres local)]
  DevAPI-->DevS3[(S3/dev bucket)]
  DevAPI-->DevQ[SQS/dev]
  DevQ-->DevW[Worker (GPU optional)]
  DevW-->DevS3
  DevUser-->DevCDN[CloudFront/dev]:::edge
  classDef edge fill:#eef,stroke:#99f;
```

Staging (multi-AZ small scale):
```mermaid
flowchart LR
  User-->StgWAF[WAF]
  StgWAF-->StgAPI[API ASG]
  StgAPI-->StgDB[(RDS Postgres Multi-AZ)]
  StgAPI-->StgS3[(S3/staging)]
  StgAPI-->StgQ[SQS/staging]
  StgQ-->StgWG[GPU Node Group (2-4 nodes)]
  StgWG-->StgS3
  User-->StgCDN[CloudFront/staging]
```

Prod (multi-AZ, autoscaled):
```mermaid
flowchart LR
  User-->ProdWAF[WAF + Rate Limiting]
  ProdWAF-->ProdAPI[API ECS/EKS]
  ProdAPI-->ProdDB[(RDS Postgres Multi-AZ + Read Replicas)]
  ProdAPI-->ProdS3[(S3/prod with KMS)]
  ProdAPI-->ProdQ[SQS/prod (priority queues)]
  ProdQ-->ProdWG[GPU Node Groups (A10/L4/A100)]
  ProdWG-->ProdS3
  User-->ProdCDN[CloudFront/prod + Shield]
```


## 9. Scalability & Capacity
- Queue-based backpressure supports 1,000 concurrent jobs; per-tier priority queues.
- Tiling for NeRF/ESRGAN; caching intermediate reconstructions; resumable processing on failures.
- Rate limits/quotas per plan; burst credits for Pro/Enterprise.

## 10. SLOs and Performance Budgets
- Availability: API 99.9% monthly.
- Viewer latency: <3s for 50MB GLB on 4G (~25 Mbps).
- Processing E2E: <5 / <12 / <25 min by tier; bold target: 80% jobs complete in <12 min.
- Cost: bold target: average <$0.50 per model at scale.

## 11. Cost Model (Targets)
- GPU minutes budget per stage with envelope alerts.
- Storage lifecycle costs managed via retention; per-export egress tracked.
- Spot instances for workers; multi-region fallback when capacity constrained.

## 12. Risk Register (Top)
- Reflective/translucent objects → capture guidance, specular removal via AI.
- GPU shortages → multi-region, mixed GPU types (A10/L4/A100), CPU fallback for selective stages.
- Patent exposure on retopo → use Instant Meshes/open alternatives; legal review gate.

## 13. Decision Log (ADRs)
- ADR-0001: AliceVision for photogrammetry — Open, quality, community support.
- ADR-0002: Hybrid NeRF + ESRGAN — Fill gaps, enhance textures, maintain geometry accuracy.
- ADR-0003: SQS for orchestration — Decoupling, reliability, scaling characteristics.
- ADR-0004: Flutter for capture app — Cross-platform performance, ARKit/ARCore support via plugins.
- ADR-0005: Postgres primary datastore — Relational integrity, analytics, extensions.
- ADR-0006: PyTorch for AI workers — Ecosystem maturity, CUDA performance, flexibility.

## 14. Backlog (Live, Prioritized; Markdown format; named owners populated)

Owner roster:
- Mobile (Flutter): Alex Chen
- Frontend (Web/Three.js): Priya Patel
- Backend/API (Node/Express): Marco Rossi
- ML/AI Workers (PyTorch): Sofia Nguyen
- DevOps/Infra: Jordan Lee
- Security/Compliance: Fatima Al-Hassan

### Epics
- E1: Capture & Upload MVP
- E2: Core Reconstruction Pipeline
- E3: Web Viewer & Export
- E4: Auth, Billing & Plans
- E5: Observability, Security & Ops
- E6: Performance & Cost Optimization

### Stories and Tasks

#### E1: Capture & Upload MVP
- E1-S1: Flutter capture UI with AR overlays [Owner: Alex Chen] [Status: Todo]
  - T1: Orbit path visualization & auto-capture [Owner: Alex Chen] [Status: Todo]
  - T2: Coverage heatmap & overlap indicator [Owner: Alex Chen] [Status: Todo]
  - T3: Quality validation (blur/noise/EXIF) [Owner: Alex Chen] [Status: Todo]
- E1-S2: Resumable uploads to S3 via pre-signed URLs [Owner: Marco Rossi] [Status: Todo]
- E1-S3: Multi-pass capture flows (orbit/elevation/detail) [Owner: Alex Chen] [Status: Todo]
- E1-S4: Images manifest generation & validation [Owner: Marco Rossi] [Status: Todo]

#### E2: Core Reconstruction Pipeline
- E2-S1: AliceVision SfM/MVS containerization [Owner: Sofia Nguyen] [Status: Todo]
  - T1: Build CUDA base image; package AliceVision [Owner: Sofia Nguyen] [Status: Todo]
  - T2: AKAZE config; vocab tree matching baseline [Owner: Sofia Nguyen] [Status: Todo]
  - T3: Incremental SfM + dense MVS pipeline script [Owner: Sofia Nguyen] [Status: Todo]
- E2-S2: Meshing & Poisson reconstruction [Owner: Sofia Nguyen] [Status: Todo]
- E2-S3: AI enhancement (NeRF/ESRGAN/Diffusion) [Owner: Sofia Nguyen] [Status: Todo]
  - T1: Instant-NGP config (30k steps, hash grids) [Owner: Sofia Nguyen] [Status: Todo]
  - T2: ESRGAN tiling FP16 for 8K textures [Owner: Sofia Nguyen] [Status: Todo]
  - T3: Diffusion inpainting for hole fill [Owner: Sofia Nguyen] [Status: Todo]
- E2-S4: Retopology & LOD generation (quad remesh 10k–100k; 5 LODs) [Owner: Sofia Nguyen] [Status: Todo]
- E2-S5: QA scoring & defect detection [Owner: Sofia Nguyen] [Status: Todo]

#### E3: Web Viewer & Export
- E3-S1: Three.js viewer with inspection tools [Owner: Priya Patel] [Status: Todo]
- E3-S2: Exporters (GLB, USDZ, FBX, OBJ/MTL, STL, PLY) [Owner: Marco Rossi] [Status: Todo]
- E3-S3: Export presets (web/game/VFX/print) & egress tracking [Owner: Marco Rossi] [Status: Todo]

#### E4: Auth, Billing & Plans
- E4-S1: JWT auth/refresh; tiered rate limits/quotas [Owner: Marco Rossi] [Status: Todo]
- E4-S2: Payments integration & plan entitlements [Owner: Marco Rossi] [Status: Todo]
- E4-S3: Admin dashboard for plans/limits [Owner: Marco Rossi] [Status: Todo]

#### E5: Observability, Security & Ops
- E5-S1: Metrics/logs/traces baseline; dashboards [Owner: Jordan Lee] [Status: Todo]
- E5-S2: Alerts for SLA breaches and queue backlogs [Owner: Jordan Lee] [Status: Todo]
- E5-S3: GDPR flows; data retention enforcement [Owner: Fatima Al-Hassan] [Status: Todo]
- E5-S4: SOC 2 Type I readiness checklist [Owner: Fatima Al-Hassan] [Status: Todo]

#### E6: Performance & Cost Optimization
- E6-S1: Runtime estimator for GPU minutes and memory [Owner: Jordan Lee] [Status: Todo]
- E6-S2: Caching of intermediate reconstructions [Owner: Sofia Nguyen] [Status: Todo]
- E6-S3: Spot instance strategy & fallbacks [Owner: Jordan Lee] [Status: Todo]

## 15. Change Log
- v1.2: Terraform modules (network/storage/queue/db); worker queue adapters refactor; feature extraction stage scaffold.
- v1.1: SQS adapter path (API/worker), AliceVision stage scaffold, OpenAPI hardened (response errors), CODEOWNERS added.
- v1.0-pre: Job event timeline persisted with job_events table and minimal job detail page; WS updates integrate into timeline.
- v0.9: Queue adapter abstraction (dev vs SQS stub) and worker uploads a dummy artifact to MinIO on completion.
- v0.8: Metrics (/metrics) and structured logging; presigned upload flow; minimal Three.js GLB viewer.
- v0.7: OpenAPI spec + request validation, storage abstraction (MinIO via S3 SDK), and minimal web dashboard page with live updates.
- v0.6: WebSocket progress events and test client page; dev status updates broadcast to /events.
- v0.5: Postgres persistence with migrations; API creates jobs in DB and dev worker updates status in DB.
- v0.4: Dev E2E flow with docker-compose, dev endpoints (/dev/*), worker polling, and in-memory FIFO queue.
- v0.3: Sprint 1 scaffolding added (API skeleton, worker scaffold, Terraform structure, CI pipeline, placeholders for web/mobile).
- v0.2: Created single-source document with Flutter/Postgres/PyTorch updates; added SOC 2 plan; set per-commit update rule; included Mermaid diagrams.
- v0.1: Initial scaffold defined (pre-approval).

## 16. Maintenance Rules (Enforced)
- Update the Decision Log (Section 13) for architecture-impacting changes; reference PR/commit IDs.
- Update Backlog item statuses and owners with each commit that affects them; include PR links.
- Weekly governance review: triage risks, adjust SLOs, re-prioritize backlog.
- Keep all related artifacts (API specs, diagrams) embedded or linked here with anchors.
