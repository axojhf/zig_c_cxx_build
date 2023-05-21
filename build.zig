const std = @import("std");
const Allocator = std.mem.Allocator;

pub fn build(b: *std.Build) !void {
    const target: std.zig.CrossTarget = .{
        .os_tag = .windows,
        .abi = .gnu,
    };
    const optimize = b.standardOptimizeOption(.{});

    const shared = b.option(bool, "Shared", "Build libuv Shared Library [default: false]") orelse false;
    const tests = b.option(bool, "Tests", "Build Tests [default: false]") orelse false;

    const lib = if (shared)
        b.addSharedLibrary(.{
            .name = "libuv",
            .optimize = optimize,
            .target = target,
            .version = .{
                .major = 1,
                .minor = 45,
                .patch = 0,
            },
        })
    else
        b.addStaticLibrary(.{
            .name = "libuv",
            .optimize = optimize,
            .target = target,
        });
    lib.want_lto = false;
    lib.disable_sanitize_c = true;
    if (optimize == .Debug or optimize == .ReleaseSafe)
        lib.bundle_compiler_rt = true
    else
        lib.strip = true;

    lib.addCSourceFiles(src, winnt_flags);
    lib.addCSourceFiles(winnt_src, winnt_flags);
    lib.defineCMacro("WIN32_LEAN_AND_MEAN", "");
    lib.defineCMacro("_WIN32_WINNT", "0x0602");
    for (include_dir) |v| {
        lib.addIncludePath(v);
    }
    for (winnt_include) |v| {
        lib.addIncludePath(v);
    }
    lib.linkLibC();
    b.installArtifact(lib);
    lib.installHeadersDirectory("include", "");

    if (tests) {}
}

const include_dir: []const []const u8 = &.{ "include", "src" };

const src: []const []const u8 = &.{
    "src/fs-poll.c",
    "src/idna.c",
    "src/inet.c",
    "src/random.c",
    "src/strscpy.c",
    "src/thread-common.c",
    "src/threadpool.c",
    "src/timer.c",
    "src/uv-data-getter-setters.c",
    "src/uv-common.c",
    "src/version.c",
    "src/strtok.c",
};

const winnt_include: []const []const u8 = &.{"src/win"};

const winnt_src: []const []const u8 = &.{
    "src/win/async.c",
    "src/win/core.c",
    "src/win/detect-wakeup.c",
    "src/win/dl.c",
    "src/win/error.c",
    "src/win/fs-event.c",
    "src/win/fs.c",
    "src/win/getaddrinfo.c",
    "src/win/getnameinfo.c",
    "src/win/handle.c",
    "src/win/loop-watcher.c",
    "src/win/pipe.c",
    "src/win/poll.c",
    "src/win/process-stdio.c",
    "src/win/process.c",
    "src/win/signal.c",
    "src/win/stream.c",
    "src/win/tcp.c",
    "src/win/thread.c",
    "src/win/tty.c",
    "src/win/udp.c",
    "src/win/util.c",
    "src/win/winapi.c",
    "src/win/winsock.c",
};

const unix_src: []const []const u8 = &.{
    "src/unix/async.c",
    "src/unix/core.c",
    "src/unix/dl.c",
    "src/unix/fs.c",
    "src/unix/getaddrinfo.c",
    "src/unix/getnameinfo.c",
    "src/unix/internal.h",
    "src/unix/loop-watcher.c",
    "src/unix/loop.c",
    "src/unix/pipe.c",
    "src/unix/poll.c",
    "src/unix/process.c",
    "src/unix/random-devurandom.c",
    "src/unix/signal.c",
    "src/unix/stream.c",
    "src/unix/tcp.c",
    "src/unix/thread.c",
    "src/unix/tty.c",
    "src/unix/udp.c",
};

const winnt_flags: []const []const u8 = &.{ "-std=gnu90", "-fvisibility=hidden", "-Wstrict-prototypes", "-Wextra", "-Wall", "-Wno-unused-parameter", "-fno-strict-aliasing" };
