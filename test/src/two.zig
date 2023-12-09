const std = @import("std");
const Allocator = std.mem.Allocator;
const log = std.debug.print;

pub const PartTwo = struct {
    const Self = @This();
    const T = u64;

    allocator: Allocator,

    pub fn init(alloctor: Allocator) Self {
        return Self{ .allocator = alloctor };
    }

    pub fn solve(self: Self, lines: [][]const u8) !T {
        const instructions = lines[0];
        var map = std.StringHashMap([2][]const u8).init(self.allocator);
        defer map.deinit();
        for (1..lines.len) |i| {
            var line_split = std.mem.tokenizeAny(u8, lines[i], " =(,)");
            const from = line_split.next().?;
            const l = line_split.next().?;
            const r = line_split.next().?;
            try map.put(from, [2][]const u8{ l, r });
        }

        var locations_buf = std.ArrayList(std.hash_map.StringHashMap([2][]const u8).Entry).init(self.allocator);
        defer locations_buf.deinit();

        var map_iter = map.iterator();
        while (map_iter.next()) |entry| {
            if (entry.key_ptr.*[2] == 'A') {
                try locations_buf.append(entry);
            }
        }

        var locations = try locations_buf.toOwnedSlice();
        defer self.allocator.free(locations);

        var distances = try self.allocator.alloc(T, locations.len);
        defer self.allocator.free(distances);

        for (0..locations.len) |i| {
            var ip: u32 = 0;
            var steps: T = 0;
            while (locations[i].key_ptr.*[2] != 'Z') {
                locations[i] = switch (instructions[ip]) {
                    'L' => map.getEntry(locations[i].value_ptr[0]).?,
                    'R' => map.getEntry(locations[i].value_ptr[1]).?,
                    else => return error.InvalidCharacter,
                };
                steps += 1;
                ip += 1;
                if (ip >= instructions.len) {
                    ip = 0;
                }
            }
            distances[i] = steps;
        }

        var steps: T = 1;

        for (distances) |distance| {
            steps = least_common_multiple(steps, distance);
        }

        return steps;
    }

    fn least_common_multiple(a: T, b: T) T {
        return (a / greatest_common_divisor(a, b)) * b;
    }

    fn greatest_common_divisor(a: T, b: T) T {
        if (b == 0) {
            return a;
        }
        return greatest_common_divisor(b, a % b);
    }
};
