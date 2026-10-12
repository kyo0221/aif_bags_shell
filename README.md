# aif_bags_shell

```bash
./control_bags.sh                 # 車両同定用
./control_bags.sh <suffix>
./perception_planning_bags.sh     # 比較走行用（画像・中間出力・車輪実測を1本に記録）
./perception_planning_bags.sh <suffix>
LIDAR_TOPICS="/velodyne_points" ./perception_planning_bags.sh <suffix>  # 3D LiDAR 一時搭載時
```

- bag は `~/aif_bags/` 以下に 200 MiB ごとに分割して保存（`MAX_BAG_SIZE` で変更可）
- `<bag>/meta/` に再現用の情報を保存
  - `manifest.yaml`: 日時・ホスト・formula_ws の branch / commit / dirty
  - `git_diff.patch`, `git_status.txt`: 未コミットの変更
  - `weights_sha256.txt`: `install/*/share/*/weights/` 以下のハッシュ
  - `params/`: 起動中の全ノードの `ros2 param dump`（ノード起動後に記録を開始すること）
  - `tegrastats.log`: Jetson の CPU/GPU 負荷・温度（tegrastats がある場合のみ）
- formula_ws の場所が `~/formula_ws` でない場合は `FORMULA_WS` を指定
