module basic;

public import core.stdc.config : c_long, c_ulong;

alias AliasSeq(T...) = T;
template Opaque(string name) {
    mixin("struct "~name~"__; alias "~name~" = "~name~"__*;");
}
template Procedure(RT, string name_, Args...) {
    alias ReturnType = RT;
    enum name = name_;
    alias ArgTypes = Args;
}
template ProcedureDeclarations(string callconv, procedures...) {
    static foreach (proc; procedures) {
        mixin("extern extern("~callconv~") proc.ReturnType "~proc.name~proc.ArgTypes.stringof~";");
    }
}
template ProcedureDeclarationsDynamic(string callconv, procedures...) {
    static foreach (proc; procedures) {
        mixin("__gshared extern("~callconv~") proc.ReturnType function"~proc.ArgTypes.stringof~" "~proc.name~";");
    }
}
