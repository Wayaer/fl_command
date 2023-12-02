import 'package:flutter/cupertino.dart';

class AdbScript {
  factory AdbScript() => _singleton ??= AdbScript._();

  AdbScript._();

  static AdbScript? _singleton;

  /// am 数据
  final AdbAMScript am = AdbAMScript();

  /// pm数据
  final AdbPMScript pm = AdbPMScript();

  /// dumpsys 数据
  final AdbAdbDumpsysScript dumpsys = AdbAdbDumpsysScript();

  /// 可以通过如下命令列出所有显示屏的 id：
  String adbAllDisplay({String? serial}) =>
      'adb ${serial == null ? '' : '-s $serial'} shell dumpsys display';

  /// 查看当前目录
  String currentDirectory = 'ls';

  /// 查看指定应用内容
  String runAS(String packageName, {String? serial}) =>
      'run ${serial == null ? '' : '-s $serial'} as $packageName';

  /// 查看服务列表
  String serviceList({String? serial}) =>
      'adb ${serial == null ? '' : '-s $serial'} shell service list';

  /// 查看服务是否存在
  String checkService(String serviceName, {String? serial}) =>
      'adb ${serial == null ? '' : '-s $serial'} shell service check $serviceName';

  String screenRecord(String path,
      {Size? size,
      int? bitRate,
      int? timeLimit,
      bool verbose = false,
      String? serial}) {
    var record =
        'adb ${serial == null ? '' : '-s $serial'} shell screenrecord $path';
    if (size != null) {
      record = record.replaceFirst('screenrecord', 'screenrecord --size $size');
    }
    if (bitRate != null) {
      record = record.replaceFirst(
          'screenrecord', 'screenrecord --bit-rate $bitRate');
    }
    if (timeLimit != null) {
      record = record.replaceFirst(
          'screenrecord', 'screenrecord --time-limit $timeLimit');
    }
    if (verbose) {
      record = record.replaceFirst('screenrecord', 'screenrecord --verbose');
    }
    return record;
  }
}

class AdbAMScript {
  factory AdbAMScript() => _singleton ??= AdbAMScript._();

  AdbAMScript._();

  static AdbAMScript? _singleton;

  //

  /// 这里-a表示动作，-d表述传入的数据，还有-t表示传入的类型
  /// 例如，打开一个网页：
  /// adb shell am start -a android.intent.action.VIEW -d http:/// www.baidu.com （这里-d表示传入的data）
  /// 打开音乐播放器:
  /// adb shell am start -a android.intent.action.MUSIC_PLAYER
  /// 发送广播：
  /// adb shell am broadcast -a {广播动作}
  String startActivity(
      {String? action,
      String? data,
      String? mimeType,
      String? identifier,
      String? serial}) {
    String start = 'adb ${serial == null ? '' : '-s $serial'} shell am start';
    if (action != null) start += ' -a $action';
    if (data != null) start += ' -d $data';
    if (mimeType != null) start += ' -t $mimeType';
    if (identifier != null) start += ' -i $identifier';
    return start;
  }

  /// 打开服务
  String startService(String serviceName, {String? serial}) =>
      'adb ${serial == null ? '' : '-s $serial'} shell am startservice $serviceName';

  /// 关闭服务
  String stopService(String serviceName, {String? serial}) =>
      'adb ${serial == null ? '' : '-s $serial'} shell am stopservice $serviceName';

  /// 应用程序启动耗时
  /// WaitTime 表示总的耗时，包括前一个应用 Activity pause 的时间和新应用启动的时；
  /// ThisTime 表示一连串启动 Activity 的最后一个 Activity 的启动耗时；
  /// TotalTime 表示新应用启动的耗时，包括新进程的启动和 Activity 的启动，但不包括前一个应用 Activity pause 的耗时。也就是说，开发者一般只要关心TotalTime 即可，这个时间才是自己应用真正启动的耗时
  String startTimeConsuming(String packageName, String activityName,
          {String? serial}) =>
      'adb ${serial == null ? '' : '-s $serial'} shell am start -W $packageName/$activityName';

  /// 查看所有应用程序的Activity栈信息
  String stackList({String? serial}) =>
      'adb ${serial == null ? '' : '-s $serial'} shell am stack list';

  /// 查看某个应用程序的Activity栈信息
  String stackListWithApp(String packageName, {String? serial}) =>
      'adb ${serial == null ? '' : '-s $serial'} shell am stack list | grep $packageName';

