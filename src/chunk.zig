const std = @import("std");
const types = @import("types.zig");

const layerType = @import("layer.zig");

pub const ChunkType = enum(types.WORD) {
    old_palette_255 = 0x0004,
    old_palette_63 = 0x0011,
    layer = 0x2004,
    cel = 0x2005,
    cel_extra = 0x2006,
    color_profile = 0x2007,
    external_files = 0x2008,
    mask = 0x2016, // DEPRECATED
};

pub const ChunkData = union(enum) {
    layer: layerType,
};

pub const RawChunk = struct {
    chunk_size: types.DWORD,
    chunk_type: ChunkType,
    chunk_data: ChunkData, // Doesn't include chunk_size and chunk_type
    
    pub fn parse(allocator: std.mem.Allocator, reader: std.io.AnyReader) !RawChunk {
        const chunk_size = try reader.readInt(types.DWORD, .little);
        const chunk_type = try reader.readEnum(ChunkType, .little);

        switch (chunk_type) {
            ChunkType.layer => {
                const chunk_data = try layerType.RawLayer.parse(allocator, reader);
                return .{
                    .chunk_size = chunk_size,
                    .chunk_type = chunk_type,
                    .chunk_data = .layer(chunk_data),
                };
            }
        }

        return .{
            .chunk_size = chunk_size,
            .chunk_type = chunk_type,
        };
    }
};
