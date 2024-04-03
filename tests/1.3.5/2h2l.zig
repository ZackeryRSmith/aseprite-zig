const std = @import("std");
const testing = std.testing;

const types = @import("src/types.zig");
const RawAseprite = @import("import.zig").RawAseprite;
const RawFrame = @import("import.zig").RawFrame;
const RawColorProfile = @import("import.zig").RawColorProfile;
const RawLayer = @import("import.zig").RawLayer;
const RawCel = @import("import.zig").RawCel;

test "raw 1.3.5:" {
    // newline for stdout formatting reasons
    std.debug.print("\n", .{});

    const file = try std.fs.cwd().openFile("sprites/1.3.5/2h2l.aseprite", .{});

    var buffer = std.io.bufferedReader(file.reader());
    const reader = buffer.reader();

    ////////////////////////////////////////////////////////////////////////////
    // HEADER
    ////////////////////////////////////////////////////////////////////////////
    std.debug.print("\tparse header: ", .{});
    const header = try RawAseprite.parse(reader);

    try testing.expectEqual(1144, header.file_size);
    try testing.expectEqual(42464, header.magic_number);
    try testing.expectEqual(2, header.frame_count);
    try testing.expectEqual(128, header.width);
    try testing.expectEqual(128, header.height);
    try testing.expectEqual(.RGBA, header.color_depth);
    try testing.expectEqual(1, header.flags);
    try testing.expectEqual(100, header._speed);
    try testing.expectEqual(0, header.palette_transparency_index);
    try testing.expectEqual(32, header.color_count);
    try testing.expectEqual(1, header.pixel_width);
    try testing.expectEqual(1, header.pixel_height);
    try testing.expectEqual(0, header.grid_pos_x);
    try testing.expectEqual(0, header.grid_pos_y);
    try testing.expectEqual(16, header.grid_width);
    try testing.expectEqual(16, header.grid_height);

    std.debug.print("OK\n", .{});

    ////////////////////////////////////////////////////////////////////////////
    // FRAME
    ////////////////////////////////////////////////////////////////////////////
    std.debug.print("\tparse frame: ", .{});
    const frame = try RawFrame.parse(reader);

    try testing.expectEqual(497, frame.frame_size);
    try testing.expectEqual(61946, frame.magic_number);
    try testing.expectEqual(6, frame.old_num_chunks);
    try testing.expectEqual(100, frame.duration);
    try testing.expectEqual(6, frame.num_chunks);

    std.debug.print("OK\n", .{});

    ////////////////////////////////////////////////////////////////////////////
    // COLOR PROFILE
    ////////////////////////////////////////////////////////////////////////////
    // NOTE: These are the chunk size and type. Since this info is hard coded
    // into the test, we just ignore these.
    _ = try reader.readInt(types.DWORD, .little);
    _ = try reader.readInt(types.WORD, .little);

    std.debug.print("\tparse color profile: ", .{});
    const color_profile = try RawColorProfile.parse(std.testing.allocator, reader);

    try testing.expectEqual(.srgb, color_profile.kind);
    try testing.expectEqual(false, color_profile.flags.use_special_gamma);
    try testing.expectEqual(0, color_profile.flags._padding);
    try testing.expectEqual(0, color_profile.fixed_gamma);

    try testing.expectEqual(0, color_profile.icc_data_length);
    // NOTE: Its not within the scope of this library to parse the ICC spec.
    // https://www.color.org/ICC1V42.pdf
    try testing.expectEqual(null, color_profile.icc_data);

    std.debug.print("OK\n", .{});

    ////////////////////////////////////////////////////////////////////////////
    // OLD PALETTE
    ////////////////////////////////////////////////////////////////////////////
    // NOTE: These are the chunk size and type. Since this info is hard coded
    // into the test, we just ignore these.
    //_ = try reader.readInt(types.DWORD, .little);
    try reader.skipBytes(try reader.readInt(types.DWORD, .little) - 4, .{});
    //_ = try reader.readInt(types.WORD, .little);

    std.debug.print("\tparse old palette: ", .{});
    std.debug.print("OK\n", .{});

    ////////////////////////////////////////////////////////////////////////////
    // LAYER 1
    ////////////////////////////////////////////////////////////////////////////
    // NOTE: These are the chunk size and type. Since this info is hard coded
    // into the test, we just ignore these.
    _ = try reader.readInt(types.DWORD, .little);
    _ = try reader.readInt(types.WORD, .little);

    std.debug.print("\tparse layer 1: ", .{});
    const layer1 = try RawLayer.parse(std.testing.allocator, reader);
    // NOTE: This is expected to be done when using the raw api.
    defer std.testing.allocator.free(layer1.name);

    try testing.expectEqual(true, layer1.flags.visible);
    try testing.expectEqual(true, layer1.flags.editable);
    try testing.expectEqual(false, layer1.flags.lock_movement);
    try testing.expectEqual(false, layer1.flags.background);
    try testing.expectEqual(false, layer1.flags.prefer_linked_cels);
    try testing.expectEqual(false, layer1.flags.display_collapsed);
    try testing.expectEqual(false, layer1.flags.reference_layer);
    try testing.expectEqual(0, layer1.flags._padding);
    try testing.expectEqual(.normal, layer1.kind);
    try testing.expectEqual(0, layer1.child_level);
    try testing.expectEqual(0, layer1.default_width);
    try testing.expectEqual(0, layer1.default_height);
    try testing.expectEqual(.normal, layer1.blend_mode);
    try testing.expectEqual(255, layer1.opacity);
    try testing.expectEqualStrings("Layer 1", layer1.name);
    try testing.expectEqual(0, layer1.tileset_index);

    std.debug.print("OK\n", .{});

    ////////////////////////////////////////////////////////////////////////////
    // LAYER 2
    ////////////////////////////////////////////////////////////////////////////

    // NOTE: These are the chunk size and type. Since this info is hard coded
    // into the test, we just ignore these.
    _ = try reader.readInt(types.DWORD, .little);
    _ = try reader.readInt(types.WORD, .little);

    std.debug.print("\tparse layer 2: ", .{});
    const layer2 = try RawLayer.parse(std.testing.allocator, reader);
    // NOTE: This is expected to be done when using the raw api.
    defer std.testing.allocator.free(layer2.name);

    try testing.expectEqual(true, layer2.flags.visible);
    try testing.expectEqual(true, layer2.flags.editable);
    try testing.expectEqual(false, layer2.flags.lock_movement);
    try testing.expectEqual(false, layer2.flags.background);
    try testing.expectEqual(false, layer2.flags.prefer_linked_cels);
    try testing.expectEqual(false, layer2.flags.display_collapsed);
    try testing.expectEqual(false, layer2.flags.reference_layer);
    try testing.expectEqual(0, layer2.flags._padding);
    try testing.expectEqual(.normal, layer2.kind);
    try testing.expectEqual(0, layer2.child_level);
    try testing.expectEqual(0, layer2.default_width);
    try testing.expectEqual(0, layer2.default_height);
    try testing.expectEqual(.normal, layer2.blend_mode);
    try testing.expectEqual(255, layer2.opacity);
    try testing.expectEqualStrings("Layer 2", layer2.name);
    try testing.expectEqual(0, layer2.tileset_index);

    std.debug.print("OK\n", .{});

    ////////////////////////////////////////////////////////////////////////////
    // CEL 1
    ////////////////////////////////////////////////////////////////////////////
    const cel1_chunk_size = try reader.readInt(types.DWORD, .little);
    // NOTE: this is the chunk type. Since this is hard coded we will ignore it
    _ = try reader.readInt(types.WORD, .little);

    std.debug.print("\tparse cel 1: ", .{});
    const cel1 = try RawCel.parse(std.testing.allocator, reader, cel1_chunk_size);
    defer cel1.data.deinit(std.testing.allocator);

    try testing.expectEqual(0, cel1.layer_index);
    try testing.expectEqual(13, cel1.x_pos);
    try testing.expectEqual(18, cel1.y_pos);
    try testing.expectEqual(255, cel1.opacity_level);
    try testing.expectEqual(.compressed_image, cel1.kind);
    try testing.expectEqual(0, cel1.z_index);
    try testing.expectEqual(15, cel1.data.compressed_image.width);
    try testing.expectEqual(25, cel1.data.compressed_image.height);
    // NOTE: I will be ignoring data for now, but this should be impl. in the
    // future

    std.debug.print("OK\n", .{});

    ////////////////////////////////////////////////////////////////////////////
    // CEL 2
    ////////////////////////////////////////////////////////////////////////////
    const cel2_chunk_size = try reader.readInt(types.DWORD, .little);
    // NOTE: this is the chunk type. Since this is hard coded we will ignore it
    _ = try reader.readInt(types.WORD, .little);

    std.debug.print("\tparse cel 2: ", .{});
    const cel2 = try RawCel.parse(std.testing.allocator, reader, cel2_chunk_size);
    defer cel2.data.deinit(std.testing.allocator);

    try testing.expectEqual(1, cel2.layer_index);
    try testing.expectEqual(41, cel2.x_pos);
    try testing.expectEqual(18, cel2.y_pos);
    try testing.expectEqual(255, cel2.opacity_level);
    try testing.expectEqual(.compressed_image, cel2.kind);
    try testing.expectEqual(0, cel2.z_index);
    try testing.expectEqual(23, cel2.data.compressed_image.width);
    try testing.expectEqual(24, cel2.data.compressed_image.height);
    // NOTE: I will be ignoring data for now, but this should be impl. in the
    // future

    std.debug.print("OK\n", .{});
}
