//! wlr-which-key: the colors, font and frame of its menu, set in the user's config.yaml.

const std = @import("std");

/// wlr-which-key's colors, font and frame; build one with `from`.
pub const App = @import("App.zig");
/// Colors from the theme.
pub const from = App.from;

test {
    std.testing.refAllDecls(@This());
    std.testing.refAllDecls(App);
}
