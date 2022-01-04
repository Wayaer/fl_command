import 'package:flutter/cupertino.dart';

class ScrcpyScript {
  factory ScrcpyScript() => _singleton ??= ScrcpyScript._();

  ScrcpyScript._();

  static ScrcpyScript? _singleton;

  /// 连接一个设备
  /// 如果 adb devices 列出了多个设备，您必须指定设备的 序列号
  /// 如果设备通过 TCP/IP 连接：
  /// Scrcpy 使用 adb 与设备通信，并且 adb 支持通过 TCP/IP 连接到设备:
  /// 将设备和电脑连接至同一 Wi-Fi。
  /// 打开 设置 → 关于手机 → 状态信息，获取设备的 IP 地址，也可以执行以下的命令：
  /// adb shell ip route | awk '{print $9}'
  /// 启用设备的网络 adb 功能： adb tcpip 5555。
  /// 断开设备的 USB 连接。
  /// 连接到您的设备：adb connect DEVICE_IP:5555 (将 DEVICE_IP 替换为设备 IP)。
  /// 正常运行 scrcpy。
  /// 可能降低码率和分辨率会更好一些：
  ///  在设备连接时自动启动
  ///  您可以使用 AutoAdb:
  String start([String? serial, bool autoADB = false]) {
    String script = 'scrcpy';
    if (serial != null) script += ' -s $serial';
    if (autoADB) script = 'autoadb ' + script;
    return script;
  }

  /// 标题
  /// 窗口的标题默认为设备型号。可以通过如下命令修改：
  String setWindowTitle(String name) => 'scrcpy --window-title $name';

  /// 位置和大小
  /// 您可以指定初始的窗口位置和大小：
  String setPosition(Size size, {Offset position = const Offset(0, 0)}) =>
      'scrcpy --window-x ${position.dx} --window-y ${position.dy} --window-width ${size.width} --window-height ${size.height}';

  /// 无边框
  /// 禁用窗口边框：
  String setBorderless = 'scrcpy --window-borderless';

  /// 保持窗口在最前
  /// 您可以通过如下命令保持窗口在最前面：
  String alwaysOnTop = 'scrcpy --always-on-top';

  /// 全屏
  /// 您可以通过如下命令直接全屏启动 scrcpy：
  /// scrcpy -f  # 简写
  String setFullscreen = 'scrcpy --fullscreen';

  /// 可选的值有：
  /// 0: 无旋转
  /// 1: 逆时针旋转 90°
  /// 2: 旋转 180°
  /// 3: 顺时针旋转 90°
  String setRotation(int rotation) => 'scrcpy --rotation $rotation';

  /// 只读
  /// 禁用电脑对设备的控制 (任何可与设备交互的方式：如键盘输入、鼠标事件和文件拖放)：
  /// scrcpy -n
  String setNoControl = 'scrcpy --no-control';

  /// 保持常亮
  /// 阻止设备在连接时一段时间后休眠：
  /// scrcpy -w
  String stayAwake = 'scrcpy --stay-awake';

  /// 关闭设备屏幕
  /// 可以通过以下的命令行参数在关闭设备屏幕的状态下进行镜像：
  /// scrcpy -S
  String turnOffScreen = 'scrcpy --turn-screen-off';

  ///  退出时息屏
  /// scrcpy 退出时关闭设备屏幕：
  String powerOffOnClose = 'scrcpy --power-off-on-close';

  /// 退出
  String powerOff = 'scrcpy --power-off';

  /// 显示触摸
  /// 在演示时，可能会需要显示 (在物理设备上的) 物理触摸点。
  /// Android 在 开发者选项 中提供了这项功能。
  /// Scrcpy 提供一个选项可以在启动时开启这项功能并在退出时恢复初始设置：
  /// scrcpy -t
  String showTouches = 'scrcpy --show-touches';

  /// 关闭屏保
  /// Scrcpy 默认不会阻止电脑上开启的屏幕保护。
  /// 关闭屏幕保护：
  String disableScreensaver = 'scrcpy --disable-screensaver';

