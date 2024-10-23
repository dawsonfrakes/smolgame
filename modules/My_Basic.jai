CPU_Endianness :: enum u8 {
    UNKNOWN :: 0;
    LITTLE :: 1;
    BIG :: 2;
}

ENDIAN :: #run -> CPU_Endianness {
    ifx #complete CPU == {
        case .UNINITIALIZED; #through;
        case .KRAMPU; #through;
        case .CUSTOM;
            return .UNKNOWN;
        case .X64; #through;
        case .ARM64;
            return .LITTLE;
    };
}

#assert ENDIAN != .UNKNOWN;

native_to_little :: ($T: Type, x: T) -> T {
    Bit_Operations :: #import "Bit_Operations";
    return ifx ENDIAN == .LITTLE x else Bit_Operations.byte_swap(x);
}

native_to_big :: ($T: Type, x: T) -> T {
    Bit_Operations :: #import "Bit_Operations";
    return ifx ENDIAN == .BIG x else Bit_Operations.byte_swap(x);
}

ascii_to_utf16le_string_literal :: ($name: string) -> [name.count + 1] u16 {
    result : [name.count + 1] u16;
    for 0..name.count-1
        result[it] = native_to_little(u16, name[it]);
    return result;
}
