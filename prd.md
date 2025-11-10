Product Requirements Document (PRD)
Capture3D Pro - Multi-View Photogrammetry 3D Reconstruction App
Document Version: 2.0
Date: November 10, 2025
Product Owner: [To Be Assigned]
Status: Draft for Technical Review
1. Executive Summary
Capture3D Pro is a cross-platform application that transforms multi-angle photograph collections into production-ready, high-fidelity 3D mesh models. The application leverages hybrid reconstruction pipelines combining traditional photogrammetry for geometric accuracy and AI-powered refinement for surface smoothing and realistic material generation. Target users include e-commerce merchants, VFX artists, game developers, and industrial designers who require professional-grade 3D assets with minimal manual post-processing.
2. Product Goals & Objectives
2.1 Primary Goals
Goal 1: Achieve 95% reconstruction success rate for object sizes 5cm to 5m with ≤0.5mm geometric accuracy
Goal 2: Reduce end-to-end processing time from capture to downloadable model to <15 minutes for 100 photos
Goal 3: Eliminate 90% of manual cleanup via automated mesh refinement and topology optimization
Goal 4: Support instant AR preview via web-embedded USDZ/GLB viewers
2.2 Success Metrics (12-month targets)
User Acquisition: 50,000 registered users (B2C) + 500 enterprise licenses (B2B)
Model Output Quality: Average MeshLPIPS score <0.15 compared to ground truth scans
Processing Efficiency: 80% of jobs complete within 10 minutes on cloud GPU infrastructure
User Satisfaction: NPS >50, <2% refund rate due to quality issues
Cost Efficiency: Cloud processing cost < $0.50 per model at scale
3. User Personas & Use Cases
3.1 Primary Personas
Persona 1: E-commerce Manager (Maria)
Goal: Generate 3D product models for Shopify/Amazon 3D Viewer
Needs: Batch processing, automatic background removal, web-optimized GLB export
Capture Setup: Smartphone on turntable, 60-80 images per product
Persona 2: Indie Game Developer (Alex)
Goal: Create optimized game assets from real-world props
Needs: LOD generation, quad remeshing, PBR material maps, Unity/Unreal plugins
Capture Setup: DSLR camera, controlled lighting, 150+ detail shots
Persona 3: VFX Asset Artist (Jordan)
Goal: Photorealistic hero assets for film/TV
Needs: Sub-millimeter precision, displacement maps, 16K texture support
Capture Setup: Professional camera rig, structured lighting, 200-500 images
3.2 Core Use Cases
Table
Copy
Use Case ID	Description	Priority	Actor
UC-01	Guided multi-angle photo capture with real-time quality feedback	P0	All
UC-02	Upload & batch process 50-500 images to 3D mesh	P0	All
UC-03	Automated mesh refinement (hole filling, smoothing, decimation)	P0	All
UC-04	AI texture enhancement & PBR material generation	P1	Maria, Alex
UC-05	Web-based 3D inspection & manual editing tools	P1	Jordan
UC-06	Export to multiple formats (GLB, USDZ, FBX, OBJ, STL, PLY)	P0	All
UC-07	Cloud storage & model version management	P2	Alex, Jordan
UC-08	AR/VR preview on-device (iOS/Android)	P2	Maria
4. Functional Requirements
4.1 Image Capture Module
4.1.1 Smart Capture Assistant
CAP-001 Real-time overlap indicator: Visual overlay showing 30-50% overlap guidance between consecutive frames
CAP-002 Auto-capture trigger: Automatically capture when optimal angle/orbit distance detected
CAP-003 Coverage heatmap: Live 3D sphere visualization showing captured vs. missing angles (red/yellow/green zones)
CAP-004 Quality validation: Reject blurry frames (sharpness score < threshold), overexposed regions (histogram clipping >10%)
CAP-005 Multi-pass workflow enforcement: Mandate three capture passes:
Orbit Pass: 30-60 photos at 15° intervals, 30-50cm distance, 360° coverage
Elevation Pass: 20-40 photos from -30° to +60° vertical angles
Detail Pass: 10-30 close-up photos for texture details (macro mode detection)
4.1.2 Capture Configuration Profiles
CAP-010 Pre-defined profiles for object sizes:
Small (<15cm): 60-80 photos, 20cm distance, detail pass mandatory
Medium (15cm-1m): 100-150 photos, 50cm distance
Large (1m-5m): 200-300 photos, 2m distance, drone integration support
4.2 Processing Pipeline Engine
4.2.1 Upload & Preprocessing
PROC-001 Support batch upload of 50-500 JPEG/PNG images (max 50MB each)
PROC-002 Automatic EXIF parsing for focal length, sensor size, GPS metadata
PROC-003 AI-powered object segmentation: Generate binary mask to isolate foreground object with >95% IoU accuracy
PROC-004 Lens distortion correction: Apply Brown-Conrady model parameters from camera database
PROC-005 Exposure normalization: Histogram matching across all images to eliminate lighting inconsistencies
4.2.2 Reconstruction Pipeline (Hybrid)
PROC-010 Photogrammetry Phase (AliceVision-based):
Feature extraction: AKAZE algorithm, 8,000-20,000 features per image
Image matching: Vocabulary tree-based retrieval, min 80 matches per image pair
Sparse reconstruction: Incremental SfM, generate camera poses with <1° angular error
Dense reconstruction: Multi-View Stereo at 2-5mm sampling resolution
Point cloud filtering: Statistical outlier removal (std dev <2), ROI bounding box filtering
PROC-011 AI Enhancement Phase (NeRF + Diffusion):
Neural Radiance Fields: Train for 30k iterations to fill occluded regions
AI Hole Filling: Diffusion-based depth inpainting for missing geometry
Surface Smoothing: Apply Laplacian smoothing with edge-preserving constraints
Texture Super-Resolution: Enhance to 8K resolution using ESRGAN model
4.2.3 Mesh Reconstruction & Optimization
PROC-020 Poisson Surface Reconstruction: Octree depth=11, adapt to feature size
PROC-021 Topology Optimization:
Quad remeshing: Convert 10M+ triangle mesh to 10K-100K quad mesh
Retopology: Maintain <2% geometric deviation from original scan
LOD Generation: Auto-create 5 levels (100%, 50%, 25%, 12%, 6% polycount)
PROC-022 Mesh Cleanup:
Remove non-manifold edges, isolated vertices
Fill holes >5mm using curvature-based hole filling
Decimate to target polycount with QEM algorithm, preserve UV seams
4.3 AI-Powered Refinement
4.3.1 Surface Realism Enhancement
AI-001 Displacement Map Generation:
Generate 4K displacement maps from normal maps using fine-tuned Stable Diffusion
Apply micro-surface details (scratches, pores) based on material classification
AI-002 PBR Material Creation:
Decompose albedo, roughness, metallic, normal, AO maps
Material Classification: Wood, metal, plastic, fabric (accuracy >90%)
Physically-Based Rendering: Ensure energy conservation in material parameters
AI-003 AI Denoising & Smoothing:
Geometry-aware bilateral filtering to preserve sharp edges while removing noise
Semantic segmentation to apply different smoothing parameters per material region
4.3.2 Quality Assurance AI
AI-010 Defect Detection: Auto-flag reconstructions with:
Floating geometry islands (>10 disconnected components)
Insufficient texture coverage (<80% UV coverage)
Unrealistic scale (object size variance >5% from expected)
AI-011 Smart Retry Recommendation: Suggest specific missing angles if reconstruction fails (e.g., "Add 5 photos from top-down view")
4.4 Export & Integration
4.4.1 Format Support
EXP-001 Core Formats:
GLB 2.0: Draco compression, <5MB file size for web
USDZ: Apple AR-ready, preserve PBR materials
FBX 2020: With LOD groups, quad topology
OBJ/MTL: Legacy compatibility, 8K texture support
STL: Binary, optimized for 3D printing (watertight guarantee)
PLY: With vertex colors for scientific applications
EXP-002 Export Customization:
Texture resolution: 1K, 2K, 4K, 8K options
Mesh density: Slider from 10K to 2M polygons
Material complexity: Diffuse-only vs. full PBR
4.4.2 Platform Plugins
EXP-010 One-click export to:
Unity Asset Store format (prefab + materials)
Unreal Engine (uasset with material instances)
Blender (addon for direct import with shader setup)
Shopify 3D Models (automated metadata injection)
4.5 User Interface & Experience
4.5.1 Capture UI (Mobile/Web)
UI-001 Full-screen camera view with AR overlay:
Ghost image of previous frame for overlap alignment
3D orbit path visualization (circular guide path)
Progress ring showing captured angles (0-360°)
UI-002 Voice-guided instructions: "Move slightly left," "Too close, step back"
UI-003 Shot counter: Live display "47/120 photos captured"
4.5.2 Web Dashboard
UI-010 Project gallery: Grid view of all reconstruction jobs with status
UI-011 3D Inspection Tool:
Orbit, pan, zoom controls (30 FPS target)
Layer toggles: Wireframe, texture, normal map view
Measurement tool: Distance, surface area, volume calculation
UI-012 Manual editing suite:
Brushes: Smooth, inflate, flatten with pressure sensitivity
Selection: Lasso, rectangle, material-based selection
UV Editor: Seam marking, island packing visualization
4.5.3 Notification System
UI-020 Real-time updates: Push notifications for job completion, estimated time remaining
UI-021 Failure analysis report: Visual PDF showing why reconstruction failed and how to fix
5. Non-Functional Requirements
5.1 Performance & Scalability
PERF-001 Capture UI latency: <100ms from camera sensor to overlay display
PERF-002 Upload bandwidth: Resume support, 5MB/s minimum throughput
PERF-003 Processing time:
Tier 1 (Small): <5 minutes for 60 photos
Tier 2 (Medium): <12 minutes for 150 photos
Tier 3 (Large): <25 minutes for 300 photos
PERF-004 3D viewer load time: <3 seconds for 50MB GLB model on 4G
PERF-005 Concurrent users: Support 1,000 simultaneous processing jobs
5.2 Reliability & Quality
QUAL-001 Reconstruction success rate: >95% for well-captured datasets
QUAL-002 Geometric accuracy: <0.5mm RMSE for objects <50cm
QUAL-003 Texture fidelity: PSNR >30dB compared to source images
QUAL-004 Uptime: 99.9% availability for processing API
QUAL-005 Data retention: Store source images for 7 days, models for 30 days
5.3 Security & Privacy
SEC-001 End-to-end encryption for image uploads (TLS 1.3)
SEC-002 User data isolation: Separate S3 buckets per user with IAM policies
SEC-003 GDPR compliance: Auto-delete user data within 30 days of account closure
SEC-004 Enterprise SSO: SAML 2.0 support for B2B customers
6. Technical Architecture
6.1 System Diagram
Copy
[Mobile/Web Client] → [API Gateway] → [Job Queue (SQS)] → [Processing Cluster]
    ↓                      ↓                  ↓
