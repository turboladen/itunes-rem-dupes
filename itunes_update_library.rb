#!/usr/bin/env ruby

require 'osx/cocoa'
require 'logger'
require 'rubygems'
require 'highline/import'
require 'pp'

include OSX
OSX.require_framework 'ScriptingBridge'

#------------------------------------------------------------------------------
# 
#------------------------------------------------------------------------------
class ITunesController < NSObject
  attr_reader :iTunes, :playlists, :sources, :tracks, :logger, :log_file
    
  def initialize
    # Get a handle to iTunes
    @iTunes = SBApplication.applicationWithBundleIdentifier:'com.apple.iTunes'
    @sources = []
    @playlists = []
    @tracks = []
    @dead_track_list = []
	  @log_file = ENV['HOME']+"/Desktop/itunes_update_library_log.txt"
    @logger = Logger.new @log_file
  end
    
  # Print the version of iTunes
  def show_version
    puts "iTunes version: #{@iTunes.version}"
    @logger.info "iTunes version: #{@iTunes.version}"
  end
  
  # Get a list of all possible iTunes sources
  def sources
    @iTunes.sources.each do |source|
      @sources << source
    end
  end
    
  #def tracks
  # @iTunes.sources.each do |source|
  #    puts source.name
  #    source.playlists.each do |playlist|
  #      puts " -> #{playlist.name}"
  #      playlist.tracks.each do |track|
  #        puts "      -> #{track.name}" if track.enabled?
  #      end
  #    end
  #  end 
  #end
  
  # Get list of all tracks
  def tracks source, playlist
		@iTunes.sources.each_with_index do |source,i|
		  #puts "iTunes source[#{i}]:    #{source.name}"
		  
		  source.userPlaylists.each_with_index do |playlist,j|
		    #puts "       playlist[#{j}]:    #{playlist.name}"
		    
		    playlist.fileTracks.each do |track|
		      #puts "#{track.enabled?}    #{track.name}: #{track.location}"
          tracks << track if track.enabled?
		    end
		  end
		end
  end
    
  #def playlists
  # @iTunes.sources.each do |source|
  #    puts source.name
  #    source.playlists.each do |playlist|
  #      puts " -> #{playlist.name}"
        #@plists.push playlist.name
  #    end
  #  end 
  #end
  
  # Get list of all playlists in a given source
  def playlists_in source
    source.userPlaylists.each do |playlist|
      @playlists << playlist
    end
  end
  
  # Find a playlist by its name
  def find_playlist_by_name name
    @playlists.each do |playlist|
      return playlist.index if name == playlist.name
    end
  end
  
  # Find all the tracks with an empty location (aka path)
  def find_dead_tracks playlist
    playlist.fileTracks.each do |track|
      next unless track.location == nil
      puts "Dead track:  #{track.databaseID}: #{track.artist}/#{track.album}/#{track.name}"
      @logger.info "Dead track:  #{track.databaseID}: #{track.artist}/#{track.album}/#{track.name}"
      #@dead_track_list << track
    end
    
    #return @dead_track_list
  end
  
  # Return the number of dead tracks
  def count_dead_tracks 
    @dead_track_list.length
  end
  
  # Remove tracks from the track_list from the iTunes database
  def rem_dead_tracks playlist
    begin
	    playlist.fileTracks.each do |track|
	      #puts "#{track.index}: #{track.location}"
	      next unless track.location == nil 
	      puts "Deleting dead track: #{track.artist} - #{track.album} - #{track.name}"
	      @logger.info "Deleting dead track: #{track.artist} - #{track.album} - #{track.name}"
	      track.delete
	    end
	  rescue Exception => e
      puts e.message
    end
  end
end



#------------------------------------------------------------------------------
# Start the action
#------------------------------------------------------------------------------
it_controller = ITunesController.new

# Print a list of all sources (aka libraries)
80.times {print "#"}
puts ""
puts "Listing iTunes sources and their playlists..."
it_controller.logger.info "Listing iTunes sources and their playlists..."


# For each playlist in the main Music source, find dead tracks
it_controller.playlists_in(it_controller.sources[0]).each do |playlist|
  puts "#{playlist.name}[#{playlist.index}]"
  it_controller.logger.info playlist.name
  #it_controller.find_dead_tracks playlist
end

pl_index = it_controller.find_playlist_by_name "Music"
pl_index -= 2
puts "Finding dead tracks in playlist: #{it_controller.playlists[pl_index].name}"
it_controller.logger.info "Finding dead tracks in playlist: #{it_controller.playlists[pl_index].name}"
track_list = it_controller.find_dead_tracks it_controller.playlists[pl_index]
#track_list.each {|track| puts track.location}

# Prompt the user to see the list of duplicate files
response = ask("Do you wish to see the list of duplicate files? [y/n]   ") do |q|
  q.validate = /y|n/
end
if response == 'y'
  system "open #{it_controller.log_file}"
end

# Prompt the user to delete the dupes or not
response = ask("Do you wish to remove all duplicate entries now? [y/n]   ") do |q|
  q.validate = /y|n/
end
if response == 'y'
  r = ask("Are you sure? [y/n]    ") {|q| q.validate = /y|n/}
  
  if r == 'y'
		# Delete all the tracks from the list
		it_controller.rem_dead_tracks it_controller.playlists[pl_index]
	else
    puts "Exiting."
    exit 0
	end
end

80.times {print "#"}
puts ""