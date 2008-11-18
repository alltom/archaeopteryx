// ChucK's time warps wall clock time to match audio stream
// Cyclone's time warps ChucK's time to match a rhythm

class BeatEvent extends Event {
  0 => float beats;
}

// just an inefficient queue
// this one stores BeatEvents
class BeatQueue {
  BeatEvent @ queue[0];

  fun void add(BeatEvent @ ev) {
    queue.cap() + 1 => queue.size;
    ev @=> queue[queue.cap()-1];
  }

  fun int empty() { return queue.size() == 0; }
  fun void reset() { 0 => queue.size; }

  fun int _peek() {
    if(queue.size() == 0)
      return -1;
    0 => int ev;
    for(1 => int i; i < queue.size(); i++)
      if(queue[i].beats < queue[ev].beats)
        i @=> ev;
    return ev;
  }

  fun void _remove(int index) {
    for(index+1 => int i; i < queue.size(); i++)
      queue[i] @=> queue[i-1];
    queue.size() - 1 => queue.size;
  }

  fun BeatEvent @ peek() {
    _peek() => int ev;
    if(ev == -1) return null;
    return queue[ev];
  }

  fun BeatEvent @ remove() {
    _peek() => int i;
    if(i == -1) return null;
    queue[i] @=> BeatEvent @ ev;
    _remove(i);
    return ev;
  }
}

public class Cyclone {
  BeatQueue queue;
  time last_beat;

  int beatnow; // beats since start
  int beat; // index into beats array
  dur beats[]; // beat durations

  // event fired at beginning of each beat
  new BeatEvent @=> BeatEvent @ next_beat;

  // shred running _start() for this Cyclone
  null => Shred @ manager;

  // time between checking for events to send
  1::ms => dur resolution;

  fun time next_beat_time() {
    return last_beat + beats[beat];
  }

  fun float progress() {
    now - last_beat => dur diff;
    next_beat_time() - last_beat => dur len;
    return diff / len;
  }

  // returns an event which will fire after the given number of beats
  fun Event @ wait(float beats) {
    return waitfor(beatnow + progress() + beats);
  }

  // returns an event which will fire at the specified time
  fun Event @ waitfor(float beats) {
    new BeatEvent @=> BeatEvent @ ev;
    beats => ev.beats;
    queue.add(ev);
    return ev;
  }

  fun void _start() {
    now => last_beat;
    while(resolution => now) {
      beat % beats.size() => beat; // in case # of beats changed
      if(now >= next_beat_time()) {
        now => last_beat;
        (beat + 1) % beats.size() => beat;
        beatnow + 1 => beatnow;
      }
      while(!queue.empty() && queue.peek().beats < beatnow + progress()) {
        queue.remove() @=> BeatEvent @ ev;
        ev.broadcast();
        if(ev == next_beat) {
          beatnow + 1 => ev.beats;
          ev => queue.add;
        }
      }
    }
  }

  fun void _init() {
    queue.reset();
    0 => next_beat.beats;
    next_beat => queue.add;
    set([1::second]);
    0 => beatnow;
    0 => beat;
    spork ~ _start() @=> manager;
  }

  fun void set(dur beat_lengths[]) {
    beat_lengths @=> beats;
  }

  fun void reset() {
    if(manager != null)
      Machine.remove(manager.id());
    _init();
  }

  _init();
}
