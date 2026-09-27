#!/usr/bin/env bash
set -eu

OUTPUT_DIR="${HOME}/aif_bags/perception_planning_$(date +%Y%m%d_%H%M%S)${1:+_$1}"
mkdir -p "$(dirname "${OUTPUT_DIR}")"

TOPICS=(
  /zed/zed_node/rgb/image_rect_color
  /zed/zed_node/rgb/camera_info
  /zed/zed_node/odom
  /vectornav/imu
  /vectornav/velocity_body
  /vectornav/pose
  /vectornav/gnss
  /localization/odom
  /tf
  /tf_static
  /cmd_vel
  /caster_data
  /autonomous
  /joy
)

ros2 bag record -o "${OUTPUT_DIR}" "${TOPICS[@]}"
