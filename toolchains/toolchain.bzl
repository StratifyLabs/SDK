"""
Quick helper to set the toolchain
"""

def select_toolchain():
    return select({
        "toolchains//config:stratifyos": "toolchains//:arm-none-eabi",
        "config//os:macos": "toolchains//:cxx",
    });
