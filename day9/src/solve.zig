const process = @import("std").process;
const expect = @import("std").testing.expect;

var gpa = @import("std").heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

var stdout_bw = @import("std").io.bufferedWriter(@import("std").io.getStdOut().writer());
const stdout = stdout_bw.writer();

const File = @import("parser.zig").File;
const PartOne = @import("one.zig").PartOne;
const PartTwo = @import("two.zig").PartTwo;

const usage = @import("usage.zig");

pub fn main() !void {
    defer if (gpa.deinit() == .leak) @panic("Memory leaked");

    var args = process.args();
    _ = args.skip();

    const file_name = args.next() orelse {
        try usage.usage();
        return;
    };
    const file = try File.init(allocator, file_name);
    defer file.deinit();

    if (file.lines.len == 0) {
        try usage.empty_file(file_name);
        return;
    }

    const part_one = PartOne.init(allocator);
    const part_two = PartTwo.init(allocator);

    const solution_one = try part_one.solve(file.lines);
    const solution_two = try part_two.solve(file.lines);

    try stdout.print("\nSolution part one: {d}\nSolution part two: {d}\n", .{ solution_one, solution_two });
    try stdout_bw.flush();
}
