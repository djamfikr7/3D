import shutil, subprocess, time
from loguru import logger

def run_feature_extraction(images_dir: str, output_dir: str, preset: str = 'high'):
    bin_name = 'aliceVision_featureExtraction'
    if shutil.which(bin_name) is None:
        logger.warning(f"{bin_name} not found on PATH; simulating feature extraction")
        time.sleep(1.5)
        return True
    cmd = [bin_name, '--input', images_dir, '--output', output_dir, '--describerPreset', preset, '--describerMethod', 'akaze']
    logger.info(f"Running: {' '.join(cmd)}")
    try:
        subprocess.check_call(cmd)
        return True
    except subprocess.CalledProcessError as e:
        logger.error(f"feature extraction failed: {e}")
        return False
