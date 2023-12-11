const std = @import("std");
const Allocator = std.mem.Allocator;
const log = std.debug.print;

pub const PartTwo = struct {
    const Self = @This();
    const T = u128;

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
        const Cord = struct {
            x: usize,
            y: usize,
        };

        var empty_rows = std.AutoHashMap(usize, void).init(self.allocator);
        defer empty_rows.deinit();
        var empty_columns = std.AutoHashMap(usize, void).init(self.allocator);
        defer empty_columns.deinit();

        var galaxies_buf = std.ArrayList(Cord).init(self.allocator);

        for (lines, 0..) |row, i| {
            var empty = true;
            for (row, 0..) |char, j| {
                if (char == '#') {
                    empty = false;
                    try galaxies_buf.append(Cord{ .x = j, .y = i });
                }
            }
            if (empty) {
                try empty_rows.put(i, {});
            }
        }

        for (0..lines[0].len) |i| {
            var empty = true;
            for (lines) |row| {
                if (row[i] == '#') {
                    empty = false;
                    break;
                }
            }
            if (empty) {
                try empty_columns.put(i, {});
            }
        }

        var sum: T = 0;

        const galaxies = try galaxies_buf.toOwnedSlice();
        defer self.allocator.free(galaxies);

        for (0..galaxies.len) |i| {
            for (i + 1..galaxies.len) |j| {
                var from = galaxies[j].x;
                var to = galaxies[i].x;
                if (from > to) {
                    from = galaxies[i].x;
                    to = galaxies[j].x;
                }
                for (from..to) |col| {
                    sum += 1;
                    if (empty_columns.contains(col)) {
                        sum += 1000000 - 1;
                    }
                }
                from = galaxies[j].y;
                to = galaxies[i].y;
                if (from > to) {
                    from = galaxies[i].y;
                    to = galaxies[j].y;
                }
                for (from..to) |row| {
                    sum += 1;
                    if (empty_rows.contains(row)) {
                        sum += 1000000 - 1;
                    }
                }
            }
        }

        return sum;
    }
};
