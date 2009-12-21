#!/usr/bin/perl -w

use strict;

use Test::More tests => 7;

use List::UtilsBy qw( sortby );

is_deeply( [ sortby { } ], [], 'empty list' );

is_deeply( [ sortby { $_ } "a" ], [ "a" ], 'unit list' );

is_deeply( [ sortby { my $ret = $_; undef $_; $ret } "a" ], [ "a" ], 'localises $_' );

is_deeply( [ sortby { $_ } "a", "b" ], [ "a", "b" ], 'identity function no-op' );
is_deeply( [ sortby { $_ } "b", "a" ], [ "a", "b" ], 'identity function on $_' );

is_deeply( [ sortby { $_[0] } "b", "a" ], [ "a", "b" ], 'identity function on $_[0]' );

# list reverse on a single element is a no-op; scalar reverse will swap the
# characters. This test also ensures the correct context is seen by the function
is_deeply( [ sortby { reverse $_ } "az", "by" ], [ "by", "az" ], 'reverse function' );
