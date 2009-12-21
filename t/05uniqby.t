#!/usr/bin/perl -w

use strict;

use Test::More tests => 7;

use List::UtilsBy qw( uniqby );

is_deeply( [ uniqby { } ], [], 'empty list' );

is_deeply( [ uniqby { $_ } "a" ], [ "a" ], 'unit list' );

is_deeply( [ uniqby { my $ret = $_; undef $_; $ret } "a" ], [ "a" ], 'localises $_' );

is_deeply( [ uniqby { $_ } "a", "b" ], [ "a", "b" ], 'identity function no-op' );
is_deeply( [ uniqby { $_ } "b", "a" ], [ "b", "a" ], 'identity function on $_' );

is_deeply( [ uniqby { $_[0] } "b", "a" ], [ "b", "a" ], 'identity function on $_[0]' );

is_deeply( [ uniqby { length $_ } "a", "b", "cc", "dd", "eee" ], [ "a", "cc", "eee" ], 'length function' );
