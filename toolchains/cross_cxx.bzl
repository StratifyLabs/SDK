# Copyright (c) Meta Platforms, Inc. and affiliates.
#
# This source code is licensed under both the MIT license found in the
# LICENSE-MIT file in the root directory of this source tree and the Apache
# License, Version 2.0 found in the LICENSE-APACHE file in the root directory
# of this source tree.

"""
Cross Compiler Toolchain
"""

load(
    "@prelude//cxx:cxx_toolchain_types.bzl",
    "BinaryUtilitiesInfo",
    "CCompilerInfo",
    "CvtresCompilerInfo",
    "CxxCompilerInfo",
    "CxxPlatformInfo",
    "CxxToolchainInfo",
    "LinkerInfo",
    "PicBehavior",
    "RcCompilerInfo",
    "ShlibInterfacesMode",
)
load("@prelude//cxx:headers.bzl", "HeaderMode")
load("@prelude//cxx:linker.bzl", "is_pdb_generated")
load("@prelude//linking:link_info.bzl", "LinkOrdering", "LinkStyle")
load("@prelude//linking:lto.bzl", "LtoMode")

def _cross_cxx_toolchain_impl(ctx: AnalysisContext):
    """
    A very simple toolchain that is hardcoded to the current environment.
    """
    archiver_args = ctx.attrs.archiver_args
    archiver_type = "gnu"
    archiver_supports_argfiles = True
    asm_compiler = ctx.attrs.compiler
    asm_compiler_type = ctx.attrs.compiler_type
    compiler = ctx.attrs.compiler
    cxx_compiler = ctx.attrs.cxx_compiler
    cvtres_compiler = ctx.attrs.cvtres_compiler
    rc_compiler = ctx.attrs.rc_compiler
    linker = ctx.attrs.linker
    linker_type = "gnu"
    pic_behavior = PicBehavior("not_supported")
    binary_extension = ""
    object_file_extension = "o"
    static_library_extension = "a"
    shared_library_name_default_prefix = "lib"
    shared_library_name_format = "{}.so"
    shared_library_versioned_name_format = "{}.so.{}"
    additional_linker_flags = []
    if ctx.attrs.linker == "g++" or ctx.attrs.cxx_compiler == "g++":
        pass
    else:
        additional_linker_flags = ["-fuse-ld=lld"]

    if ctx.attrs.compiler_type == "clang":
        llvm_link = RunInfo(args = ["llvm-link"])
    else:
        llvm_link = None

    return [
        DefaultInfo(),
        CxxToolchainInfo(
            mk_comp_db = ctx.attrs.make_comp_db,
            linker_info = LinkerInfo(
                linker = RunInfo(args = linker),
                linker_flags = additional_linker_flags + ctx.attrs.link_flags,
                post_linker_flags = ctx.attrs.post_link_flags,
                archiver = RunInfo(args = archiver_args),
                archiver_type = archiver_type,
                archiver_supports_argfiles = archiver_supports_argfiles,
                generate_linker_maps = False,
                lto_mode = LtoMode("none"),
                type = linker_type,
                link_binaries_locally = True,
                archive_objects_locally = True,
                use_archiver_flags = True,
                static_dep_runtime_ld_flags = [],
                static_pic_dep_runtime_ld_flags = [],
                shared_dep_runtime_ld_flags = [],
                independent_shlib_interface_linker_flags = [],
                shlib_interfaces = ShlibInterfacesMode("disabled"),
                link_style = LinkStyle(ctx.attrs.link_style),
                link_weight = 1,
                binary_extension = binary_extension,
                object_file_extension = object_file_extension,
                shared_library_name_default_prefix = shared_library_name_default_prefix,
                shared_library_name_format = shared_library_name_format,
                shared_library_versioned_name_format = shared_library_versioned_name_format,
                static_library_extension = static_library_extension,
                force_full_hybrid_if_capable = False,
                is_pdb_generated = is_pdb_generated(linker_type, ctx.attrs.link_flags),
                link_ordering = ctx.attrs.link_ordering,
            ),
            bolt_enabled = False,
            binary_utilities_info = BinaryUtilitiesInfo(
                nm = RunInfo(args = ["nm"]),
                objcopy = RunInfo(args = ["objcopy"]),
                objdump = RunInfo(args = ["objdump"]),
                ranlib = RunInfo(args = ["ranlib"]),
                strip = RunInfo(args = ["strip"]),
                dwp = None,
                bolt_msdk = None,
            ),
            cxx_compiler_info = CxxCompilerInfo(
                compiler = RunInfo(args = [cxx_compiler]),
                preprocessor_flags = [],
                compiler_flags = ctx.attrs.cxx_flags,
                compiler_type = ctx.attrs.compiler_type,
            ),
            c_compiler_info = CCompilerInfo(
                compiler = RunInfo(args = [compiler]),
                preprocessor_flags = [],
                compiler_flags = ctx.attrs.c_flags,
                compiler_type = ctx.attrs.compiler_type,
            ),
            as_compiler_info = CCompilerInfo(
                compiler = RunInfo(args = [compiler]),
                compiler_type = ctx.attrs.compiler_type,
            ),
            asm_compiler_info = CCompilerInfo(
                compiler = RunInfo(args = [asm_compiler]),
                compiler_type = asm_compiler_type,
            ),
            cvtres_compiler_info = CvtresCompilerInfo(
                compiler = RunInfo(args = [cvtres_compiler]),
                preprocessor_flags = [],
                compiler_flags = ctx.attrs.cvtres_flags,
                compiler_type = ctx.attrs.compiler_type,
            ),
            rc_compiler_info = RcCompilerInfo(
                compiler = RunInfo(args = [rc_compiler]),
                preprocessor_flags = [],
                compiler_flags = ctx.attrs.rc_flags,
                compiler_type = ctx.attrs.compiler_type,
            ),
            header_mode = HeaderMode("symlink_tree_only"),
            cpp_dep_tracking_mode = ctx.attrs.cpp_dep_tracking_mode,
            pic_behavior = pic_behavior,
            llvm_link = llvm_link,
        ),
        CxxPlatformInfo(name = "x86_64"),
    ]

