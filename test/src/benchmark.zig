var gpa = @import("std").heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

var stdout_bw = @import("std").io.bufferedWriter(@import("std").io.getStdOut().writer());
const stdout = stdout_bw.writer();

const Timer = @import("std").time.Timer;

const process = @import("std").process;
const math = @import("std").math;
const fmt = @import("std").fmt;

const File = @import("parser.zig").File;
const PartOne = @import("one.zig").PartOne;
const PartTwo = @import("two.zig").PartTwo;

pub fn main() !void {
    defer if (gpa.deinit() == .leak) @panic("Memory leaked");

    var args = process.args();
    _ = args.skip();

    const file_name = args.next().?;

    const part_one = PartOne.init(allocator);
    const part_two = PartTwo.init(allocator);

    var parse_timer = try Timer.start();
    var part_one_timer = try Timer.start();
    var part_two_timer = try Timer.start();

    var total_parse_time: u64 = 0;
    var total_part_one_time: u64 = 0;
    var total_part_two_time: u64 = 0;

    const n_runs: usize = fmt.parseInt(usize, args.next().?, 10) catch 100;

    for (0..n_runs) |_| {
        parse_timer.reset();
        const file = try File.init(allocator, file_name);
        defer file.deinit();
        total_parse_time += parse_timer.read();

        part_one_timer.reset();
        _ = try part_one.solve(file.lines);
        total_part_one_time += part_one_timer.read();

        part_two_timer.reset();
        _ = try part_two.solve(file.lines);
        total_part_two_time += part_two_timer.read();
    }

    const parse_time: f64 = (@as(f64, @floatFromInt(total_parse_time)) * math.pow(f64, 10, -6)) /
        @as(f64, @floatFromInt(n_runs));
    const part_one_time: f64 = (@as(f64, @floatFromInt(total_part_one_time)) * math.pow(f64, 10, -6)) /
        @as(f64, @floatFromInt(n_runs));
    const part_two_time: f64 = (@as(f64, @floatFromInt(total_part_two_time)) * math.pow(f64, 10, -6)) /
        @as(f64, @floatFromInt(n_runs));

    try stdout.print("============Benchmark============\n", .{});
    try stdout.print("Results for {d} runs\n", .{n_runs});
    try stdout.print("Time to parse file: {e:.03}\n", .{parse_time});
    try stdout.print("Time part one: {e:.03}\n", .{part_one_time});
    try stdout.print("Time part two: {e:.03}\n", .{part_two_time});
    try stdout_bw.flush();
}
