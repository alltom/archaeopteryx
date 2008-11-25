module Archaeopteryx
  class LiveChucK
    def initialize(options = {})
      @clock = options[:clock]
      @logging = options[:logging]

      begin
        require "osc"
      rescue LoadError
        puts "puts 'Could not load OSC library'" if @logging
        return
      end

      @osc = OSC::UDPSocket.new
      osc_send "/archaeopteryx/sync", "i", 0 # 0 meaningless
    end

    def play(midi_note, on_time = @clock.time)
      puts "@chuck.play(#{midi_note.to_code}, #{on_time})" if @logging
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
      return unless @osc
      @osc.send OSC::Message.new(address, types, *args), 0, "localhost", 5000
    end

    def to_code
      "LiveChucK.new(blahblah)"
    end
  end
end
