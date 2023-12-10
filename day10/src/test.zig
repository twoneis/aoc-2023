const expect = @import("std").testing.expect;
const stderr = @import("std").debug.print;

var gpa = @import("std").heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

const File = @import("parser.zig").File;
const PartOne = @import("one.zig").PartOne;
const PartTwo = @import("two.zig").PartTwo;

test PartOne {
    const file_name = "test1.txt";
    const file = try File.init(allocator, file_name);
    defer file.deinit();

    if (file.lines.len == 0) {
        stderr("Empty file for part 1\n", .{});
        return;
    }

    const solver = PartOne.init(allocator);

    const solution = try solver.solve(file.lines);
    const expected = 8;

    expect(solution == expected) catch {
        stderr("Part one\n", .{});
        stderr("\n=====Unexpected Result=====\n", .{});
        stderr("Expected {d}, got {d}\n\n", .{ expected, solution });
        return error.TestUnexpectedResult;
    };
}

test PartTwo {
    const file_name = "test4.txt";
    const file = try File.init(allocator, file_name);
    defer file.deinit();

    if (file.lines.len == 0) {
        stderr("Empty file for part 2\n", .{});
        return;
    }

    const solver = PartTwo.init(allocator);

    const solution = try solver.solve(file.lines);
    const expected = 10;

    expect(solution == expected) catch {
        stderr("Part two\n", .{});
        stderr("\n=====Unexpected Result=====\n", .{});
        stderr("Expected {d}, got {d}\n\n", .{ expected, solution });
        return error.TestUnexpectedResult;
    };
}

test gpa {
    expect(gpa.deinit() != .leak) catch {
        stderr("Memory leaked\n", .{});
        return error.MemoryLeak;
    };
}
