const std = @import("std");
const Allocator = std.mem.Allocator;
const log = std.debug.print;

pub const PartOne = struct {
    const Self = @This();
    const T = u32;

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

        var steps: T = 0;

        var ip: u32 = 0;
        var location = map.getEntry("AAA").?;
        while (!std.mem.eql(u8, location.key_ptr.*, "ZZZ")) {
            location = switch (instructions[ip]) {
                'L' => map.getEntry(location.value_ptr[0]).?,
                'R' => map.getEntry(location.value_ptr[1]).?,
                else => return error.InvalidCharacter,
            };
            steps += 1;
            ip += 1;
            if (ip >= instructions.len) {
                ip = 0;
            }
        }

        return steps;
    }
};
