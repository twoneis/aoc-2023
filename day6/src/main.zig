const std = @import("std");
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();
var bw = std.io.bufferedWriter(std.io.getStdOut().writer());
const stdout = bw.writer();

pub fn main() !void {
    defer if (gpa.deinit() == .leak) @panic("Memory leaked");

    var total_timer = try std.time.Timer.start();

    var args = std.process.args();
    _ = args.skip();

    const file_name = args.next().?;
    const file = try std.fs.cwd().openFile(file_name, .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var file_contents_buf = std.ArrayList([]u8).init(allocator);
    defer file_contents_buf.deinit();

    var eof: bool = false;
    var line_number: usize = 0;
    while (!eof) {
        var buf = std.ArrayList(u8).init(allocator);
        defer buf.deinit();
        in_stream.streamUntilDelimiter(buf.writer(), '\n', null) catch |err| switch (err) {
            error.EndOfStream => eof = true,
            else => return err,
        };
        const line = try buf.toOwnedSlice();
        if (line.len != 0) {
            try file_contents_buf.insert(line_number, line);
            line_number += 1;
        }
    }

    const file_contents = try file_contents_buf.toOwnedSlice();
    defer allocator.free(file_contents);
    defer {
        for (file_contents) |line| {
            allocator.free(line);
        }
    }

    var timer_part_one = try std.time.Timer.start();
    const solution_one = try part_one(file_contents);
    const nano_part_one = timer_part_one.read();
    const time_part_one: f64 = @as(f64, @floatFromInt(nano_part_one)) * std.math.pow(f64, 10, -9);

    var timer_part_two = try std.time.Timer.start();
    const solution_two = try part_two(file_contents);
    const nano_part_two = timer_part_two.read();
    const time_part_two: f64 = @as(f64, @floatFromInt(nano_part_two)) * std.math.pow(f64, 10, -9);

    const nano_total = total_timer.read();
    const total_time: f64 = @as(f64, @floatFromInt(nano_total)) * std.math.pow(f64, 10, -9);

    try stdout.print("\nSolution part one: {d}\nTime part 1 (without parsing file): {e:.3}s\n", .{ solution_one, time_part_one });
    try stdout.print("\nSolution part two: {d}\nTime part 2 (without parsing file): {e:.3}s\n", .{ solution_two, time_part_two });

    try stdout.print("\nTotal time (with file parsing): {e:.3}s\n", .{total_time});

    try bw.flush();
}

fn part_one(file: [][]const u8) !u32 {
    var result: u32 = 1;

    var times: []u32 = undefined;
    defer allocator.free(times);
    var distances: []u32 = undefined;
    defer allocator.free(distances);

    var buf_array = std.ArrayList(u32).init(allocator);
    defer buf_array.deinit();

    for (file) |line| {
        var num_buf = std.ArrayList(u8).init(allocator);
        defer num_buf.deinit();
        for (line) |c| {
            if (!std.ascii.isDigit(c)) {
                if (num_buf.items.len != 0) {
                    const buf = try num_buf.toOwnedSlice();
                    defer allocator.free(buf);
                    const num = try std.fmt.parseInt(u32, buf, 10);
                    try buf_array.append(num);
                    num_buf.clearRetainingCapacity();
                }
                continue;
            }
            try num_buf.append(c);
        }
        const buf = try num_buf.toOwnedSlice();
        defer allocator.free(buf);
        const num = try std.fmt.parseInt(u32, buf, 10);
        try buf_array.append(num);

        if (line[0] == 'T') {
            times = try buf_array.toOwnedSlice();
        }
        if (line[0] == 'D') {
            distances = try buf_array.toOwnedSlice();
        }
    }

    for (times, distances) |time, distance| {
        var winning_times: u32 = 0;
        for (0..time) |i| {
            const travelled = i * (time - i);
            if (travelled > distance) {
                winning_times += 1;
            }
        }

        result *= winning_times;
    }

    return result;
}

fn part_two(file: [][]const u8) !u64 {
    var result: u64 = 0;

    var time: u64 = 0;
    var distance: u64 = 0;

    var buf_array = std.ArrayList(u32).init(allocator);
    defer buf_array.deinit();

    for (file) |line| {
        var num_buf = std.ArrayList(u8).init(allocator);
        defer num_buf.deinit();
        for (line) |c| {
            if (!std.ascii.isDigit(c)) {
                continue;
            }
            try num_buf.append(c);
        }
        const buf = try num_buf.toOwnedSlice();
        defer allocator.free(buf);
        const num = try std.fmt.parseInt(u64, buf, 10);

        if (line[0] == 'T') {
            time = num;
        }
        if (line[0] == 'D') {
            distance = num;
        }
    }

    for (0..time) |i| {
        const travelled = i * (time - i);
        if (travelled > distance) {
            result += 1;
        }
    }

    return result;
}
