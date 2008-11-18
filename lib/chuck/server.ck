// initialize osc
OscRecv osc;
5000 => osc.port;
osc.listen();

// initialize midi
MidiOut midi;
if(!midi.open(Std.atoi(me.arg(0)))) {
  <<< "could not open MIDI device", Std.atoi(me.arg(0)) >>>;
  me.exit();
}

// make our Cyclone available to all shreds
public class Arkx {
  static Cyclone @ cyc;
}
Cyclone @ cyc;
new Cyclone @=> cyc @=> Arkx.cyc;

Event sync_event;

// sends a MIDI note at time t
fun void send(float beat, int control, int chan, int note, int vel) {
  cyc.waitfor(beat) => now; // lie and wait

  MidiMsg msg;
  control => msg.data1;
  note => msg.data2;
  vel => msg.data3;
  msg => midi.send;
  //<<< "midi: ", chan, note, vel >>>;
}

// listens for note-on schedulings
fun void listen_on() {
  osc.event( "/archaeopteryx/noteon, iiii" ) @=> OscEvent ev;
  while(ev => now) {
    while( ev.nextMsg() != 0 ) {
      ev.getInt()/1000. => float beat;
      ev.getInt() => int chan;
      ev.getInt() => int note;
      ev.getInt() => int vel;
      //<<< "osc note-on:", beat, chan, note, vel >>>;
      spork ~ send(beat, 0x90, chan, note, vel);
    }
  }
}

// listens for note-off schedulings
fun void listen_off() {
  osc.event( "/archaeopteryx/noteoff, iii" ) @=> OscEvent ev;
  while(ev => now) {
    while( ev.nextMsg() != 0 ) {
      ev.getInt()/1000. => float beat;
      ev.getInt() => int chan;
      ev.getInt() => int note;
      //<<< "osc note-off:", t, chan, note >>>;
      spork ~ send(beat, 0x80, chan, note, 0);
    }
  }
}

// asks for beats just before the start of every period
fun void ask_beats() {
  OscSend xmit;
  xmit.setHost("localhost", 5001);
  xmit.startMsg("/archaeopteryx/needbeats", "i");
  0 => xmit.addInt;
  while(true) {
    cyc.wait(0.5) => now;
    xmit.startMsg("/archaeopteryx/needbeats", "i");
    0 => xmit.addInt;
    <<< "asked for beats" >>>;
    cyc.next_beat => now;
  }
}

// listens for sync messages from archaeopteryx
// resets everything each time
// so this script can be left open for multiple arkx restarts
fun void listen_sync() {
  null => Shred @ ask;

  osc.event("/archaeopteryx/sync, i") @=> OscEvent sync;
  while(sync => now) {
    while( sync.nextMsg() != 0 ) {
      cyc.reset();
      cyc.set( [1::minute/45] );
      <<< "synchronized with archaeopteryx" >>>;
      sync_event.signal();

      if(ask != null)
        Machine.remove(ask.id());
      spork ~ ask_beats() @=> ask;
    }
  }
}

// wait for first sync
spork ~ listen_sync();
sync_event => now;

// begin to listen
spork ~ listen_on();
spork ~ listen_off();

while(cyc.wait(1.0) => now)
  <<< "beat\a" >>>;
