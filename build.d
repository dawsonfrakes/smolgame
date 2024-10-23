import std.array : split;
import std.process : spawnProcess, wait;
import std.file : mkdirRecurse;
import std.stdio : writeln;

void main(string[] args) {
    bool do_run = false;
    if (args.length >= 2) switch (args[1]) {
        case "run": do_run = true; break;
        default: writeln("error: usage: ", args[0], " [run]"); return;
    }

    ".build".mkdirRecurse;

    "ldmd2 -betterC -of=.build/game.exe platform/main_windows".split.spawnProcess.wait;

    if (do_run) ".build/game.exe".spawnProcess.wait;
}
