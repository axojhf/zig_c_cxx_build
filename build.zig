const std = @import("std");
const Allocator = std.mem.Allocator;

pub fn build(b: *std.Build) !void {
    const target: std.zig.CrossTarget = .{
        .os_tag = .windows,
        .abi = .gnu,
    };
    const optimize = b.standardOptimizeOption(.{});

    const shared = b.option(bool, "Shared", "Build Shared Library [default: false]") orelse false;
    const tests = b.option(bool, "Tests", "Build Tests [default: false]") orelse false;
    const CAPSTONE_BUILD_DIET = b.option(bool, "CAPSTONE_BUILD_DIET", "Build diet library [default: false]") orelse false;
    const CAPSTONE_USE_DEFAULT_ALLOC = b.option(bool, "CAPSTONE_USE_DEFAULT_ALLOC", "Use default memory allocation functions [default: true]") orelse true;
    const CAPSTONE_X86_REDUCE = b.option(bool, "CAPSTONE_X86_REDUCE", "x86 with reduce instruction sets to minimize library [default: false]") orelse false;
    const CAPSTONE_X86_ATT_DISABLE = b.option(bool, "CAPSTONE_X86_ATT_DISABLE", "Disable AT&T syntax for X86 [default: false]") orelse false;
    const CAPSTONE_DEBUG = b.option(bool, "CAPSTONE_DEBUG", "Whether to enable extra debug assertions [default: false]") orelse false;
    const lib = if (shared)
        b.addSharedLibrary(.{
            .name = "capstone",
            .optimize = optimize,
            .target = target,
            .version = .{
                .major = 5,
                .minor = 0,
                .patch = 0,
            },
        })
    else
        b.addStaticLibrary(.{
            .name = "capstone",
            .optimize = optimize,
            .target = target,
        });
    lib.want_lto = false;
    lib.disable_sanitize_c = true;
    if (optimize == .Debug or optimize == .ReleaseSafe)
        lib.bundle_compiler_rt = true
    else
        lib.strip = true;

    if (CAPSTONE_BUILD_DIET) {
        lib.defineCMacro("CAPSTONE_DIET", "");
    } else {
        lib.addCSourceFile("arch/X86/X86ATTInstPrinter.c", compile_flags);
    }
    if (CAPSTONE_USE_DEFAULT_ALLOC) {
        lib.defineCMacro("CAPSTONE_USE_SYS_DYN_MEM", "");
    }
    if (CAPSTONE_X86_REDUCE) {
        lib.defineCMacro("CAPSTONE_X86_REDUCE", "");
    }
    if (CAPSTONE_X86_ATT_DISABLE) {
        lib.defineCMacro("CAPSTONE_X86_ATT_DISABLE", "");
    }
    if (CAPSTONE_DEBUG) {
        lib.defineCMacro("CAPSTONE_DEBUG", "");
    }

    comptime var CMacro0: [supportedArchitectures.len][]const u8 = .{};
    comptime var CMacro1: [supportedArchitectures.len][]const u8 = .{};
    comptime {
        for (supportedArchitectures, 0..) |v, i| {
            CMacro0[i] = "CAPSTONE_" ++ v ++ "_SUPPORT";
            CMacro1[i] = "CAPSTONE_HAS_" ++ v;
        }
    }
    for (CMacro0) |v| {
        lib.defineCMacro(v, "");
    }
    for (CMacro1) |v| {
        lib.defineCMacro(v, "");
    }
    lib.addCSourceFiles(SOURCES_ENGINE, compile_flags);
    lib.addCSourceFiles(SOURCES_ARM, compile_flags);
    lib.addCSourceFiles(SOURCES_ARM64, compile_flags);
    lib.addCSourceFiles(SOURCES_MIPS, compile_flags);
    lib.addCSourceFiles(SOURCES_PPC, compile_flags);
    lib.addCSourceFiles(SOURCES_X86, compile_flags);
    lib.addCSourceFiles(SOURCE_SPARC, compile_flags);
    lib.addCSourceFiles(SOURCES_SYSZ, compile_flags);
    lib.addCSourceFiles(SOURCES_XCORE, compile_flags);
    lib.addCSourceFiles(SOURCES_M68K, compile_flags);
    lib.addCSourceFiles(SOURCES_TMS320C64X, compile_flags);
    lib.addCSourceFiles(SOURCES_M680X, compile_flags);
    lib.addCSourceFiles(SOURCES_EVM, compile_flags);
    lib.addCSourceFiles(SOURCES_WASM, compile_flags);
    lib.addCSourceFiles(SOURCES_MOS65XX, compile_flags);
    lib.addCSourceFiles(SOURCES_BPF, compile_flags);
    lib.addCSourceFiles(SOURCES_RISCV, compile_flags);
    lib.addCSourceFiles(SOURCES_SH, compile_flags);
    lib.addCSourceFiles(SOURCES_TRICORE, compile_flags);

    lib.addIncludePath(HEADERS_ENGINE);
    lib.addIncludePath(HEADERS_COMMON);
    lib.addIncludePath(HEADERS_ARM);
    lib.addIncludePath(HEADERS_ARM64);
    lib.addIncludePath(HEADERS_MIPS);
    lib.addIncludePath(HEADERS_PPC);
    lib.addIncludePath(HEADERS_X86);
    lib.addIncludePath(HEADERS_SPARC);
    lib.addIncludePath(HEADERS_SYSZ);
    lib.addIncludePath(HEADERS_XCORE);
    lib.addIncludePath(HEADERS_M68K);
    lib.addIncludePath(HEADERS_TMS320C64X);
    lib.addIncludePath(HEADERS_M680X);
    lib.addIncludePath(HEADERS_EVM);
    lib.addIncludePath(HEADERS_WASM);
    lib.addIncludePath(HEADERS_MOS65XX);
    lib.addIncludePath(HEADERS_BPF);
    lib.addIncludePath(HEADERS_RISCV);
    lib.addIncludePath(HEADERS_SH);
    lib.addIncludePath(HEADERS_TRICORE);
    lib.addIncludePath("include");
    lib.linkLibC();
    b.installArtifact(lib);
    lib.installHeadersDirectory("include", "");

    if (tests) {}
}

