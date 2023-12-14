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
        const Entry = struct {
            records: []const u8,
            sizes: []const T,
        };
        var entries_buf = std.ArrayList(Entry).init(self.allocator);
        for (lines) |line| {
            var tokens = std.mem.tokenize(u8, line, " ,");
            const records = tokens.next().?;
            var numbers = std.ArrayList(T).init(self.allocator);
            while (tokens.next()) |num| {
                try numbers.append(try parseInt(num));
            }
            try entries_buf.append(Entry{ .records = records, .sizes = try numbers.toOwnedSlice() });
        }

        const entries = try entries_buf.toOwnedSlice();
        defer {
            for (entries) |entry| {
                self.allocator.free(entry.sizes);
            }
            self.allocator.free(entries);
        }

        var sum: T = 0;

        for (entries) |entry| {
            sum += try self.rec_solver(entry.records, 0, entry.sizes);
        }

        return sum;
    }

    fn rec_solver(self: Self, line: []const u8, idx: T, groups: []const T) !T {
        if (idx == line.len) {
            if (check_correct(line, groups)) {
                return 1;
            }
            return 0;
        }

        var sum: T = 0;
        sum += try self.rec_solver(line, idx + 1, groups);

        if (line[idx] == '?') {
            var line_cpy = try self.allocator.alloc(u8, line.len);
            defer self.allocator.free(line_cpy);
            @memcpy(line_cpy, line);
            line_cpy[idx] = '#';
            sum += try self.rec_solver(line_cpy, idx + 1, groups);
        }

        return sum;
    }

    fn check_correct(line: []const u8, groups: []const T) bool {
        var cur_group_len: T = 0;
        var group_idx: usize = 0;
        for (line) |char| {
            if (char == '#') {
                cur_group_len += 1;
                continue;
            }
            if (cur_group_len != 0) {
                if (group_idx >= groups.len) return false;
                if (cur_group_len != groups[group_idx]) {
                    return false;
                }
                group_idx += 1;
                cur_group_len = 0;
            }
        }

        if (cur_group_len != 0) {
            if (group_idx >= groups.len) return false;
            if (cur_group_len != groups[group_idx]) {
                return false;
            }
            group_idx += 1;
        }

        if (group_idx != groups.len) {
            return false;
        }

        return true;
    }
};
