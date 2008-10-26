module Archaeopteryx
  class LiveChucK
    def initialize(options = {})
      @clock = options[:clock]
      @logging = options[:logging]
      if @logging
        puts <<LOG_PLAYBACK
require 'lib/archaeopteryx'
@midi = #{self.to_code}
LOG_PLAYBACK
      end
      
      @osc = OSC::UDPSocket.new
      osc_send "/archaeopteryx/sync", "f", Time.now.to_f
    end

    def play(midi_note, on_time = @clock.time)
      if @logging
        puts "@chuck.play(#{midi_note.to_code}, #{on_time})"
      end
      note_on(on_time, midi_note)
      note_off(on_time + midi_note.duration, midi_note)
    end
    
    def note_on(time, note)
      osc_send "/archaeopteryx/noteon", "iiii", (time.to_f*1000).to_i, note.channel, note.number, note.velocity
    end
    
    def note_off(time, note)
      osc_send "/archaeopteryx/noteoff", "iii", (time.to_f*1000).to_i, note.channel, note.number
    end
    
    def osc_send(address, types, *args)
      puts "OSC: #{address} (#{types}): #{args.join(", ")}"
      @osc.send OSC::Message.new(address, types, *args), 0, "localhost", 5000
    end
    
    def to_code
      "LiveChucK.new(blahblah)"
    end
  end
end
