#!/usr/bin/perl -w

use strict;

use Test::More tests => 8;

use List::UtilsBy qw( nsortby );

is_deeply( [ nsortby { } ], [], 'empty list' );

is_deeply( [ nsortby { $_ } 1 ], [ 1 ], 'unit list' );

is_deeply( [ nsortby { my $ret = $_; undef $_; $ret } 10 ], [ 10 ], 'localises $_' );

is_deeply( [ nsortby { $_ } 20, 25 ], [ 20, 25 ], 'identity function no-op' );
is_deeply( [ nsortby { $_ } 25, 20 ], [ 20, 25 ], 'identity function on $_' );

is_deeply( [ nsortby { $_[0] } 30, 35 ], [ 30, 35 ], 'identity function on $_[0]' );

is_deeply( [ nsortby { length $_ } "a", "bbb", "cc" ], [ "a", "cc", "bbb" ], 'length function' );

# List context would yield the matches and fail, scalar context would yield
# the count and be correct
is_deeply( [ nsortby { () = m/(a)/g } "apple", "hello", "armageddon" ], [ "hello", "apple", "armageddon" ], 'scalar context' );
