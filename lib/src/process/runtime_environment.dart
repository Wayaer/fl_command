import 'dart:io';

class RuntimeEnvironment {
  factory RuntimeEnvironment() => _singleton ??= RuntimeEnvironment._();

  RuntimeEnvironment._();

  static RuntimeEnvironment? _singleton;

  final String _binKey = 'BIN';
  final String _tmpKey = 'TMP';
  final String _homeKey = 'HOME';
  final String _filesKey = 'FILES';
  final String _usrKey = 'USR';

  /// 在安卓端是沙盒路径
  final String _dataKey = 'DATA';
  final String _pathKey = 'PATH';
  bool _isInit = false;

  final Map<String, String> _environment = {};
  String _packageName = '';

  String get packageName => _packageName;

  void initEnvWithPackageName(String packageName) {
    if (_isInit) return;
    _packageName = packageName;
    if (!Platform.isAndroid) {
      _initEnvForDesktop();
      return;
    }
    _environment[_dataKey] = '/data/data/$packageName';
    _environment[_filesKey] = '${_environment[_dataKey]}/files';
    _environment[_usrKey] = '${_environment[_filesKey]}/usr';
    _environment[_binKey] = '${_environment[_usrKey]}/bin';
    _environment[_homeKey] = '${_environment[_filesKey]}/home';
    _environment[_tmpKey] = '${_environment[_usrKey]}/tmp';
    _environment[_pathKey] =
        '${_environment[_binKey]}:${Platform.environment['PATH'] ?? ''}';
    _isInit = true;
  }

  /// 这个不再开放，统一只调用initEnvWithPackageName函数
  /// 即使是PC也需要用packageName来作为标识独立运行
  /// 还是作为集成包运行
  void _initEnvForDesktop() {
    if (_isInit) {
      return;
    }
    String dataPath =
        '${FileSystemEntity.parentOf(Platform.resolvedExecutable)}${Platform.pathSeparator}data';
    Directory dataDir = Directory(dataPath);
    if (!dataDir.existsSync()) {
      dataDir.createSync();
    }
    _environment[_dataKey] = dataPath;
    _environment[_filesKey] = dataPath;
    _environment[_usrKey] = '$dataPath${Platform.pathSeparator}usr';
    _environment[_binKey] =
        '${_environment[_usrKey]}${Platform.pathSeparator}bin';
    _environment[_homeKey] = '$dataPath${Platform.pathSeparator}home';
    _environment[_tmpKey] =
        '${_environment[_usrKey]}${Platform.pathSeparator}tmp';
    _environment[_pathKey] =
        '${_environment[_binKey]}:${Platform.environment['PATH'] ?? ''}';
    _isInit = true;
  }

  Map<String, String> environment() {
    final Map<String, String> map = Map.from(Platform.environment);
    if (Platform.isWindows) {
      map['PATH'] = '$binPath;${map['PATH'] ?? ''}';
    } else {
      map['PATH'] = '$binPath:${map['PATH'] ?? ''}';
    }
    return map;
  }

  void write(String key, String value) => _environment[key] = value;

  String? getValue(String key) {
    if (_environment.containsKey(key)) {
      return _environment[key];
    }
    return '';
  }

  String get binPath {
    if (_environment.containsKey(_binKey)) {
      return _environment[_binKey] ?? '';
    }
    throw Exception();
  }

  /// 这是是 PATH 这个变量的值
  String get path {
    if (_environment.containsKey(_pathKey)) {
      return _environment[_pathKey] ?? '';
    }
    throw Exception();
  }

  String get dataPath {
    if (_environment.containsKey(_dataKey)) {
      return _environment[_dataKey] ?? '';
    }
    throw Exception();
  }

  set binPath(String value) => _environment[_binKey] = value;

  String get usrPath {
    if (_environment.containsKey(_usrKey)) {
      return _environment[_usrKey] ?? '';
    }
    throw Exception();
  }

  set usrPath(String value) => _environment[_usrKey] = value;

  String get tmpPath {
    if (_environment.containsKey(_tmpKey)) {
      return _environment[_tmpKey] ?? '';
    }
    throw Exception();
  }

  set tmpPath(String value) => _environment[_tmpKey] = value;

  String get homePath {
    if (_environment.containsKey(_homeKey)) {
      return _environment[_homeKey] ?? '';
    }
    throw Exception();
  }

  set homePath(String value) => _environment[_homeKey] = value;

  String get filesPath {
    if (_environment.containsKey(_filesKey)) {
      return _environment[_filesKey] ?? '';
    }
    throw Exception();
  }

  set filesPath(String value) => _environment[_filesKey] = value;
}
