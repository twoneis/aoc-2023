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
        var grid = try self.allocator.alloc([]u8, lines.len);
        for (0..lines.len) |i| {
            grid[i] = try self.allocator.alloc(u8, lines[i].len);
            @memcpy(grid[i], lines[i]);
        }
        defer {
            for (grid) |row| {
                self.allocator.free(row);
            }
            self.allocator.free(grid);
        }

        for (grid, 0..) |row, i| {
            for (row, 0..) |cell, j| {
                if (cell == 'O') {
                    var i_height = @as(i64, @intCast(i));
                    while (i_height > 0) : (i_height -= 1) {
                        const height = @as(usize, @intCast(i_height));
                        if (grid[height - 1][j] == '#' or grid[height - 1][j] == 'O') {
                            break;
                        }
                        grid[height][j] = '.';
                        grid[height - 1][j] = 'O';
                    }
                }
            }
        }

        var sum: T = 0;

        for (grid, 0..) |row, i| {
            var stones: T = 0;
            for (row) |cell| {
                if (cell == 'O') {
                    stones += 1;
                }
            }
            sum += castInt(grid.len - i) * stones;
        }

        return sum;
    }
};
