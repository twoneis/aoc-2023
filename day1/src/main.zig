const std = @import("std");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    var args = std.process.args();
    _ = args.skip();

    const file_name = args.next().?;

    const solution_one = try part_one(file_name);
    const solution_two = try part_two(file_name);

    try stdout.print("Solution part one: {d}\nSolution part two: {d}\n", .{ solution_one, solution_two });
}

fn part_one(file_name: []const u8) !u32 {
    var file = try std.fs.cwd().openFile(file_name, .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var sum: u32 = 0;

    var buf: [1024]u8 = undefined;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var first_num: u8 = undefined;
        var last_num: u8 = undefined;
        var first = true;
        for (line, 0..) |_, i| {
            if (std.ascii.isDigit(line[i])) {
                if (first) {
                    first_num = line[i];
                    first = false;
                }
                last_num = line[i];
            }
        }
        const num_str = [_]u8{ first_num, last_num };
        const num = try std.fmt.parseInt(u32, &num_str, 10);
        sum += num;
    }

    return sum;
}

fn part_two(file_name: []const u8) !u32 {
    const alpha_digits = [_][]const u8{ "zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine" };

    var file = try std.fs.cwd().openFile(file_name, .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var sum: u32 = 0;

    var buf: [1024]u8 = undefined;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var first_num: u8 = undefined;
        var last_num: u8 = undefined;
        var first = true;
        for (line, 0..) |_, i| {
            for (alpha_digits, 0..) |alpha_digit, j| {
                if (i + alpha_digit.len <= line.len and std.mem.eql(u8, line[i .. i + alpha_digit.len], alpha_digit)) {
                    line[i] = @as(u8, @truncate(j)) + '0';
                }
            }

            if (std.ascii.isDigit(line[i])) {
                if (first) {
                    first_num = line[i];
                    first = false;
                }
                last_num = line[i];
            }
        }
        const num_str = [_]u8{ first_num, last_num };
        const num = try std.fmt.parseInt(u32, &num_str, 10);
        sum += num;
    }

    return sum;
}
