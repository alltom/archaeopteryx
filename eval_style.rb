require 'lib/archaeopteryx'

$clock = Clock.new(170)
$mutation = L{|measure| 0 == (measure - 1) % 2}
$measures = 4

# @loop = Arkx.new(:clock => $clock, # rename Arkx to Loop
#                  :measures => $measures,
#                  :logging => false,
#                  :evil_timer_offset_wtf => 0.2,
#                  :generator => Rhythm.new(:drumfile => "db_drum_definition.rb",
#                                           :mutation => $mutation))
# @loop.go

@loop = ChucKArkx.new(:clock => $clock,
                      :logging => false,
                      :generator => Rhythm.new(:drumfile => "db_drum_definition.rb",
                                                :mutation => $mutation))
$clock.bpm = 60*4 # hack! make measures 1 "second" long
$measures = 1 # hack! ChucK will ask for one measure at a time
@loop.go
