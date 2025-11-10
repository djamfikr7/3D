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
        subprocess.check_call(cmd)
        return True
    except subprocess.CalledProcessError as e:
        logger.error(f"matching failed: {e}")
        return False
