const std = @import("std");
var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();
var bw = std.io.bufferedWriter(std.io.getStdOut().writer());
const stdout = bw.writer();

pub fn main() !void {
    defer arena.deinit();

    var args = std.process.args();
    _ = args.skip();

    const file_name = args.next().?;
    const file = try std.fs.cwd().openFile(file_name, .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var file_contents_buf = std.ArrayList([]u8).init(allocator);

    var buf = std.ArrayList(u8).init(allocator);
    var eof: bool = false;
    var line_number: usize = 0;
    while (!eof) {
        in_stream.streamUntilDelimiter(buf.writer(), '\n', null) catch |err| switch (err) {
            error.EndOfStream => eof = true,
            else => return err,
        };
        const line = try buf.toOwnedSlice();
        if (line.len != 0) {
            try file_contents_buf.insert(line_number, line);
        }

        buf.clearRetainingCapacity();
        line_number += 1;
    }

    const file_contents = try file_contents_buf.toOwnedSlice();

    const solution_one = try part_one(file_contents);
    const solution_two = try part_two(file_contents);

    try stdout.print("Solution part one: {d}\nSolution part two: {d}\n", .{ solution_one, solution_two });

    try bw.flush();
}

fn part_one(file: [][]const u8) !u32 {
    const line_len = file[0].len;
    const line_num = file.len;

    var matrix = try allocator.alloc([]bool, line_num);
    for (matrix, 0..) |_, i| {
        matrix[i] = try allocator.alloc(bool, line_len);
        for (matrix[i], 0..) |_, j| {
            matrix[i][j] = false;
        }
    }

    for (file, 0..) |line, i| {
        for (line, 0..) |c, j| {
            if (!std.ascii.isDigit(c) and c != '.') {
                for (0..3) |m| {
                    for (0..3) |n| {
                        if (0 <= i + m - 1 and i + m - 1 < line_num and 0 <= j + n - 1 and j + n - 1 < line_num) {
                            const x = i + m - 1;
                            const y = j + n - 1;
                            matrix[x][y] = true;
                        }
                    }
                }
            }
        }
    }

    var sum: u32 = 0;

    for (file, 0..) |line, i| {
        var num_buf: [3]u8 = undefined;
        var nbp: usize = 0;
        for (line, 0..) |c, j| {
            if (std.ascii.isDigit(c)) {
                num_buf[nbp] = c;
                nbp += 1;
            }
            if (!std.ascii.isDigit(c) or j == line_len - 1) {
                if (nbp != 0) {
                    var adjacent = false;
                    for (1..nbp + 1) |k| {
                        if (matrix[i][j - k]) {
                            adjacent = true;
                        }
                    }
                    if (adjacent) {
                        const num = try std.fmt.parseInt(u32, num_buf[0..nbp], 10);
                        sum += num;
                    }
                    nbp = 0;
                }
            }
        }
    }

    return sum;
}

fn part_two(file: [][]const u8) !u32 {
    const Gear = struct { n: u32, ratio: u32 };

    const line_len = file[0].len;
    const line_num = file.len;

    var matrix = try allocator.alloc([]u32, line_num);
    for (matrix, 0..) |_, i| {
        matrix[i] = try allocator.alloc(u32, line_len);
        for (matrix[i], 0..) |_, j| {
            matrix[i][j] = 0;
        }
    }

    var current_id: u32 = 1;
    for (file, 0..) |line, i| {
        for (line, 0..) |c, j| {
            if (c == '*') {
                for (0..3) |m| {
                    for (0..3) |n| {
                        if (0 <= i + m - 1 and i + m - 1 < line_num and 0 <= j + n - 1 and j + n - 1 < line_num) {
                            const x = i + m - 1;
                            const y = j + n - 1;
                            matrix[x][y] = current_id;
                        }
                    }
                }
                current_id += 1;
            }
        }
    }

    var gears = try allocator.alloc(Gear, current_id);
    defer allocator.free(gears);

    for (gears, 0..) |_, k| {
        gears[k] = Gear{ .n = 0, .ratio = 1 };
    }

    for (file, 0..) |line, i| {
        var num_buf: [3]u8 = undefined;
        var nbp: usize = 0;
        for (line, 0..) |c, j| {
            if (std.ascii.isDigit(c)) {
                num_buf[nbp] = c;
                nbp += 1;
            }
            if (!std.ascii.isDigit(c) or j == line_len - 1) {
                if (nbp != 0) {
                    const num = try std.fmt.parseInt(u32, num_buf[0..nbp], 10);
                    var adjacent_ids = [8]u32{ 0, 0, 0, 0, 0, 0, 0, 0 };
                    var adjacent_id_n: usize = 0;
                    for (1..nbp + 1) |k| {
                        if (matrix[i][j - k] != 0) {
                            if (!std.mem.containsAtLeast(u32, &adjacent_ids, 1, &[_]u32{matrix[i][j - k]})) {
                                adjacent_ids[adjacent_id_n] = matrix[i][j - k];
                                adjacent_id_n += 1;

                                gears[matrix[i][j - k]].ratio *= num;
                                gears[matrix[i][j - k]].n += 1;
                            }
                        }
                    }
                    nbp = 0;
                }
            }
        }
    }

    var ratioSum: u32 = 0;
    for (gears) |gear| {
        if (gear.n == 2) {
            ratioSum += gear.ratio;
        }
    }

    return ratioSum;
}