  /// 输入控制
  /// 旋转设备屏幕
  /// 使用 MOD+r 在竖屏和横屏模式之间切换。
  ///
  /// 需要注意的是，只有在前台应用程序支持所要求的模式时，才会进行切换。
  ///
  /// 复制粘贴
  /// 每次安卓的剪贴板变化时，其内容都会被自动同步到电脑的剪贴板上。
  ///
  /// 所有的 Ctrl 快捷键都会被转发至设备。其中：
  ///
  /// Ctrl+c 通常执行复制
  /// Ctrl+x 通常执行剪切
  /// Ctrl+v 通常执行粘贴 (在电脑到设备的剪贴板同步完成之后)
  /// 大多数时候这些按键都会执行以上的功能。
  ///
  /// 但实际的行为取决于设备上的前台程序。例如，Termux 会在按下 Ctrl+c 时发送 SIGINT，又如 K-9 Mail 会新建一封邮件。
  ///
  /// 要在这种情况下进行剪切，复制和粘贴 (仅支持 Android >= 7)：
  ///
  /// MOD+c 注入 COPY (复制)
  /// MOD+x 注入 CUT (剪切)
  /// MOD+v 注入 PASTE (粘贴) (在电脑到设备的剪贴板同步完成之后)
  /// 另外，MOD+Shift+v 会将电脑的剪贴板内容转换为一串按键事件输入到设备。在应用程序不接受粘贴时 (比如 Termux)，这项功能可以派上一定的用场。不过这项功能可能会导致非 ASCII 编码的内容出现错误。
  ///
  /// 警告： 将电脑剪贴板的内容粘贴至设备 (无论是通过 Ctrl+v 还是 MOD+v) 都会将内容复制到设备的剪贴板。如此，任何安卓应用程序都能读取到。您应避免将敏感内容 (如密码) 通过这种方式粘贴。
  ///
  /// 一些设备不支持通过程序设置剪贴板。通过 --legacy-paste 选项可以修改 Ctrl+v 和 MOD+v 的工作方式，使它们通过按键事件 (同 MOD+Shift+v) 来注入电脑剪贴板内容。
  ///
  /// 双指缩放
  /// 模拟“双指缩放”：Ctrl+按住并移动鼠标。
  ///
  /// 更准确的说，在按住鼠标左键时按住 Ctrl。直到松开鼠标左键，所有鼠标移动将以屏幕中心为原点，缩放或旋转内容 (如果应用支持)。
  ///
  /// 实际上，scrcpy 会在关于屏幕中心对称的位置上用“虚拟手指”发出触摸事件。
  ///
  /// 物理键盘模拟 (HID)
  /// 默认情况下，scrcpy 使用安卓按键或文本注入，这在任何情况都可以使用，但仅限于ASCII字符。
  ///
  /// 在 Linux 上，scrcpy 可以模拟为 Android 上的物理 USB 键盘，以提供更好地输入体验 (使用 USB HID over AOAv2)：禁用虚拟键盘，并适用于任何字符和输入法。
  ///
  /// 不过，这种方法仅支持 USB 连接以及 Linux平台。
  /// 启用 HID 模式：
  /// scrcpy -K  # 简写
  String hidKeyboard = 'scrcpy --hid-keyboard';

  /// 如果失败了 (如设备未通过 USB 连接)，则自动回退至默认模式 (终端中会输出日志)。这即允许通过 USB 和 TCP/IP 连接时使用相同的命令行参数。
  /// 在这种模式下，原始按键事件 (扫描码) 被发送给设备，而与宿主机按键映射无关。因此，若键盘布局不匹配，需要在 Android 设备上进行配置，具体为 设置 → 系统 → 语言和输入法 → [实体键盘]。
  /// 文本注入偏好
  /// 打字的时候，系统会产生两种事件：
  /// 按键事件 ，代表一个按键被按下或松开。
  /// 文本事件 ，代表一个字符被输入。
  /// 程序默认使用按键事件来输入字母。只有这样，键盘才会在游戏中正常运作 (例如 WASD 键)。
  /// 但这也有可能造成一些问题。如果您遇到了问题，可以通过以下方式避免：
  String preferText = 'scrcpy --prefer-text';

  /// (这会导致键盘在游戏中工作不正常)
  /// 该选项不影响 HID 键盘 (该模式下，所有按键都发送为扫描码)。
  /// 按键重复
  /// 默认状态下，按住一个按键不放会生成多个重复按键事件。在某些游戏中这通常没有实际用途，且可能会导致性能问题。
  /// 避免转发重复按键事件：
  String noKeyRepeat = 'scrcpy --no-key-repeat';

  /// 该选项不影响 HID 键盘 (该模式下，按键重复由 Android 直接管理)。
  /// 右键和中键
  /// 默认状态下，右键会触发返回键 (或电源键开启)，中键会触发 HOME 键。要禁用这些快捷键并把所有点击转发到设备：
  String forwardAllClicks = 'scrcpy --forward-all-clicks';

  /// 文件拖放
  /// 安装APK
  /// 将 APK 文件 (文件名以 .apk 结尾) 拖放到 scrcpy 窗口来安装。
  /// 不会有视觉反馈，终端会输出一条日志。
  /// 将文件推送至设备
  /// 要推送文件到设备的 /sdcard/Download/，将 (非 APK) 文件拖放至 scrcpy 窗口。
  /// 不会有视觉反馈，终端会输出一条日志。
  /// 在启动时可以修改目标目录：
  String pushFile(String path) => 'scrcpy --push-target=/sdcard/$path';

