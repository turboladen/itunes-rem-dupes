# Introduction #

---

Initially, this script started off with the idea that I knew I'd migrated my iTunes library a number of times, and ended up with a number of duplicates.  At some point in my audio file collecting career, I switched to using iTunes on my Mac since WinAmp wasn't available, and started to really enjoy iTunes' ability to auto-manage my files.  As a result of moving files from server to desktop and back, I ended up with tons of duplicate song files in my song repo.  This script came about with the goal to free disk space used by those duplicate files, but may turn in to more.


# Details #

---

While iTunes does a fair job of organizing your song files, it only does an average job (if that) of keeping your library clean of duplicates.  Sure, it provides a way to show you your duplicates, but it's not a very intuitive interface for making sure you don't delete stuff that you want to keep.  I've also noticed that if you've run in to the case where you've got duplicates like:
  * 01 Song.mp3
  * 01 Song 1.mp3

...it's a bit of a pain to make sure you delete the '01 Song 1.mp3' file instead of the original file.  This probably isn't a big deal to most, but I get a little OCD with my organizing and really just want that original.

# How it works #

---

## Overview ##
The initial version of the script
  1. searches through each album folder
  1. creates an [md5sum](http://en.wikipedia.org/wiki/Md5sum) of each file
  1. compares each file's md5sum to every other file's md5sum in that album folder.  This ensures that regardless of the file's name, the songs really are the _exact_ same.
  1. makes a list of all files that are the same in that folder
  1. prompts you, asking you if you really want to delete/trash these duplicates
    1. If yes, it deletes/trashes them
    1. If no, it moves on to the next album folder until done

## Some Features Worth Mentioning ##
### Trash ###
I mentioned "trash" in the previous section for a reason.  Since we're talking about deleting precious music files, the script has an option to "trash" duplicate files.  All this really means is that if this option is turned on, instead of deleting the files, the script will move the duplicates to a pre-defined "trash" directory (which is configurable), thus allowing you to review your duplicates before choosing to delete them for good.  This option is **on** by default.

### Logging ###
Again, since we're talking about deleting data, you should have a clear idea of what activities the script performed during the course of execution.  The log file location is configurable and is set to the current user's **Desktop** folder.