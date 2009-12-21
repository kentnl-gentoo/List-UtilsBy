#!/usr/bin/perl -w

use strict;

use Test::More tests => 5;

use List::UtilsBy qw( minby );

is_deeply( ( minby {} ), undef, 'empty list yields undef' );

is_deeply( ( minby { $_ } 10 ), 10, 'unit list yields value' );

is_deeply( ( minby { $_ } 10, 20 ), 10, 'identity function' );

is_deeply( ( minby { length $_ } "a", "ccc", "bb" ), "a", 'length function' );

is_deeply( ( minby { length $_ } "a", "ccc", "bb", "e" ), "a", 'ties yield first' );
