const std = @import("std");

/// A 8-bit unsigned integer value.
pub const BYTE = u8;
/// A 16-bit unsigned integer value.
pub const WORD = u16;
/// A 16-bit signed integer value.
pub const SHORT = i16;
/// A 32-bit unsigned integer value.
pub const DWORD = u32;
/// A 32-bit signed integer value.
pub const LONG = i32;
// TODO: FIXED
/// A 32-bit single-precision value.
pub const FLOAT = f32;
/// A 64-bit double-precision value.
pub const DOUBLE = f64;
/// A 64-bit unsigned integer value.
pub const QWORD = u64;
/// A 64-bit signed integer value.
pub const LONG64 = i64;
// TODO: add doc comment here
pub const STRING = struct {
   length: WORD,
   data: []BYTE,

   pub fn parse(reader: anytype, a: std.mem.Allocator) !STRING {
       const length = try reader.readInt(WORD, .little);
       const buffer = a.alloc(u8, length);
       try reader.readAtLeast(buffer, length);
       return .{ .length = length, .data = buffer };
   }
};
/// A struct containing two LONG's: x and y.
pub const POINT = struct { x: LONG, y: LONG };
/// A struct containing two LONG's: width and height.
pub const SIZE = struct { width: LONG, height: LONG };

/// A struct containing a POINT and a SIZE.
pub const RECT = struct { origin: POINT, size: SIZE };

pub const ColorDepth = enum(WORD) {
    /// Has 1 byte (the index).
    INDEXED = 8,
    /// Has 2 bytes in the order Value, Alpha.
    GRAYSCALE = 16,
    /// Has 4 bytes in this order Red, Green, Blue, Alpha.
    RGBA = 32,
};

// TODO: TILE

/// A Universally Unique IDentifier.
pub const UUID = [16]u8;
