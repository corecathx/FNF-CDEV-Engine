Mods folder, put your custom songs and charts here!

How to put your custom charts and songs to my engine?

1. Put your custom charting file to the "/cdev-mods/data/" folder.
2. Put your custom chart's song file into the "/cdev-mods/songs/" folder.
3. To make your custom song(s) shown in the Freeplay List,
   you need to type your song's name on the "/cdev-mods/modList.txt/" file.
4. Make sure that you're inputted your song's name like this:
   "songName:character:week"
      -songName = Your song's name (in the .json chart file)
      -character = The song's head icon to show in the Freeplay list
                   (the head icon will automatically set to the
                    placeholder icon if you put an not existing character name
		    since this engine still doesn't support custom
                    character yet)
      -week = the week folder that this song will use
5. After you do this steps, now you can play your custom songs!

//note//
in this version of CoreDEV-Engine, you currently only can put custom songs
and chart to the engine

i'm still learning how to making softcoded mod support to my engine.