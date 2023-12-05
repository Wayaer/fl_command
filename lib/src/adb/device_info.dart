class DeviceInfoModel {
  DeviceInfoModel({required this.id, required this.info})
      : model = info["ro.product.model"],
        release = info["ro.build.version.release"],
        sdk = info["ro.build.version.sdk"],
        brand = info["ro.product.brand"];

  /// sdk [29]
  final String? sdk;

  /// release [Android 10]
  final String? release;

  /// brand [HUAWEI]
  final String? brand;

  /// model
  final String? model;

  /// device id
  final String id;

  final Map<String, String> info;
}

class DeviceProcessModel {
  static int l = 9;

  DeviceProcessModel(List<String> info)
      : user = info[0],
        pid = info[1],
        ppid = info[2],
        vsz = info[3],
        rss = info[4],
        wchan = info[5],
        addr = info[6],
        s = info[7],
        name = info[8];

  final String user;
  final String pid;
  final String ppid;
  final String vsz;
  final String rss;
  final String wchan;
  final String addr;
  final String s;
  final String name;
}
