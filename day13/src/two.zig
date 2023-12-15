const std = @import("std");
const Allocator = std.mem.Allocator;
const log = std.debug.print;

pub const PartTwo = struct {
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
                if (blk: {
                    var second_chance = true;
                    for (pattern[i], pattern[i + 1]) |top_line, bottom_line| {
                        if (top_line != bottom_line) {
                            if (second_chance) {
                                second_chance = false;
                            } else {
                                break :blk false;
                            }
                        }
                    }
                    break :blk true;
                }) {
                    try potential_mirror_rows.append(i);
                }
            }

            var mirror_rows = std.ArrayList(usize).init(self.allocator);
            defer mirror_rows.deinit();

            outer: for (potential_mirror_rows.items) |start| {
                var i = @as(i64, @intCast(start));
                var j = @as(i64, @intCast(start + 1));
                var second_chance = true;
                while (i >= 0 and j < pattern.len) : ({
                    i -= 1;
                    j += 1;
                }) {
                    if (blk: {
                        for (pattern[@as(usize, @intCast(i))], pattern[@as(usize, @intCast(j))]) |top_line, bottom_line| {
                            if (top_line != bottom_line) {
                                if (second_chance) {
                                    second_chance = false;
                                } else {
                                    break :blk true;
                                }
                            }
                        }
                        break :blk false;
                    }) {
                        continue :outer;
                    }
                }
                if (!second_chance or (i != -1 and j != pattern.len)) {
                    try mirror_rows.append(start);
                }
            }

            var potential_mirror_cols = std.ArrayList(usize).init(self.allocator);
            defer potential_mirror_cols.deinit();

            for (0..pattern[0].len - 1) |i| {
                if (blk: {
                    var second_chance = true;
                    for (pattern) |line| {
                        if (line[i] != line[i + 1]) {
                            if (second_chance) {
                                second_chance = false;
                            } else {
                                break :blk false;
                            }
                        }
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
                var second_chance = true;
                while (i >= 0 and j < pattern[0].len) : ({
                    i -= 1;
                    j += 1;
                }) {
                    if (blk: {
                        for (pattern) |line| {
                            if (line[@as(usize, @intCast(i))] != line[@as(usize, @intCast(j))]) {
                                if (second_chance) {
                                    second_chance = false;
                                } else {
                                    break :blk true;
                                }
                            }
                        }
                        break :blk false;
                    }) {
                        continue :outer;
                    }
                }
                if (!second_chance or (i != -1 and j != pattern[0].len)) {
                    try mirror_cols.append(start);
                }
            }

            log("Mirror rows: {any}\n", .{mirror_rows.items});
            log("Mirror cols: {any}\n", .{mirror_cols.items});
            log("\n", .{});

            if (mirror_rows.items.len != 0) {
                sum += 100 * (mirror_rows.items[0] + 1);
                continue;
            }
            sum += mirror_cols.items[0] + 1;
        }

        return sum;
    }
};
