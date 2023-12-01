const std = @import("std");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    var file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var sum: i32 = 0;

    var buf: [1024]u8 = undefined;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var first_num: u8 = undefined;
        var last_num: u8 = undefined;
        var first = true;
        for (line, 0..) |_, i| {
            if (i + "zero".len <= line.len and std.mem.eql(u8, line[i .. i + "zero".len], "zero")) {
                line[i] = '0';
            } else if (i + "one".len <= line.len and std.mem.eql(u8, line[i .. i + "one".len], "one")) {
                line[i] = '1';
            } else if (i + "two".len <= line.len and std.mem.eql(u8, line[i .. i + "two".len], "two")) {
                line[i] = '2';
            } else if (i + "three".len <= line.len and std.mem.eql(u8, line[i .. i + "three".len], "three")) {
                line[i] = '3';
            } else if (i + "four".len <= line.len and std.mem.eql(u8, line[i .. i + "four".len], "four")) {
                line[i] = '4';
            } else if (i + "five".len <= line.len and std.mem.eql(u8, line[i .. i + "five".len], "five")) {
                line[i] = '5';
            } else if (i + "six".len <= line.len and std.mem.eql(u8, line[i .. i + "six".len], "six")) {
                line[i] = '6';
            } else if (i + "seven".len <= line.len and std.mem.eql(u8, line[i .. i + "seven".len], "seven")) {
                line[i] = '7';
            } else if (i + "eight".len <= line.len and std.mem.eql(u8, line[i .. i + "eight".len], "eight")) {
                line[i] = '8';
            } else if (i + "nine".len <= line.len and std.mem.eql(u8, line[i .. i + "nine".len], "nine")) {
                line[i] = '9';
            }

            if (line[i] >= '0' and line[i] <= '9') {
                if (first) {
                    first_num = line[i];
                    first = false;
                }
                last_num = line[i];
            }
        }
        const num_str = [_]u8{ first_num, last_num };
        const num = try std.fmt.parseInt(i32, &num_str, 10);
        sum += num;
    }
    try stdout.print("{d}\n", .{sum});
}
