import shutil, subprocess, time
from loguru import logger

def run_sfm(matches_dir: str, sfm_dir: str):
    bin_name = 'aliceVision_incrementalSfm'
    if shutil.which(bin_name) is None:
        logger.warning(f"{bin_name} not found; simulating SfM")
        time.sleep(1.2)
        return True
    cmd = [bin_name, '--input', matches_dir, '--output', sfm_dir]
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
        logger.error(f"sfm failed with code {e.returncode}")
        return False
