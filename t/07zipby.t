#!/usr/bin/perl -w

use strict;

use Test::More tests => 6;

use List::UtilsBy qw( zipby );

is_deeply( [ zipby { } ], [], 'empty list' );

is_deeply( [ zipby { [ @_ ] } [ "a" ], [ "b" ], [ "c" ] ], [ [ "a", "b", "c" ] ], 'singleton lists' );

is_deeply( [ zipby { [ @_ ] } [ "a", "b", "c" ] ], [ [ "a" ], [ "b" ], [ "c" ] ], 'narrow lists' );

is_deeply( [ zipby { [ @_ ] } [ "a1", "a2" ], [ "b1", "b2" ] ], [ [ "a1", "b1" ], [ "a2", "b2" ] ], 'zip with []' );

is_deeply( [ zipby { join ",", @_ } [ "a1", "a2" ], [ "b1", "b2" ] ], [ "a1,b1", "a2,b2" ], 'zip with join()' );

is_deeply( [ zipby { [ @_ ] } [ 1 .. 3 ], [ 1 .. 2 ] ], [ [ 1, 1 ], [ 2, 2 ], [ 3, undef ] ], 'non-rectangular adds undef' );
