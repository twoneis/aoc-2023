const std = @import("std");
const Allocator = std.mem.Allocator;
const log = std.debug.print;

pub const PartTwo = struct {
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

        var last_list = std.ArrayList([][]u8).init(self.allocator);
        defer {
            for (last_list.items) |last_grid| {
                for (last_grid) |row| {
                    self.allocator.free(row);
                }
                self.allocator.free(last_grid);
            }
            last_list.deinit();
        }

        const iterations = 1000000000;

        var found_pattern = false;
        var x: i128 = iterations;
        while (x > 0) : (x -= 1) {
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

            for (grid, 0..) |row, i| {
                for (row, 0..) |cell, j| {
                    if (cell == 'O') {
                        var i_height = @as(i64, @intCast(j));
                        while (i_height > 0) : (i_height -= 1) {
                            const height = @as(usize, @intCast(i_height));
                            if (grid[i][height - 1] == '#' or grid[i][height - 1] == 'O') {
                                break;
                            }
                            grid[i][height] = '.';
                            grid[i][height - 1] = 'O';
                        }
                    }
                }
            }

            for (0..grid.len) |i| {
                const row = grid[grid.len - i - 1];
                for (row, 0..) |cell, j| {
                    if (cell == 'O') {
                        var i_height = @as(i64, @intCast(grid.len - i - 1));
                        while (i_height < grid.len - 1) : (i_height += 1) {
                            const height = @as(usize, @intCast(i_height));
                            if (grid[height + 1][j] == '#' or grid[height + 1][j] == 'O') {
                                break;
                            }
                            grid[height][j] = '.';
                            grid[height + 1][j] = 'O';
                        }
                    }
                }
            }

            for (grid, 0..) |row, i| {
                for (0..row.len) |j| {
                    const cell = row[row.len - j - 1];
                    if (cell == 'O') {
                        var i_height = @as(i64, @intCast(row.len - j - 1));
                        while (i_height < row.len - 1) : (i_height += 1) {
                            const height = @as(usize, @intCast(i_height));
                            if (grid[i][height + 1] == '#' or grid[i][height + 1] == 'O') {
                                break;
                            }
                            grid[i][height] = '.';
                            grid[i][height + 1] = 'O';
                        }
                    }
                }
            }

            if (found_pattern) {
                continue;
            }

            for (last_list.items, 0..) |last, i| {
                var eql = true;
                for (last, grid) |last_row, row| {
                    if (!std.mem.eql(u8, last_row, row)) {
                        eql = false;
                    }
                }
                if (eql) {
                    x = @mod(x, (last_list.items.len - i));
                    found_pattern = true;
                    break;
                }
            }

            var last = try self.allocator.alloc([]u8, lines.len);
            for (0..grid.len) |i| {
                last[i] = try self.allocator.alloc(u8, lines[i].len);
                @memcpy(last[i], grid[i]);
            }
            try last_list.append(last);
        }

        var sum: T = 0;

        log("\n", .{});
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
