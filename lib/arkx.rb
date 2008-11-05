module Archaeopteryx
  class Arkx
    def initialize(attributes)
      @generator = attributes[:generator]
      # @measures = attributes[:measures] || 32
      @beats = attributes[:beats] || 16
      midi_destination = attributes[:midi_destination] || 0
      @evil_timer_offset_wtf = attributes[:evil_timer_offset_wtf]
      @chuck = LiveChucK.new(:clock => @clock = attributes[:clock], # confusion!!!!!!!!!!
                             :logging => attributes[:logging] || false,
                             :midi_destination => midi_destination)
    end
    def play(music)
      music.each {|note| @chuck.play(note)}
    end
    def osc_serve(&generate_beats)
      require "osc"
      osc = OSC::UDPServer.new
      osc.bind "localhost", 5001
      osc.add_method "/archaeopteryx/needbeats", "i", &generate_beats
      Thread.new { osc.serve }
    end
    def go
      generate_beats = L do
        puts "making beats"
        (1..$measures).each do |measure|
          @generator.mutate(measure)
          (0..(@beats - 1)).each do |beat|
            play @generator.notes(beat)
            @clock.tick
          end
        end
      end
      osc_serve &generate_beats
      gets
    end
  end
end
