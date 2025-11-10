import shutil, subprocess, time
from loguru import logger

def run_matching(features_dir: str, matches_dir: str, preset: str = 'high'):
    bin_name = 'aliceVision_imageMatching'
    if shutil.which(bin_name) is None:
        logger.warning(f"{bin_name} not found; simulating matching")
        time.sleep(1.0)
        return True
    cmd = [bin_name, '--input', features_dir, '--output', matches_dir]
    logger.info(f"Running: {' '.join(cmd)}")
    try:
        proc = subprocess.run(cmd, capture_output=True, text=True, check=True)
        if proc.stdout:
            logger.info(proc.stdout)
        if proc.stderr:
            logger.warning(proc.stderr)
        return True
    except subprocess.CalledProcessError as e:
        if e.stdout:
            logger.info(e.stdout)
        if e.stderr:
            logger.error(e.stderr)
        logger.error(f"matching failed with code {e.returncode}")
        return False
