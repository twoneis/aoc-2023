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
        const Cord = struct {
            x: usize,
            y: usize,
        };

        var buf = std.ArrayList(std.ArrayList(u8)).init(self.allocator);
        for (buf.items, 0..) |_, i| {
            buf.items[i] = std.ArrayList(u8).init(self.allocator);
        }

        for (0..lines.len) |i| {
            var line_cpy = try self.allocator.alloc(u8, lines[i].len);
            @memcpy(line_cpy, lines[i]);
            try buf.append(std.ArrayList(u8).fromOwnedSlice(self.allocator, line_cpy));
            for (0..lines[i].len + 1) |j| {
                if (j == lines[i].len) {
                    var extra_line = try self.allocator.alloc(u8, lines[i].len);
                    @memcpy(extra_line, lines[i]);
                    try buf.append(std.ArrayList(u8).fromOwnedSlice(self.allocator, extra_line));
                    break;
                }
                if (lines[i][j] == '#') {
                    break;
                }
            }
        }

        var owned_buf = try buf.toOwnedSlice();

        const original_len = lines[0].len;
        for (0..original_len) |i| {
            const idx = original_len - i - 1;
            for (0..owned_buf.len + 1) |j| {
                if (j == owned_buf.len) {
                    for (0..owned_buf.len) |k| {
                        try owned_buf[k].insert(idx, '.');
                    }
                    break;
                }
                if (owned_buf[j].items[idx] == '#') {
                    break;
                }
            }
        }

        var expanded = try self.allocator.alloc([]u8, owned_buf.len);
        for (0..owned_buf.len) |i| {
            expanded[i] = try owned_buf[i].toOwnedSlice();
        }
        self.allocator.free(owned_buf);
        defer {
            for (expanded) |item| {
                self.allocator.free(item);
            }
            self.allocator.free(expanded);
        }

        var galaxies_buf = std.ArrayList(Cord).init(self.allocator);

        // TODO: Replace lines wit expanded;
        for (0..expanded.len) |i| {
            for (0..expanded[i].len) |j| {
                if (expanded[i][j] == '#') {
                    try galaxies_buf.append(Cord{ .x = j, .y = i });
                }
            }
        }

        const galaxies = try galaxies_buf.toOwnedSlice();
        defer self.allocator.free(galaxies);

        var sum: T = 0;

        for (0..galaxies.len) |i| {
            for (i + 1..galaxies.len) |j| {
                const x_dist = try std.math.absInt(@as(i64, @intCast(galaxies[i].x)) - @as(i64, @intCast(galaxies[j].x)));
                const y_dist = try std.math.absInt(@as(i64, @intCast(galaxies[i].y)) - @as(i64, @intCast(galaxies[j].y)));
                sum += castInt(x_dist + y_dist);
            }
        }

        return sum;
    }
};
