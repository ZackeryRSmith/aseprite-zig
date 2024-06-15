const std = @import("std");

pub fn assertReader(comptime T: type) void {
    const hasReadInt = comptime @hasDecl(T, "readInt");
    const hasReadEnum = comptime @hasDecl(T, "readEnum");
    const hasRead = comptime @hasDecl(T, "read");
    const hasReadStruct = comptime @hasDecl(T, "readStruct");

    if (!hasReadInt or !hasReadEnum or !hasRead or !hasReadStruct) {
        @compileError("Type is not a Reader");
    }
}