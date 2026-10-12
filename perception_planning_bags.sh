#!/usr/bin/env bash
set -eu

source "$(dirname "$(readlink -f "$0")")/lib/common.sh"

# 比較走行用。画像・中間出力・車輪実測を同じ bag に入れる
OUTPUT_DIR="${HOME}/aif_bags/perception_planning_$(date +%Y%m%d_%H%M%S)${1:+_$1}"
mkdir -p "$(dirname "${OUTPUT_DIR}")"

TOPICS=(
  # カメラ
  /zed/zed_node/rgb/image_rect_color
  /zed/zed_node/rgb/camera_info
  /zed/zed_node/odom

  # 認識
  /perception/objects
  /perception/lane_line_points

  # 計画の中間出力（header.stamp は画像のスタンプを継承。受信時刻との差で各段の入力年齢を出す）
  /planner/vision_path
  /planner/global_path
  /planner/local_path
  /planner/speed_path
  /planning/stop_point
  /planning/nav_cmd
  /flag

  # 自己位置
  /localization/pf_pose
  /localization/pose
  /localization/odom
  /vectornav/imu
  /vectornav/velocity_body
  /vectornav/pose
  /vectornav/gnss
  /tf
  /tf_static

  # 指令と車輪の実測（Ltrack・停止距離の解析用）
  /cmd_vel
  /autonomous
  /restart
  /joy
  /caster_data
  /caster_odom
  /can_tx
  /can_rx_012
  /can_rx_013
  /can_rx_301
  /can_rx_309
  /can_rx_711
  /can_rx_712
  /left_rpm_tx
  /right_rpm_tx
  /left_rpm_rx
  /right_rpm_rx
  /odrive_axis0/control_message
  /odrive_axis0/controller_status
)

# 3D LiDAR を一時搭載するときは LIDAR_TOPICS="/velodyne_points" のように指定する
if [ -n "${LIDAR_TOPICS:-}" ]; then
  read -r -a EXTRA <<< "${LIDAR_TOPICS}"
  TOPICS+=("${EXTRA[@]}")
fi

record_bag "${TOPICS[@]}"
