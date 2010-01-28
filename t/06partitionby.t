#!/usr/bin/perl -w

use strict;

use Test::More tests => 7;

use List::UtilsBy qw( partitionby );

is_deeply( { partitionby { } }, {}, 'empty list' );

is_deeply( { partitionby { $_ } "a" }, { a => [ "a" ] }, 'unit list' );

is_deeply( { partitionby { my $ret = $_; undef $_; $ret } "a" }, { a => [ "a" ] }, 'localises $_' );

is_deeply( { partitionby { "all" } "a", "b" }, { all => [ "a", "b" ] }, 'constant function preserves order' );
is_deeply( { partitionby { "all" } "b", "a" }, { all => [ "b", "a" ] }, 'constant function preserves order' );

is_deeply( { partitionby { $_[0] } "b", "a" }, { a => [ "a" ], b => [ "b" ] }, 'identity function on $_[0]' );

is_deeply( { partitionby { length $_ } "a", "b", "cc", "dd", "eee" },
           { 1 => [ "a", "b" ], 2 => [ "cc", "dd" ], 3 => [ "eee" ] }, 'length function' );
