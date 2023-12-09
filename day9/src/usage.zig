var stdout_bw = @import("std").io.bufferedWriter(@import("std").io.getStdOut().writer());
const stdout = stdout_bw.writer();
const process = @import("std").process;

pub fn usage() !void {
    var args = process.args();
    try stdout.print("Usage: {s} <input file>\n", .{args.next().?});
    try stdout_bw.flush();
}

pub fn empty_file(file_name: []const u8) !void {
    try stdout.print("Empty input file: {s}\n", .{file_name});
    try stdout_bw.flush();
}
