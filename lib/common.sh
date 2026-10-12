# 記録スクリプト共通処理（source して使う）

FORMULA_WS="${FORMULA_WS:-${HOME}/formula_ws}"
MAX_BAG_SIZE="${MAX_BAG_SIZE:-209715200}"  # 200 MiB で分割

# bag は ros2 bag record が OUTPUT_DIR を作るため、メタ情報は一時ディレクトリに集めて終了時に移す
META_TMP="$(mktemp -d)"
TEGRASTATS_PID=""

# 再現用の情報（コード・モデル・パラメータ）を保存する
write_manifest() {
  {
    echo "date: $(date --iso-8601=seconds)"
    echo "host: $(hostname)"
    echo "ros_distro: ${ROS_DISTRO:-unknown}"
    echo "formula_ws: ${FORMULA_WS}"
    if git -C "${FORMULA_WS}/src" rev-parse --git-dir >/dev/null 2>&1; then
      echo "git_branch: $(git -C "${FORMULA_WS}/src" branch --show-current)"
      echo "git_commit: $(git -C "${FORMULA_WS}/src" rev-parse HEAD)"
      echo "git_dirty: $([ -n "$(git -C "${FORMULA_WS}/src" status --porcelain)" ] && echo true || echo false)"
    else
      echo "git_commit: unknown"
    fi
  } > "${META_TMP}/manifest.yaml"

  if git -C "${FORMULA_WS}/src" rev-parse --git-dir >/dev/null 2>&1; then
    git -C "${FORMULA_WS}/src" diff HEAD > "${META_TMP}/git_diff.patch" || true
    git -C "${FORMULA_WS}/src" status --porcelain > "${META_TMP}/git_status.txt" || true
  fi

  # TensorRT エンジン等のハッシュ（install/<pkg>/share/<pkg>/weights 以下）
  find "${FORMULA_WS}/install" -path '*/share/*/weights/*' -type f -print0 2>/dev/null \
    | xargs -0 -r sha256sum > "${META_TMP}/weights_sha256.txt" || true

  # 起動中ノードのパラメータ
  mkdir -p "${META_TMP}/params"
  for node in $(ros2 node list 2>/dev/null); do
    ros2 param dump "${node}" > "${META_TMP}/params/$(echo "${node#/}" | tr '/' '_').yaml" 2>/dev/null || true
  done
}

# Jetson の CPU/GPU 負荷・温度（tegrastats がなければ何もしない）
start_tegrastats() {
  if command -v tegrastats >/dev/null 2>&1; then
    tegrastats --interval 100 --logfile "${META_TMP}/tegrastats.log" &
    TEGRASTATS_PID=$!
  fi
}

finalize() {
  [ -n "${TEGRASTATS_PID}" ] && kill "${TEGRASTATS_PID}" 2>/dev/null || true
  if [ -d "${OUTPUT_DIR}" ]; then
    mv "${META_TMP}" "${OUTPUT_DIR}/meta"
    echo "メタ情報を保存しました: ${OUTPUT_DIR}/meta"
  else
    echo "bag が作成されていないため、メタ情報は ${META_TMP} に残しました" >&2
  fi
}

# トピック配列を受け取って記録する。Ctrl-C で record が終わった後も finalize を走らせる
record_bag() {
  trap finalize EXIT
  trap ':' INT  # 無視（''）にすると子プロセスにも継承されるのでハンドラにする
  write_manifest
  start_tegrastats
  ros2 bag record -o "${OUTPUT_DIR}" --max-bag-size "${MAX_BAG_SIZE}" "$@" || true
}
