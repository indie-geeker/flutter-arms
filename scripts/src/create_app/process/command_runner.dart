import 'dart:io';

class CommandResult {
  const CommandResult({
    required this.exitCode,
    required this.stdout,
    required this.stderr,
  });

  final int exitCode;
  final String stdout;
  final String stderr;

  bool get isSuccess => exitCode == 0;
}

abstract class CommandRunner {
  Future<CommandResult> run(List<String> command, {String? workingDirectory});
}

class ProcessCommandRunner implements CommandRunner {
  const ProcessCommandRunner();

  @override
  Future<CommandResult> run(
    List<String> command, {
    String? workingDirectory,
  }) async {
    final executable = command.first;
    final args = command.sublist(1);

    final result = await Process.run(
      executable,
      args,
      workingDirectory: workingDirectory,
      runInShell: true,
    );

    return CommandResult(
      exitCode: result.exitCode,
      stdout: result.stdout.toString(),
      stderr: result.stderr.toString(),
    );
  }
}
