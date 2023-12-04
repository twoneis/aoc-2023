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

    const solution_one = try part_one(file_contents);
    const solution_two = try part_two(file_contents);

    try stdout.print("Solution part one: {d}\nSolution part two: {d}\n", .{ solution_one, solution_two });

    try bw.flush();
}

fn part_one(file: [][]const u8) !u32 {
    _ = file;
    return 0;
}

fn part_two(file: [][]const u8) !u32 {
    _ = file;
    return 0;
}