# SDK Creator

This can be used to create a new SDK.

- First download the compilers from ARM
- Rebuild libstdc++ with long-calls
- Package everything up

```sh
dotslasher --archive-executables=stratifyos-arm-none-eabi-11.3.1-windows-x86_64.tar.gz --manifest=dotslasher-windows.json --directory=windows/arm-gnu-toolchain-11.3.rel1-mingw-w64-i686-arm-none-eabi
dotslasher --archive-executables=stratifyos-arm-none-eabi-11.3.1-macos-x86_64.tar.gz --manifest=dotslasher.json --directory=macos
dotslasher --archive-executables=stratifyos-arm-none-eabi-11.3.1-linux-x86_64.tar.gz --manifest=dotslasher.json --directory=linux/arm-gnu-toolchain-11.3.rel1-x86_64-arm-none-eabi
dotslasher --archive-dotslashed=stratifyos-arm-none-eabi-11.3.1.zip --manifest=dotslasher.json --directory=macos --template=dotslasher-template
```

```sh
dotslash -- create-url-entry https://github.com/StratifyLabs/SDK/releases/download/v11.3.1/stratifyos-arm-none-eabi-11.3.1-linux-x86_64.tar.gz
dotslash -- create-url-entry https://github.com/StratifyLabs/SDK/releases/download/v11.3.1/stratifyos-arm-none-eabi-11.3.1-macos-x86_64.tar.gz
dotslash -- create-url-entry https://github.com/StratifyLabs/SDK/releases/download/v11.3.1/stratifyos-arm-none-eabi-11.3.1-windows-x86_64.tar.gz
```