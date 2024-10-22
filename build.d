import std.array : split;
import std.file : mkdirRecurse;
import std.process : spawnProcess, wait;
import std.stdio : writeln;

void main(string[] args) {
    bool do_run = false;
    if (args.length >= 2) {
        switch (args[1]) {
            case "run":
                do_run = true;
                break;
            default:
                writeln("error: usage: ", args[0], " [run]");
                return;
        }
    }

    ".build".mkdirRecurse;

    if ("ldmd2 -g -J. -of=.build/game.exe main.d".split.spawnProcess.wait != 0) return;

    if (do_run) ".build/game.exe".spawnProcess;
}
