const types = @import("types.zig");

// TODO: Aseprite

// TODO: improve my spelling below this comment
// TODO: imporve this doc comment
/// A bare bones Aseprite file representation
pub const RawAseprite = struct {
    file_size: types.DWORD,
    /// Magic number in the file.
    magic_number: types.WORD, // NOTE: ALWAYS 0xA5E0
    frame_count: types.WORD,
    /// Width in pixels.
    width: types.WORD,
    /// Height in pixels.
    height: types.WORD,
    color_depth: types.ColorDepth,
    flags: types.DWORD,
    /// Speed of each frame in miliseconds. (DEPRECATED)
    // NOTE: use frame duration found in frame header
    _speed: types.WORD,
    /// Palette entry index that defines transparent pixels.
    /// Only used if ColorDepth is INDEXED.
    palette_transparency_index: types.BYTE,
    // NOTE: 0 means 256 for old sprites
    /// Number of colors in the palette.
    color_count: types.WORD,
    /// Width of one pixel.
    pixel_width: types.BYTE,
    /// Height of one pixel.
    pixel_height: types.BYTE,
    /// Grid x start position.
    grid_pos_x: types.SHORT,
    /// Grid y start position.
    grid_pos_y: types.SHORT,
    /// Width of grid. 0 if there is no grid, 16 by default.
    grid_width: types.WORD,
    /// Height of grid. 0 if there is no grid, 16 by default.
    grid_height: types.WORD,

    pub fn parse(reader: anytype) !RawAseprite {
        // TODO: maybe verify that `reader` is a reader of some kind?
        const file_size = try reader.readInt(types.DWORD, .little);
        const magic_number = try reader.readInt(types.WORD, .little);

        // check the magic number
        if (magic_number != 0xA5E0) {
            return error.InvalidMagicNumber;
        }

        const frame_count = try reader.readInt(types.WORD, .little);
        const width = try reader.readInt(types.WORD, .little);
        const height = try reader.readInt(types.WORD, .little);
        const color_depth = try reader.readEnum(types.ColorDepth, .little);
        const flags = try reader.readInt(types.DWORD, .little);
        const _speed = try reader.readInt(types.WORD, .little);

        const zero1 = try reader.readInt(types.DWORD, .little);
        const zero2 = try reader.readInt(types.DWORD, .little);

        if (zero1 != 0 or zero2 != 0) {
            return error.InvalidHeader;
        }

        const palette_transparency_index = try reader.readInt(types.BYTE, .little);

        // skip 3 bytes of reserved data
        try reader.skipBytes(3, .{});

        const color_count = try reader.readInt(types.WORD, .little);
        const pixel_width = try reader.readInt(types.BYTE, .little);
        const pixel_height = try reader.readInt(types.BYTE, .little);
        const grid_pos_x = try reader.readInt(types.SHORT, .little);
        const grid_pos_y = try reader.readInt(types.SHORT, .little);
        const grid_width = try reader.readInt(types.WORD, .little);
        const grid_height = try reader.readInt(types.WORD, .little);

        // skip 84 bytes of reserved data
        try reader.skipBytes(84, .{});

        return .{
            .file_size = file_size,
            .magic_number = magic_number,
            .frame_count = frame_count,
            .width = width,
            .height = height,
            .color_depth = color_depth,
            .flags = flags,
            ._speed = _speed,
            .palette_transparency_index = palette_transparency_index,
            .color_count = color_count,
            .pixel_width = pixel_width,
            .pixel_height = pixel_height,
            .grid_pos_x = grid_pos_x,
            .grid_pos_y = grid_pos_y,
            .grid_width = grid_width,
            .grid_height = grid_height,
        };
    }
};
