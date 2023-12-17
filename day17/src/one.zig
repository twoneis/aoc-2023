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

    const Cord = struct { x: isize, y: isize, value: T = 0, dir: usize = 0, dir_num: T = 0 };
    fn eql(a: Cord, b: Cord) bool {
        return a.x == b.x and a.y == b.y;
    }
    fn add(a: Cord, b: Cord) Cord {
        return Cord{ .x = a.x + b.x, .y = a.y + b.y };
    }
    fn op(a: usize) usize {
        if (a == 0) return 1;
        if (a == 1) return 0;
        if (a == 2) return 3;
        if (a == 3) return 2;
        return 4;
    }
    fn lt(ctx: @TypeOf(.{}), a: Cord, b: Cord) bool {
        _ = ctx;
        return a.value < b.value;
    }
    const NORTH = Cord{ .x = 0, .y = -1 };
    const SOUTH = Cord{ .x = 0, .y = 1 };
    const WEST = Cord{ .x = -1, .y = 0 };
    const EAST = Cord{ .x = 1, .y = 0 };
    const ZERO = Cord{ .x = 0, .y = 0 };
    const directions = [_]Cord{ NORTH, SOUTH, EAST, WEST };

    pub fn solve(self: Self, lines: [][]const u8) !T {
        var next = std.ArrayList(Cord).init(self.allocator);
        defer next.deinit();
        var start = ZERO;
        start.value = 0;
        start.dir = 4;
        try next.append(start);
        const end = Cord{ .x = @as(isize, @intCast(lines[0].len - 1)), .y = @as(isize, @intCast(lines.len - 1)) };

        var map = try self.allocator.alloc([]T, lines.len);
        for (0..map.len) |i| {
            map[i] = try self.allocator.alloc(T, lines[i].len);
            for (0..map[i].len) |j| {
                map[i][j] = std.math.maxInt(T);
            }
        }
        map[0][0] = 0;
        defer {
            for (map) |line| {
                self.allocator.free(line);
            }
            self.allocator.free(map);
        }

        while (!eql(start, end)) {
            std.sort.insertion(Cord, next.items, .{}, lt);
            start = next.orderedRemove(0);
            for (directions, 0..) |dir, idx| {
                var pot = add(start, dir);
                if (idx == start.dir and start.dir_num == 3) {
                    continue;
                }
                if (pot.x < 0 or pot.x >= map[0].len or pot.y < 0 or pot.y >= map.len) {
                    continue;
                }
                if (idx == op(start.dir)) {
                    continue;
                }
                pot.value = start.value + lines[@as(usize, @intCast(pot.y))][@as(usize, @intCast(pot.x))] - '0';
                pot.dir = idx;
                if (map[@as(usize, @intCast(pot.y))][@as(usize, @intCast(pot.x))] < pot.value) {
                    continue;
                }
                if (pot.dir == start.dir) {
                    pot.dir_num = start.dir_num + 1;
                }
                map[@as(usize, @intCast(pot.y))][@as(usize, @intCast(pot.x))] = pot.value;
                var i: usize = 0;
                while (i < next.items.len) : (i += 1) {
                    if (eql(next.items[i], pot)) {
                        _ = next.orderedRemove(i);
                        i -= 1;
                    }
                }
                try next.append(pot);
            }
        }

        for (map) |line| {
            for (line) |num| {
                log(" {d} ", .{num});
            }
            log("\n", .{});
        }

        return start.value;
    }
};
