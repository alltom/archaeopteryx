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

time start;

// synchronize timing
Event sync_event;
fun void listen_sync() {
	osc.event("/archaeopteryx/sync, f") @=> OscEvent sync;
	while(sync => now) {
		while( sync.nextMsg() != 0 ) {
			now => start;
			<<< "synchronized with archaeopteryx" >>>;
			sync_event.signal();
		}
	}
}

spork ~ listen_sync();
sync_event => now; // wait for first sync

// send a MIDI note at time t
fun void send(time t, int control, int chan, int note, int vel) {
	t => now; // lie and wait

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
			start + ev.getInt()::ms => time t;
			ev.getInt() => int chan;
			ev.getInt() => int note;
			ev.getInt() => int vel;
			//<<< "osc note-on:", t, chan, note, vel >>>;
			spork ~ send(t, 0x90, chan, note, vel);
		}
	}
}

// listen for note-off schedulings
fun void listen_off() {
	osc.event( "/archaeopteryx/noteoff, iii" ) @=> OscEvent ev;
	while(ev => now) {
		while( ev.nextMsg() != 0 ) {
			start + ev.getInt()::ms => time t;
			ev.getInt() => int chan;
			ev.getInt() => int note;
			//<<< "osc note-off:", t, chan, note >>>;
			spork ~ send(t, 0x80, chan, note, 0);
		}
	}
}

// begin to listen
spork ~ listen_on();
spork ~ listen_off();

// keep parent shred from dying
while(1::day => now);