  /// 模拟系统低内存
  /// level:
  /// COMPLETE：该进程接近后台LRU列表的末尾，如果很快找不到更多内存，它将被终止。
  /// MODERATE：该进程位于后台LRU列表的中间； 释放内存可以帮助系统在列表中稍后运行其他进程以获得更好的整体性能。
  /// BACKGROUND：该进程已进入LRU列表。 这是一个清理资源的好机会，如果用户返回应用程序，可以高效快速地重建这些资源。
  /// HIDDEN：该进程一直显示用户界面，并且不再这样做。 此时应该释放具有UI的大量分配，以便更好地管理内存。
  /// RUNNING_CRITICAL：该进程不是一个可消耗的后台进程，但是该设备的内存运行极低，并且无法保持任何后台进程运行。 您的运行进程应该释放尽可能多的非关键资源，以允许在其他地方使用该内存。 接下来的事情将在{@link #onLowMemory（）}调用后报告该事件什么都没有可以保留在后台，这种情况可以明显影响用户。
  /// RUNNING_LOW：该进程不是可消耗的后台进程，但设备内存不足。 您的运行进程应释放不需要的资源，以允许在其他地方使用该内存。
  /// RUNNING_MODERATE：该进程不是可消耗的后台进程，但设备的内存运行速度适中。 您的运行进程可能希望释放一些不需要的资源以供其他地方使用。
  /// 例子
  /// adb shell am send-trim-memory 10053 RUNNING_LOW
  String sendTrimMemory(String pid, String level, {String? serial}) =>
      'adb ${serial == null ? '' : '-s $serial'} shell am send-trim-memory $pid $level';

  /// 查看更多信息
  String am({String? serial}) =>
      'adb ${serial == null ? '' : '-s $serial'} shell am';
}

class AdbPMScript {
  factory AdbPMScript() => _singleton ??= AdbPMScript._();

  AdbPMScript._();

  static AdbPMScript? _singleton;

  /// 安装包路径信息
  String apkPath(String packageName, {String? serial}) =>
      'adb ${serial == null ? '' : '-s $serial'} shell pm path --user 0 $packageName';

  /// 查看手机上安装的应用程序
  String packageList({String? serial}) =>
      'adb ${serial == null ? '' : '-s $serial'} shell pm list packages';

  /// 输出包和包相关联的文件
  String associatedPackages({String? serial}) =>
      'adb ${serial == null ? '' : '-s $serial'} shell pm list packages -f';

  /// 只输出禁用的包(有可能没有)
  String disablePackages({String? serial}) =>
      'adb ${serial == null ? '' : '-s $serial'} shell pm list packages -d';

  /// 只输出启用的包
  String enablePackages({String? serial}) =>
      'adb ${serial == null ? '' : '-s $serial'} shell pm list packages -e';

  /// 只输出系统的包
  String systemPackages({String? serial}) =>
      'adb ${serial == null ? '' : '-s $serial'} shell pm list packages -s';

  /// 只输出第三方的包
  String userPackages({String? serial}) =>
      'adb ${serial == null ? '' : '-s $serial'} shell pm list packages -3';

  /// 只输出包和安装信息（安装来源）
  String installPackages({String? serial}) =>
      'adb ${serial == null ? '' : '-s $serial'} shell pm list packages -i';

  /// 只输出包和未安装包信息（安装来源）
  String uninstallPackages({String? serial}) =>
      'adb ${serial == null ? '' : '-s $serial'} shell pm list packages -u';

  /// 根据用户id查询用户的空间的所有包，USER_ID代表当前连接设备的顺序，从零开始：
  String userAllPackages(String userId, {String? serial}) =>
      'adb ${serial == null ? '' : '-s $serial'} shell pm list packages --user $userId';

  /// 清除包数据
  String clearPackageData(String packageName, {String? serial}) =>
      'adb ${serial == null ? '' : '-s $serial'} shell pm clear $packageName';

  /// 查看更多信息
  String pm({String? serial}) =>
      'adb ${serial == null ? '' : '-s $serial'} shell pm';
}

class AdbAdbDumpsysScript {
  factory AdbAdbDumpsysScript() => _singleton ??= AdbAdbDumpsysScript._();

  AdbAdbDumpsysScript._();

  static AdbAdbDumpsysScript? _singleton;

  /// 查看dumpsys相关命令：
  String dumpsysHelp({String? serial}) =>
      'adb ${serial == null ? '' : '-s $serial'} shell dumpsys --help';

  /// 输出可与dumpsys一起使用的完整系统服务列表：
  String dumpsysL({String? serial}) =>
      'adb ${serial == null ? '' : '-s $serial'} shell dumpsys -l';

  /// AC powered: false
  /// USB powered: true
  /// Wireless powered: false
  /// Max charging current: 500000
  /// Max charging voltage: 4925000
  /// Charge counter: 139
  /// status: 2 /// 电池状态：2为充电状态 ，其他数字为非充电状态
  /// health: 2 /// 电池健康状态：只有数字2表示good
  /// present: true /// 电池是否安装在机身
  /// level: 73 /// 电量: 百分比
  /// scale: 100
  /// voltage: 4058 /// 电池电压
  /// temperature: 300 /// 电池温度，单位是0.1摄氏度
  /// technology: Li-poly /// 电池种类
  String dumpsysBattery({String? serial}) =>
      'adb ${serial == null ? '' : '-s $serial'} shell dumpsys battery';

