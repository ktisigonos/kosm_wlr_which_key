//! wlr-which-key's style, set by name in the user's config.yaml; the menu and every other
//! setting stay as they are. Field names are wlr-which-key's.

const App = @This();

const std = @import("std");
const kosm = @import("kosm");

/// wlr-which-key's config; each set option's key must be in it already.
/// Default: `~/.config/wlr-which-key/config.yaml`.
file: []const u8 = "~/.config/wlr-which-key/config.yaml",
/// How values are spelled. Null fields take these: `#rrggbbaa`, which wlr-which-key reads
/// with alpha.
format: kosm.Format = .{ .color = .hex8 },
/// The font as a Pango description: families, then the size in points
/// (`"JetBrains Mono, Noto Sans 12"`). null: left as it is.
font: ?[]const u8 = null,
/// The menu's background. null: left as it is.
background: ?kosm.Color = null,
/// The text. null: left as it is.
color: ?kosm.Color = null,
/// The frame around the menu. null: left as it is.
border: ?kosm.Color = null,
/// The frame's width in pixels. null: left as it is.
border_width: ?u32 = null,
/// The corners' radius in pixels. null: left as it is.
corner_r: ?u32 = null,

/// Colors from the theme: the background role at the theme's `background_alpha`, the text the
/// foreground role and the frame the accent. The font and frame sizes are left alone.
pub fn from(theme: kosm.Theme) App {
    return .{
        .background = theme.asBackground(theme.roles.background),
        .color = theme.roles.foreground,
        .border = theme.roles.accent,
    };
}

/// Sets every set option in `file`. With none set, the file is not read.
pub fn apply(self: App, output: *kosm.Output) !void {
    var config: ?kosm.Output.Selection = null;
    inline for (@typeInfo(App).@"struct".field_names) |name| {
        if (comptime !std.mem.eql(u8, name, "file") and !std.mem.eql(u8, name, "format")) {
            if (@field(self, name)) |option| {
                if (config == null) config = try output.edit(.{ .files = self.file, .lang = "yaml", .format = self.format });
                try config.?.set(name, option);
            }
        }
    }
}

const testing = std.testing;
const yaml_adapter = @import("root.zig").yaml_adapter;

const shipped =
    \\font: JetBrainsMono Nerd Font 12
    \\background: "#282828d0"
    \\color: "#fbf1c7"
    \\border: "#8ec07c"
    \\separator: " -> "
    \\border_width: 2
    \\corner_r: 10
    \\anchor: center
    \\
    \\menu:
    \\  - key: "p"
    \\    desc: Power
    \\    submenu:
    \\      - key: "s"
    \\        desc: Sleep
    \\        cmd: systemctl suspend
    \\
;

test "only the set options' values change, and a missing key fails naming the file" {
    var tmp = testing.tmpDir(.{});
    defer tmp.cleanup();
    try tmp.dir.createDirPath(testing.io, ".config/wlr-which-key");
    try tmp.dir.writeFile(testing.io, .{ .sub_path = ".config/wlr-which-key/config.yaml", .data = shipped });
    var home_buffer: [std.Io.Dir.max_path_bytes]u8 = undefined;
    var arena: std.heap.ArenaAllocator = .init(testing.allocator);
    defer arena.deinit();
    var plan: kosm.Plan = .init(testing.allocator, testing.io);
    defer plan.deinit();
    var diagnostics: kosm.Diagnostics = .{};
    var warnings: kosm.Warnings = .init(arena.allocator());
    var output: kosm.Output = .{
        .allocator = arena.allocator(),
        .home = home_buffer[0..try tmp.dir.realPath(testing.io, &home_buffer)],
        .adapters = &.{yaml_adapter},
        .plan = &plan,
        .diagnostics = &diagnostics,
        .warnings = &warnings,
        .app = "wlr_which_key",
    };
    var theme = kosm.Theme.from(.{ .palette = .{ .black = kosm.hex("000000"), .white = kosm.hex("ffffff"), .cyan = kosm.hex("00ffff") }, .mode = .dark });
    theme.background_alpha = 0.5;
    var app = from(theme);
    app.font = "Iosevka, Noto Sans 14";
    app.corner_r = 12;
    try app.apply(&output);
    try testing.expectEqualStrings(
        \\font: "Iosevka, Noto Sans 14"
        \\background: "#00000080"
        \\color: "#ffffffff"
        \\border: "#00ffffff"
        \\separator: " -> "
        \\border_width: 2
        \\corner_r: 12
        \\anchor: center
        \\
        \\menu:
        \\  - key: "p"
        \\    desc: Power
        \\    submenu:
        \\      - key: "s"
        \\        desc: Sleep
        \\        cmd: systemctl suspend
        \\
    , plan.files.items[0].new);

    try tmp.dir.writeFile(testing.io, .{ .sub_path = ".config/wlr-which-key/other.yaml", .data = "anchor: center\n" });
    const missing: App = .{ .file = "~/.config/wlr-which-key/other.yaml", .border_width = 1 };
    try testing.expectError(error.NoMatch, missing.apply(&output));
    try testing.expectEqualStrings("~/.config/wlr-which-key/other.yaml", diagnostics.file);
}
