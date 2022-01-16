# CoreDEV-Engine

This is the repository for Friday Night Funkin': CoreDEV-Engine.

## Build instructions

First you need to install Haxe and HaxeFlixel.
1. [Install Haxe 4.1.5](https://haxe.org/download/version/4.1.5/) (Download 4.1.5 instead of 4.2.0 because 4.2.0 is not recommended at all and wont work on gits properly.)
2. [Install HaxeFlixel](https://haxeflixel.com/documentation/install-haxeflixel/) after downloading Haxe.

Second, you need to install the additional libraries, a fully updated list will be in `Project.xml` in the project root. Here's the list of libraries that you need to install:
```
flixel
flixel-addons
flixel-ui
hscript
newgrounds
```
Type `haxelib install [library]` for each of those libs, so like: `haxelib install newgrounds`.

You'll also need to install a couple things that involve Gits. To do this, you need to do a few things first.
1. Download [git-scm](https://git-scm.com/downloads). Works for Windows, Mac, and Linux, just select your build.
2. Follow instructions to install the application properly.
3. Run `haxelib git polymod https://github.com/larsiusprime/polymod.git` to install Polymod.
4. Run `haxelib git discord_rpc https://github.com/Aidan63/linc_discord-rpc` to install Discord RPC.

You should have everything ready for compiling the engine! Follow the guide below to continue!

At the moment, you can optionally fix the transition bug in songs with zoomed out cameras.
- Run `haxelib git flixel-addons https://github.com/HaxeFlixel/flixel-addons` in the terminal/command-prompt.

### Ignored files

ninjamuffin99 gitignored the API keys for the game, so that no one can nab them and post fake highscores on the leaderboards. But because of that the game
doesn't compile without it.

Just make a file in `/source` and call it `APIStuff.hx`, and copy paste this into it

```haxe
package;

class APIStuff
{
	public static var API:String = "";
	public static var EncKey:String = "";
}

```

and you should be good to go there.

### Compiling game

Once you have all those installed, it's pretty easy to compile the engine. You just need to run 'lime test html5 -debug' in the root of the project to build and run the HTML5 version.

To compile the engine on your desktop (Windows, Mac, Linux), you need to install Visual Studio Community 2019.
While installing VSC, don't click on any of the options to install workloads. Instead, go to the individual components tab and choose the following:
* MSVC v141 - VS 2017 C++ x64/x86 build tools
* MSVC v142 - VS 2019 C++ x64/x86 build tools
* Windows SDK (10.0.17763.0)
* C++ Profiling tools
* C++ CMake tools for windows
* C++ ATL for v142 build tools (x86 & x64)

It will took 7GB of your computer disk space, so make sure you have more than 7GB on your computer before installing those components.
The executables are located on export/ folder in the root of the project after it was compiled.

Once everything has done, have fun with the engine!

## Credits

CoreDEV-Engine
- [CoreDev](https://twitter.com/itz_core5570r) - Programmer of this engine, additional assets.

Codes
- Shadow Mario - Downscroll Codes, Custom songs and charts / mods folder, and health icon offsets
- RozeBud - KeyBinds menu codes cuz idk how to make custom keybinds lmao.
- KadeDev - Some of the note press calculations codes, and Story Menu Characters codes

Friday Night Funkin'
- [ninjamuffin99](https://twitter.com/ninja_muffin99) - Programmer
- [PhantomArcade3K](https://twitter.com/phantomarcade3k) - Art
- [Evilsk8r](https://twitter.com/evilsk8r) - Art
- [KawaiSprite](https://twitter.com/kawaisprite) - Musician
