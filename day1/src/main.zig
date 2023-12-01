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
            if (line[i] >= 48 and line[i] <= 57) {
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
