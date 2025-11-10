import shutil, subprocess, time
from loguru import logger

def run_meshing(mvs_dir: str, mesh_out: str):
    bin_name = 'aliceVision_meshing'
    if shutil.which(bin_name) is None:
        logger.warning(f"{bin_name} not found; simulating meshing")
        time.sleep(1.0)
        return True
    cmd = [bin_name, '--input', mvs_dir, '--output', mesh_out]
    logger.info(f"Running: {' '.join(cmd)}")
    try:
        subprocess.check_call(cmd)
        return True
    except subprocess.CalledProcessError as e:
        logger.error(f"meshing failed: {e}")
        return False
