const std = @import("std");
const Allocator = std.mem.Allocator;
const log = std.debug.print;

pub const PartOne = struct {
    const Self = @This();
    const T = u64;

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
        var patterns_buf = std.ArrayList([][]const u8).init(self.allocator);
        var pattern_buf = std.ArrayList([]const u8).init(self.allocator);
        for (lines) |line| {
            if (line.len == 0) {
                const pattern = try pattern_buf.toOwnedSlice();
                try patterns_buf.append(pattern);
                continue;
            }

            try pattern_buf.append(line);
        }

        var sum: T = 0;

        const patterns = try patterns_buf.toOwnedSlice();
        defer {
            for (patterns) |pattern| {
                self.allocator.free(pattern);
            }
            self.allocator.free(patterns);
        }

        for (patterns) |pattern| {
            var potential_mirror_rows = std.ArrayList(usize).init(self.allocator);
            defer potential_mirror_rows.deinit();

            for (0..pattern.len - 1) |i| {
                if (std.mem.eql(u8, pattern[i], pattern[i + 1])) {
                    try potential_mirror_rows.append(i);
                }
            }

            var mirror_rows = std.ArrayList(usize).init(self.allocator);
            defer mirror_rows.deinit();

            outer: for (potential_mirror_rows.items) |start| {
                var i = @as(i64, @intCast(start));
                var j = @as(i64, @intCast(start + 1));
                while (i >= 0 and j < pattern.len) : ({
                    i -= 1;
                    j += 1;
                }) {
                    if (!std.mem.eql(u8, pattern[@as(usize, @intCast(i))], pattern[@as(usize, @intCast(j))])) {
                        continue :outer;
                    }
                }
                try mirror_rows.append(start);
            }

            var potential_mirror_cols = std.ArrayList(usize).init(self.allocator);
            defer potential_mirror_cols.deinit();

            for (0..pattern[0].len - 1) |i| {
                if (blk: {
                    for (pattern) |line| {
                        if (line[i] != line[i + 1]) break :blk false;
                    }
                    break :blk true;
                }) {
                    try potential_mirror_cols.append(i);
                }
            }

            var mirror_cols = std.ArrayList(usize).init(self.allocator);
            defer mirror_cols.deinit();

            outer: for (potential_mirror_cols.items) |start| {
                var i = @as(i64, @intCast(start));
                var j = @as(i64, @intCast(start + 1));
                while (i >= 0 and j < pattern[0].len) : ({
                    i -= 1;
                    j += 1;
                }) {
                    if (blk: {
                        for (pattern) |line| {
                            if (line[@as(usize, @intCast(i))] != line[@as(usize, @intCast(j))]) break :blk true;
                        }
                        break :blk false;
                    }) {
                        continue :outer;
                    }
                }
                try mirror_cols.append(start);
            }

            if (mirror_rows.items.len != 0) {
                sum += 100 * (mirror_rows.items[0] + 1);
                continue;
            }
            sum += mirror_cols.items[0] + 1;
        }

        return sum;
    }
};
