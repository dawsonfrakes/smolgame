module basic;

public import core.stdc.config : c_long, c_ulong;

alias AliasSeq(T...) = T;
template Procedure(RT, string name_, Args...) {
    alias ReturnType = RT;
    enum name = name_;
    alias ArgTypes = Args;
}
