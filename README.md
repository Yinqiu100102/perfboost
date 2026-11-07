# Mi439 Performance Tune

Redmi 8 / 8A（`olive` / `olivelite`，Snapdragon 439）在 MIUI 14 移植包上的轻量性能调优模块。

> Lightweight IO/VM/animation tuning for Redmi 8 / 8A (Mi439) running MIUI 14 ports.

## 做了什么 / What it does

### 开机早期（`post-fs-data.sh`）

| 项目 | 值 | 理由 |
|---|---|---|
| IO 调度器 | `noop` | eMMC 上 CFQ/BFQ 的排队收益很低，noop 减少无谓开销 |
| `read_ahead_kb` | `1024` | 提升顺序读（应用冷启动、相册缩略图） |
| `vm.swappiness` | `100` | 小内存机器（3/4GB）优先用 zram 换出，比杀进程体验好 |
| `vm.dirty_ratio` | `20` | 降低一次性回写阻塞主线程的概率 |
| `vm.dirty_background_ratio` | `5` | 更早后台回写，避免突发卡顿 |
| `vm.vfs_cache_pressure` | `50` | 少回收 dentry/inode 缓存 |

### 开机完成后（`service.sh`）

- 三档动画缩放设为 `0.5x`（`window/transition/animator`）——这是体感提升最明显的一项；
- 打开 `cached_apps_freezer`（缓存进程冻结）；
- **再次写入**上面的 IO/VM 参数。原因：部分 MIUI 移植包在开机后期会重置这些值，
  `post-fs-data` 阶段写的会被覆盖，所以在 `boot_completed` 之后再补一次。

## 安装 / Install

1. 下载或自行打包：`./build.sh`
2. Magisk → 模块 → 从本地安装 → 重启。

## 调参 / Tuning

参数全部是明文的 `echo`，直接改对应脚本里的数值即可。几个常见方向：

- **想要更省电**：把 `read_ahead_kb` 降到 `512`，`swappiness` 降到 `60`；
- **想要更流畅**：`read_ahead_kb` 提到 `2048`（顺序读更猛，但内存占用略增）；
- **不想改动画**：删掉 `service.sh` 里三行 `settings put`；
- **不想要 zram 激进换出**：`swappiness` 改回 `60`。

改完重新打包安装，或直接 `su -c 'sh /data/adb/modules/perfboost/service.sh'` 热重载一次。

## 验证 / Verify

```sh
su -c 'cat /sys/block/mmcblk0/queue/scheduler'      # [noop] ...
su -c 'cat /sys/block/mmcblk0/queue/read_ahead_kb'   # 1024
su -c 'cat /proc/sys/vm/swappiness'                  # 100
su -c 'settings get global window_animation_scale'   # 0.5
```

## 注意 / Caveats

- `swappiness=100` 会让 zram 更积极地压缩换出，**低内存机型收益明显，但 CPU 占用会略升**；
  如果你的 ROM 本身 zram 关着，这条基本无感，可以删。
- 动画 0.5x 属于个人口味，觉得「太快不跟手」就删掉那三行。
- 不同 MIUI 移植包的内核默认值不同，本模块只是**覆盖写法**，没有做条件判断。

## 卸载 / Uninstall

Magisk 移除后重启。动画缩放不会自动还原，需要手动改回 1.0x：

```sh
su -c 'settings put global window_animation_scale 1.0'
su -c 'settings put global transition_animation_scale 1.0'
su -c 'settings put global animator_duration_scale 1.0'
```

## License

MIT
