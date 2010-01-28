#!/usr/bin/perl -w

use strict;

use Test::More tests => 6;

use List::UtilsBy qw( maxby );

is_deeply( ( maxby {} ), undef, 'empty list yields undef' );

is_deeply( ( maxby { $_ } 10 ), 10, 'unit list yields value' );

is_deeply( ( maxby { $_ } 10, 20 ), 20, 'identity function on $_' );
is_deeply( ( maxby { $_[0] } 10, 20 ), 20, 'identity function on $_[0]' );

is_deeply( ( maxby { length $_ } "a", "ccc", "bb" ), "ccc", 'length function' );

is_deeply( ( maxby { length $_ } "a", "ccc", "bb", "ddd" ), "ccc", 'ties yield first' );
