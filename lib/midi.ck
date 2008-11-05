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

// oh yeah, let's do the time warp
Cyclone.singleton() @=> Cyclone @ cyc;

Event sync_event;

// send a MIDI note at time t
fun void send(float beat, int control, int chan, int note, int vel) {
    cyc.waitfor(beat) => now; // lie and wait

	MidiMsg msg;
	control => msg.data1;
	note => msg.data2;
	vel => msg.data3;
	msg => midi.send;
	//<<< "midi: ", chan, note, vel >>>;
}

// listen for note-on schedulings
fun void listen_on() {
	osc.event( "/archaeopteryx/noteon, iiii" ) @=> OscEvent ev;
	while(ev => now) {
		while( ev.nextMsg() != 0 ) {
			ev.getInt()/1000. => float beat;
			ev.getInt() => int chan;
			ev.getInt() => int note;
			ev.getInt() => int vel;
			<<< "osc note-on:", beat, chan, note, vel >>>;
			spork ~ send(beat, 0x90, chan, note, vel);
		}
	}
}

// listen for note-off schedulings
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

fun void ask_beats() {
	OscSend xmit;
	xmit.setHost("localhost", 5001);
	1 => int first;
	while(true) {
		xmit.startMsg("/archaeopteryx/needbeats", "i");
		0 => xmit.addInt;
		<<< "asked for beats" >>>;
		if(first) {
			cyc.wait(0.9) => now;
			0 => first;
		} else {
			cyc.wait(1.0)  => now;
		}
	}
}

fun void listen_sync() {
	null => Shred @ ask;
	
	osc.event("/archaeopteryx/sync, i") @=> OscEvent sync;
	while(sync => now) {
		while( sync.nextMsg() != 0 ) {
			cyc.reset();
			cyc.set( [1::minute/40, 1::minute/40],
			         [1., 1.] );
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

// keep parent shred from dying
while(1::day => now);
