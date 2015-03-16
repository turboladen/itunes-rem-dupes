# Introduction #

---

As this script is really only just that--a script--you might require a little direction pointing to figure out how to get mileage out of it.  This page shows you what you'll need to do to get moving and cleaning up that library.


# Getting Started #

---

Currently, there isn't much of a user interface (read: there isn't any), so in order to set your options correctly, you'll need to edit the script before executing.  This section gives an overview of how to get started.

## Before Using ##
_Ruby._  As this is a basic Ruby script, you'll need to have Ruby installed to get anywhere with this.  If you're on a Mac, you're probably good to go if you're running Leopard or Snow Leopard; if you're on Windows, you'll probably need to get Ruby from [here](http://www.ruby-lang.org).  This script was written with version 1.8.7.

## Running the Script ##
While you shouldn't try to run it before you edit it, all you'll need to do to run is:
```
sl-mbp$ ruby itunes_rem_dupes.rb
```
...and you're off and running.

## Prepping the Script ##
Before running the script, you should check to make sure that it will do the stuff that you need it to do.  Here are the things you'll need to edit before running.

# Script Settings #

---

**Note:** Versions > 1 have a ` use_default_folders ` setting that they can set to 'true', which will allow users that are using default locations for their iTunes folders to not have to bother with setting up the following.

## iTunes Base Directory ##
The script needs to know what the root of your iTunes folder is.  On OSX, the default is ~/Music/iTunes/, where your contents look something like:
```
+iTunes
|
+-+/Album Artwork/
|
+--iTunes Library
|
+--iTunes Library Extras.itdb
|
+--iTunes Library Genius.itdb
|
+-+/iTunes Music/
|
+--iTunes Music Library.xml
```

Open the script for editing and look for ` @itunes_base ` in the _SCRIPT SETTINGS_ section.  If you're using the default iTunes location, make sure this line looks like:
```
@itunes_base = ENV['HOME']+"/Music/iTunes/" 
```

I keep my songs on an external HDD, in a directory called Music so the above doesn't work for me.  For my external HDD named "MEDIA", I set this to:
```
@itunes_base ="/Volumes/MEDIA/Music/" 
```

## iTunes Music Directory ##
The script also needs to know where all your goods are--the music.  This folder usually lives inside the iTunes Base Directory that we just set, above (see the diagram above).  Open the script for editing and look for ` @itunes_music ` in the _SCRIPT SETTINGS_ section.  If you're using the default library settings, make sure this line looks like:
```
@itunes_music = "#{@itunes_base}/iTunes Music/"
```

Using my external HDD, I keep all of my music in a folder called "iTunes", and thus I use:
```
@itunes_music = "#{@itunes_base}/iTunes/"
```

## Logging ##
The script logs all activity to a file so you know what it did.  Change this to log to another location.  Default setting is to save to the current user's Desktop:
```
@log_file = ENV['HOME']+"/Desktop/itunes_rem_dupes_log.txt"
```

## Trash ##
The script offers a "trash" feature which moves duplicate files to a pre-defined directory, so you don't have to commit to deleting your files right away.  There are two settings available here:
  * ` @use_trash `
  * ` @trash_base_dir `

If ` @use_trash = true `, the script will (obviously) move duplicate files to the directory specified in ` @trash_base_dir `.  If set to false, the script will automatically delete the duplicate files (**Not working in Version 1**).

Set ` @trash_base_dir ` to the directory you want the script to move your duplicate files to when ` @use_trash = true `.  The script will create directories for [Artist](Artist.md)/[Album](Album.md) and put the duplicates in there to ensure you know where they came from.

## Auto-Accept ##
By default, the script will prompt you have it's found duplicates for any album, allowing you to skip deletion/trash if you want.  If you're sure you want to always delete/trash, you can set ` @auto_accept = true ` (**Not working in Version 1**).