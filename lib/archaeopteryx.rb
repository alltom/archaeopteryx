alias :L :lambda

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
   
   lib/pitches
   
   lib/infinite_stream
   lib/infinite_beats
   lib/feigenbaum
   lib/metacircular_evaluator

   lib/midi/note
   lib/midi/clock
   lib/live_chuck

   lib/midi/practical_ruby_projects/no_midi_destinations
   lib/midi/practical_ruby_projects/core_midi
   lib/midi/practical_ruby_projects/core_foundation
   lib/midi/practical_ruby_projects/live_midi
   lib/midi/practical_ruby_projects/timer}.each do |lib|
     require File.join(File.dirname(__FILE__), '../', lib)
     require "osc"
   end

[Archaeopteryx,
 Archaeopteryx::Midi,
 Archaeopteryx::Midi::PracticalRubyProjects].each {|constant| include constant}