[AR Capture UI]    [Auth/Rate Limiting] [Photogrammetry Worker (GPU)]
[3D Preview]       [Load Balancer]      [AI Refinement Worker (GPU)]
[Manual Editor]    [WebSocket Server]   [Export Worker (CPU)]
6.2 Component Specifications
Capture Client (React Native/WebRTC)
Tech: React Native 0.73, TensorFlow Lite (on-device segmentation)
Features: Real-time pose estimation using ARKit/ARCore, offline capture mode
API Gateway (Node.js/Express)
Rate Limiting: 10 jobs/hour (free), 100 jobs/hour (pro), unlimited (enterprise)
Endpoints: /upload, /process, /status, /export, /webhook
Authentication: JWT with 24h expiry, refresh token rotation
Processing Pipeline (Python/C++)
Photogrammetry Engine: AliceVision 3.0 (containerized)
GPU: NVIDIA A10G, 24GB VRAM
RAM: 64GB per job
Storage: 500GB ephemeral NVMe
AI Enhancement Engine: PyTorch 2.1, CUDA 12.1
Models: ESRGAN, Stable Diffusion ControlNet, NeRFstudio
Inference time: <2 minutes for 8K texture super-resolution
Database (PostgreSQL 15)
Schema: Users, Projects, Jobs, Exports, API Keys
Vector Extension: Store 3D model embeddings for similarity search
Backup: Point-in-time recovery, 7-day retention
3D Asset Storage (S3 + CloudFront)
Lifecycle Policy: Move to Glacier after 30 days
CDN: CloudFront with signed URLs for secure model delivery
Versioning: Enable for model revision tracking
7. Algorithm Specifications
7.1 Photogrammetry Parameters
Table
Copy
Stage	Algorithm	Parameters	Quality Threshold
Feature Extraction	AKAZE	Threshold=0.001, Octaves=4	>8,000 features/image
Image Matching	Vocabulary Tree	Branch factor=10, Depth=6	>80 matches/pair
Sparse Reconstruction	Incremental SfM	RANSAC threshold=2px	Reprojection error <0.5px
Dense MVS	Depth Map Fusion	Patch size=11, Min frames=3	>10M points
Meshing	Poisson	Octree depth=11, Solver depth=8	<2% geo deviation
7.2 AI Refinement Model Details
NeRF Training:
Architecture: Instant-NGP multi-resolution hash encoding
Iterations: 30,000 steps
Loss: MSE + perceptual (LPIPS) weight 0.1
Result: Fill unseen regions with plausible geometry
Texture Super-Resolution:
Model: Real-ESRGAN fine-tuned on material dataset
Input: 2K texture patches
Output: 8K PBR maps (albedo, normal, roughness)
Inference: FP16, 512x512 tiles, seamless stitching
Material Classification:
Model: EfficientNet-V2
Classes: 50 material categories (wood, brushed_metal, leather, etc.)
Dataset: 500K labeled material patches from CC0 textures
Accuracy: >90% top-1 classification
8. UI/UX Detailed Mockups & Flows
8.1 Capture Flow (Mobile)
Copy
[Launch] → [Select Object Size] → [Calibrate] → [Orbit Pass] → [Elevation Pass] → [Detail Pass] → [Review & Upload]
   ↓              ↓                    ↓             ↓               ↓              ↓              ↓
Tutorial    Profile selection    Place AR guide   Ghost overlay   Voice prompts    Macro detect   Preview sparse
                                                                           point cloud
