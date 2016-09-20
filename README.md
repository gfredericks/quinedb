<img src="logo2.png" title="logo" align="right" />

# QuineDB

[![Build Status](https://travis-ci.org/gfredericks/quinedb.svg?branch=master)](https://travis-ci.org/gfredericks/quinedb)

QuineDB is a quine that is also a key/value store.

_If your database can't print its own source code,
can you really trust it?_

## Getting Started

QuineDB consists of the `quinedb` script in this repository. It
is written in Bash and requires Bash 4.

When you run it, the (possibly modified) source code of `quinedb` is
printed to `STDOUT`, and the results of the specific command run are
printed to `STDERR`. Therefore, each time you run a write operation
you must redirect `STDOUT` to an appropriate place.  For consistency,
we recommend doing this for all operations. However this can be very
tedious to do directly, so a bash function such as the following can
be helpful, and the examples that follow will make use of it:

``` shell
qdb () {
  ./quinedb "$@" > qdb.out 2> qdb.err || return "$?"
  cat qdb.out > quinedb
  cat qdb.err
  rm qdb.err qdb.out
}
```

### API

QuineDB has four commands: `get`, `set`, `delete`, and `keys`.

#### `set`

To set a key to a value, use `quinedb set <k> <v>`:

``` shell
$ qdb set foo bar
OK
$ qdb set count 42
OK
```

#### `get`

To get a value, use `quinedb get <k>`:

``` shell
$ qdb get foo
bar
```

#### `keys`

To list the keys in the database, use `quinedb keys`:

``` shell
$ qdb keys
count
foo
```

#### `delete`

To delete a key, use `quinedb delete <k>`:

``` shell
$ qdb delete foo
OK
$ qdb keys
count
```

### Syntax

Keys and values are printed in the syntax of bash strings, which
allows `keys` to print one key on each line unambiguously (even if a
key contains a newline) and `get` to unambiguously print no output for
a missing key.

``` shell
$ qdb set \
  $'this\nkey\nhas\nfour\nlines' \
  $'and the \'value\' has \"quotes\"'
OK

$ qdb set empty ''
OK

$ qdb keys
$'this\nkey\nhas\nfour\nlines'
empty

$ qdb get $'this\nkey\nhas\nfour\nlines'
$'and the \'value\' has \"quotes\"'

$ qdb get empty
$''

$ qdb get missing

```

### Transactions

To group several operations into an atomic transaction you can simply
chain operations by redirecting `STDOUT` to an invocation of
`/usr/bin/env bash` like so:

``` shell
$ ./quinedb set k1 v1 | \
/usr/bin/env bash -s set k2 v2 | \
/usr/bin/env bash -s set k3 v3 | \
/usr/bin/env bash -s keys > tmp; chmod +x tmp; mv tmp quinedb
OK
OK
OK
k1
k3
k2
```

## FAQ

### Why should my database be a quine?

1. Why _shouldn't_ your database be a quine?
2. If your data and the database code are not stored in the same
   place, you risk losing track of one, making the other useless.
3. You can store various versions of your database, or even fork it,
   with no extra effort.

### How fast does it go?

I was able to insert 100 k/v pairs into an empty database in a mere 10
seconds. The runtime of each operation is (probably) proportional to
O(n·log(n)), so it's not too surprising that inserting 1000 k/v pairs
took over 11 minutes. If you need the database to be fast, we
recommend not putting too much data in it.

### Are the keys and values unicode strings or arbitrary binary data?

I'm not sure. How does bash work exactly?

### How many concurrent connections can I have?

I'm not sure you've been paying attention.

### Can I run a QuineDB cluster?

Well I mean, um.

## Contributing

Pull requests are welcome.

## Acknowledgments

- [@timgaleckas](https://github.com/timgaleckas) for reviewing and
  coming up with the mechanism for transactions

## License

Copyright © 2016 Gary Fredericks

Distributed under the Eclipse Public License either version 1.0 or (at
your option) any later version.
