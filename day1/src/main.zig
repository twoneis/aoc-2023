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
            if (i + 4 <= line.len and std.mem.eql(u8, line[i .. i + 4], "zero")) {
                std.log.info("{s} == zero", .{line[i..]});
                line[i] = '0';
            } else if (i + 3 <= line.len and std.mem.eql(u8, line[i .. i + 3], "one")) {
                std.log.info("{s} == one", .{line[i..]});
                line[i] = '1';
            } else if (i + 3 <= line.len and std.mem.eql(u8, line[i .. i + 3], "two")) {
                std.log.info("{s} == two", .{line[i..]});
                line[i] = '2';
            } else if (i + 5 <= line.len and std.mem.eql(u8, line[i .. i + 5], "three")) {
                std.log.info("{s} == three", .{line[i..]});
                line[i] = '3';
            } else if (i + 4 <= line.len and std.mem.eql(u8, line[i .. i + 4], "four")) {
                std.log.info("{s} == four", .{line[i..]});
                line[i] = '4';
            } else if (i + 4 <= line.len and std.mem.eql(u8, line[i .. i + 4], "five")) {
                std.log.info("{s} == five", .{line[i..]});
                line[i] = '5';
            } else if (i + 3 <= line.len and std.mem.eql(u8, line[i .. i + 3], "six")) {
                std.log.info("{s} == six", .{line[i .. i + 3]});
                line[i] = '6';
            } else if (i + 5 <= line.len and std.mem.eql(u8, line[i .. i + 5], "seven")) {
                std.log.info("{s} == seven", .{line[i..]});
                line[i] = '7';
            } else if (i + 5 <= line.len and std.mem.eql(u8, line[i .. i + 5], "eight")) {
                std.log.info("{s} == eight", .{line[i..]});
                line[i] = '8';
            } else if (i + 4 <= line.len and std.mem.eql(u8, line[i .. i + 4], "nine")) {
                std.log.info("{s} == nine", .{line[i..]});
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
