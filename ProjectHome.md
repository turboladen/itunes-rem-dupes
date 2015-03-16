A simple Ruby script that uses md5summing to check for duplicate files in all Artist/Album folders in an iTunes library.  The initial problem I wanted to solve was where I ended up with song files:
  * 01 Song.mp3
  * 01 Song 1.mp3

This script uses md5sums to compare the two to make sure they're the same, then gives you the option to delete the '01 Song 1.mp3' file.  Actually, it does this for all song files in all album folders in your library.

For more, check out the [Intro](Intro.md) page.

---

**Note:** Currently, this script doesn't remove the songs from the iTunes library, just the file on disk.  Also, this has only been tested on OSX 10.6.1 with Ruby 1.8.7, although Win support may come soon.


---

Requires:
  * Ruby 1.8.7