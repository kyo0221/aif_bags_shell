#!/usr/bin/env bash
set -eu

source "$(dirname "$(readlink -f "$0")")/lib/common.sh"

OUTPUT_DIR="${HOME}/aif_bags/control_$(date +%Y%m%d_%H%M%S)${1:+_$1}"
mkdir -p "$(dirname "${OUTPUT_DIR}")"

TOPICS=(
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
  /vectornav/velocity_body
  /vectornav/imu
  /vectornav/pose
  /vectornav/gnss
  /localization/odom
  /tf
  /tf_static
)

record_bag "${TOPICS[@]}"
