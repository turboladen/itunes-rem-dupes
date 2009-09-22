#!/usr/bin/ruby

#------------------------------------------------------------------------------
# Version:      1
#------------------------------------------------------------------------------

require 'digest/md5'
require 'fileutils'
require 'logger'

#------------------------------------------------------------------------------
# SCRIPT SETTINGS:
#
# Set to use the default folder structure or not.
use_default_folders = false

# Set up directories to use
if use_default_folders == true
  # Use the current user's home folder (i.e. /Users/sloveless/)
  @itunes_base = ENV['HOME']+"/Music/iTunes/"
  @itunes_music = "#{@itunes_base}/iTunes Music/"
else
  #@itunes_base = "/Volumes/MEDIA/Music/"
  #@itunes_music = "#{@itunes_base}/iTunes/"
  @itunes_base = ENV['HOME']+"/tmp/iTunes test"
  @itunes_music = "#{@itunes_base}/iTunes Music/"
end 

# set log file
@log_file = ENV['HOME']+"/Desktop/itunes_rem_dupes_log.txt"

# choose to use "trash" or not
# enabling this means moving files to a local folder for review so the user
# can choose to delete after reviewing.
@use_trash = false
if @use_trash == true : @trash_base_dir = ENV['HOME']+"/Music/iTunesTrash" end

# choose to auto-accept deletion.
# enabling this means that instead of prompting to delete the list of found
# matches, the script will just accept, delete, and move to the next.
@auto_accept = true
#
# END SETTINGS
#------------------------------------------------------------------------------

# init logger
@logger = Logger.new(@log_file)

# init some global vars
@artist_dir = ""
@album_dir = ""
@matches = Hash.new

# Start by logging trash dir
puts "Trash dir: #{@trash_base_dir}"
@logger.debug "Trash dir: #{@trash_base_dir}"


# for each subdir (artist dir) in itunes dir...
Dir.chdir(@itunes_music)
puts "iTunes dir: #{Dir.pwd}"
@logger.debug "iTunes dir: #{Dir.pwd}"

#------------------------------------------------------------------------------
# method:     parse_artists_in
#------------------------------------------------------------------------------
def parse_artists_in itunes_music
  # Go through each artist
  Dir.foreach(itunes_music) do |artist_dir|
    # If '.' or '..' or some file, skip
    if artist_dir.eql? "." or artist_dir.eql? ".." or File.stat(artist_dir).file?
      next
    end
    
    # Get for later use with trash
    if @use_trash == true
      @artist_dir = artist_dir
    end
    
    # Format output
    80.times {print "#"}
    puts ""
    @logger.debug ""
    puts " Artist:          #{artist_dir}"
    @logger.debug " Artist:          #{artist_dir}"
    
    # Make sure to use the full path
    artist_dir = File.expand_path artist_dir
    
    # change to the artist dir
    Dir.chdir(artist_dir)
    puts " Artist dir:     #{Dir.pwd}"
    @logger.debug " Artist dir:     #{Dir.pwd}"

    # Check out the albums in this artist directory
    parse_albums_in artist_dir
    
    # change back to the itunes music dir
    Dir.chdir(itunes_music)
    80.times { print "#" }
    puts ""
    @logger.debug ""
  end
end

#------------------------------------------------------------------------------
# method:     parse_albums_in
#------------------------------------------------------------------------------
def parse_albums_in artist_dir
  # Go through each album
  Dir.foreach(artist_dir) do |album_dir|
    # If '.' or '..' or some file, skip
    if album_dir.eql? "." or album_dir.eql? ".." or File.stat(album_dir).file?
      next
    end
    
    # Get for later use with trash
    if @use_trash == true
      @album_dir = album_dir
    end
    
    # Format output
    80.times {print "-"}
    puts ""
    @logger.debug ""
    puts " Album:          #{album_dir}"
    @logger.debug " Album:          #{album_dir}"
    
    # Make sure we're using the full path
    album_dir = File.expand_path album_dir
    Dir.chdir album_dir
    puts " Album dir:      #{Dir.pwd}"
    @logger.debug " Album dir:      #{Dir.pwd}"
    
    # Check out songs in this album directory
    parse_songs_in album_dir
    
    # Go back to artist dir   to prep for next iteration
    Dir.chdir artist_dir
  end
end