const supportedArchitectures: []const []const u8 = &.{ "ARM", "ARM64", "M68K", "MIPS", "PPC", "SPARC", "SYSZ", "XCORE", "X86", "TMS320C64X", "M680X", "EVM", "MOS65XX", "WASM", "BPF", "RISCV", "SH", "TRICORE" };
const supportedArchitectureLabels: []const []const u8 = &.{ "ARM", "ARM64", "M68K", "MIPS", "PowerPC", "Sparc", "SystemZ", "XCore", "x86", "TMS320C64x", "M680x", "EVM", "MOS65XX", "WASM", "BPF", "RISCV", "SH", "TriCore" };

const compile_flags: []const []const u8 = &.{
    "-Wunused-function",
    "-Warray-bounds",
    "-Wunused-variable",
    "-Wparentheses",
    "-Wint-in-bool-context",
};

const SOURCES_ENGINE: []const []const u8 = &.{
    "cs.c",
    "MCInst.c",
    "MCInstrDesc.c",
    "MCRegisterInfo.c",
    "SStream.c",
    "utils.c",
};

const HEADERS_ENGINE: []const u8 = "./";
const HEADERS_COMMON: []const u8 = "include/capstone/";

const SOURCES_ARM: []const []const u8 = &.{
    "arch/ARM/ARMDisassembler.c",
    "arch/ARM/ARMInstPrinter.c",
    "arch/ARM/ARMMapping.c",
    "arch/ARM/ARMModule.c",
};

const HEADERS_ARM: []const u8 = "arch/ARM/";

const SOURCES_ARM64: []const []const u8 = &.{
    "arch/AArch64/AArch64BaseInfo.c",
    "arch/AArch64/AArch64Disassembler.c",
    "arch/AArch64/AArch64InstPrinter.c",
    "arch/AArch64/AArch64Mapping.c",
    "arch/AArch64/AArch64Module.c",
};

const HEADERS_ARM64: []const u8 = "arch/AArch64/";

const SOURCES_MIPS: []const []const u8 = &.{
    "arch/Mips/MipsDisassembler.c",
    "arch/Mips/MipsInstPrinter.c",
    "arch/Mips/MipsMapping.c",
    "arch/Mips/MipsModule.c",
};

const HEADERS_MIPS: []const u8 = "arch/Mips/";

const SOURCES_PPC: []const []const u8 = &.{
    "arch/PowerPC/PPCDisassembler.c",
    "arch/PowerPC/PPCInstPrinter.c",
    "arch/PowerPC/PPCMapping.c",
    "arch/PowerPC/PPCModule.c",
};

const HEADERS_PPC: []const u8 = "arch/PowerPC/";

const SOURCES_X86: []const []const u8 = &.{
    "arch/X86/X86Disassembler.c",
    "arch/X86/X86DisassemblerDecoder.c",
    "arch/X86/X86IntelInstPrinter.c",
    "arch/X86/X86InstPrinterCommon.c",
    "arch/X86/X86Mapping.c",
    "arch/X86/X86Module.c",
};

