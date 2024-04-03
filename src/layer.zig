const std = @import("std");
const types = @import("types.zig");

pub const LayerKind = enum(types.WORD) {
    normal = 0,
    group = 1,
    tilemap = 2,
};

pub const LayerFlags = packed struct(types.WORD) {
    visible: bool,
    editable: bool,
    lock_movement: bool,
    background: bool,
    prefer_linked_cels: bool,
    display_collapsed: bool,
    reference_layer: bool,

    _padding: u9,
};

pub const LayerBlendMode = enum(types.WORD) {
    normal = 0,
    multiply = 1,
    screen = 2,
    overlay = 3,
    darken = 4,
    lighten = 5,
    color_dodge = 6,
    color_burn = 7,
    hard_light = 8,
    soft_light = 9,
    difference = 10,
    exclusion = 11,
    hue = 12,
    saturation = 13,
    color = 14,
    luminosity = 15,
    addition = 16,
    subtract = 17,
    divide = 18,
};

pub const RawLayer = struct {
    flags: LayerFlags,
    kind: LayerKind,
    child_level: types.WORD,
    // NOTE: both of these are ignored
    default_width: types.WORD,
    default_height: types.WORD,
    blend_mode: LayerBlendMode,
    opacity: types.BYTE,
    name: []const u8,
    tileset_index: types.DWORD = 0,

    pub fn parse(allocator: std.mem.Allocator, reader: anytype) !RawLayer {
        const flags = try reader.readStruct(LayerFlags);
        const kind = try reader.readEnum(LayerKind, .little);
        const child_level = try reader.readInt(types.WORD, .little);
        const default_width = try reader.readInt(types.WORD, .little);
        const default_height = try reader.readInt(types.WORD, .little);
        const blend_mode = try reader.readEnum(LayerBlendMode, .little);
        const opacity = try reader.readInt(types.BYTE, .little);

        // skip 3 bytes of reserved data
        try reader.skipBytes(3, .{});

        const name_size = try reader.readInt(types.WORD, .little);
        const name = try allocator.alloc(types.BYTE, name_size);
        const bytes_read = try reader.read(name);
        if (bytes_read != name_size) {
            return error.InvalidLayerChunk;
        }

        var tileset_index: types.DWORD = 0;
        if (kind == .tilemap) {
            tileset_index = try reader.readInt(types.DWORD, .little);
        }

        return .{
            .flags = flags,
            .kind = kind,
            .child_level = child_level,
            .default_width = default_width,
            .default_height = default_height,
            .blend_mode = blend_mode,
            .opacity = opacity,
            .name = name,
            .tileset_index = tileset_index,
        };
    }
};
