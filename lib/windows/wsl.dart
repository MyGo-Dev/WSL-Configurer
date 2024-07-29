import 'dart:io';

import 'package:wslconfigurer/windows/utf16.dart';

class WindowsSubSystemLinux {
  static const encoding = utf16;

  static void shutdown(String target, {String? distro}) async {
    await Process.run("wsl.exe", [
      ...distro != null ? ["-d", distro] : [],
      "--shutdown"
    ]);
  }

  static Future<Process> sudo({
    String? distro,
    String? user,
    required String password,
    Iterable<String> commands = const [],
  }) async {
    return await exec(
      commands: ["echo", password, "|", "sudo", "-S", ...commands],
      distro: distro,
      user: user,
    );
  }

  static Future<Process> exec({
    String? distro,
    String? user,
    Iterable<String> commands = const [],
  }) async {
    return await Process.start(
      "wsl",
      [
        ...distro != null ? ["-d", distro] : [],
        ...user != null ? ["-u", user] : [],
        "-e",
        "sh",
        "-c",
        commands.join(" ")
      ],
    );
  }

  static Future<List<String>> getAvailableDistro() async {
    return (await Process.run("wsl.exe", ["-l", "-q"],
            stdoutEncoding: encoding))
        .stdout
        .toString()
        .split("\n")
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }

  static List<String> getAvailableDistroSync() {
    return Process.runSync("wsl.exe", ["-l", "-q"], stdoutEncoding: encoding)
        .stdout
        .toString()
        .split("\n")
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }

  static Future<Process> start({
    Iterable<String> args = const [],
    String? distro,
    String? user,
  }) async {
    return Process.start(
      "start",
      [
        "wsl.exe",
        ...distro != null ? ["-d", distro] : [],
        ...user != null ? ["-u", user] : [],
        "--cd",
        "~",
        ...args
      ],
      runInShell: true,
    );
  }
}

class WSLExplorer {
  final String distro;
  late final String root;
  late Directory current;

  WSLExplorer(this.distro) {
    root = "//wsl.localhost/$distro";
    current = Directory("$root/home");
  }

  Stream<FileSystemEntity> list() {
    return current.list();
  }

  bool get isRoot => current.path == root;

  Future<bool> move(String path) async {
    var target = Directory(path);
    if (await target.exists()) {
      current = target;
      return true;
    }
    return false;
  }

  void parent() {
    current = current.parent;
  }
}
