const std = @import("std");
const types = @import("types.zig");

pub const ColorProfileKind = enum(types.WORD) {
    none = 0,
    srgb = 1,
    embedded_icc_profile = 2,
};

pub const ColorProfileFlags = packed struct(types.WORD) {
    use_special_gamma: bool,
    _padding: u15,
};

pub const RawColorProfile = struct {
    kind: ColorProfileKind,
    flags: ColorProfileFlags,
    // NOTE: As zig doesn't support fixed point numbers I've just opted to use
    // a DWORD for now
    fixed_gamma: types.DWORD,
    icc_data_length: types.DWORD = 0,
    icc_data: ?[]types.BYTE = null,

    pub fn parse(allocator: std.mem.Allocator, reader: anytype) !RawColorProfile {
        const kind = try reader.readEnum(ColorProfileKind, .little);
        const flags = try reader.readStruct(ColorProfileFlags);
        const fixed_gamma = try reader.readInt(types.DWORD, .little);

        // skip 8 bytes of reserved data
        try reader.skipBytes(8, .{});

        var icc_data_length: types.DWORD = 0;
        var icc_data: ?[]types.BYTE = null;
        if (kind == .embedded_icc_profile) {
            icc_data_length = try reader.readInt(types.DWORD, .little);
            const icc_data_buf = try allocator.alloc(types.BYTE, icc_data_length);

            // check that we read the correct number of bytes
            const bytes_read = try reader.read(icc_data_buf);
            if (bytes_read != icc_data_length) {
                return error.InvalidColorProfileChunk;
            }

            icc_data = icc_data_buf;
        }

        return .{
            .kind = kind,
            .flags = flags,
            .fixed_gamma = fixed_gamma,
            .icc_data_length = icc_data_length,
            .icc_data = icc_data,
        };
    }
};
