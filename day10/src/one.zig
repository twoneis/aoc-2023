const std = @import("std");
const Allocator = std.mem.Allocator;
const log = std.debug.print;

pub const PartOne = struct {
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
        var maze = try PipeMap.init(self.allocator, lines[0].len, lines.len);
        defer maze.deinit();

        var starting_position: Cord = undefined;

        for (lines, 0..) |line, i| {
            for (line, 0..) |char, j| {
                if (char == 'S') {
                    starting_position = Cord{ .x = @as(i64, @intCast(j)), .y = @as(i64, @intCast(i)) };
                }
                maze.nodes[i][j] = switch (char) {
                    '|' => Node{ .north = true, .south = true, .east = false, .west = false },
                    '-' => Node{ .north = false, .south = false, .east = true, .west = true },
                    'L' => Node{ .north = true, .south = false, .east = true, .west = false },
                    'J' => Node{ .north = true, .south = false, .east = false, .west = true },
                    '7' => Node{ .north = false, .south = true, .east = false, .west = true },
                    'F' => Node{ .north = false, .south = true, .east = true, .west = false },
                    'S' => Node{ .north = true, .south = true, .east = true, .west = true },
                    else => Node{ .north = false, .south = false, .east = false, .west = false },
                };
            }
        }

        const path = try maze.find_loop(starting_position);
        defer self.allocator.free(path);

        return @as(T, @intCast(try std.math.divFloor(usize, path.len, 2)));
    }
};

const Cord = struct {
    x: i64,
    y: i64,

    pub fn sub(a: Cord, b: Cord) Cord {
        return .{ .x = a.x - b.x, .y = a.y - b.y };
    }

    pub fn eql(a: Cord, b: Cord) bool {
        return a.x == b.x and a.y == b.y;
    }
};

const PipeMap = struct {
    const Self = @This();

    allocator: Allocator,
    nodes: [][]Node,

    pub fn init(allocator: Allocator, width: usize, height: usize) !Self {
        const rows = try allocator.alloc([]Node, height);
        for (0..rows.len) |i| {
            rows[i] = try allocator.alloc(Node, width);
        }
        return .{ .allocator = allocator, .nodes = rows };
    }

    pub fn find_loop(self: *Self, from: Cord) ![]Cord {
        var path = try self.allocator.create(std.ArrayList(Cord));
        defer self.allocator.destroy(path);
        path.* = std.ArrayList(Cord).init(self.allocator);
        if (!try self.find_loop_rec(from, from, Cord{ .x = -1, .y = -1 }, path)) {
            return error.NoPathFound;
        }

        return path.toOwnedSlice();
    }

    fn find_loop_rec(self: *Self, from: Cord, to: Cord, recent: Cord, path: *std.ArrayList(Cord)) !bool {
        if (Cord.eql(from, to) and path.items.len != 0) {
            return true;
        }

        try path.append(from);

        const north = Cord.sub(from, Cord{ .x = 0, .y = -1 });
        const south = Cord.sub(from, Cord{ .x = 0, .y = 1 });
        const east = Cord.sub(from, Cord{ .x = 1, .y = 0 });
        const west = Cord.sub(from, Cord{ .x = -1, .y = 0 });

        if (!Cord.eql(recent, north) and self.connected(from, north) and try self.find_loop_rec(north, to, from, path)) {
            return true;
        }
        if (!Cord.eql(recent, south) and self.connected(from, south) and try self.find_loop_rec(south, to, from, path)) {
            return true;
        }
        if (!Cord.eql(recent, east) and self.connected(from, east) and try self.find_loop_rec(east, to, from, path)) {
            return true;
        }
        if (!Cord.eql(recent, west) and self.connected(from, west) and try self.find_loop_rec(west, to, from, path)) {
            return true;
        }

        _ = path.pop();
        return false;
    }

    fn connected(self: *Self, a: Cord, b: Cord) bool {
        if (a.x < 0 or a.x >= self.nodes[0].len or a.y < 0 or a.y >= self.nodes.len or b.x < 0 or b.x >= self.nodes[0].len or b.y < 0 or b.y >= self.nodes.len) {
            return false;
        }

        const ax = @as(usize, @intCast(a.x));
        const ay = @as(usize, @intCast(a.y));
        const bx = @as(usize, @intCast(b.x));
        const by = @as(usize, @intCast(b.y));

        const dif: Cord = Cord.sub(a, b);

        if (Cord.eql(dif, Cord{ .x = 0, .y = 1 })) {
            return self.nodes[ay][ax].north and self.nodes[by][bx].south;
        }
        if (Cord.eql(dif, Cord{ .x = 0, .y = -1 })) {
            return self.nodes[ay][ax].south and self.nodes[by][bx].north;
        }
        if (Cord.eql(dif, Cord{ .x = -1, .y = 0 })) {
            return self.nodes[ay][ax].east and self.nodes[by][bx].west;
        }
        if (Cord.eql(dif, Cord{ .x = 1, .y = 0 })) {
            return self.nodes[ay][ax].west and self.nodes[by][bx].east;
        }
        return false;
    }

    pub fn deinit(self: *Self) void {
        for (self.nodes) |row| {
            self.allocator.free(row);
        }
        self.allocator.free(self.nodes);
    }
};

const Node = struct { north: bool, east: bool, south: bool, west: bool };