  /// 快捷键
  /// 在以下列表中, MOD 是快捷键的修饰键。 默认是 (左) Alt 或 (左) Super。
  ///
  /// 您可以使用 --shortcut-mod 来修改。可选的按键有 lctrl、rctrl、lalt、ralt、lsuper 和 rsuper。例如：
  ///
  /// # 使用右 Ctrl 键
  /// scrcpy --shortcut-mod=rctrl
  ///
  /// # 使用左 Ctrl 键 + 左 Alt 键，或 Super 键
  /// scrcpy --shortcut-mod=lctrl+lalt,lsuper
  /// Super 键通常是指 Windows 或 Cmd 键。
  ///
  /// 操作	快捷键
  /// 全屏	MOD+f
  /// 向左旋转屏幕	MOD+← (左箭头)
  /// 向右旋转屏幕	MOD+→ (右箭头)
  /// 将窗口大小重置为1:1 (匹配像素)	MOD+g
  /// 将窗口大小重置为消除黑边	MOD+w | 双击左键¹
  /// 点按 主屏幕	MOD+h | 中键
  /// 点按 返回	MOD+b | 右键²
  /// 点按 切换应用	MOD+s | 第4键³
  /// 点按 菜单 (解锁屏幕)	MOD+m
  /// 点按 音量+	MOD+↑ (上箭头)
  /// 点按 音量-	MOD+↓ (下箭头)
  /// 点按 电源	MOD+p
  /// 打开屏幕	鼠标右键²
  /// 关闭设备屏幕 (但继续在电脑上显示)	MOD+o
  /// 打开设备屏幕	MOD+Shift+o
  /// 旋转设备屏幕	MOD+r
  /// 展开通知面板	MOD+n | 第5键³
  /// 展开设置面板	MOD+n+n | 双击第5键³
  /// 收起通知面板	MOD+Shift+n
  /// 复制到剪贴板⁴	MOD+c
  /// 剪切到剪贴板⁴	MOD+x
  /// 同步剪贴板并粘贴⁴	MOD+v
  /// 注入电脑剪贴板文本	MOD+Shift+v
  /// 打开/关闭FPS显示 (至标准输出)	MOD+i
  /// 捏拉缩放	Ctrl+按住并移动鼠标
  /// 拖放 APK 文件	从电脑安装 APK 文件
  /// 拖放非 APK 文件	将文件推送至设备
  /// ¹双击黑边可以去除黑边。
  /// ²点击鼠标右键将在屏幕熄灭时点亮屏幕，其余情况则视为按下返回键 。
  /// ³鼠标的第4键和第5键。
  /// ⁴需要安卓版本 Android >= 7。
  ///
  /// 有重复按键的快捷键通过松开再按下一个按键来进行，如“展开设置面板”：
  ///
  /// 按下 MOD 不放。
  /// 双击 n。
  /// 松开 MOD。
  /// 所有的 Ctrl+按键 的快捷键都会被转发到设备，所以会由当前应用程序进行处理。
  /// 自定义路径
  /// 要使用指定的 adb 二进制文件，可以设置环境变量 ADB：
  /// ADB=/path/to/adb scrcpy
  /// 要覆盖 scrcpy-server 的路径，可以设置 SCRCPY_SERVER_PATH。
  /// 要覆盖图标，可以设置其路径至 SCRCPY_ICON_PATH。

  ///  显示屏
  /// 如果设备有多个显示屏，可以选择要镜像的显示屏：
  String display(String id) => 'scrcpy --display $id';

  /// ssh -CN -L5037:localhost:5037 -R27183:localhost:27183 your_remote_computer
  /// # 保持该窗口开启
  /// 若要不使用远程端口转发，可以强制使用正向连接 (注意 -L 和 -R 的区别)：
  /// adb kill-server    # 关闭本地 5037 端口上的 adb 服务端
  /// ssh -CN -L5037:localhost:5037 -L27183:localhost:27183 your_remote_computer
  /// # 保持该窗口开启

  /// 安装 scrcpy
  String get install => 'install scrcpy';

  /// 安装 adb
  String get installADB => 'install adb';

  /// 安装 android-platform-tools
  String get installAndroidTools => 'install android-platform-tools';

  String get help => 'scrcpy --help';

  /// 降低分辨率
  /// 有时候，可以通过降低镜像的分辨率来提高性能。
  /// 要同时限制宽度和高度到某个值 (例如 1024)
  /// "scrcpy -m 1024"  # 简写
  String setMaxSize(int size) => 'scrcpy --max-size $size';

