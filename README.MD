# AltMastery - Repeatable Tasks & Milestones Management

**AltMastery** is a flexible tool designed to help manage repeatable tasks, track long-time progress towards milestones and reach personal goals of many kinds.  In other words, if you're looking for an addon to check off your daily TODO list - this is it.

It aims to be highly configurable and most importantly, automatic, allowing you to spend more time playing the game and achieving things rather than reserving mental capacities for and waste time on managing the organizational aspects of your ingame activities.

This is especially helpful for players with multiple alts (hence the name), but there's many ways to benefit from proper planning of your day-to-day for even just one character. If you're addicted to checking off boxes, chasing goals, and completing things you'll have much more freedom to do just that... *and aren't we all?* ;)

## Features

The addon comes with three key features you should understand in order to use it efficiently. This basic design helps to keep things relatively simple and intuitive, but nevertheless having an idea of how to use each feature properly will allow you to adapt its functionality to your needs more easily.

Please understand that this document can only provide a brief overview. For a detailed list and explanation on how to use the more advanced features, feel free to browse the [Wiki](https://github.com/SacredDuckwhale/AltMastery/wiki) (currently <del>a work-in-progress</del> just a stub, so there's no point in checking out it yet).

**Note: As the addon is still in the early phases of development, not all features are fully implemented yet! I decided to leave the design blueprint in here so everyone could give feedback and see what I've planned for the future. Features that aren't fully implemented yet are marked with a (NYI) tag for the time being.**

### Groups

Groups are the main structure used to organize your Tasks and Milestones. They can contain Tasks or other Groups, which means you get to customize the layout of your character's TODO lists in whichever way suits you best. A few of the things you can do with them are:

* Create, edit, delete and move Groups around easily without affecting the Tasks themselves **(NYI: The GUI frontend to do this is currently in planning, but you can use the predefined lists)**
* Assign Groups to characters to have them become the "active" list, and start tracking the referenced Tasks in it **(NYI: The active list is stored account-wide for now)**
* Import and export Groups to easily copy them or create alternative versions for multiple characters (*Note: Does not copy the Tasks themselves, so if you want to share your custom groups with others you will have to export any task not part of the default list separately for them to add to their database*) **(NYI: Exporting will be added after custom Tasks and Groups can be created)**
* Order tasks by priority, or manually if you prefer **(NYI: This will be added as soon as the initial bugtesting phases are over)**

It should be said that Tasks and Groups are independent of each other; this means that Groups are used to *organize* tasks but they don't actually *contain* them. You can think of it more like containing a reference, so that Groups can be changed repeatedly and Tasks will not be deleted and can be re-used without difficulty, though they also need to be managed separately.

This extra step may seem unnecessary, but it makes restructuring Groups quite fast and responsive. It also enables you to add tasks you don't necessarily want to track *right now*, as they're stored in their own database and will be available for importing into groups whenever you wish to use them.

### Tasks

Tasks are exactly what the name implies - some action you want to do or a goal you are trying to achieve, with Milestones being simply Tasks that track non-repeatable Criteria for each character. They may be organized in Groups and will be tracked and shown according to their respective Criteria. Some basic use cases:

* Create, edit, delete and assign predefined or custom Tasks that can be used by any character **(NYI: You can add custom Tasks via the Saved Variables, but it's not exactly user-friendly until the GUI is finished)**
* Complete tasks manually (overriding their autocompletion criteria) if you'd rather handle things on your own, or the task isn't an actual ingame-activity, or difficult/impossible to check for ingame **(NYI)**
* Dismiss Tasks (temporarily) if you don't feel like doing them *right now*, hiding them for a previously defined amount of time, or until a previously defined event takes place, even if they're not yet completed
* Disable Tasks, which hides them from the active Group without actually removing their reference. They'll be right there when you chose to re-enable them
* Add sequences of criteria: Tasks may contain a list of steps needed for completion, which can be tracked individually (though for simplicity's sake they aren't Tasks themselves). These are not actually required for a task to complete, but they can track requirements and break down tasks into more manageable chunks
* Track completions and display statistics to see which tasks are frequently skipped, or to measure your own diligence should you so choose **(NYI: This is not exactly important and so I haven't started work on it yet)**
* Import and export Tasks to share or modify them with little overhead (*Note: The tasks are de-coupled from any Groups that may contain them, but after custom tasks have been added to the database they will show up in Groups that they were referenced in as expected*)

Naturally, not all tasks need to be tracked - they're more like a menu of things you *could* track, from which you select those that you need to create your very own, delicious meals (the Groups).

If none are to your liking, you can always create new and custom solutions to track almost anything imaginable - even if it isn't supported out-of-the-box. Feel free to experiment!

### Criteria

Critera are, simply put, conditions that need to be met before a group/task is being shown/hidden or (automatically) completed. They can consist of actual Lua code if you like to get fancy, but there are also numerous shortcuts and aliases installed for the most common tasks you might want to track, so that using them becomes fairly straight-forward.

Some currently implemented shortcuts <del>(see Wiki for usage)</del>:

* Quest: Used for (repeatable) quests, rare mobs, bonus rolls, and a variety of other things
* Class: Checks if the player's class matches
* Level: Allows to filter Criteria by level
* Achievement: Tracks <del>(guild)</del> achievements and Feats of Strength
* Profession: Can be used to determine the player's skill level for a given profession
* WorldEvent: Used to see if a given holiday or world event is currently active
* EventBoss: Used to check if a given event boss (for holidays/world event) has been defeated yet
* InventoryItem: Scans the player's inventory for a given item
* Currency: Allows access to any currency in the game
* BonusRolls: Counts the number of obtained bonus rolls for the week (only for those that are limited currencies)
* WorldQuest: Checks availability of a given world quest
* Buff: Scans for a given spell (buff)

There are also meta-shortcuts, which allow interaction with the Tasks and Groups themselves:
* Objectives: Detects whether or not all Objectives for a given Task are completed
* NumObjectives: Refers to the number of completed objectives for a given Task

More shortcuts will be added as they become necessary, such as:
* Reputation: Tracks reputation with a given faction
* Instance: (Dungeon / Raid / ChallengeMode?) ?
* MythicPlus: Highest M+ level run for the week?
* Item: (EquippedItem / InventoryItem) ?
* Follower: (GarrisonFollower / OrderHallFollower) ?
* Profession: (ProfessionSkill / ProfessionCooldown / ProfessionRecipe)
* Mount
* Pet
* GarrisonBuilding
* OrderHallTalent
* WorkOrder (also used for Legion AutoComplete cooldown)
* Currency
* Gold
* Zone

Custom shortcuts are easily implemented; you can usually do it yourself **(NYI: Will have to be done manually for now,a s there's no GUI for it yet)**. I am, however, open to adding something to the default criteria shipped with the addon if it makes sense. Just let me know if you think that something generally useful to most people is missing!

### Slash Commands

<List of commands>

Most things can easily be done using nothing but the provided Configuration interface (see below).

### Keybinds

You may set a keybind to toggle the Tracker window for your convenience. This is found in the default Blizzard keybinding settings under Addons > AltMastery

### Configuration GUI

The configuration GUI is implemented. However, there aren't too many settings at this point.

## Issues / Feature Requests

While I try to monitor the comments on this page, I don't always get notified of them. Therefore, I kindly ask you to use the [Issue Tracker](https://wow.curseforge.com/projects/altmastery/issues) on the Project Site when appropriate (You can use the same Curse account you use to comment here for that).

Alternatively, you can follow the addon's development on [GitHub](https://github.com/SacredDuckwhale/AltMastery), where a list of [Known Issues](https://github.com/SacredDuckwhale/AltMastery/issues) is available. The [Project Timeline](https://github.com/SacredDuckwhale/AltMastery/projects/1) allows you to see what is currently being worked on and when you can expect any given change to be implemented.

## Localization

Localization will be added once the addon is ready for public distribution. There is little point in translating phrases while everything is still changing on a very frequent basis.