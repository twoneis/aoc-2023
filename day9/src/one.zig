const std = @import("std");
const Allocator = std.mem.Allocator;
const log = std.debug.print;

pub const PartOne = struct {
    const Self = @This();
    const T = i128;

    allocator: Allocator,

    pub fn init(alloctor: Allocator) Self {
        return Self{ .allocator = alloctor };
    }

    pub fn solve(self: Self, lines: [][]const u8) !T {
        var row_buf = std.ArrayList([]T).init(self.allocator);
        for (lines) |line| {
            var buf = std.ArrayList(T).init(self.allocator);
            var tokens = std.mem.tokenize(u8, line, " ");
            while (tokens.next()) |token| {
                const num = try std.fmt.parseInt(T, token, 10);
                try buf.append(num);
            }
            try row_buf.append(try buf.toOwnedSlice());
        }

        const rows = try row_buf.toOwnedSlice();
        defer self.allocator.free(rows);

        var sum: T = 0;

        for (rows) |row| {
            var table_buf = std.ArrayList([]T).init(self.allocator);
            var all_zero = false;
            try table_buf.append(row);
            var i: usize = 0;
            while (!all_zero) {
                var previous = table_buf.items[i];
                var buf = try self.allocator.alloc(T, previous.len - 1);
                all_zero = true;
                for (0..previous.len - 1) |j| {
                    // log("{d}: {d} - {d}\n", .{ j, previous[j + 1], previous[j] });
                    buf[j] = previous[j + 1] - previous[j];
                    if (buf[j] != 0) {
                        all_zero = false;
                    }
                }
                try table_buf.append(buf);
                i += 1;
            }

            const table = try table_buf.toOwnedSlice();
            defer {
                for (table) |t_row| {
                    self.allocator.free(t_row);
                }
                self.allocator.free(table);
            }

            var val: T = 0;
            for (0..table.len) |j| {
                const idx = table.len - j - 1;
                val += table[idx][table[idx].len - 1];
            }
            sum += val;
        }

        return sum;
    }
};