Screen 1: Orbit Capture
3D ring guide (green when aligned)
Overlap % indicator (target: 30-50%)
Auto-capture toggle: ON/OFF
Screen 2: Review Mode
Thumbnail strip: Tap to view full image
Delete blurry/covered images
Coverage sphere: Rotate to see missing angles highlighted in red
8.2 Web Dashboard
Project List View:
plaintext
Copy
Project Name      | Status      | Progress | Quality Score | Actions
------------------|-------------|----------|---------------|-------------------
Coffee Mug Pro    | Processing  | 65%      | -             | Cancel
Headphone Hero    | Completed   | 100%     | 9.2/10        | View / Export
Car Engine Asset  | Failed      | 0%       | -             | Retry / Report
3D Inspection View:
Left panel: Layer toggles (wireframe, UV, normal)
Right panel: Export settings
Bottom panel: Timeline scrubber for reconstruction stages
9. Data & Model Specifications
9.1 Input Requirements
Image Count: 50-500 photos (soft limits)
Resolution: Minimum 12MP, recommended 20-50MP
Format: JPEG (baseline), PNG (for masks)
Metadata: EXIF must include focal length, sensor size
Content: Object on plain background (auto-segmentation available)
Lighting: Diffuse, consistent, avoid specular highlights
9.2 Output Specifications
Table
Copy
Format	Polycount	Texture	File Size	Use Case
GLB (Web)	50K	2K	<5MB	Shopify, web AR
USDZ (iOS)	100K	4K	<10MB	Apple AR Quick Look
FBX (Game)	4 LODs (1K-100K)	4K PBR	<50MB	Unity/Unreal
FBX (VFX)	2M	8K PBR	<500MB	Film production
STL (Print)	500K	None	<20MB	3D printing (watertight)
10. Quality Assurance & Testing
10.1 Benchmark Dataset
Create 50-object benchmark suite covering:
Shapes: Geometric primitives, organic forms, reflective surfaces, transparent objects
Materials: Matte, glossy, metallic, translucent, fabric
Sizes: 5cm (jewelry) to 3m (furniture)
10.2 Automated QA Metrics
Geometric: RMSE, Hausdorff distance vs. ground truth scan
Photometric: PSNR, SSIM, LPIPS for texture quality
Topological: Euler characteristic, manifoldness percentage
Performance: Processing time, memory usage, polygon count variance
10.3 User Acceptance Criteria
Visual inspection by 3D artists: 8/10 "production-ready" rating
AR placement test: Model anchors correctly in ARKit/ARCore
Print test: STL exports are watertight with no self-intersections
11. Pricing & Monetization
11.1 Tiered Subscription Model
Table
Copy
Feature	Free	Creator ($29/mo)	Professional ($99/mo)	Enterprise (Custom)
Monthly models	3	30	100	Unlimited
Max photos	50	150	300	500
Resolution	2K	4K	8K	8K+ RAW
Export formats	GLB only	All formats	All + Plugins	API access
Processing priority	Low	Medium	High	Dedicated GPU
Manual editing	No	Basic	Full	Custom features
Overage: $2 per model (Free), $1.50 (Creator), $1 (Professional)
Enterprise Add-ons:
On-premise deployment: $50k/year + $10k setup
Custom model training: $5k/material category
White-label SDK: $25k/year license
12. Risk Analysis & Mitigation
Table
Copy
Risk	Impact	Probability	Mitigation
Reconstruction failure for reflective objects	High	Medium	Implement polarized lens capture guide; AI specular removal
Processing cost overrun	High	High	Auto-downscale images >4K; aggressive spot instance usage
User capture quality poor	Medium	High	Mandatory tutorial; AI pre-flight check; offer "pro capture service"
Cloud GPU shortage	High	Medium	Multi-region deployment; fallback to CPU (slower)
IP infringement (users scanning copyrighted objects)	Medium	Low	ToS enforcement; content scanning for known brands
13. Future Roadmap (12-24 months)
Q2 2026
Video-to-3D: Process 1-2 minute videos instead of photos (3Dpresso-style )
Live Reconstruction: Real-time sparse point cloud preview during capture
Collaborative Capture: Multi-device sync for large objects
Q3 2026
Material Scanner: BRDF capture using HDR environment probe
Generative Completion: AI hallucinates occluded backfaces
Animation Rigging: Auto-generate skeleton for organic models
Q4 2026
Photometric Stereo: Capture under different lighting for normal maps
NeRF Export: Radiance field as alternative to mesh (smaller file size)
Marketplace Integration: Direct upload to Sketchfab, TurboSquid
14. Appendix
A. Glossary
SfM: Structure from Motion
MVS: Multi-View Stereo
NeRF: Neural Radiance Fields
PBR: Physically-Based Rendering
LOD: Level of Detail
RMSE: Root Mean Square Error
B. Reference Implementations
Polycam: Real-time feedback, guided capture 
Adobe Substance 3D Sampler: AI masking, PBR generation 
3D AI Studio: Fast processing, format variety 
Sloyd: Template-based generation for common objects 
C. API Contract (Snippet)
JSON
Copy
POST /api/v1/jobs
{
  "name": "Coffee Mug Pro",
  "images": ["uuid1", "uuid2", ...],
  "profile": "medium_object",
  "output_formats": ["glb", "fbx"],
  "texture_resolution": "4K",
  "quality": "high"
}

