import shutil, subprocess, time
from loguru import logger

def run_mvs(sfm_dir: str, mvs_dir: str):
    bin_name = 'aliceVision_mvs'
    if shutil.which(bin_name) is None:
        logger.warning(f"{bin_name} not found; simulating MVS")
        time.sleep(1.2)
        return True
    cmd = [bin_name, '--input', sfm_dir, '--output', mvs_dir]
    logger.info(f"Running: {' '.join(cmd)}")
    try:
        subprocess.check_call(cmd)
        return True
    except subprocess.CalledProcessError as e:
        logger.error(f"mvs failed: {e}")
        return False
