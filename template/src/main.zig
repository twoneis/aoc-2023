const process = @import("std").process;

var gpa = @import("std").heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

var bw = @import("std").io.bufferedWriter(@import("std").io.getStdOut().writer());
const stdout = bw.writer();

const File = @import("parser.zig").File;
const PartOne = @import("one.zig").PartOne;
const PartTwo = @import("two.zig").PartTwo;

pub fn main() !void {
    defer if (gpa.deinit() == .leak) @panic("Memory leaked");

    var args = process.args();
    _ = args.skip();

    const file_name = args.next().?;
    const file = try File.init(allocator, file_name);
    defer file.deinit();

    const part_one = PartOne.init(allocator);
    const part_two = PartTwo.init(allocator);

    const solution_one = try part_one.solve(file.lines);
    const solution_two = try part_two.solve(file.lines);

    try stdout.print("\nSolution part one: {d}\nSolution part two: {d}\n", .{ solution_one, solution_two });
    try bw.flush();
}
