const std = @import("std");
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();
var bw = std.io.bufferedWriter(std.io.getStdOut().writer());
const stdout = bw.writer();

pub fn main() !void {
    defer if (gpa.deinit() == .leak) std.debug.print("Memory leaked\n", .{});

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
    try stdout.print("\nSolution part two: {d}\nTime part 2 (without parsing file): {e:.3}s)\n", .{ solution_two, time_part_two });

    try stdout.print("\nTotal time (with file parsing): {e:.3}\n", .{total_time});

    try bw.flush();
}

fn part_one(file: [][]const u8) !i64 {
    const Entry = struct { from_lower: i64, from_upper: i64, to_offset: i64 };
    var maps = std.ArrayList([]Entry).init(allocator);
    defer maps.deinit();
    var map = std.ArrayList(Entry).init(allocator);
    defer map.deinit();
    var targets = std.ArrayList(i64).init(allocator);
    defer targets.deinit();

    for (file) |line| {
        if (line[line.len - 1] == ':') {
            try maps.append(try map.toOwnedSlice());
            map.clearRetainingCapacity();
            continue;
        }
        if (!std.ascii.isDigit(line[0])) {
            var line_split = std.mem.splitAny(u8, line, " ");
            while (line_split.next()) |x| {
                try targets.append(std.fmt.parseInt(i64, x, 10) catch |err| switch (err) {
                    error.InvalidCharacter => continue,
                    else => return err,
                });
            }
            continue;
        }

        var line_split = std.mem.splitAny(u8, line, " ");
        const v = try std.fmt.parseInt(i64, line_split.next().?, 10);
        const k = try std.fmt.parseInt(i64, line_split.next().?, 10);
        const range = try std.fmt.parseInt(i64, line_split.next().?, 10);
        const offset: i64 = v - k;

        try map.append(Entry{ .from_lower = k, .from_upper = k + range, .to_offset = offset });
    }
    try maps.append(try map.toOwnedSlice());

    var locations = try targets.toOwnedSlice();
    defer allocator.free(locations);

    const filled_maps = try maps.toOwnedSlice();
    defer allocator.free(filled_maps);
    defer {
        for (filled_maps, 0..) |_, i| {
            allocator.free(filled_maps[i]);
        }
    }

    for (filled_maps) |current_map| {
        for (locations, 0..) |location, i| {
            for (current_map) |entry| {
                if (location >= entry.from_lower and location < entry.from_upper) {
                    locations[i] += entry.to_offset;
                }
            }
        }
    }

    var min = locations[0];
    for (locations) |location| {
        if (location < min) {
            min = location;
        }
    }

    return min;
}

fn part_two(file: [][]const u8) !i64 {
    const Entry = struct { from_lower: i64, from_upper: i64, to_offset: i64 };
    const TargetEntry = struct { lower: i64, upper: i64 };
    var maps = std.ArrayList([]Entry).init(allocator);
    defer maps.deinit();
    var map = std.ArrayList(Entry).init(allocator);
    defer map.deinit();
    var targets = std.ArrayList(TargetEntry).init(allocator);
    defer targets.deinit();

    for (file) |line| {
        if (line[line.len - 1] == ':') {
            try maps.append(try map.toOwnedSlice());
            map.clearRetainingCapacity();
            continue;
        }
        if (!std.ascii.isDigit(line[0])) {
            var line_split = std.mem.splitAny(u8, line, " ");
            while (line_split.next()) |x| {
                const start = (std.fmt.parseInt(i64, x, 10) catch |err| switch (err) {
                    error.InvalidCharacter => continue,
                    else => return err,
                });
                const range = try std.fmt.parseInt(i64, line_split.next().?, 10);
                try targets.append(TargetEntry{ .lower = start, .upper = start + range });
            }
            continue;
        }

        var line_split = std.mem.splitAny(u8, line, " ");
        const v = try std.fmt.parseInt(i64, line_split.next().?, 10);
        const k = try std.fmt.parseInt(i64, line_split.next().?, 10);
        const range = try std.fmt.parseInt(i64, line_split.next().?, 10);
        const offset: i64 = v - k;

        try map.append(Entry{ .from_lower = k, .from_upper = k + range, .to_offset = offset });
    }
    try maps.append(try map.toOwnedSlice());

    const filled_maps = try maps.toOwnedSlice();
    defer allocator.free(filled_maps);
    defer {
        for (filled_maps, 0..) |_, i| {
            allocator.free(filled_maps[i]);
        }
    }

    for (filled_maps) |current_map| {
        for (0..targets.items.len) |i| {
            for (current_map) |entry| {
                const location = targets.items[i];
                if (location.lower >= entry.from_lower and location.upper <= entry.from_upper) {
                    const new_location = TargetEntry{ .lower = location.lower + entry.to_offset, .upper = location.upper + entry.to_offset };
                    try targets.replaceRange(i, 1, &[_]TargetEntry{new_location});
                    break;
                } else if (location.lower >= entry.from_lower and location.lower < entry.from_upper) {
                    const new_location = TargetEntry{ .lower = location.lower + entry.to_offset, .upper = entry.from_upper + entry.to_offset - 1 };
                    const old_location = TargetEntry{ .lower = entry.from_upper, .upper = location.upper };
                    try targets.replaceRange(i, 1, &[_]TargetEntry{old_location});
                    try targets.append(new_location);
                } else if (location.upper >= entry.from_lower and location.upper < entry.from_upper) {
                    const new_location = TargetEntry{ .lower = entry.from_lower + entry.to_offset, .upper = location.upper + entry.to_offset };
                    const old_location = TargetEntry{ .lower = location.lower, .upper = entry.from_lower - 1 };
                    try targets.replaceRange(i, 1, &[_]TargetEntry{old_location});
                    try targets.append(new_location);
                }
            }
        }
    }

    const locations = try targets.toOwnedSlice();
    defer allocator.free(locations);
    var min = locations[0].lower;
    for (locations) |location| {
        if (location.lower < min) {
            min = location.lower;
        }
    }

    return min;
}
