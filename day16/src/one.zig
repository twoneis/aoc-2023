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
        var energized = try self.allocator.alloc([]std.ArrayList(Cord), lines.len);

        for (0..energized.len) |i| {
            energized[i] = try self.allocator.alloc(std.ArrayList(Cord), lines[i].len);
            for (0..energized[i].len) |j| {
                energized[i][j] = std.ArrayList(Cord).init(self.allocator);
            }
        }
        defer {
            for (energized) |row| {
                for (row) |cell| {
                    cell.deinit();
                }
                self.allocator.free(row);
            }
            self.allocator.free(energized);
        }

        try self.shot_ray(&energized, lines, Cord{ .x = 0, .y = 0 }, EAST);

        var sum: T = 0;
        for (energized) |row| {
            for (row) |cell| {
                if (cell.items.len != 0) {
                    sum += 1;
                }
            }
        }

        return sum;
    }

    const Cord = struct {
        x: i64,
        y: i64,
    };

    const NORTH = Cord{ .x = 0, .y = -1 };
    const SOUTH = Cord{ .x = 0, .y = 1 };
    const WEST = Cord{ .x = -1, .y = 0 };
    const EAST = Cord{ .x = 1, .y = 0 };
    const ZERO = Cord{ .x = 0, .y = 0 };

    fn add(a: Cord, b: Cord) Cord {
        return Cord{ .x = a.x + b.x, .y = a.y + b.y };
    }

    fn eql(a: Cord, b: Cord) bool {
        return a.x == b.x and a.y == b.y;
    }

    fn shot_ray(self: Self, energized: *[][]std.ArrayList(Cord), map: [][]const u8, start: Cord, direction: Cord) !void {
        try energized.*[castInt(start.y)][castInt(start.x)].append(direction);
        var next_directions = std.ArrayList(Cord).init(self.allocator);
        defer next_directions.deinit();

        switch (map[castInt(start.y)][castInt(start.x)]) {
            '/' => {
                if (eql(direction, EAST)) {
                    try next_directions.append(NORTH);
                } else if (eql(direction, SOUTH)) {
                    try next_directions.append(WEST);
                } else if (eql(direction, NORTH)) {
                    try next_directions.append(EAST);
                } else if (eql(direction, WEST)) {
                    try next_directions.append(SOUTH);
                }
            },
            '\\' => {
                if (eql(direction, EAST)) {
                    try next_directions.append(SOUTH);
                } else if (eql(direction, SOUTH)) {
                    try next_directions.append(EAST);
                } else if (eql(direction, NORTH)) {
                    try next_directions.append(WEST);
                } else if (eql(direction, WEST)) {
                    try next_directions.append(NORTH);
                }
            },
            '|' => {
                if (eql(direction, WEST) or eql(direction, EAST)) {
                    try next_directions.append(NORTH);
                    try next_directions.append(SOUTH);
                } else {
                    try next_directions.append(direction);
                }
            },
            '-' => {
                if (eql(direction, NORTH) or eql(direction, SOUTH)) {
                    try next_directions.append(EAST);
                    try next_directions.append(WEST);
                } else {
                    try next_directions.append(direction);
                }
            },
            else => {
                try next_directions.append(direction);
            },
        }

        for (next_directions.items) |item| {
            const next = add(start, item);
            if (next.x < 0 or next.x >= map[0].len or next.y < 0 or next.y >= map.len) {
                continue;
            }
            var is_in = false;
            for (energized.*[castInt(next.y)][castInt(next.x)].items) |in| {
                if (eql(in, item)) {
                    is_in = true;
                    break;
                }
            }
            if (!is_in) {
                try self.shot_ray(energized, map, next, item);
            }
        }
    }
};