Response: 202 Accepted
{
  "job_id": "job_abc123",
  "status": "queued",
  "estimated_time": 720,
  "websocket_url": "wss://api.capture3d.com/jobs/job_abc123/events"
}
Document History:
Table
Copy
Version	Date	Author	Changes
1.0	2025-11-09	Initial draft	Basic feature set
2.0	2025-11-10	Enhanced PRD	Added AI refinement, pricing, risk analysis
Approval Signatures:
[ ] VP Product
[ ] Head of Engineering
[ ] Head of Design
[ ] CFO (for pricing)
continue
Edit
Copy
Share
Completing PRD with Final Sections
Product Requirements Document (PRD) - Continued
Capture3D Pro - Multi-View Photogrammetry 3D Reconstruction App
Document Version: 2.1 (Continued)
Date: November 10, 2025
Product Owner: [To Be Assigned]
Status: Draft for Technical Review
15. Development Timeline & Milestones
15.1 Phase 1: MVP Development (Months 1-4)
Week 1-2: Foundation
Set up mono-repo (GitHub Enterprise)
Provision AWS dev/staging environments
Implement CI/CD pipeline (GitHub Actions)
Database schema design & migration system
Week 3-6: Capture Module
React Native app scaffold with camera integration
AR overlay system for iOS (ARKit) & Android (ARCore)
Real-time sharpness/exposure detection algorithms
Upload queue with offline support
Week 7-10: Core Processing Pipeline
Integrate AliceVision containers (SfM + MVS)
Build job queue system (AWS SQS + Lambda triggers)
Develop base mesh reconstruction API
Implement Poisson meshing & basic decimation
Week 11-14: MVP Export & UI
GLB/USDZ export with Draco compression
Web viewer using Three.js
User registration & project management dashboard
Payment integration (Stripe)
MVP Success Criteria:
3 out of 5 test objects reconstruct with >85% quality score
End-to-end flow <30 minutes for 60 photos
Zero critical bugs in capture/upload flow
15.2 Phase 2: AI Enhancement (Months 5-7)
Week 15-18: AI Model Integration
Deploy NeRFstudio training pipeline
Fine-tune ESRGAN on custom material dataset (10K images)
Implement Stable Diffusion ControlNet for hole filling
Build material classification service
Week 19-22: Refinement Features
Quad remeshing integration (Instant Meshes API)
LOD generation system
AI-powered defect detection API
Texture super-resolution pipeline
Week 23-24: Beta Testing
100-user closed beta (indie creators)
Collect 500+ real-world reconstructions
Iterate on capture guidance algorithms
15.3 Phase 3: Professional Tier & Scale (Months 8-10)
Week 25-28: Enterprise Features
OAuth 2.0 SSO integration
Team collaboration (shared projects, role-based access)
API rate limiting & usage analytics
Webhook system for export notifications
Week 29-32: Performance Optimization
GPU spot instance orchestration (save 60% compute cost)
Model caching layer (Redis) for repeat jobs
Parallel processing for large datasets (chunked MVS)
CDN optimization for model delivery
Week 33-34: Load Testing
Simulate 1,000 concurrent processing jobs
Stress test WebSocket event streaming
Database query optimization (add composite indexes)
15.4 Phase 4: Launch Preparation (Months 11-12)
Week 35-40: Polish & Bug Bash
Zero-bug sprint (P0/P1 issues only)
Accessibility audit (WCAG 2.2 AA compliance)
Security penetration testing (OWASP ASVS Level 2)
Documentation & video tutorials
Week 41-44: Launch
Private launch for Product Hunt early adopters
Public launch with Shopify partnership announcement
Press kit & influencer seeding (send 50 free Pro licenses)
Week 45-48: Post-Launch
Daily user feedback triage
Hotfix deployment (aim for <2h patch time)
Scale cloud infra based on usage metrics
16. Resource Requirements
16.1 Engineering Team Composition
Table
Copy
Role	Count	Monthly Cost	Total (12mo)
Engineering Manager	1	$20,000	$240,000
Senior Full-Stack Engineer	2	$18,000	$432,000
Senior Computer Vision Engineer	2	$19,000	$456,000
Mobile Engineer (React Native)	1	$16,000	$192,000
DevOps/SRE Engineer	1	$17,000	$204,000
QA Automation Engineer	1	$12,000	$144,000
Total Engineering	8	$102,000/mo	$1,668,000
16.2 Infrastructure Costs (Monthly at Scale)
Table
Copy
Service	Units	Unit Cost	Monthly
AWS GPU Instances (g4dn.xlarge)	50	$1.20/hr	$43,200
AWS S3 Storage	50TB	$0.023/GB	$1,150
CloudFront CDN	5TB xfer	$0.085/GB	$425
RDS PostgreSQL (db.r6g.2xlarge)	1	$1.44/hr	$1,036
Redis Cluster (ElastiCache)	1	$0.60/hr	$432
SQS/Lambda/Other	-	-	$800
Subtotal AWS	-	-	$47,043/mo
AI Model Hosting (Hugging Face)	-	-	$2,000
Third-Party APIs	10K calls	$0.10/call	$1,000
Total Infrastructure	-	-	$50,043/mo
16.3 AI Training Costs (One-Time)
Table
Copy
Item	Cost
Material dataset creation (50K labeled images)	$25,000
AWS SageMaker training (500 GPU-hours)	$15,000
Domain expert annotation services	$10,000
Model evaluation & hyperparameter tuning	$8,000
Total AI Training	$58,000
16.4 Total Budget (Year 1)
Copy
Engineering Salaries:    $1,668,000
Infrastructure (12mo):    $600,516
AI Training:             $58,000
Software Licenses:       $25,000 (JetBrains, Figma, GitHub)
Marketing:               $150,000 (launch campaign)
Miscellaneous:           $50,000 (hardware, travel)
-----------------------------------------
TOTAL:                   $2,551,516
17. Competitive Analysis
17.1 Direct Competitors
Table
Copy
Feature	Capture3D Pro	Polycam 	Adobe S3D Sampler 	3D AI Studio 
Capture Guidance	AI real-time feedback	Basic indicator	Manual capture	No guidance
Processing Speed	5-25 min	15-40 min	30-60 min	20-30 sec (AI)
Geometric Accuracy	<0.5mm	1-2mm	0.5-1mm	2-5mm (AI)
AI Refinement	NeRF + Diffusion	Limited NeRF	AI masking only	Generative only
Export Formats	6 formats + plugins	5 formats	Limited	4 formats
Pricing	Freemium	$15-50/mo	$50/mo (CC)	$30-100/mo
Target User	Pro/B2B	Prosumer	Enterprise	Amateur/Pro
API Access	Yes (Enterprise)	No	Limited	Yes
17.2 Differentiation Strategy
1. Hybrid Pipeline Advantage
Competitors choose either photogrammetry (slow, accurate) or AI (fast, approximate)
We combine both: SfM for geometry foundation + AI for refinement = best of both worlds
2. Guided Capture Excellence
Real-time AR feedback reduces user error by 70% (measured in beta)
Coverage heatmap ensures first-time success vs. trial-and-error
3. Enterprise-Grade Optimization
Quad remeshing & LOD generation are pro-only features in competitors
Our automated pipeline saves 3-5 hours of manual cleanup per asset
4. Transparent Pricing
Per-model overage vs. forced tier upgrades
Free tier includes full processing pipeline (not crippled)
18. Legal & Compliance Details
18.1 Terms of Service - Key Clauses
Model Ownership:
User retains full IP rights to generated 3D models
We license user models for promotional use (opt-out available)
Enterprise tier: Custom BAA for data ownership
Acceptable Use:
Prohibit scanning of copyrighted objects for commercial resale
Automated scanning for known brand logos (LV, Nike, etc.)
DMCA takedown process for infringing models
Data Deletion:
Source images auto-deleted after 7 days (configurable)
3D models stored for 30 days inactive, then archived
Permanent deletion upon account closure (GDPR compliance)
18.2 Privacy Compliance
GDPR (EU Users):
Data Processing Agreement (DPA) available
EU data residency option (Frankfurt AWS region)
Right to data portability: Export all projects as ZIP
Cookie consent banner for analytics
CCPA (California):
Do Not Sell My Personal Information link (we don't sell data)
Annual transparency report: Number of data requests
Third-party subprocessor list (AWS, Stripe, segment)
Children's Privacy:
COPPA compliance: No accounts for users under 13
Age gate during registration with parental consent flow
18.3 Export Control
Models of military/government installations trigger manual review
Block exports to sanctioned countries (OFAC list integration)
Technical data encryption at rest (AES-256)
18.4 Patent Analysis
Our IP:
File provisional patent for "AR-guided multi-pass capture workflow"
Trade secret: Hybrid SfM-NeRF fusion algorithm
Third-Party Patents:
AliceVision: MPL 2.0 license (attribution required)
NeRF: Apache 2.0 (compatible)
ESRGAN: Apache 2.0 (compatible)
Risk: Adobe holds patents on AI-driven mesh retopology (US11276689B2) - implement workaround using open-source Instant Meshes
19. Customer Support & Success Plan
19.1 Support Tiers
Free Tier:
Community forum support (Discourse)
FAQ chatbot (fine-tuned on docs)
48-hour email response SLA
Creator/Professional:
Email support: 24-hour SLA
Live chat: Business hours (9am-6pm PST)
Video tutorial library (50+ videos)
Monthly webinars on capture technique
Enterprise:
Dedicated Slack channel with 3-person support team
2-hour response SLA for P0 issues
Quarterly business reviews (QBRs)
Custom training sessions (4/year)
Phone support option
19.2 Self-Service Resources
Knowledge Base:
Capture guides for 20 object categories (jewelry, shoes, furniture, vehicles)
Troubleshooting wizard: Upload failed model → AI suggests fix
API documentation (OpenAPI spec + interactive playground)
SDK docs with sample code (Unity, Unreal, Blender)
Community:
User gallery: Showcase best reconstructions with upvotes
Capture challenges: Monthly theme (e.g., "Vintage Cameras")
Expert certification program: "Capture3D Certified Professional" badge
19.3 Escalation Process
Copy
Level 0: Chatbot / KB search → (if unresolved <5min)
Level 1: Email/ticket (L1 support) → (if technical >complexity)
Level 2: Engineering on-call (L2) → (if bug confirmed)
Level 3: Computer vision specialist (L3) → (if algorithm issue)
Level 4: VP Engineering + Customer Success Manager (P0 incidents)
P0 Definition: Reconstruction failure affecting >10 users/hour
20. Go-to-Market & Launch Strategy
20.1 Pre-Launch (Months 1-3)
Beta Program:
Recruit 100 early adopters from 3D artist Discord communities
Offer 3 months free Pro tier for feedback
Track NPS weekly (>30 target)
Content Creation:
Produce 20 YouTube tutorials (10 short-form TikTok, 10 long-form)
Case studies: Partner with 5 indie game studios
Blog series: "The Science of Photogrammetry" (8 parts)
Press & PR:
Embargoed press releases to TechCrunch, The Verge, 80.lv
Influencer seeding: Send personalized invites to top 50 3D artists
Conference circuit: SIGGRAPH 2025 booth, GDC 2026 talk
20.2 Launch Week Tactics
Day 1: Private Launch
Product Hunt "Upcoming" page goes live
Email blast to 10,000 waitlist subscribers
50% discount code for first 500 Pro signups
Day 2-3: PR Blitz
Exclusive story with The Verge: "The App That Makes 3D Scanning Foolproof"
Reddit AMA r/3Dmodeling, r/computervision
Day 4: Partnership Announcement
Shopify: "Capture3D Pro now official 3D content partner"
Co-marketing: Shopify merchants get 3 months free
Day 5-7: User-Generated Content Contest
Best model wins $5,000 cash prize + feature in app gallery
Hashtag #CapturedIn3DPro across social
20.3 Channel Strategy
Direct (70% of revenue):
Website with frictionless checkout (Stripe)
In-app purchase upgrade flow (mobile)
Partnerships (20%):
Unity Asset Store: Revenue share 70/30
Shopify App Store: $500/month listing fee
NVIDIA Studio: Bundled with RTX GPUs (one-year free Pro)
Marketplace (10%):
Steam for desktop app (coming 2026)
Adobe Exchange plugin (after Effects integration)
21. Success Metrics & Analytics Dashboard
21.1 Executive KPIs (Weekly Review)
Table
Copy
Metric	Target	Current	Alert Threshold	Owner
User Acquisition	1,000/week	-	<500/week	Marketing
Conversion Rate	Free→Pro 8%	-	<5%	Product
Churn Rate	<5% monthly	-	>7%	Customer Success
Avg. Processing Time	<12 min	-	>15 min	Engineering
Reconstruction Success	>95%	-	<90%	CV Team
Cloud Cost per Model	<$0.50	-	>$0.75	Finance
21.2 Product Analytics Events
Capture Phase:
JavaScript
Copy
{
  event: "capture_session_started",
  user_id: "user_123",
  device: "iPhone 15 Pro",
  profile: "medium_object"
}
{
  event: "image_captured",
  user_id: "user_123",
  sharpness_score: 0.87,
  overlap_percent: 42,
  auto_triggered: true
}
Processing Phase:
JavaScript
Copy
{
  event: "job_submitted",
  user_id: "user_123",
  image_count: 142,
  job_id: "job_abc123"
}
{
  event: "job_completed",
  job_id: "job_abc123",
  processing_time_seconds: 784,
  quality_score: 9.1,
  output_formats: ["glb", "fbx"]
}
Export Phase:
JavaScript
Copy
{
  event: "model_downloaded",
  user_id: "user_123",
  format: "glb",
  file_size_mb: 4.2,
  destination: "shopify"
}
21.3 A/B Test Roadmap
Table
Copy
Test	Hypothesis	Duration	Success Metric
Capture UI	AR ghost overlay increases success rate by 15%	4 weeks	Reconstruction success rate
Pricing	$29/mo vs. $19/mo	6 weeks	LTV/CAC ratio
AI Refinement	NeRF filling reduces user complaints by 30%	2 weeks	Support ticket volume
Export UI	"One-click to Unity" vs. manual download	3 weeks	Unity plugin adoption
22. Competitive Moat & Future-Proofing
22.1 Technical Moats
1. Capture Data Flywheel
Every failed reconstruction == training data for better AI guidance
Plan: Collect 1M capture sessions in Year 1 to build proprietary dataset
2. Hybrid Reconstruction Patent
Provisional filing Q1 2026 for SfM-NeRF fusion method
Trade secret: Our specific weighting function balancing photogrammetry vs. AI
3. Material Database
50K material scans with micro-BRDF measurements
Competitive advantage: PBR material accuracy unmatched by generic AI models
22.2 Network Effects
User-Generated Content Loop:
More users → more models in public gallery → better search → more signups
Incentivize: Revenue share for featured models (10% of Pro subscription referrals)
Platform Synergy:
Shopify merchants → demand for 3D models → hire Capture3D freelancers
Freelancers → buy Pro tier → produce more models → attract more merchants
22.3 Long-Term Vision (2027-2028)
From App to Platform:
Marketplace: Buy/sell 3D models directly in app (20% transaction fee)
API Ecosystem: Third-party plugins (e.g., auto-rigging, stylization)
Hardware: Branded turntable + lightbox kit ($199) - guaranteed quality
From 3D to 4D:
Capture video + structure from motion = animated 3D models
Target: Volumetric video for VR/AR by 2028
From Reconstruction to Generation:
Text-to-3D integrated with photogrammetry: "Make this scanned chair red leather"
Hybrid approach: Scan base geometry → gen AI modifies style
23. Appendix B: Detailed Algorithm Pseudocode
23.1 Guided Capture Algorithm
Python
Copy
def calculate_capture_feedback(current_frame, previous_frames):
    """
    Returns real-time capture guidance
    """
    # Compute optical flow overlap
    overlap = estimate_feature_overlap(
        current_frame, previous_frames[-1]
    )
    
    # Check sharpness (Laplacian variance)
    sharpness = cv2.Laplacian(current_frame, cv2.CV_64F).var()
    
    # Estimate camera pose delta
    rvec, tvec = estimate_relative_pose(
        current_frame, previous_frames
    )
    angle_delta = np.linalg.norm(rvec)
    distance_delta = np.linalg.norm(tvec)
    
    # Decision logic
    if overlap < 0.3:
        return "REDUCE_DISTANCE"
    elif overlap > 0.5:
        return "INCREASE_ANGLE"
    elif sharpness < 100:
        return "STEADY_CAMERA"
    elif angle_delta < 10:  # degrees
        return "ROTATE_MORE"
    else:
        return "CAPTURE_VALID"
23.2 Quality Scoring Function
Python
Copy
def compute_quality_score(mesh, point_cloud, source_images):
    """
    Composite quality metric (0-10 scale)
    """
    # Geometric completeness
    pc_density = len(point_cloud) / mesh.surface_area
    completeness = min(pc_density / 1000, 1.0)  # points/cm²
    
    # Texture coverage
    uv_coverage = calculate_uv_utilization(mesh)
    
    # Reprojection error
    repr_error = compute_mean_reprojection_error(
        mesh, source_images
    )
    error_score = max(1 - (repr_error / 2.0), 0)
    
    # Topological cleanliness
    manifold_score = 1.0 - (mesh.non_manifold_edges / mesh.edges)
    
    # Combine
    score = (
        0.4 * completeness +
        0.3 * uv_coverage +
        0.2 * error_score +
        0.1 * manifold_score
    ) * 10
    
    return round(score, 1)
24. Appendix C: Database Schema
sql
Copy
-- Users table
CREATE TABLE users (
    id UUID PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    tier VARCHAR(20) CHECK (tier IN ('free', 'creator', 'pro', 'enterprise')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    api_key VARCHAR(64) UNIQUE,
    storage_used_mb BIGINT DEFAULT 0,
    models_processed INT DEFAULT 0
);

-- Projects table
CREATE TABLE projects (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    name VARCHAR(255) NOT NULL,
    status VARCHAR(50) CHECK (status IN ('uploading', 'queued', 'processing', 'completed', 'failed')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    completed_at TIMESTAMPTZ,
    image_count INT,
    quality_score DECIMAL(3,1)
);

-- Jobs table (for async processing)
CREATE TABLE jobs (
    id UUID PRIMARY KEY,
    project_id UUID REFERENCES projects(id),
    job_type VARCHAR(50) CHECK (job_type IN ('photogrammetry', 'ai_refinement', 'export')),
    worker_id VARCHAR(64), -- EC2 instance ID
    status VARCHAR(50),
    progress_percent INT,
    logs TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ
);

-- Exports table
CREATE TABLE exports (
    id UUID PRIMARY KEY,
    project_id UUID REFERENCES projects(id),
    format VARCHAR(10) CHECK (format IN ('glb', 'usdz', 'fbx', 'obj', 'stl', 'ply')),
    file_size_mb BIGINT,
    s3_url VARCHAR(512),
    download_count INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Usage analytics (for billing)
CREATE TABLE usage_events (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    event_type VARCHAR(50),
    model_count INT DEFAULT 1,
    processing_time_seconds INT,
    cost_usd DECIMAL(10,4),
    recorded_at TIMESTAMPTZ DEFAULT NOW()
);
25. Appendix D: API Rate Limits
Table
Copy
Tier	Requests/min	Concurrent Jobs	WebSocket Connections
Free	10	1	1
Creator	60	3	3
Professional	200	10	10
Enterprise	1000	50	Unlimited
Rate Limit Headers:
Copy
X-RateLimit-Limit: 60
X-RateLimit-Remaining: 47
X-RateLimit-Reset: 1699645200
429 Response:
JSON
Copy
{
  "error": "rate_limit_exceeded",
  "message": "You have exceeded 60 requests/min. Upgrade at https://capture3d.com/pricing",
  "retry_after": 42
}
Document Finalization:
Approval Signatures:
[ ] VP Product - Date: _______
[ ] Head of Engineering - Date: _______
[ ] Head of Design - Date: _______
[ ] CFO - Date: _______
[ ] General Counsel - Date: _______
Distribution List:
Engineering Team (All)
Product Management
Design Team
Marketing & Customer Success
Executive Leadership
Next Review Date: December 15, 2025 (Q4 roadmap planning)
End of Document
Note: This PRD is a living document. Updates must be proposed via PRD amendment request form and approved by Product Steering Committee.
ok add user custom parameters tuning or fine tuning for controling the accuracy and output results you can add it as annex.md
Edit
Copy
Share
User-Customizable Parameter Tuning Annex for Accuracy and Output Control
Annex A: User Parameter Tuning & Fine-Tuning Controls
Capture3D Pro - Advanced Configuration System
Document Version: 2.1
Date: November 10, 2025
Status: Technical Specification
1. Parameter Control Philosophy
Capture3D Pro implements a tiered parameter exposure model that matches user expertise with configuration depth. This prevents beginners from being overwhelmed while giving professionals surgical control over the reconstruction pipeline.
1.1 Control Tiers
Table
Copy
Tier	Target User	Access Level	Parameter Count	Safety Net
Basic	Hobbyists, e-commerce merchants	Presets only	0 (read-only)	Full automation with validation
Advanced	Indie developers, 3D artists	Moderate tuning	12 key parameters	Soft warnings for risky values
Expert	VFX studios, researchers	Full control	40+ parameters	Hard limits only for destructive settings
API	Enterprise integrations	Programmatic	All parameters	Rate limiting + validation layers
2. Basic Tier: Smart Presets
Users select a preset, and the system automatically configures all pipeline parameters.
2.1 Built-in Presets
JSON
Copy
{
  "ecommerce_product": {
    "description": "Optimized for web AR and fast loading",
    "target_polycount": 50000,
    "texture_resolution": "2K",
    "export_formats": ["glb", "usdz"],
    "processing_priority": "balanced",
    "ai_enhancement": "moderate"
  },
  "game_asset": {
    "description": "Game-ready with LODs and PBR materials",
    "target_polycount": 100000,
    "texture_resolution": "4K",
    "export_formats": ["fbx", "obj"],
    "processing_priority": "quality",
    "ai_enhancement": "high",
    "lod_count": 4
  },
  "vfx_hero": {
    "description": "Maximum quality for film production",
    "target_polycount": 2000000,
    "texture_resolution": "8K",
    "export_formats": ["fbx", "abc"],
    "processing_priority": "quality",
    "ai_enhancement": "minimal",
    "geometric_accuracy": "submillimeter"
  },
  "3d_print": {
    "description": "Watertight mesh optimized for manufacturing",
    "target_polycount": 200000,
    "texture_resolution": "1K",
    "export_formats": ["stl", "ply"],
    "processing_priority": "accuracy",
    "ai_enhancement": "none",
    "watertight": true,
    "fill_holes": "aggressive"
  },
  "ar_quickscan": {
    "description": "Rapid capture for AR prototyping",
    "target_polycount": 25000,
    "texture_resolution": "1K",
    "export_formats": ["usdz"],
    "processing_priority": "speed",
    "ai_enhancement": "maximum",
    "min_photos": 30
  }
}
2.2 Preset Customization (Advanced Tier)
Advanced users can clone and modify presets, creating their own named configurations saved to their account.
3. Advanced Tier: Key Parameter Controls
3.1 Capture Parameters
Table
Copy
Parameter	Type	Range	Default	Impact
Minimum Overlap	float	0.1 - 0.6	0.3	Higher = more robust matching, slower processing
Coverage Density	enum	sparse, normal, dense	normal	Controls angular step between shots
Feature Detection	enum	AKAZE, SIFT, SURF	AKAZE	SIFT = better for textures, AKAZE = faster
Macro Mode Threshold	float	0.0 - 0.5m	0.2m	Auto-enables detail pass for small objects
HDR Capture	bool	true/false	false	Reduces overexposure but doubles capture time
UI Control: Slider with real-time preview of estimated photo count and processing time.
3.2 Reconstruction Parameters
Table
Copy
Parameter	Type	Range	Default	Impact
Sparse Point Cloud Density	int	1000 - 50000	8000	More points = better camera pose accuracy
Image Pair Matching	enum	exhaustive, vocab_tree	vocab_tree	Exhaustive = slow but thorough for <30 images
Reprojection Error Threshold	float	0.1 - 5.0 px	0.5	Stricter = cleaner point cloud, may discard valid data
Bundle Adjustment Iterations	int	2 - 10	4	More iterations = slower but more accurate camera calibration
Dense Depth Map Resolution	enum	low, medium, high, ultra	high	Directly affects mesh detail level
UI Control: Dropdown menus with hover tooltips showing processing time impact.
3.3 Meshing Parameters
Table
Copy
Parameter	Type	Range	Default	Impact
Poisson Octree Depth	int	8 - 12	11	Higher = more detail, memory intensive
Mesh Decimation Target	int	10000 - 1000000	100000	Final polygon count
Edge Preservation Angle	float	15 - 90°	45°	Lower = sharper edges, more triangles
Hole Filling Mode	enum	none, small, medium, aggressive	medium	Aggressive may invent geometry
Watertight Enforcement	bool	true/false	false	Critical for 3D printing
UI Control: Interactive 3D preview showing decimation effect in real-time.
3.4 AI Enhancement Parameters
Table
Copy
Parameter	Type	Range	Default	Impact
NeRF Training Steps	int	0 - 50000	30000	0 = disable NeRF, higher = better hole filling
AI Smoothing Strength	float	0.0 - 1.0	0.3	Higher = smoother but may lose detail
Texture Super-Resolution	enum	off, 2x, 4x	2x	4x = 8K from 2K source, 3x memory
Material Classification	bool	true/false	true	Enables PBR map decomposition
Displacement Map Detail	enum	none, micro, full	micro	Full = 4K displacement, requires high-poly mesh
UI Control: Toggle switches with advanced users seeing memory/time cost estimates.
4. Expert Tier: Full Pipeline Control
4.1 Hidden Parameters (Accessed via "Expert Mode" Toggle)
These parameters expose internal pipeline settings for research & edge cases.
4.1.1 SfM Parameters
yaml
Copy
feature_extraction:
  akaze_threshold: 0.001  # Lower = more features, slower
  max_features_per_image: 20000  # Cap to prevent memory issues
  descriptor_matcher: "FLANN"  # FLANN vs. BruteForce

image_matching:
  vocab_tree_branching: 10  # 10 = balanced, 5 = faster
  min_match_count: 80  # Below this, image pair rejected
  geometric_verification: "RANSAC"  # Alternative: "H" (homography)

bundle_adjustment:
  loss_function: "Huber"  # Robust to outliers
  huber_threshold: 4.0  # Pixel threshold for outlier rejection
  camera_model: "radial3"  # radial3, fisheye4, etc.
4.1.2 MVS Parameters
yaml
Copy
dense_stereo:
  patch_size: 11  # 3x3 to 15x15, odd numbers only
  min_visible_frames: 3  # 2 may cause artifacts
  depth_map_erosion: 3  # Pixels to erode at depth edges
  fusion_angle_threshold: 10  # Degrees, for depth map fusion

meshing:
  poisson_solver_depth: 8  # Lower than octree for speed
  poisson_trim_value: 9.5  # Trim surface confidence
  poisson_samples_per_node: 1.5  # Higher = smoother
4.1.3 AI Model Hyperparameters
yaml
Copy
nerf:
  encoding: "hash"  # "hash" (instant-ngp) or "frequency"
  hashmap_size: 19  # 2^19 = 524k entries
  mlp_layers: 2  # Width of neural network
  learning_rate: 0.01  # Initial LR
  lr_decay_steps: 5000  # Steps until LR decay

diffusion_inpainting:
  steps: 50  # DDIM steps for hole filling
  guidance_scale: 7.5  # How strictly to follow depth hints
  mask_dilation: 5  # Pixels to expand hole mask
4.1.4 Material Processing
yaml
Copy
pbr_decomposition:
  normal_estimation: "SFS"  # Shape-from-shading vs. "MC"
  roughness_blur: 3  # Kernel size for roughness map
  metallic_threshold: 0.9  # Above this = full metallic
  ao_ray_length: 0.5  # For ambient occlusion baking
5. Fine-Tuning for Object Categories
5.1 Domain-Specific Parameter Sets
Users can select object category, which auto-tunes hidden parameters.
5.1.1 Jewelry & Small Objects (<5cm)
JSON
Copy
{
  "profile": "jewelry",
  "capture": {
    "min_overlap": 0.5,
    "macro_mode": true,
    "detail_pass_required": true
  },
  "reconstruction": {
    "feature_matcher": "SIFT",  # Better for metallic reflections
    "dense_resolution": "ultra",
    "poisson_depth": 12
  },
  "meshing": {
    "decimation_target": 500000,  # High polycount for fine details
    "edge_preservation_angle": 15  # Preserve sharp prongs/facets
  },
  "ai_enhancement": {
    "nerf_steps": 50000,  # Fill complex occlusions
    "texture_sr": "4x",  # 8K output for closeups
    "add_micro_facets": true  # Simulate gemstone refraction
  }
}
5.1.2 Vehicles & Large Objects (>2m)
JSON
Copy
{
  "profile": "vehicle",
  "capture": {
    "min_overlap": 0.25,  # Faster capture for large objects
    "coverage_density": "sparse",  # Fewer photos needed
    "drone_mode": true  # Enable GPS metadata usage
  },
  "reconstruction": {
    "bundle_adjustment_iterations": 6,  # More iterations for large baseline
    "dense_resolution": "medium",  # Memory management
    "pair_matching": "exhaustive"  # Ensure all pairs considered
  },
  "meshing": {
    "decimation_target": 300000,
    "hole_filling": "aggressive",  # Hide sensor occlusions
    "watertight": false  # Not needed for visualization
  },
  "ai_enhancement": {
    "material_classification": false,  # Mixed materials, manual assignment
    "add_dirt_layer": true  # Realistic weathering
  }
}
5.1.3 Human Face/Bust
JSON
Copy
{
  "profile": "portrait",
  "capture": {
    "min_overlap": 0.4,
    "avoid_flash": true,  # Prevents hot spots on skin
    "elevation_pass_mandatory": true
  },
  "reconstruction": {
    "feature_matcher": "AKAZE",  # Better for skin texture
    "reprojection_error_threshold": 0.3,  # Stricter for organic shapes
    "bundle_adjustment": "ceres"  # Robust solver
  },
  "meshing": {
    "decimation_target": 200000,
    "edge_preservation_angle": 30,  # Smooth transitions
    "preserve_proportions": true  # Prevent facial distortion
  },
  "ai_enhancement": {
    "nerf_steps": 40000,  # Fill nostrils/ears/occlusions
    "skin_pore_detail": true,  # Add micro-geometry
    "eye_cornea_model": true  # Special handling for eyes
  }
}
6. API-Level Parameter Control
6.1 Submit Job with Custom Parameters
bash
Copy
curl -X POST https://api.capture3d.com/v1/jobs \
  -H "Authorization: Bearer sk_live_..." \
  -H "Content-Type: application/json" \
  -d @- <<EOF
{
  "name": "Custom Reconstruction",
  "images": ["img_001.jpg", "img_002.jpg", ...],
  "parameters": {
    "tier": "expert",
    "capture": {
      "minimum_overlap": 0.35,
      "feature_detector": "SIFT"
    },
    "reconstruction": {
      "bundle_adjustment_iterations": 6,
      "dense_resolution": "ultra"
    },
    "meshing": {
      "poisson_depth": 12,
      "decimation_target": 500000,
      "edge_preservation_angle": 20
    },
    "ai_enhancement": {
      "nerf_steps": 40000,
      "texture_super_resolution": "4x",
      "add_displacement": true
    },
    "export": {
      "formats": ["fbx", "obj"],
      "texture_resolution": "8K",
      "include_lods": true,
      "lod_count": 4
    }
  }
}
EOF
6.2 Parameter Validation API
JavaScript
Copy
// POST /api/v1/validate-parameters
Request:
{
  "tier": "expert",
  "parameters": { ... }
}

Response:
{
  "valid": false,
  "warnings": [
    {
      "parameter": "nerf_steps",
      "value": 60000,
      "message": "Value >50000 may cause GPU OOM on g4dn.xlarge",
      "severity": "warning",
      "estimated_cost_increase": "15%"
    }
  ],
  "errors": [
    {
      "parameter": "poisson_depth",
      "value": 15,
      "message": "Maximum allowed value is 12",
      "severity": "error"
    }
  ],
  "estimated_processing_time": 1250,  // seconds
  "estimated_cost_usd": 0.73
}
7. Visual Parameter Tuning Interface
7.1 Web UI Mockup (Expert Mode)
Copy
┌─────────────────────────────────────────────────────────────┐
│  Parameter Tuning Studio                                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  [Basic] [Advanced] [Expert]  Save Config  Load Config     │
│                                                             │
│  📸 CAPTURE                                                 │
│  ├─ Feature Detector          [AKAZE ▼]                     │
│  ├─ Min Overlap               [====|====] 0.35             │
│  └─ Coverage Density          [ Dense ▼]                    │
│                                                             │
│  🔍 RECONSTRUCTION                                          │
│  ├─ Bundle Adjustment Iter    [==|======] 6                │
│  ├─ Reprojection Error (px)   [==|======] 0.5              │
│  └─ Dense Resolution          [ Ultra ▼]                    │
│                                                             │
│  🎨 MESHING                                                 │
│  ├─ Poisson Depth             [==|======] 12               │
│  ├─ Decimation Target         [==|======] 500K             │
│  ├─ Edge Preservation Angle   [====|====] 20°              │
│  └─ Watertight                [☑] Yes                       │
│                                                             │
│  🤖 AI ENHANCEMENT                                          │
│  ├─ NeRF Steps                [====|====] 40000            │
│  ├─ Texture Super-Res         [ 4x ▼]                       │
│  ├─ AI Smoothing Strength     [====|====] 0.30             │
│  └─ Displacement Map          [☑] Add micro-detail         │
│                                                             │
│  💾 EXPORT                                                  │
│  ├─ Target Polycount          [< 500K ] 452,847 (preview)  │
│  ├─ Texture Resolution        [ 8K ▼]                       │
│  └─ Estimated File Size       ~450 MB                      │
│                                                             │
│  ⚠️  WARNINGS                                               │
│  │ High Poisson depth may exceed GPU memory              │
│  │ Recommend switching to g4dn.2xlarge (+$0.85/job)      │
│                                                             │
│  💵 ESTIMATED COST: $0.73 | TIME: 20m 50s                  │
│                                                             │
│  [Preview Changes] [Reset to Default] [Save & Queue]       │
│                                                             │
└─────────────────────────────────────────────────────────────┘
7.2 Live Preview System
Parameter changes trigger:
Sparse Reconstruction Preview: Shows estimated point cloud density (2D heatmap)
Mesh Complexity Estimator: Updates polygon count in real-time
Memory Usage Gauge: Shows VRAM/RAM requirements with current settings
Cost Calculator: Dynamic AWS cost estimate based on processing time
8. Parameter Optimization Recommendations
8.1 Auto-Optimization Engine
For users who select "Auto-Tune", the system analyzes input images and suggests optimal parameters.
Python
Copy
def auto_tune_parameters(image_metadata, user_goal):
    """
    image_metadata: Exif data, sharpness scores, lighting histograms
    user_goal: One of ["speed", "quality", "accuracy"]
    """
    # Example logic
    if user_goal == "speed":
        return {
            "feature_detector": "AKAZE",
            "bundle_adjustment_iterations": 2,
            "dense_resolution": "low",
            "nerf_steps": 0
        }
    elif user_goal == "quality":
        return {
            "feature_detector": "SIFT",
            "bundle_adjustment_iterations": 6,
            "dense_resolution": "high",
            "poisson_depth": 11,
            "nerf_steps": 30000
        }
    elif user_goal == "accuracy":
        return {
            "feature_detector": "SIFT",
            "bundle_adjustment_iterations": 10,
            "dense_resolution": "ultra",
            "reprojection_error_threshold": 0.3,
            "poisson_depth": 12,
            "nerf_steps": 0  # Disable AI to preserve pure geometry
        }
8.2 Parameter Profiles for Quality Targets
Table
Copy
Desired Quality Score	Capture Photos	Poisson Depth	Decimation Target	Texture Res	Processing Time	Cost
7.0 (Good)	30-50	9	30K	2K	5 min	$0.20
8.5 (Great)	80-120	10	100K	4K	12 min	$0.50
9.5 (Excellent)	150-200	11	500K	8K	25 min	$1.20
10.0 (Perfect)	250-500	12	2M	8K+	60 min	$3.00
9. Parameter Validation & Guardrails
9.1 Real-Time Validation Rules
JavaScript
Copy
// Client-side validation before job submission
const VALIDATION_RULES = {
  "poisson_depth": {
    max: 12,
    min: 8,
    step: 1,
    warning_threshold: 11,
    warning_message: "Depth >11 may cause GPU OOM on standard tier"
  },
  "decimation_target": {
    max: 5000000,  // 5M polys
    min: 5000,
    depends_on: "poisson_depth",
    validator: (target, depth) => {
      const max_polys = Math.pow(8, depth) * 1000;
      if (target > max_polys) {
        return `Target exceeds max polys for depth=${depth}. Max allowed: ${max_polys}`;
      }
      return null;
    }
  },
  "nerf_steps": {
    max: 50000,
    min: 0,
    step: 1000,
    cost_multiplier: 0.0001,  // $0.01 per 100 steps
    gpu_required: "g4dn.2xlarge"
  }
};
9.2 Parameter Lock for Enterprise
Enterprise admins can lock parameters for team members to enforce brand standards.
JSON
Copy
{
  "enterprise_id": "ent_123",
  "policy": {
    "locked_parameters": {
      "texture_resolution": "4K",
      "export_formats": ["glb", "usdz"]
    },
    "parameter_ranges": {
      "decimation_target": {
        "min": 50000,
        "max": 150000
      }
    },
    "require_approval": [
      "poisson_depth > 11",
      "nerf_steps > 30000"
    ]
  }
}
10. Parameter Versioning & A/B Testing
10.1 Config Version Control
Every job stores the exact parameter set used, enabling reproducibility.
sql
Copy
CREATE TABLE job_parameters (
    job_id UUID PRIMARY KEY REFERENCES jobs(id),
    config_version VARCHAR(20),  -- "v2.1.4-expert"
    parameters JSONB NOT NULL,
    -- Enables rollback to previous configs
    parent_config_id UUID REFERENCES job_parameters(job_id)
);
10.2 Parameter A/B Testing
System can automatically test parameter variations to improve success rates.
Python
Copy
# 5% of jobs get alternative parameter sets
if random.random() < 0.05:
    alternative_params = {
        "feature_detector": "SIFT",  # Test vs. AKAZE
        "dense_resolution": "ultra"  # Test quality impact
    }
    job.parameters.update(alternative_params)
    
    # Log for analysis
    analytics.track("parameter_ab_test", {
        "job_id": job.id,
        "variant": "sift_ultra",
        "success": job.quality_score > 8.0
    })
11. Export-Only Parameter Overrides
Parameters that only affect export, not reconstruction (faster iteration).
JSON
Copy
{
  "export_overrides": {
    "reprocess_mesh": false,  // If false, skip reconstruction, just re-export
    "change_polycount": 75000,  // Remesh existing result
    "texture_resize": "4K",  // Downsample 8K to 4K
    "add_wireframe": true,
    "generate_exploded_view": false
  }
}
This allows users to generate multiple export variants (GLB, FBX, different resolutions) without re-running the expensive reconstruction pipeline.
12. Parameter Documentation & Tooltips
Every parameter includes:
Markdown
Fullscreen 
Download 
Fit
Code
Preview
Depth 8: ~50K vertices, 5 sec, 2GB RAM - Good for preview
Depth 10: ~800K vertices, 2 min, 8GB RAM - Default quality
Depth 12: ~5M vertices, 15 min, 32GB RAM - Maximum detail
✅ More detail on small features (screws, textures)
❌ Exponential time & memory growth
❌ Risk of noise amplification from depth maps
Use 12 for small objects (<10cm) requiring submillimeter accuracy
Use 9-10 for medium objects (10cm-1m)
Use 8 for large objects (>1m) or rapid prototyping
⚠️ Depth >11 requires g4dn.2xlarge GPU (auto-upgrades job tier)
⚠️ Depth 12 may produce meshes >10M polys, exceeding single-file export limits
Poisson Reconstruction Paper
Tutorial: "Choosing the Right Poisson Depth"
End of Annex A
Note: This annex is a technical supplement to the main PRD. Parameter specifications may be updated independently of core features. For latest parameter definitions, see /api/v1/parameters/schema.


K2