const HEADERS_X86: []const u8 = "arch/X86/";

const SOURCE_SPARC: []const []const u8 = &.{
    "arch/Sparc/SparcDisassembler.c",
    "arch/Sparc/SparcInstPrinter.c",
    "arch/Sparc/SparcMapping.c",
    "arch/Sparc/SparcModule.c",
};

const HEADERS_SPARC: []const u8 = "arch/Sparc/";

const SOURCES_SYSZ: []const []const u8 = &.{
    "arch/SystemZ/SystemZDisassembler.c",
    "arch/SystemZ/SystemZInstPrinter.c",
    "arch/SystemZ/SystemZMapping.c",
    "arch/SystemZ/SystemZModule.c",
    "arch/SystemZ/SystemZMCTargetDesc.c",
};

const HEADERS_SYSZ: []const u8 = "arch/SystemZ/";

const SOURCES_XCORE: []const []const u8 = &.{
    "arch/XCore/XCoreDisassembler.c",
    "arch/XCore/XCoreInstPrinter.c",
    "arch/XCore/XCoreMapping.c",
    "arch/XCore/XCoreModule.c",
};

const HEADERS_XCORE: []const u8 = "arch/XCore/";

const SOURCES_M68K: []const []const u8 = &.{
    "arch/M68k/M68kDisassembler.c",
    "arch/M68k/M68kInstPrinter.c",
    "arch/M68k/M68kModule.c",
};

const HEADERS_M68K: []const u8 = "arch/M68k/";

const SOURCES_TMS320C64X: []const []const u8 = &.{
    "arch/TMS320C64x/TMS320C64xDisassembler.c",
    "arch/TMS320C64x/TMS320C64xInstPrinter.c",
    "arch/TMS320C64x/TMS320C64xMapping.c",
    "arch/TMS320C64x/TMS320C64xModule.c",
};

const HEADERS_TMS320C64X: []const u8 = "arch/TMS320C64x/";

const SOURCES_M680X: []const []const u8 = &.{
    "arch/M680x/M680xDisassembler.c",
    "arch/M680x/M680xInstPrinter.c",
    "arch/M680x/M680xModule.c",
};

const HEADERS_M680X: []const u8 = "arch/M680x/";

const SOURCES_EVM: []const []const u8 = &.{
    "arch/EVM/EVMDisassembler.c",
    "arch/EVM/EVMInstPrinter.c",
    "arch/EVM/EVMMapping.c",
    "arch/EVM/EVMModule.c",
};

const HEADERS_EVM: []const u8 = "arch/EVM/";

const SOURCES_WASM: []const []const u8 = &.{
    "arch/Wasm/WasmDisassembler.c",
    "arch/Wasm/WasmInstPrinter.c",
    "arch/Wasm/WasmMapping.c",
    "arch/Wasm/WasmModule.c",
};

const HEADERS_WASM: []const u8 = "arch/Wasm/";

const SOURCES_MOS65XX: []const []const u8 = &.{
    "arch/MOS65XX/MOS65XXModule.c",
    "arch/MOS65XX/MOS65XXDisassembler.c",
};

const HEADERS_MOS65XX: []const u8 = "arch/MOS65XX/";

const SOURCES_BPF: []const []const u8 = &.{
    "arch/BPF/BPFDisassembler.c",
    "arch/BPF/BPFInstPrinter.c",
    "arch/BPF/BPFMapping.c",
    "arch/BPF/BPFModule.c",
};

const HEADERS_BPF: []const u8 = "arch/BPF/";

const SOURCES_RISCV: []const []const u8 = &.{
    "arch/RISCV/RISCVDisassembler.c",
    "arch/RISCV/RISCVInstPrinter.c",
    "arch/RISCV/RISCVMapping.c",
    "arch/RISCV/RISCVModule.c",
};

const HEADERS_RISCV: []const u8 = "arch/RISCV/";

const SOURCES_SH: []const []const u8 = &.{
    "arch/SH/SHDisassembler.c",
    "arch/SH/SHInstPrinter.c",
    "arch/SH/SHModule.c",
};

const HEADERS_SH: []const u8 = "arch/SH/";

const SOURCES_TRICORE: []const []const u8 = &.{
    "arch/TriCore/TriCoreDisassembler.c",
    "arch/TriCore/TriCoreInstPrinter.c",
    "arch/TriCore/TriCoreMapping.c",
    "arch/TriCore/TriCoreModule.c",
};

const HEADERS_TRICORE: []const u8 = "arch/TriCore/";