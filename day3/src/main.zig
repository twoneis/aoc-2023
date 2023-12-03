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

    std.debug.print("{any}\n", .{file_contents});

    const solution_one = try part_one(file_name);
    const solution_two = try part_two(file_name);

    try stdout.print("Solution part one: {d}\nSolution part two: {d}\n", .{ solution_one, solution_two });

    try bw.flush();
}

fn part_one(file_name: []const u8) !u32 {
    var file = try std.fs.cwd().openFile(file_name, .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;
    const line_len = (try in_stream.readUntilDelimiterOrEof(&buf, '\n')).?.len;
    var line_num: u32 = 1;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        _ = line;
        line_num += 1;
    }

    var matrix = try allocator.alloc([]bool, line_num);
    for (matrix, 0..) |_, i| {
        matrix[i] = try allocator.alloc(bool, line_len);
        for (matrix[i], 0..) |_, j| {
            matrix[i][j] = false;
        }
    }

    file = try std.fs.cwd().openFile(file_name, .{});
    buf_reader = std.io.bufferedReader(file.reader());
    in_stream = buf_reader.reader();

    var i: usize = 0;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        for (line, 0..) |c, j| {
            if (!std.ascii.isDigit(c) and c != '.') {
                if (i + 1 < line_num) {
                    matrix[i + 1][j] = true;
                }
                if (i - 1 >= 0) {
                    matrix[i - 1][j] = true;
                }
                if (j + 1 < line_len) {
                    matrix[i][j + 1] = true;
                }
                if (j - 1 >= 0) {
                    matrix[i][j - 1] = true;
                }
                if (i + 1 < line_num and j + 1 < line_len) {
                    matrix[i + 1][j + 1] = true;
                }
                if (i + 1 < line_num and j - 1 >= 0) {
                    matrix[i + 1][j - 1] = true;
                }
                if (i - 1 >= 0 and j + 1 < line_len) {
                    matrix[i - 1][j + 1] = true;
                }
                if (i - 1 >= 0 and j - 1 >= 0) {
                    matrix[i - 1][j - 1] = true;
                }
            }
        }
        i += 1;
    }

    file = try std.fs.cwd().openFile(file_name, .{});
    buf_reader = std.io.bufferedReader(file.reader());
    in_stream = buf_reader.reader();

    var sum: u32 = 0;

    i = 0;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var j: usize = 0;
        var num_buf: [3]u8 = undefined;
        var nbp: usize = 0;
        for (line) |c| {
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
            j += 1;
        }
        i += 1;
    }

    return sum;
}

fn part_two(file_name: []const u8) !u32 {
    const Star = struct { n: u32, ratio: u32 };

    var file = try std.fs.cwd().openFile(file_name, .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;
    const line_len = (try in_stream.readUntilDelimiterOrEof(&buf, '\n')).?.len;
    var line_num: u32 = 1;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        _ = line;
        line_num += 1;
    }

    var matrix = try allocator.alloc([]u32, line_num);
    for (matrix, 0..) |_, i| {
        matrix[i] = try allocator.alloc(u32, line_len);
        for (matrix[i], 0..) |_, j| {
            matrix[i][j] = 0;
        }
    }

    file = try std.fs.cwd().openFile(file_name, .{});
    buf_reader = std.io.bufferedReader(file.reader());
    in_stream = buf_reader.reader();

    var i: usize = 0;
    var current_id: u32 = 1;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        for (line, 0..) |c, j| {
            if (c == '*') {
                if (i + 1 < line_num) {
                    matrix[i + 1][j] = current_id;
                }
                if (i - 1 >= 0) {
                    matrix[i - 1][j] = current_id;
                }
                if (j + 1 < line_len) {
                    matrix[i][j + 1] = current_id;
                }
                if (j - 1 >= 0) {
                    matrix[i][j - 1] = current_id;
                }
                if (i + 1 < line_num and j + 1 < line_len) {
                    matrix[i + 1][j + 1] = current_id;
                }
                if (i + 1 < line_num and j - 1 >= 0) {
                    matrix[i + 1][j - 1] = current_id;
                }
                if (i - 1 >= 0 and j + 1 < line_len) {
                    matrix[i - 1][j + 1] = current_id;
                }
                if (i - 1 >= 0 and j - 1 >= 0) {
                    matrix[i - 1][j - 1] = current_id;
                }

                current_id += 1;
            }
        }
        i += 1;
    }

    var gears = try allocator.alloc(Star, current_id);

    for (gears, 0..) |_, k| {
        gears[k] = Star{ .n = 0, .ratio = 1 };
    }

    file = try std.fs.cwd().openFile(file_name, .{});
    buf_reader = std.io.bufferedReader(file.reader());
    in_stream = buf_reader.reader();

    i = 0;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var j: usize = 0;
        var num_buf: [3]u8 = undefined;
        var nbp: usize = 0;
        for (line) |c| {
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
            j += 1;
        }
        i += 1;
    }

    var ratioSum: u32 = 0;
    for (gears) |gear| {
        if (gear.n == 2) {
            ratioSum += gear.ratio;
        }
    }

    return ratioSum;
}
