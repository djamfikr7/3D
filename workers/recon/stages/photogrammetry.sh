#!/usr/bin/env bash
set -euo pipefail
# Placeholder scaffold for AliceVision photogrammetry pipeline
# TODO: Replace with real commands (feature extraction, matching, SfM, MVS, meshing)

echo "[photogrammetry] Starting pipeline at $(date)"
# Example placeholders:
# aliceVision_featureExtraction --input imgs --output feats --describerMethod akaze --describerPreset high
# aliceVision_imageMatching --input feats --output matches
# aliceVision_sfm --input matches --output sfm
# aliceVision_mvs --input sfm --output mvs
# aliceVision_meshing --input mvs --output mesh

echo "[photogrammetry] Done at $(date)"
