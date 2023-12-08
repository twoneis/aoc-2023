const std = @import("std");
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();
var bw = std.io.bufferedWriter(std.io.getStdOut().writer());
const stdout = bw.writer();
const log = std.debug.print;

pub fn main() !void {
    defer if (gpa.deinit() == .leak) @panic("Memory leaked");

    var total_timer = try std.time.Timer.start();
    _ = total_timer;

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

    const n_runs: usize = 1000;
    _ = n_runs;

    // const solution_one = try part_one(file_contents);
    const solution_one = 0;
    const solution_two = try part_two(file_contents);
    try stdout.print("\nSolution part one: {d}\nSolution part two: {d}\n", .{ solution_one, solution_two });
    try bw.flush();

    // const nano_total = total_timer.read();
    // const total_time: f64 = @as(f64, @floatFromInt(nano_total)) * std.math.pow(f64, 10, -6);

    // var nano_part_one: u64 = 0;
    // for (0..n_runs) |_| {
    //     var timer_part_one = try std.time.Timer.start();
    //     _ = try part_one(file_contents);
    //     nano_part_one += timer_part_one.read();
    // }
    // const time_part_one: f64 = (@as(f64, @floatFromInt(nano_part_one)) * std.math.pow(f64, 10, -6)) / @as(f64, @floatFromInt(n_runs));

    // var nano_part_two: u64 = 0;
    // for (0..n_runs) |_| {
    //     var timer_part_two = try std.time.Timer.start();
    //     _ = try part_two(file_contents);
    //     nano_part_two += timer_part_two.read();
    // }
    // const time_part_two: f64 = (@as(f64, @floatFromInt(nano_part_two)) * std.math.pow(f64, 10, -6)) / @as(f64, @floatFromInt(n_runs));
    // try stdout.print("\nTime part 1: {e:.3}ms\nTime part 2: {e:.3}ms\n", .{ time_part_one, time_part_two });
    // try stdout.print("\nTotal time (with file parsing): {e:.3}ms\n", .{total_time});

    // try bw.flush();
}

fn part_one(file: [][]const u8) !u32 {
    const instructions = file[0];
    var map = std.StringHashMap([2][]const u8).init(allocator);
    defer map.deinit();
    for (1..file.len) |i| {
        var line_split = std.mem.tokenizeAny(u8, file[i], " =(,)");
        const from = line_split.next().?;
        const l = line_split.next().?;
        const r = line_split.next().?;
        try map.put(from, [2][]const u8{ l, r });
    }

    var steps: u32 = 0;

    var ip: u32 = 0;
    var location = map.getEntry("AAA").?;
    while (!std.mem.eql(u8, location.key_ptr.*, "ZZZ")) {
        location = switch (instructions[ip]) {
            'L' => map.getEntry(location.value_ptr[0]).?,
            'R' => map.getEntry(location.value_ptr[1]).?,
            else => return error.InvalidCharacter,
        };
        steps += 1;
        ip += 1;
        if (ip >= instructions.len) {
            ip = 0;
        }
    }

    return steps;
}

fn part_two(file: [][]const u8) !u32 {
    const instructions = file[0];
    var map = std.StringHashMap([2][]const u8).init(allocator);
    defer map.deinit();
    for (1..file.len) |i| {
        var line_split = std.mem.tokenizeAny(u8, file[i], " =(,)");
        const from = line_split.next().?;
        const l = line_split.next().?;
        const r = line_split.next().?;
        try map.put(from, [2][]const u8{ l, r });
    }

    var locations_buf = std.ArrayList(std.hash_map.StringHashMap([2][]const u8).Entry).init(allocator);
    defer locations_buf.deinit();

    var map_iter = map.iterator();
    while (map_iter.next()) |entry| {
        if (entry.key_ptr.*[2] == 'A') {
            try locations_buf.append(entry);
        }
    }

    var steps: u32 = 0;

    var ip: u32 = 0;
    var locations = try locations_buf.toOwnedSlice();
    defer allocator.free(locations);
    var all_true = false;
    while (!all_true) {
        all_true = true;
        for (locations, 0..) |location, i| {
            if (location.key_ptr.*[2] != 'Z') {
                all_true = false;
            }
            locations[i] = switch (instructions[ip]) {
                'L' => map.getEntry(location.value_ptr[0]).?,
                'R' => map.getEntry(location.value_ptr[1]).?,
                else => return error.InvalidCharacter,
            };
        }
        steps += 1;
        ip += 1;
        if (ip >= instructions.len) {
            ip = 0;
        }
    }

    return steps - 1;
}
