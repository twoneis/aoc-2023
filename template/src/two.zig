const std = @import("std");
const Allocator = std.mem.Allocator;
const log = std.debug.print;

pub const PartTwo = struct {
    const Self = @This();
    const T = u32;

    fn parseInt(buf: []const u8) !T {
        try std.fmt.parseInt(T, buf, 10);
    }

    allocator: Allocator,

    pub fn init(alloctor: Allocator) Self {
        return Self{ .allocator = alloctor };
    }

    pub fn solve(self: Self, lines: [][]const u8) !T {
        _ = self;
        _ = lines;
        return 0;
    }
};
