const std = @import("std");
const types = @import("types.zig");

pub const CelType = enum(types.WORD) {
    raw = 0,
    linked = 1,
    compressed_image = 2,
    compressed_tilemap = 3,
};

pub const CelData = union(enum) {
    raw: struct {
        width: types.WORD,
        height: types.WORD,
        data: []types.BYTE,
    },
    linked: struct {
        frame_position: types.WORD,
    },
    // TODO: support me
    compressed_image: struct {
        width: types.WORD,
        height: types.WORD,
        data: []types.BYTE,
    },
    // TODO: support me
    compressed_tilemap: struct {
        /// Width in tiles.
        width: types.WORD,
        /// Height in tiles.
        height: types.WORD,
        // NOTE: At the moment it's always 32-bit per tile .
        bits_per_tile: types.WORD = 32,
        title_id_bitmask: types.DWORD,
        x_flip_bitmask: types.DWORD,
        y_flip_bitmask: types.DWORD,
        diagonal_flip_bitmask: types.DWORD,
        data: []types.BYTE,
    },

    pub fn deinit(self: CelData, allocator: std.mem.Allocator) void {
        switch (self) {
            .raw => |raw| {
                allocator.free(raw.data);
            },
            // NOTE: nothing to deinit here
            .linked => {},
            .compressed_image => |compressed_image| {
                allocator.free(compressed_image.data);
            },
            // TODO: impl.
            .compressed_tilemap => {},
        }
    }
};

pub const RawCel = struct {
    layer_index: types.WORD,
    x_pos: types.SHORT,
    y_pos: types.SHORT,
    opacity_level: types.BYTE,
    kind: CelType,
    z_index: types.SHORT,
    data: CelData,

    pub fn parse(allocator: std.mem.Allocator, reader: anytype, chunk_size: types.DWORD) !RawCel {
        const layer_index = try reader.readInt(types.WORD, .little);
        const x_pos = try reader.readInt(types.SHORT, .little);
        const y_pos = try reader.readInt(types.SHORT, .little);
        const opacity_level = try reader.readInt(types.BYTE, .little);
        const kind = try reader.readEnum(CelType, .little);
        const z_index = try reader.readInt(types.SHORT, .little);

        // skip 5 bytes of reserved data
        try reader.skipBytes(5, .{});

        var cel_data: CelData = undefined;
        switch (kind) {
            .raw => {
                const width = try reader.readInt(types.WORD, .little);
                const height = try reader.readInt(types.WORD, .little);

                // calculate the length of the image data by subtracting the
                // size of the cel header + width and height fields
                const data_length = chunk_size - 26;
                const data = try allocator.alloc(types.BYTE, data_length);
                const bytes_read = try reader.read(data);
                if (bytes_read != data_length) {
                    return error.InvalidCelChunk;
                }

                cel_data = .{ .raw = .{
                    .width = width,
                    .height = height,
                    .data = data,
                } };
            },

            .linked => {
                const frame_position = try reader.readInt(types.WORD, .little);

                cel_data = .{ .linked = .{
                    .frame_position = frame_position,
                } };
            },

            .compressed_image => {
                const width = try reader.readInt(types.WORD, .little);
                const height = try reader.readInt(types.WORD, .little);

                // Calculate the length of the image data by subtracting the size of the header, width and height fields.
                const data_length = chunk_size - 26;
                const data = try allocator.alloc(u8, data_length);
                const bytes_read = try reader.read(data);
                if (bytes_read != data_length) {
                    return error.InvalidCelChunk;
                }

                cel_data = CelData{
                    .compressed_image = .{
                        .width = width,
                        .height = height,
                        .data = data,
                    },
                };
            },

            // TODO: impl.
            .compressed_tilemap => {
                return error.UnsupportedCelType;
            },
        }

        return .{
            .layer_index = layer_index,
            .x_pos = x_pos,
            .y_pos = y_pos,
            .opacity_level = opacity_level,
            .kind = kind,
            .z_index = z_index,
            .data = cel_data,
        };
    }
};
