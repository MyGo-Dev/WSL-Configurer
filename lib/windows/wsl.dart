import 'dart:io';

class WindowsSubSystemLinux {
  static void shutdown(String target, {String? distro}) async {
    await Process.run("wsl", [
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
    return (await Process.run("wsl", ["-l", "-q"]))
        .stdout
        .toString()
        .split("\n")
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }

  static List<String> getAvailableDistroSync() {
    return Process.runSync("wsl", ["-l", "-q"])
        .stdout
        .toString()
        .split("\n")
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }
}
