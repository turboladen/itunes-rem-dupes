#!/usr/bin/env ruby

require 'osx/cocoa'
require 'digest/md5'
require 'fileutils'

include OSX
OSX.require_framework 'ScriptingBridge'

class ITunesController < NSObject
    attr_reader :text_field, :show_version, :iTunes, :plists
    
    def initialize
      @iTunes = SBApplication.applicationWithBundleIdentifier:'com.apple.iTunes'
    end
    
    def show_version
        @text_field = "iTunes version: #{@iTunes.version}"
        puts @text_field
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
    
    #def playlists
    # @iTunes.sources.each do |source|
    #    puts source.name
    #    source.playlists.each do |playlist|
    #      puts " -> #{playlist.name}"
          #@plists.push playlist.name
    #    end
    #  end 
    #end
    
    #def find_duplicates(playlist, &do_delete)
    #  tracks = {}
    #
    #  playlist.tracks.each do |t|
    #     digest = Digest::MD5.hexdigest( [ t.name.downcase, 
    #                                       t.album.downcase, 
    #                                       t.artist.downcase,
    #                                       t.duration.to_s,
    #                                     ].join(':') )
    #     if tracks[digest]
    #        tracks[digest] << t
    #     else
    #        tracks[digest] = [t]
    #     end
    #  end
    
    #  tracks.each do |k,v|
    #     next if v.length < 2
    #     while v.length > 1 do
    #         track = v.pop
    #         puts track.location
    #         do_delete.call(track)
    #     end
    #  end
    #end
    
    def find_dead_tracks(playlist, &rem_dead_track)
      tracklist = {}
      
      playlist.fileTracks.each do |t|
        next if t.location != nil
        puts "Dead track:  #{t.databaseID}: #{t.artist}/#{t.album}/#{t.name}"
        tracklist[t.databaseID] = [t]
      end
      
      tracklist.each do |k,v|
          track = v.pop
          puts "Deleting dead track #{track.name}"
          rem_dead_track.call(track)
      end
    end
end

it_controller = ITunesController.new
playlist = ''
it_controller.iTunes.sources.each do |source|
  puts source.name
end

#it_controller.iTunes.sources[0].userPlaylists.each do |p|
#    puts "  playlist: #{p.name}"
#    p.fileTracks.each do |t|
#        puts "    #{t.name}: #{t.location.absoluteString}"
#    end
#end
plist_name = '80\'s Music'
opts = plist_name
#opts =''

if opts.size > 0
  it_controller.iTunes.sources[0].userPlaylists.each do |p|
    #next if p.name != opts[:p]
    next if p.name != opts[plist_name]
    puts "Playlist = #{p.name}"
    playlist = p
  end
#else
   # 'Library' -> 'Music'
# playlist = it_controller.iTunes.sources[0].playlists[0]
# puts "Playlist = #{playlist.name}"
end
#http://opensoul.org/2007/6/30/bending-itunes-to-my-will-with-rubyosa-take-1
it_controller.find_dead_tracks(playlist) do |track|
  location = track.location
  puts location
  #it_controller.iTunes.sources[0].userPlaylists.delete(track)
  #playlist.delete(track)
  #track.delete
  #it_controller.iTunes.sources[0].userPlaylists[0].delete(track)
  dbid = track.databaseID
  lib_track_ref = it_controller.iTunes.sources[0].libraryPlaylists[1].tracks[its.databaseID.eq(dbid)].first
end
#it_controller.find_duplicates( playlist) do |track|
  #do_delete
  #if opts[:y]
#     location = track.location
#     puts location
     #itunes.delete(track)
     #FileUtils.rm(location)
  #end
#end