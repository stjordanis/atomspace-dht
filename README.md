# atomspace-dht
[OpenDHT](https://github.com/savoirfairelinux/opendht/wiki)
backend driver to the
[AtomSpace](https://github.com/opencog/atomspace) (hyper-)graph database.

The code here is a backend driver to the AtomSpace graph database,
enabling AtomSpace contents to be shared via the OpenDHT content
distribution network.  The goal is to allow efficient decentralized,
distributed operation over the global internet, allowing many
AtomSpace processes to access and perform updates to large datasets.

### The AtomSpace
The [AtomSpace](https://wiki.opencog.org/w/AtomSpace) is a
(hyper-)graph database whose nodes and links are called
["Atoms"](https://wiki.opencog.org/w/Atom). Each (immutable) Atom has
an associated (mutable)
[key-value store](https://wiki.opencog.org/w/Value).
The Atomspace has a variety of advanced features not normally found
in ordinary graph databases, including an advanced query language
and "active" Atoms.

### OpenDHT
OpenDHT is an internet-wide globally-accessible storage system, providing
a variety of distributed hash table services.  It provides decentralized
storage of data.

## Beta version 0.1.6
All core functions are implemented. They mostly work.  See the
[examples](examples). Most unit tests usually pass. Many desiarable
enhancements are missing; performance is a huge issue. There are
several show-stopper or near-show-stopper issues preventing further
development; see the issues list below.

### Status
In the current implementation:
 * OpenDHT appears to be compatible with the requirements imposed by
   the AtomSpace backend API. It seems to provide most of the services
   that the AtomSpace needs. This makes future development and
   operation look promising.
 * Despite this, there are several serious issues that are roadblocks
   to further development. These are listed below.
 * The implementation is almost feature-complete.  Missing are:
    + Rate-limiting issues leading to missing data.
    + Inability to flush pending output to the network.
    + Assorted desirable enhancements missing.
 * All eight unit tests have been ported over (from the original
   SQL backend driver tests). Currently six of eight pass. The
   tests below (usually) pass; sometimes ValueUTest fails; this is
   due to rate-limiting and/or flush problems.
```
1 - BasicSaveUTest
2 - ValueSaveUTest
3 - PersistUTest
4 - FetchUTest
5 - DeleteUTest
6 - MultiPersistUTest
```
 * The failing tests are:
   + `7 - MultiUserUTest` fails for unknown reasons.
   + `8 - LargeUTest` large atomspaces. Runs impossibly slowly.

### Architecture
This implementation will provide a full, complete implementation of the
standard `BackingStore` API from the Atomspace. Its a backend driver.

The git repo layout is the same as that of the AtomSpace repo. Build
and install mechanisms are the same.

### Design Notes
* Every Atom gets a unique hash. This is called the GUID.
  Every GUID is published, because, given only a GUID,
  there needs to be a way of finding out what the Atom is.
  This is needed for IncomingSet fetch, for example.
* Every (Atom, AtomSpace-name) pair gets a unique hash.
  The current values on that atom, as well as it's incoming set
  are stored under that hash.
* How can we find all current members of an AtomSpace?
  Easy, the AtomSpace is just one hash, and the atoms in it are
  DHT values.
* How can we find all members of the incoming set of an Atom?
  Easy, we generate the hash for that atom, and then look at
  all the DHT entries on it.
* How to delete entries? Atoms in the AtomSpace are tagged with
  a timestamp and an add/drop verb, so that precedence is known.
  An alternate design using CRDT seems like overkill.
* TODO: gets()'s need to be queued so that they can run async,
  and then call handlers when completed. I think futures w/callbacks
  will solve this.
* TODO: Optionally use crypto signatures to verify that the data
  comes from legitimate, cooperating sources.
* TODO: Support read-write overlays on top of read-only datasets.
  This seems like it should be easy...
* TODO: Enhancement: listen for new values on specific atoms
  or atom types.
* TODO: Enhancement: listen for atomspace updates.
* TODO: Enhancement: implement a CRDT type for `CountTruthValue`.
* TODO: Defer fetches until barrier. The futures can be created
  and then queued, until the time that they really need to be
  resolved.
* TODO: Measure total RAM usage.  This risks being quite the
  memory hog, if datasets with hundreds of millions of atoms are
  published.

### Issues
The following are serious issues, some of which are nearly
show-stoppers:

* Rate limiting causes published data to be discarded.  This is
  currently solved with a `std::this_thread::sleep_for()` in several
  places in the code. See
  [opendht issue #460](https://github.com/savoirfairelinux/opendht/issues/460)
  for details. This is a serious issue, and makes the unit tests
  fairly unreliable, as they become timing-dependent and racy.
  (This is effectively a show-stopper.)
* There does not seem to be any way of force-pushing local data out
  onto the net, (for synchronization, e.g. for example, if it is known
  that the local node is going down. See
  [opendht issue #461](https://github.com/savoirfairelinux/opendht/issues/461)
  for details. This is effectively a show-stopper, as it makes it
  impossible to safely terminate a running node with local data in it.
* There is some insane gnutls/libnettle bug when it interacts with
  BoehmGC.  It's provoked when running `MultiUserUTest` when the
  line that creates `dht::crypto::generateIdentity();` is enabled.
  It crashes with a bizarre realloc bug. One bug report is
  [bug#38041 in guile](https://debbugs.gnu.org/cgi/bugreport.cgi?bug=38041).
  It appears that gnutls is not thread-safe... or something weird.

### Architecture concerns
There are numerous concerns with using a DHT backend.
* The representation is likely to be RAM intensive, requiring KBytes
  per atom, and thus causing trouble when datasets exceeed tens of
  millions of Atoms.
* There is no backup-to-disk; thus, a total data loss is risked if
  there are large system outages.  This is a big concern, as the
  initial networks are unlikely to have more than a few dozen nodes.
  (The data should not be mixed into the global DHT... I think!?)
* How will performance compare with traditional distributed databases
  (e.g. with Postgres?)
* How do we avoid accumulating large amounts of cruft? Long lifetimes
  threaten this.  I guess that, in the end, there always needs to be
  a seeder, e.g. working off of Postres? As otherwise, the data expires.

## Build Prereqs

 * Clone and build the [AtomSpace](https://github.com/opencog/atomspace).
 * Install OpenDHT. On Debian/Ubuntu:
   ```
   sudo apt install dhtnode libopendht-dev
   ```

## Building
Building is just like that for any other OpenCog component.
After installing the pre-reqs, do this:
```
   mkdir build
   cd build
   cmake ..
   make -j
   sudo make install
```
Then go through the [examples](examples) directory.
