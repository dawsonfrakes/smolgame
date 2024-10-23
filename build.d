import std.array : split;
import std.file : mkdirRecurse;
import std.process : spawnProcess, wait;

void main(string[] args) {
    ".build".mkdirRecurse;

    if ("dmd -betterC -of=.build/game.exe platform/windows.d game/game.d".split.spawnProcess.wait != 0)
        return;

    if (args.length >= 2 && args[1] == "run")
        ".build/game.exe".spawnProcess;
}