cross_cxx_toolchain = rule(
    impl = _cross_cxx_toolchain_impl,
    attrs = {
        "c_flags": attrs.list(attrs.string(), default = []),
        "archiver_args": attrs.list(attrs.string(), default = []),
        "compiler": attrs.string(default = "cl.exe" if host_info().os.is_windows else "clang"),
        "compiler_type": attrs.string(default = "windows" if host_info().os.is_windows else "clang"),  # one of CxxToolProviderType
        "cpp_dep_tracking_mode": attrs.string(default = "makefile"),
        "cvtres_compiler": attrs.string(default = "cvtres.exe"),
        "cvtres_flags": attrs.list(attrs.string(), default = []),
        "cxx_compiler": attrs.string(default = "cl.exe" if host_info().os.is_windows else "clang++"),
        "cxx_flags": attrs.list(attrs.string(), default = []),
        "link_flags": attrs.list(attrs.string(), default = []),
        "link_ordering": attrs.option(attrs.enum(LinkOrdering.values()), default = None),
        "link_style": attrs.string(default = "static"),
        "linker": attrs.string(default = "link.exe" if host_info().os.is_windows else "clang++"),
        "linker_wrapper": attrs.default_only(attrs.exec_dep(providers = [RunInfo], default = "prelude//cxx/tools:linker_wrapper")),
        "make_comp_db": attrs.default_only(attrs.exec_dep(providers = [RunInfo], default = "prelude//cxx/tools:make_comp_db")),
        "post_link_flags": attrs.list(attrs.string(), default = []),
        "rc_compiler": attrs.string(default = "rc.exe"),
        "rc_flags": attrs.list(attrs.string(), default = []),
    },
    is_toolchain_rule = True,
)