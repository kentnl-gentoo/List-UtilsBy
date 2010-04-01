#!/usr/bin/perl -w

use strict;

use Test::More tests => 2;

use List::UtilsBy qw( sortby maxby );

is_deeply( [ sortby { $_ } "a", "b" ], [ "a", "b" ], 'sortby' );
is_deeply( ( maxby { length $_ } "a", "ccc", "bb" ), "ccc", 'maxby' );
