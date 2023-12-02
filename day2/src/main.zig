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
        var max_game_results = [_]u32{ 0, 0, 0 };

        var game_result_split = std.mem.split(u8, line, ":");

        const game = game_result_split.next().?;
        const result = game_result_split.next().?;

        var game_split = std.mem.split(u8, game, " ");
        _ = game_split.next();
        const game_id = try std.fmt.parseInt(u32, game_split.next().?, 10);

        var result_split = std.mem.split(u8, result, ";");
        while (result_split.next()) |single_result| {
            var single_result_split = std.mem.split(u8, single_result, ",");

            while (single_result_split.next()) |x| {
                var kv_split = std.mem.split(u8, x, " ");

                _ = kv_split.next();
                const v = try std.fmt.parseInt(u32, kv_split.next().?, 10);
                const k = kv_split.next().?;
                const k_index = string_to_index(k);

                if (max_game_results[k_index] < v) {
                    max_game_results[k_index] = v;
                }
            }
        }

        var n_red = max_game_results[string_to_index("red")];
        var n_green = max_game_results[string_to_index("green")];
        var n_blue = max_game_results[string_to_index("blue")];

        if (n_red <= 12 and n_green <= 13 and n_blue <= 14) {
            sum += game_id;
        }
    }

    return sum;
}

fn part_two(file_name: []const u8) !u32 {
    var file = try std.fs.cwd().openFile(file_name, .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var sum: u32 = 0;

    var buf: [1024]u8 = undefined;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var max_game_results = [_]u32{ 0, 0, 0 };

        var game_result_split = std.mem.split(u8, line, ":");

        _ = game_result_split.next().?;
        const result = game_result_split.next().?;

        var result_split = std.mem.split(u8, result, ";");
        while (result_split.next()) |single_result| {
            var single_result_split = std.mem.split(u8, single_result, ",");

            while (single_result_split.next()) |x| {
                var kv_split = std.mem.split(u8, x, " ");

                _ = kv_split.next();
                const v = try std.fmt.parseInt(u32, kv_split.next().?, 10);
                const k = kv_split.next().?;
                const k_index = string_to_index(k);

                if (max_game_results[k_index] < v) {
                    max_game_results[k_index] = v;
                }
            }
        }

        var n_red = max_game_results[string_to_index("red")];
        var n_green = max_game_results[string_to_index("green")];
        var n_blue = max_game_results[string_to_index("blue")];

        sum += n_red * n_green * n_blue;
    }

    return sum;
}

fn string_to_index(k: []const u8) u32 {
    const cases = enum { red, green, blue };
    const case = std.meta.stringToEnum(cases, k) orelse return 0;

    switch (case) {
        cases.red => return 0,
        cases.green => return 1,
        cases.blue => return 2,
    }
}
