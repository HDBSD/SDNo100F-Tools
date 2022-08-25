
# SDNo100F-Tools

Lua tools for Scooby Doo! Night of 100 Frights. Intended to be used by speedrunners for practice, glitch hunters and TAS creators.

# Features

- Powerup Toggler
- Input Viewer
- Position Viewer
- In-Game Flying
- Level Select (From Main Menu Only!)
- Max HP Toggler
- Infinite iFrames

# How to Use

In order to use this tool you are required to use a custom version of dolphin specifically built for TAS creation called Dolphin Lua Core, you can find this below ;

[**Dolphin Lua Core**](https://github.com/SwareJonge/Dolphin-Lua-Core)

Once you have downloaded this build, you will need to place the contents of the latest release into the '/sys/scripts/' folder found inside your Dolphin Lua Core install folder, download link below;

[**Releases**](https://github.com/HDBSD/SDNo100F-Tools/releases/tag/Release)

Once the scripts have been installed, you will need to disable dual core support and idle skipping by right clicking the game in your game list, selecting Properties and unchecking 'Enable Dual Core ' and 'Enable Idle Skipping'.

![Open Properties](https://github.com/HDBSD/SDNo100F-Tools/raw/main/Images/dol1.png)

![Disabling options](https://github.com/HDBSD/SDNo100F-Tools/raw/main/Images/dol2.png)

Once the game has been started the script will automatically load, you can then press Z+X+RIGHT to enable the tool, which will place a '(M)' in the top left of Dolphin.

![Tool enabled](https://github.com/HDBSD/SDNo100F-Tools/raw/main/Images/dol3.png)

# Controls

*Due to a bug on the main menu, B and Y are reversed.*

| Control | Action | Notes |
|--|--| -- |
| Z+X+RIGHT | Enable/Disable the menu |  |
| LT+X+Y | Input Viewer | Shows Digital input on the left of the screen |
| Z+Y+LT | Show HIP File Selector | UP/Down=increment/decrement 1 place respectively<br> Right/Left=increment/decrement 10 place respectively<br>A/Start=Select level<br>B=Cancel selection |
| X+Y+Z | Show Powerup Menu | UP/Down=Navigate up and down menu<br>Left/Right=Toggle Powerup<br>A=Confirm Selection<br>B=Cancel Selection |
| A+X+Z | Show POS | Rounded to Places |
| A+X+RT | Lock Z Position | RT+X=Decrease Hight (Fast)<br>Z+X=Decrease Hight (Fine)<br>RT+Y=Increase Hight (Fast)<br>Z+Y=Increase Hight (Fine) |
| B+Z+UP | Infinite iFrames | Takes affect from when you take next damage |
| B+Z+Down | Restore health |  |

# Changing controls

Controls can be changed to any button combination of your choice by modifying the Mappings in *_SDNoOF_core.lua*

All buttons must be written in uppercase (i.e 'B', 'DOWN' or 'LT'), and must have a '+' between each button.
Modifying anything but button combos may stop this tool from working if you don't understand what you are doing.

Example bind shown below;

    inputSystem.registerAction("Z+RT+LT+X+Y", {name="InputDisplay", method=inputSystem.inputViewer, type="Toggle"})

# Issue Reporting/Feature request

Please make bug reports/feature requests using Githubs issue tracking [here](https://github.com/HDBSD/SDNo100F-Tools/issues).
