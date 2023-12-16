const std = @import("std");
const Allocator = std.mem.Allocator;
const log = std.debug.print;

pub const PartOne = struct {
    const Self = @This();
    const T = u32;

    fn parseInt(buf: []const u8) !T {
        return try std.fmt.parseInt(T, buf, 10);
    }

    fn castInt(x: anytype) T {
        return @as(T, @intCast(x));
    }

    allocator: Allocator,

    pub fn init(alloctor: Allocator) Self {
        return Self{ .allocator = alloctor };
    }

    pub fn solve(self: Self, lines: [][]const u8) !T {
        _ = self;
        var sum: T = 0;
        var tokens = std.mem.tokenize(u8, lines[0], ",");
        while (tokens.next()) |string| {
            var cur: T = 0;
            for (string) |char| {
                cur += char;
                cur = (cur * 17) % 256;
            }
            sum += cur;
        }
        return sum;
    }
};
