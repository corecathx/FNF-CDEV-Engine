# Friday Night Funkin': CDEV Engine
![logo](art/CDEV-Engine-Logo.png)

FNF CDEV Engine is a Friday Night Funkin' Engine that's intended to fix issues with the base game, while also adding a lot of features to the engine.

## Build instructions

First you need to install Haxe and HaxeFlixel.
1. [Install Haxe 4.2.5](https://haxe.org/download/version/4.2.5/) (If you're using newer version of haxe, CDEV Engine would likely failed to compile due to macro stuffs)
2. [Install HaxeFlixel](https://haxeflixel.com/documentation/install-haxeflixel/) after downloading Haxe.

Second, you need to install the additional libraries, a fully updated list will be in `Project.xml` in the project root. Here's the list of libraries that you need to install:
```
flixel
flixel-addons
flixel-ui
hscript
hxCodec
extension-androidtools
HxWebView
```
Type `haxelib install [library]` for each the libraries, so like: `haxelib install newgrounds`.

There are also few libraries that you need to install using git.
1. Download [git-scm](https://git-scm.com/downloads). Works for Windows, Mac, and Linux, just select your build.
2. Follow instructions to install the application properly.
3. Run `haxelib git discord_rpc https://github.com/Aidan63/linc_discord-rpc` to install the library.
4. run `haxelib git flxanimate https://github.com/Core5570RYT/flxanimate-cdev.git` to install CDEV Engine version of FlxAnimate.

You should have everything ready for compiling the engine! Follow the guide below to continue!

### Compiling the engine

> For now, CDEV Engine supports compiling only to Windows.

To compile the engine to Windows Target, you need to install Visual Studio Community. While installing VSC, don't click on any of the options to install workloads. Instead, go to the "Individual Components" tab and choose the following:
* MSVC v143 - VS 2019 C++ x64/x86 build tools
* Windows SDK (10.0.17763.0)

Once you have finished doing all of those steps, you could run this command to build the engine.
> `lime test windows` or `lime test windows -debug` to run the game with debugging enabled.

Your compiled version of CDEV Engine are located under the `export` folder in the root of your project.

Now you know how to build the engine, enjoy!

## CDEV Engine Modding Docs
If you don't like modifying source codes, you might want to try the built-in modding feature, though you also need to read this page to understand how modding works in this engine:
> https://core5570ryt.github.io/FNF-CDEV-Engine/

## Source Code Modding!!
If you wanted to make mods without using the built-in modding support, Download the source code from the Releases tab or press [Here](https://github.com/Core5570RYT/FNF-CDEV-Engine/releases/latest)

## Supported Platforms
CDEV Engine is currently only supported for Windows target only (I don't understand how to do cross-platform support)

# Credits
CDEV Engine
- [CoreDev](https://twitter.com/core5570r) - Programmer of this engine, additional assets.

Special Thanks
- [PolybiusProxy](https://github.com/polybiusproxy) - MP4 Video Haxe Library (hxCodec).
- [SanicBTW](https://github.com/SanicBTW) - HxWebView Library.
- [CobaltBar](https://github.com/CobaltBar) - Colored Traces in terminal (game/cdev/log/Log.hx).

Engines that inspired CDEV Engine & Codes used in this engine
- [Codename Engine](https://github.com/FNF-CNE-Devs/CodenameEngine) - GPU Bitmap code.
- [Psych Engine](https://github.com/ShadowMario/FNF-PsychEngine) - Literally inspired CDEV Engine to have Modding Supports, and Chart Editor Waveform code.

Friday Night Funkin'
- [ninjamuffin99](https://twitter.com/ninja_muffin99) - Programmer
- [PhantomArcade3K](https://twitter.com/phantomarcade3k) - Art
- [Evilsk8r](https://twitter.com/evilsk8r) - Art
- [KawaiSprite](https://twitter.com/kawaisprite) - Musician
