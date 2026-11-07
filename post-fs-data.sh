#!/system/bin/sh
# IO 调度：noop + 更大预读
echo noop > /sys/block/mmcblk0/queue/scheduler
echo 1024 > /sys/block/mmcblk0/queue/read_ahead_kb
# 虚拟内存：zram 优先换出、压低脏页、减少 inode 回收
echo 100 > /proc/sys/vm/swappiness
echo 20 > /proc/sys/vm/dirty_ratio
echo 5 > /proc/sys/vm/dirty_background_ratio
echo 50 > /proc/sys/vm/vfs_cache_pressure