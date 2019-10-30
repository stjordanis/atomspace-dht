;
; OpenCog OpenDHT Persistence module
;

(define-module (opencog persist-dht))


(use-modules (opencog))
(use-modules (opencog dht-config))
(load-extension
	(string-append opencog-ext-path-persist-dht "libpersist-dht")
	"opencog_persist_dht_init")

(export dht-clear-stats dht-close dht-open dht-stats
	dht-fetch-atom dht-load-atomspace)

(set-procedure-property! dht-clear-stats 'documentation
"
 dht-clear-stats - reset the performance statistics counters.
    This will zero out the various counters used to track the
    performance of the OpenDHT backend.  Statistics will continue to
    be accumulated.
")

(set-procedure-property! dht-close 'documentation
"
 dht-close - close the currently open DHT backend.
    Close open connections to the currently-open backend, after flushing
    any pending writes in the write queues. After the close, atoms can
    no longer be stored to or fetched from the database.
")

(set-procedure-property! dht-open 'documentation
"
 dht-open URL - Open a connection to an IPFS server.

  The URL must be one of these formats:
     dht:///KEY-NAME
     dht://HOSTNAME/KEY-NAME
     dht://HOSTNAME:PORT/KEY-NAME

  If no hostname is specified, its assumed to be 'localhost'. If no port
  is specified, its assumed to be 5001.

  Examples of use with valid URL's:
     (dht-open \"dht:///atomspace-test\")
     (dht-open \"dht://localhost/atomspace-test\")
     (dht-open \"dht://localhost:5001/atomspace-test\")
")

(set-procedure-property! dht-stats 'documentation
"
 dht-stats - report performance statistics.
    This will cause some database performance statistics to be printed
    to the stdout of the server. These statistics can be quite arcane
    and are useful primarily to the developers of the database backend.
")

(set-procedure-property! dht-fetch-atom 'documentation
"
 dht-fetch-atom CID - Return the Atom associated to the CID.

     For example:
        `(dht-fetch-atom \"QmTBUxX48jRZPwAU3dEgPQm4bShxW2ED3gXTHM78gvqugB\")`
     should always return
        `(Concept \"example concept\")`

     See also `dht-atom-cid` for the inverse operation.
")

(set-procedure-property! dht-load-atomspace 'documentation
"
 dht-load-atomspace PATH - Load all Atoms from the PATH into the AtomSpace.

   For example:
      `(dht-load-atomspace \"QmT9tZttJ4gVZQwVFHWTmJYqYGAAiKEcvW9k98T5syYeYU\")`
   should load the atomspace from `basic.scm` example.  In addition,
   IPNS and IPFS paths are allowed: e.g.
      `(dht-load-atomspace \"/dht/QmT9tZt...\")`
   and
      `(ipns-load-atomspace \"/ipns/QmVkzxh...\")`
   with the last form performing an IPNS resolution to obtain the actual
   IPFS CID to be loaded.

   See also `dht-fetch-atom` for loading individual atoms.
")