# Sjöbo Mod

This is my attempt to make some sort of a game/mod for Postal 2, 
I have no idea what I will be able to achieve here but let's wing it, I have some ideas. 

Just like it looked like they did when they developed their original game.

- [Sjöbo Mod](#sjöbo-mod)
  - [Requirements](#requirements)
  - [Setup](#setup)
  - [Getting started](#getting-started)
    - [First time](#first-time)
    - [Development](#development)
      - [Source](#source)
      - [Map Editing (POSTed)](#map-editing-posted)
      - [Testing (Postal 2)](#testing-postal-2)
  - [Packaging (For Steam Workshop)](#packaging-for-steam-workshop)
  - [Documentation](#documentation)
  - [Troubleshooting](#troubleshooting)
    - [Errors that aren't errors](#errors-that-arent-errors)
    - [I know that variable/function/class exists !](#i-know-that-variablefunctionclass-exists-)


## Requirements
* **Windows**
* **GIT** (duh)
* **VSCode**
* **NodeJS** (just for launch and tasks)
* **Steam**
* **Postal2**
* **Postal2Editor** (a.k.a. **POSTed**)


## Setup
Install **Postal 2** and **Postal 2 Editor** via **Steam** before proceeding.

Browse to **Steam\steamapps\common\POSTAL2Editor**
and extract all of **POSTAL 2 UnrealScript Source.zip** into the **POSTAL2Editor** (_the one your currently browsed into, so Postal2Editor will get tons of extra folders_)

Now when everything is installed do a **git clone** of this repository in
**Steam\steamapps\common\POSTAL2Editor** so it creates a **SjoboMod** folder.


## Getting started
To get started with the development and testing, just open the **SjoboMod** repository in **VSCode**, 
it should suggest or automatically open the workspace saved in the **.vscode** folder, and if it does not then you have to open it manually.

It's needed for the Intellisense (auto completion to work)

It's also highly recommended that you install the recommended VSCode extensions provided with the Workspace, 
it will aid with auto completion and working with this repository in general.

### First time
If you just cloned this repository and haven't done this step before, then you should run the "**Setup**" VSCode task,
it will copy some System files from the parent directory and put it into this repository System folder.

Or else **POSTed.exe** and **ucc.exe** won't work properly with this source. 


### Development
Basically you find a base class from the Parent workspace, extend it and add custom logic to it, 
sounds easy, but their codebase is definetly not straight forward, but atleast they have hillarious comments in it.


#### Source
All our classes should be put into **SjoboMod/Classes** and only here.

Mostly all coding you do will involve extending an already existing class or base class from the **Parent** workspace.

And the documentation you will find online is either on Unreal Script or reading the comments of some forum.
I will provide some [links](#documentation) that might aid in understanding how to get started.


#### Map Editing (POSTed)
Run launch task "**Launch POSTed**" and it will start POSTed (Unreal Editor)

Keep in mind that the editor is laggy as hell (atleast for me on an High End PC) and it likes to crash, so save often.

It usually crashes on errors, so if it crashes, try one more time doing what you did, if it crashes again, find alternative way around it.


#### Testing (Postal 2)
Run launch task "**Launch Postal 2**" and it will start Postal 2 in windowed mode with a log window deattached.


## Packaging (For Steam Workshop)
TBD, and will also create a template repository once I've reached a good finish on this one, for you to use in your own gamemode.


## Documentation
- [Postal 2 Source Code on Github](https://github.com/Kizoky/p2unrealscript)
- [Unreal Script Documentation](https://beyondunrealwiki.github.io/)
- [Some OK tutorials to get started](https://www.moddb.com/games/postal-2/tutorials)
- [Postal 2 Modding on Postal Fandom](https://postal.fandom.com/wiki/POSTAL2_Modding)

## Troubleshooting
Here's a troubleshooting section that I expect to grow.

### Errors that aren't errors
While you code you might stumble upon variable names and properties of object being red marked by the language service,
I haven't figured out how to solve it yet, but once you start recognize them one can learn to ignore them.

The compiler is the ultimate truth, even tho that truth might be very small and not so describing, but it's most likely because of what you did, so undo.

### I know that variable/function/class exists !
The Intellisense sometimes shows something as non existing, but that is mostly due to Parent directory not being indexed.

The only way I've found to solve this is to **CTRL + Left Click** on then name and hope that VSCode finds it after some slow indexing, and if that fails
I usually ends up searching for the file and opens it in the editor, that forces VSCode to index the base class, and usually then it also indexes the
other classes aswell, but yeah this quite annoying.
