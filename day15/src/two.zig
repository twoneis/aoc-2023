const std = @import("std");
const Allocator = std.mem.Allocator;
const log = std.debug.print;

pub const PartTwo = struct {
    const Self = @This();
    const T = usize;

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
        const Entry = struct { label: []const u8, value: T };
        var boxes: [256]std.ArrayList(Entry) = undefined;
        for (0..boxes.len) |i| {
            boxes[i] = std.ArrayList(Entry).init(self.allocator);
        }
        defer {
            for (boxes) |box| {
                box.deinit();
            }
        }

        var tokens = std.mem.tokenize(u8, lines[0], ",");
        while (tokens.next()) |string| {
            var value: T = 0;
            var i: usize = 0;
            for (string) |char| {
                if (!std.ascii.isAlphabetic(char)) break;
                value += char;
                value = (value * 17) % 256;
                i += 1;
            }

            switch (string[i]) {
                '=' => {
                    const entry = Entry{ .label = string[0..i], .value = string[i + 1] - '0' };
                    for (0..boxes[value].items.len + 1) |j| {
                        if (j == boxes[value].items.len) {
                            try boxes[value].append(entry);
                            break;
                        }
                        if (std.mem.eql(u8, boxes[value].items[j].label, string[0..i])) {
                            _ = boxes[value].orderedRemove(j);
                            try boxes[value].insert(j, entry);
                            break;
                        }
                    }
                },
                else => {
                    for (0..boxes[value].items.len) |j| {
                        if (std.mem.eql(u8, boxes[value].items[j].label, string[0..i])) {
                            _ = boxes[value].orderedRemove(j);
                            break;
                        }
                    }
                },
            }
        }

        var result: T = 0;

        for (boxes, 1..) |box, i| {
            for (box.items, 1..) |item, j| {
                result += i * j * item.value;
            }
        }

        return result;
    }
};
