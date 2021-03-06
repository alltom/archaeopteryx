alias :L :lambda

%w{rubygems platform osc}.each do |lib|
  require lib
end

%w{lib/core_ext/struct
   
   lib/arkx
   lib/drum
   lib/fx
   lib/rhythm
   lib/rhythm_without_eval
   lib/scale_traversal_rhythm
   lib/sequence
   lib/mix
   lib/bassline
   lib/timer
   
   lib/pitches
   
   lib/infinite_stream
   lib/infinite_beats
   lib/feigenbaum
   lib/metacircular_evaluator

   lib/midi/note
   lib/midi/clock

   lib/midi/live_midi
   lib/chuck/live_chuck
   lib/chuck/chuck_arkx
   }.each do |lib|
     require File.join(File.dirname(__FILE__), '../', lib)
     require "osc"
   end

[Archaeopteryx,
 Archaeopteryx::Midi].each {|constant| include constant}