  /// 将手机切换充电状态
  /// 电池状态：2为充电状态 ，其他数字为非充电状态
  String setBatteryStatus(int status, {String? serial}) =>
      'adb ${serial == null ? '' : '-s $serial'} shell dumpsys battery set status $status';

  /// 改变手机电量
  String setBatteryLevel(int level, {String? serial}) =>
      'adb ${serial == null ? '' : '-s $serial'} shell dumpsys battery set level $level';

  /// 获取整个设备的电量消耗信息
  String batteryStats({String? packageName, String? serial}) {
    var stats =
        'adb ${serial == null ? '' : '-s $serial'} shell dumpsys batterystats | more';
    if (packageName != null) stats = stats.replaceFirst('|', '$packageName |');
    return stats;
  }
}

class AndroidSettingActivity {
  factory AndroidSettingActivity() => _singleton ??= AndroidSettingActivity._();

  AndroidSettingActivity._();

  static AndroidSettingActivity? _singleton;

  /// 辅助功能设置
  String accessibilitySettings = 'com.android.settings.AccessibilitySettings';

  /// 选择活动
  String activityPicker = 'com.android.settings.ActivityPicker';

  /// APN设置
  String apnSettings = 'com.android.settings.ApnSettings';

  /// 应用程序设置
  String applicationSettings = 'com.android.settings.ApplicationSettings';

  /// 设置GSM/UMTS波段
  String bandMode = 'com.android.settings.BandMode';

  /// 电池信息
  String batteryInfo = 'com.android.settings.BatteryInfo';

  /// 日期和坝上旅游网时间设置
  String dateTimeSettings = 'com.android.settings.DateTimeSettings';

  /// 日期和时间设置
  String dateTimeSettingsSetupWizard =
      'com.android.settings.DateTimeSettingsSetupWizard';

  /// 开发者设置
  String developmentSettings = 'com.android.settings.DevelopmentSettings';

  /// 设备管理器
  String deviceAdminSettings = 'com.android.settings.DeviceAdminSettings';

  /// 关于手机
  String deviceInfoSettings = 'com.android.settings.DeviceInfoSettings';

  /// 显示——设置显示字体大小及预览
  String display = 'com.android.settings.Display';

  /// 显示设置
  String displaySettings = 'com.android.settings.DisplaySettings';

  /// 底座设置
  String dockSettings = 'com.android.settings.DockSettings';

  /// SIM卡锁定设置
  String iccLockSettings = 'com.android.settings.IccLockSettings';

  /// 语言和键盘设置
  String installedAppDetails = 'com.android.settings.InstalledAppDetails';

  /// 语言和键盘设置
  String languageSettings = 'com.android.settings.LanguageSettings';

  /// 选择手机语言
  String localePicker = 'com.android.settings.LocalePicker';

  /// 选择手机语言
  String localePickerInSetupWizard =
      'com.android.settings.LocalePickerInSetupWizard';

  /// 已下载（安装）软件列表
  String manageApplications = 'com.android.settings.ManageApplications';

  /// 恢复出厂设置
  String masterClear = 'com.android.settings.MasterClear';

  /// 格式化手机闪存
  String mediaFormat = 'com.android.settings.MediaFormat';

  /// 设置键盘
  String physicalKeyboardSettings =
      'com.android.settings.PhysicalKeyboardSettings';

  /// 隐私设置
  String privacySettings = 'com.android.settings.PrivacySettings';

  /// 代理设置
  String proxySelector = 'com.android.settings.ProxySelector';

  /// 手机信息
  String radioInfo = 'com.android.settings.RadioInfo';

  /// 正在运行的程序（服务）
  String runningServices = 'com.android.settings.RunningServices';

  /// 位置和安全设置
  String securitySettings = 'com.android.settings.SecuritySettings';

  /// 系统设置
  String settings = 'com.android.settings.Settings';

  /// 安全信息
  String settingsSafetyLegalActivity =
      'com.android.settings.SettingsSafetyLegalActivity';

  /// 声音设置
  String soundSettings = 'com.android.settings.SoundSettings';

  /// 测试——显示手机信息、电池信息、使用情况统计、Wifi information、服务信息
  String testingSettings = 'com.android.settings.TestingSettings';

  /// 绑定与便携式热点
  String tetherSettings = 'com.android.settings.TetherSettings';

  /// 文字转语音设置
  String textToSpeechSettings = 'com.android.settings.TextToSpeechSettings';

  /// 使用情况统计
  String usageStats = 'com.android.settings.UsageStats';

  /// 用户词典
  String userDictionarySettings = 'com.android.settings.UserDictionarySettings';

  /// 语音输入与输出设置
  String voiceInputOutputSettings =
      'com.android.settings.VoiceInputOutputSettings';

  /// 无线和网络设置
  String wirelessSettings = 'com.android.settings.WirelessSettings';
}