  /// 修改码率
  /// 默认码率是 8 Mbps。改变视频码率 (例如改为 2 Mbps)
  /// scrcpy -b 2M  # 简写
  String setBitRate(int rate) => 'scrcpy --bit-rate ${rate}M';

  /// 限制帧率
  /// 要限制采集的帧率
  /// 本功能从 Android 10 开始才被官方支持，但在一些旧版本中也能生效。
  String setMaxFPS(int fps) => 'scrcpy --max-fps $fps';

  /// 画面裁剪
  /// 可以对设备屏幕进行裁剪，只镜像屏幕的一部分。
  /// 例如可以只镜像 Oculus Go 的一只眼睛。
  String crop(Offset startOffset, Offset endOffset) =>
      'scrcpy --crop ${startOffset.dx}:${startOffset.dy}:${endOffset.dx}:${endOffset.dy}';

  /// 锁定屏幕方向
  /// 要锁定镜像画面的方向
  /// 默认为 初始方向
  /// 0  自然方向
  /// 1  逆时针旋转 90°
  /// 2  180°
  /// 3  顺时针旋转 90°
  String lockOrientation([String orientation = '']) =>
      'scrcpy --lock-video-orientation $orientation';

  /// 编码器
  /// 一些设备内置了多种编码器，但是有的编码器会导致问题或崩溃。可以手动选择其它编码器：
  String encoder(String encoder) => 'scrcpy --encoder $encoder';

  /// 列出可用的编码器，可以指定一个不存在的编码器名称，错误信息中会包含所有的编码器
  String encoderList(r) => 'scrcpy --encoder _';

  /// 屏幕录制
  /// 可以在镜像的同时录制视频：
  /// scrcpy -r file.mkv
  String record(String fileName) => 'scrcpy --record $fileName';

  /// 仅录制，不显示镜像：
  /// # 按 Ctrl+C 停止录制
  /// 录制时会包含“被跳过的帧”，即使它们由于性能原因没有实时显示。设备会为每一帧打上 时间戳 ，所以 包时延抖动 不会影响录制的文件。
  /// scrcpy -Nr file.mkv
  String recordNoDisplay(String fileName) =>
      'scrcpy --no-display --record $fileName';

  /// v4l2loopback
  /// 在 Linux 上，可以将视频流发送至 v4l2 回环 (loopback) 设备，因此可以使用任何 v4l2 工具像摄像头一样打开安卓设备。
  /// 需安装 v4l2loopback 模块：
  String get installV4l2loopback => 'sudo apt install v4l2loopback-dkms';

  /// 创建一个 v4l2 设备：
  /// 这样会在 /dev/videoN 创建一个新的视频设备，其中 N 是整数。 (更多选项 可以用来创建多个设备或者特定 ID 的设备)。

  String get modprobeV4l2loopback => 'sudo modprobe v4l2loopback';

  /// 列出已启用的设备：
  /// # 需要 v4l-utils 包
  String get v4l2List => 'v4l2-ctl --list-devices';

  /// 使用一个 v4l2 漏开启 scrcpy：
  ///  scrcpy --v4l2-sink=/dev/videoN
  /// scrcpy --v4l2-sink=/dev/videoN --no-display  # 禁用窗口镜像
  /// scrcpy --v4l2-sink=/dev/videoN -N            # 简写
  /// (将 N 替换为设备 ID，使用 ls /dev/video* 命令查看)
  String v4l2OpenScrcpy({bool noDisplay = false, String id = ''}) =>
      'scrcpy --v4l2-sink=/dev/video$id ${noDisplay ? '--no-display' : ''}';

  /// 启用之后，可以使用 v4l2 工具打开视频流：
  /// ffplay -i /dev/videoN
  /// vlc v4l2:/dev/videoN   # VLC 可能存在一些缓冲延迟
  /// 例如，可以在 OBS 中采集视频。
  String v4l2OpenVideo([bool userVlc = false]) =>
      !userVlc ? 'ffplay -i /dev/videoN' : 'vlc v4l2:/dev/videoN';

  /// 缓冲
  /// 可以加入缓冲，会增加延迟，但可以减少抖动 (见 #2464)。
  /// 对于显示缓冲： # 为显示增加 50 毫秒的缓冲
  String addCache(double ms) => 'scrcpy --display-buffer=$ms';

  /// 对于 V4L2 漏:
  /// # 为 v4l2 漏增加 500 毫秒的缓冲
  String addCacheWithV4l2(double ms) => 'scrcpy --v4l2-buffer=$ms';
}
