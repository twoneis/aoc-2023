const expect = @import("std").testing.expect;
const stderr = @import("std").debug.print;

var gpa = @import("std").heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

const File = @import("parser.zig").File;
const PartOne = @import("one.zig").PartOne;
const PartTwo = @import("two.zig").PartTwo;

test "Test example case for part one" {
    defer if (gpa.deinit() == .leak) @panic("Memory leaked");

    const test_file = try File.init(allocator, "test1.txt");
    defer test_file.deinit();
    const solver = PartOne.init(allocator);

    const solution = try solver.solve(test_file.lines);
    const expected = 0;

    expect(solution == expected) catch stderr("Expected {d}, got {d}\n", .{ expected, solution });
}

test "Test example case for part two" {
    defer if (gpa.deinit() == .leak) @panic("Memory leaked");

    const test_file = try File.init(allocator, "test2.txt");
    defer test_file.deinit();
    const solver = PartTwo.init(allocator);

    const solution = try solver.solve(test_file.lines);
    const expected = 0;

    expect(solution == expected) catch stderr("Expected {d}, got {d}\n", .{ expected, solution });
}
