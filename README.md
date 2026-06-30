# 开摆 · 混底薪神器

> 把「熬时间」变成「看得见的到账」。每小时播报支付宝/微信到账，配上经典熊猫头梗图，让上班这件事稍微没那么难熬。

![Flutter](https://img.shields.io/badge/Flutter-3.44-blue)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Windows%20%7C%20macOS%20%7C%20Linux-lightgrey)
![License](https://img.shields.io/badge/License-MIT-green)

---

## 功能一览

| 功能 | 说明 |
|---|---|
| 💰 实时计薪 | 根据月薪/休息天数/工时自动计算时薪，开机后金额按秒增长 |
| 📣 每小时到账播报 | 支持支付宝/微信两种播报音效，TTS 语音 + 系统通知 |
| 😂 滑动下班 | iOS 风格滑动解锁关机，防误触 |
| 📊 今日总结 | 关机后弹窗展示开机时间、时长、总金额、播报次数 |
| 🔒 防偷窥模式 | 一键把「元」换成「豆」，主题色同步变紫，老板看不出来 |
| 🔔 数字跳动 | 金额每秒逐位滚动，股票报价机既视感 |
| 💻 桌面端支持 | Windows / macOS / Linux 原生窗口，含系统托盘 |
| 📱 本地隐私 | 所有数据仅存本机，不联网，不上传，不登录 |

---

## 截图

| 开机开始混底薪 | 关机下班底薪到手 |
|:-:|:-:|
| ![开机开始混底薪](assets/images/开机开始混底薪.png) | ![关机下班底薪到手](assets/images/关机下班底薪到手.png) |

---

## 安装

### Android

从 [Releases](../../releases) 下载对应架构的 APK 直接安装：

- `app-arm64-v8a-release.apk` — 主流机型（推荐）
- `app-armeabi-v7a-release.apk` — 旧机型
- `app-x86_64-release.apk` — 模拟器

### Windows

从 Releases 下载 `kaipai-windows.zip`，解压后运行 `kaibai.exe`。

### macOS

从 Releases 下载 `kaipai-macos.zip`，解压后将 `开摆.app` 拖入应用程序文件夹。  
首次运行需**右键 → 打开**绕过 Gatekeeper（未签名）。

### Linux

```bash
tar -xzf kaipai-linux.tar.gz
cd bundle
./kaibai
```

需要系统已安装 `libgtk-3-0`、`libnotify4`（主流发行版默认有）。

---

## 本地开发

**环境要求**

- Flutter 3.44+
- Android：Android SDK + JDK 17
- Windows：Visual Studio 2022+（含「使用 C++ 的桌面开发」工作负载）+ NuGet

```bash
# 克隆
git clone https://github.com/your-username/kaibai.git
cd kaibai

# 安装依赖
flutter pub get

# Android 模拟器
flutter run -d emulator-5554

# Windows 桌面
flutter build windows --debug
```

---

## 薪资设置

进入设置页可配置：

- **月薪**：快捷预设（3K–3W）或自定义输入
- **月休天数**：无休 / 单休 / 双休 / 自定义
- **每日工作时长**：6h–12h 或自定义
- **收款方式**：支付宝 / 微信，含 TTS 试听

时薪计算公式：

```
时薪 = 月薪 ÷ (当月自然天数 - 月休天数) ÷ 每日工作时长
```

---

## 构建 & 发布

推 tag 自动触发四平台打包：

```bash
git tag v1.0.0
git push origin v1.0.0
```

GitHub Actions 会并行构建 Android / macOS / Linux / Windows，完成后自动创建 Release。

详见 [`.github/workflows/build.yml`](.github/workflows/build.yml)。

---

## 隐私声明

- 不需要账号，不需要网络
- 月薪等数据仅通过 `SharedPreferences` 存储在本机
- 不收集任何使用数据

---

## License

MIT