#------------------------------------------------------------------------------
# method:     parse_song_in
#------------------------------------------------------------------------------
def parse_songs_in album_dir
  # hash to store song/md5sum pairs to
  songs = Hash.new
  # hash to store song matches
  tmp_matches = Array.new
  
  # Go through all songs and get md5sum
  Dir.foreach(album_dir) do |song|
    # If '.' or '..' or some directory, skip
    if song.eql? "." or song.eql? ".." or File.stat(song).directory? : next end
    
    # Get the md5sum for the file
    md5sum = Digest::MD5.file(song).hexdigest
    
    # Associate the song and md5sum
    songs["#{song}"] = md5sum
  end
  
  # Sort the songs
  songs = songs.sort
  
  # Print song list
  songs.each do |key,value|
    puts " Song:           #{key}"
    @logger.debug " Song:           #{key}"
  end
  
  songs_to_compare = songs
  
  # Compare songs in the album to find duplicates
  songs.each do |key, value|
    #puts " #{key} is #{value}"
    
    curr_song = key
    curr_hash = value
    
    # Compare current song to other songs in the directory
    latest_match = songs_to_compare.select do |key, value|
      # Skip if comparing the same song
      if key.eql? curr_song : next end
      
      # Skip if the song name (curr_key) is > the match found
      if curr_song.length > key.length : next end
      
      # Get values if they're the same as the song in question
      #puts "Comparing '#{curr_song}' to #{key}"
      
      # Check to see if the md5sums are the same
      value.eql? curr_hash
    end
    tmp_matches.push(latest_match)
    
  end
  
  # Print list of matches
  @matches = Hash[*tmp_matches.flatten]
  @matches = @matches.sort
  
  # Continue if no matches
  if @matches.empty?
  else 
    puts " Matches:"
    @logger.debug " Matches:"
    @matches.each do |key,value|
      puts "        #{key}"
      @logger.debug "       #{key}"
      #puts "#{curr_song} matches #{key}"
    end 
    puts ""
    @logger.debug ""
    
    # Check to make sure we want to go ahead with the deleting
    if proceed?
      if @use_trash == true
        # Create the trash dir if it doesn't exist
        if File.exists? @trash_base_dir
        else 
        # Trash dir already exists on disk
          puts "Making trash dir"
          @logger.debug "Making trash dir"
          Dir.mkdir @trash_base_dir
        end
        
        # Create the artist dir in the trash if it doesn't exist
        trash_artist_dir = @trash_base_dir + '/' + @artist_dir
        if File.exists? trash_artist_dir
        else 
          puts "Making artist dir in trash"
          @logger.debug "Making artist dir in trash"
          Dir.mkdir trash_artist_dir
        end
        
        # Create the album dir in the trash if it doesn't exist
        trash_album_dir = trash_artist_dir + '/' + @album_dir
        if File.exists? trash_album_dir
        else 
          puts "Making album dir in trash"
          @logger.debug "Making album dir in trash"
          Dir.mkdir trash_album_dir
        end
      elsif @use_trash == false 
      end
      
      # Delete/Trash the duplicates; key = song filename, value = hash
      @matches.each do |key, value|
        # Move to trash, if @use_trash is enabled 
        if @use_trash == true
          puts " Moving '#{key}' to '#{trash_album_dir}'..."
          @logger.debug " Moving '#{key}' to '#{trash_album_dir}'..."
          FileUtils.move(key,trash_album_dir)
        # Otherwise, delete the file
        else 
          puts " Deleting '#{key}'..."
          @logger.debug " Deleting '#{key}'..."
          File.delete(key)
        end
      end
    end
  end
end


def proceed?
  # If auto_accept was = true, immediately return, accepting to delete files
  if @auto_accept == true
    return true
  end
  
  valid_response = false
    
  # Make sure we get a response
  while valid_response == false
    if @use_trash == true
      puts "Trash these files?"
    else
      puts "Delete these files?"
    end
    $stdout.flush
    response = $stdin.gets
    exit if response == nil
    response.chomp!
  
    if response == 'y' or response == 'yes'
      return true
    elsif response == 'n' or response == 'no'
      puts "Quitting."
      return false
    elsif response == 'q' or response == 'quit'
      exit 0
    else
      $stderr.puts "Please answer 'yes', 'no' or 'quit'."
    end
  end
end

def make_trash_dirs
        puts "Making trash dir"
        @logger.debug "Making trash dir"
        Dir.mkdir @trash_base_dir
end

parse_artists_in @itunes_music