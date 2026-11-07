#!/system/bin/sh
# 等开机完成
for i in $(seq 1 60); do
  [ "$(getprop sys.boot_completed)" = "1" ] && break
  sleep 2
done
# 动画减半，体感提升最明显
settings put global window_animation_scale 0.5
settings put global transition_animation_scale 0.5
settings put global animator_duration_scale 0.5
# 缓存进程冻结
settings put global cached_apps_freezer enabled
# 重新应用内核参数（防止被 ROM 覆盖）
echo noop > /sys/block/mmcblk0/queue/scheduler
echo 1024 > /sys/block/mmcblk0/queue/read_ahead_kb
echo 100 > /proc/sys/vm/swappiness
echo 20 > /proc/sys/vm/dirty_ratio
echo 5 > /proc/sys/vm/dirty_background_ratio
echo 50 > /proc/sys/vm/vfs_cache_pressure