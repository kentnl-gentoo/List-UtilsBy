#!/usr/bin/perl -w

use strict;

use Test::More tests => 6;

use List::UtilsBy qw( min_by );

is_deeply( ( min_by {} ), undef, 'empty list yields undef' );

is_deeply( ( min_by { $_ } 10 ), 10, 'unit list yields value' );

is_deeply( ( min_by { $_ } 10, 20 ), 10, 'identity function on $_' );
is_deeply( ( min_by { $_[0] } 10, 20 ), 10, 'identity function on $_[0]' );

is_deeply( ( min_by { length $_ } "a", "ccc", "bb" ), "a", 'length function' );

is_deeply( ( min_by { length $_ } "a", "ccc", "bb", "e" ), "a", 'ties yield first' );
