module basic;

alias AliasSeq(T...) = T;
template Procedure(RT, string name_, Args...) {
    alias ReturnType = RT;
    enum name = name_;
    alias ArgTypes = Args;
}
