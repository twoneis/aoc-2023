const std = @import("std");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    var args = std.process.args();
    _ = args.skip();

    const file_name = args.next().?;

    var file = try std.fs.cwd().openFile(file_name, .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var sum: i32 = 0;

    const alpha_digits = [_][]const u8{ "zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine" };

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
