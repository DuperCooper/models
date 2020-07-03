#!/bin/bash
# Copyright 2018 The TensorFlow Authors All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ==============================================================================
#
# Script to preprocess the Cityscapes dataset. Note (1) the users should
# register the Cityscapes dataset website at
# https://www.cityscapes-dataset.com/downloads/ to download the dataset,
# and (2) the users should download the utility scripts provided by
# Cityscapes at https://github.com/mcordts/cityscapesScripts.
#
# Usage:
#   bash ./convert_cityscapes.sh
#
# The folder structure is assumed to be:
#  + datasets
#    - build_cityscapes_data.py
#    - convert_cityscapes.sh
#    + cityscapes
#      + cityscapesscripts (downloaded scripts)
#      + gtFine
#      + leftImg8bit
#

# Exit immediately if a command exits with a non-zero status.

set -e

CURRENT_DIR=$(pwd)
WORK_DIR="./kitti_seg"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
mkdir -p "${WORK_DIR}"
cd "${WORK_DIR}"

# Root path for Cityscapes dataset.
KITTI_ROOT="${WORK_DIR}/KITTIdevkit/KITTI"

# Remove the colormap in the ground truth annotations.
SEG_FOLDER="${KITTI_ROOT}/SegmentationClass"
SEMANTIC_SEG_FOLDER="${KITTI_ROOT}/SegmentationClassRaw"

echo "Removing the color map in ground truth annotations..."
python "${SCRIPT_DIR}/remove_gt_colormap.py" \
  --original_gt_folder="${SEG_FOLDER}" \
  --output_dir="${SEMANTIC_SEG_FOLDER}"

# Create training labels.
# python "${KITTI_ROOT}/cityscapesscripts/preparation/createTrainIdLabelImgs.py"

# Build TFRecords of the dataset.
# First, create output directory for storing TFRecords.
OUTPUT_DIR="${KITTI_ROOT}/tfrecord"
mkdir -p "${OUTPUT_DIR}"

IMAGE_FOLDER="${KITTI_ROOT}/JPEGImages"
LIST_FOLDER="${KITTI_ROOT}/ImageSets/Segmentation"

echo "Converting KITTI dataset..."
python "${SCRIPT_DIR}/build_kitti_data.py" \
  --image_folder="${IMAGE_FOLDER}" \
  --semantic_segmentation_folder="${SEMANTIC_SEG_FOLDER}" \
  --list_folder="${LIST_FOLDER}" \
  --image_format="jpg" \
  --output_dir="${OUTPUT_DIR}"