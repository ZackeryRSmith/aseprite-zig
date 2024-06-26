const types = @import("types.zig");

// TODO: AsepriteFrame

pub const RawFrame = struct {
    frame_size: types.DWORD,
    /// Magic number in the file.
    magic_number: types.WORD, // NOTE: ALWAYS 0xF1FA
    /// (OLD) Number of chunks in the frame.
    old_chunk_count: types.WORD,
    /// Frame duration. (in milliseconds)
    duration: types.WORD,
    /// Number of chunks in the frame.
    chunk_count: types.DWORD,

    pub fn parse(reader: anytype) !RawFrame {
        const frame_size = try reader.readInt(types.DWORD, .little);
        const magic_number = try reader.readInt(types.WORD, .little);

        // check the magic number
        if (magic_number != 0xF1FA) {
            return error.InvalidMagicNumber;
        }

        const old_chunk_count = try reader.readInt(types.WORD, .little);
        const duration = try reader.readInt(types.WORD, .little);

        // skip 2 bytes of reserved data
        try reader.skipBytes(2, .{});

        const chunk_count = try reader.readInt(types.DWORD, .little);

        return .{
            .frame_size = frame_size,
            .magic_number = magic_number,
            .old_chunk_count = old_chunk_count,
            .duration = duration,
            .chunk_count = chunk_count,
        };
    }
};
