const cwd = @import("std").fs.cwd();
const Allocator = @import("std").mem.Allocator;
const io = @import("std").io;
const vector = @import("std").ArrayList;

pub const File = struct {
    const Self = @This();

    allocator: Allocator,
    file_name: []const u8,
    lines: [][]const u8,

    pub fn init(allocator: Allocator, file_name: []const u8) !Self {
        const lines = try parse_file(file_name, allocator);
        return Self{ .allocator = allocator, .file_name = file_name, .lines = lines };
    }

    pub fn deinit(self: Self) void {
        for (self.lines) |line| {
            self.allocator.free(line);
        }
        self.allocator.free(self.lines);
    }

    fn parse_file(file_name: []const u8, allocator: Allocator) ![][]u8 {
        const file = try cwd.openFile(file_name, .{});
        defer file.close();

        var buf_reader = io.bufferedReader(file.reader());
        var in_stream = buf_reader.reader();

        var file_contents_buf = vector([]u8).init(allocator);

        var eof: bool = false;
        while (!eof) {
            var buf = vector(u8).init(allocator);
            in_stream.streamUntilDelimiter(buf.writer(), '\n', null) catch |err| switch (err) {
                error.EndOfStream => eof = true,
                else => return err,
            };
            const line = try buf.toOwnedSlice();
            try file_contents_buf.append(line);
        }

        return try file_contents_buf.toOwnedSlice();
    }
};
