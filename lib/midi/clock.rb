# get singleton from std lib
module Archaeopteryx
  module Midi
    class Clock # < Singleton
      attr_reader :time
      def initialize
        @start = 0.0
        @time = 0.0
      end
      def tick
        @time += (1.0 / 16.0)
        @time
      end
    end
  end
end
