#  You may distribute under the terms of either the GNU General Public License
#  or the Artistic License (the same terms as Perl itself)
#
#  (C) Paul Evans, 2009,2010 -- leonerd@leonerd.org.uk

package List::UtilsBy;

use strict;
use warnings;

our $VERSION = '0.04';

use Exporter 'import';

our @EXPORT_OK = qw(
   sort_by
   nsort_by

   max_by
   min_by

   uniq_by

   partition_by

   zip_by
);

# Back-compat for old names of these functions.
# We won't document it because we'll be getting rid of it sometime soon
{
   no strict 'refs';

   foreach ( grep m/_by$/, @EXPORT_OK ) {
      ( my $oldname = $_ ) =~ s/_by$/by/;

      *$oldname = \&$_;
      push @EXPORT_OK, $oldname;
   }
}

=head1 NAME

C<List::UtilsBy> - higher-order list utility functions

=head1 SYNOPSIS

 use List::UtilsBy qw( nsort_by min_by );

 use File::stat qw( stat );
 my @files_by_age = nsort_by { stat($_)->mtime } @files;

 my $shortest_name = min_by { length } @names;

=head1 DESCRIPTION

This module provides a number of list utility functions, all of which take an
initial code block to control their behaviour. They are variations on similar
core perl or C<List::Util> functions of similar names, but which use the block
to control their behaviour. For example, the core Perl function C<sort> takes
a list of values and returns them, sorted into order by their string value.
The C<sort_by> function sorts them according to the string value returned by
the extra function, when given each value.

 my @names_sorted = sort @names;

 my @people_sorted = sort_by { $_->name } @people;

=cut

=head1 FUNCTIONS

=cut

=head2 @vals = sort_by { KEYFUNC } @vals

Returns the list of values sorted according to the string values returned by
the C<KEYFUNC> block or function. A typical use of this may be to sort objects
according to the string value of some accessor, such as

 sort_by { $_->name } @people

The key function is called in scalar context, being passed each value in turn
as both C<$_> and the only argument in the parameters, C<@_>. The values are
then sorted according to string comparisons on the values returned.

This is equivalent to

 sort { $a->name cmp $b->name } @people

except that it guarantees the C<name> accessor will be executed only once per
value.

=cut

sub sort_by(&@)
{
   my $keygen = shift;
   my @vals = @_;

   my @keys = map { local $_ = $vals[$_]; scalar $keygen->( $_ ) } 0 .. $#vals;
   return map { $vals[$_] } sort { $keys[$a] cmp $keys[$b] } 0 .. $#vals;
}

=head2 @vals = nsort_by { KEYFUNC } @vals

Equivalent to C<sort_by> but compares its key values numerically.

=cut

sub nsort_by(&@)
{
   my $keygen = shift;
   my @vals = @_;

   my @keys = map { local $_ = $vals[$_]; scalar $keygen->( $_ ) } 0 .. $#vals;
   return map { $vals[$_] } sort { $keys[$a] <=> $keys[$b] } 0 .. $#vals;
}

=head2 $optimal = max_by { KEYFUNC } @vals

Returns the (first) value from C<@vals> that gives the numerically largest
result from the key function.

 my $tallest = max_by { $_->height } @people

 use File::stat qw( stat );
 my $newest = max_by { stat($_)->mtime } @files;

In the case of a tie, the first value to give the largest result is returned.
To obtain the last, reverse the input list.

 my $longest = max_by { length $_ } reverse @strings;

If called on an empty list, C<undef> is returned.

=cut

sub max_by(&@)
{
   my $code = shift;

   return undef unless @_;

   local $_;

   my $maximal = $_ = shift @_;
   my $max     = $code->( $_ );

   foreach ( @_ ) {
      my $this = $code->( $_ );
      if( $this > $max ) {
         $maximal = $_;
         $max     = $this;
      }
   }

   return $maximal;
}

=head2 $optimal = min_by { KEYFUNC } @vals

Equivalent to C<max_by> but returns the first value which gives the
numerically smallest result from the key function.

=cut

sub min_by(&@)
{
   my $code = shift;

   return undef unless @_;

   local $_;

   my $minimal = $_ = shift @_;
   my $min     = $code->( $_ );

   foreach ( @_ ) {
      my $this = $code->( $_ );
      if( $this < $min ) {
         $minimal = $_;
         $min     = $this;
      }
   }

   return $minimal;
}

=head2 @vals = uniq_by { KEYFUNC } @vals

Returns a list of the subset of values for which the key function block
returns unique values. The first value yielding a particular key is chosen,
subsequent values are rejected.

 my @some_fruit = uniq_by { $_->colour } @fruit;

To select instead the last value per key, reverse the input list. If the order
of the results is significant, don't forget to reverse the result as well:

 my @some_fruit = reverse uniq_by { $_->colour } reverse @fruit;

=cut

sub uniq_by(&@)
{
   my $code = shift;

   my %present;
   return grep {
      my $key = $code->( local $_ = $_ );
      !$present{$key}++
   } @_;
}

=head2 %parts = partition_by { KEYFUNC } @vals

Returns a hash of ARRAY refs, containing all the original values distributed
according to the result of the key function block. Each ARRAY ref will contain
all the values which returned the same string from the key function, in their
original order.

 my %balls_by_colour = partition_by { $_->colour } @balls;

Because the values of the key function are used as hash keys, they ought to
either be strings, or at least well-behaved as strings (such as numbers, or
object references which overload stringification in a suitable manner).

=cut

sub partition_by(&@)
{
   my $code = shift;

   my %parts;
   push @{ $parts{ $code->( local $_ = $_ ) } }, $_ for @_;

   return %parts;
}

=head2 @vals = zip_by { ITEMFUNC } \@arr0, \@arr1, \@arr2,...

Returns a list of each of the values returned by the function block, when
invoked with values from across each each of the given ARRAY references. Each
value in the returned list will be the result of the function having been
invoked with arguments at that position, from across each of the arrays given.

 my @transposition = zip_by { [ @_ ] } @matrix;

 my @names = zip_by { "$_[1], $_[0]" } \@firstnames, \@surnames;

 print zip_by { "$_[0] => $_[1]\n" } [ keys %hash ], [ values %hash ];

If some of the arrays are shorter than others, the function will behave as if
they had C<undef> in the trailing positions. The following two lines are
equivalent:

 zip_by { f(@_) } [ 1, 2, 3 ], [ "a", "b" ]
 f( 1, "a" ), f( 2, "b" ), f( 3, undef )

(A function having this behaviour is sometimes called C<zipWith>, e.g. in
Haskell, but that name would not fit the naming scheme used by this module).

=cut

sub zip_by(&@)
{
   my $code = shift;
   my @lists = @_;

   @lists or return;

   my $len = 0;
   scalar @$_ > $len and $len = scalar @$_ for @lists;

   return map {
      my $idx = $_;
      $code->( map { $lists[$_][$idx] } 0 .. $#lists )
   } 0 .. $len-1;
}

# Keep perl happy; keep Britain tidy
1;

=head1 TODO

=over 4

=item * XS implementations

These functions are currently all written in pure perl. Some at least, may
benefit from having XS implementations to speed up their logic.

=item * List-context C<max_by> and C<min_by>

Consider whether C<max_by> and C<min_by> ought to return a list of all the
optimal values, in the case of a tie.

=item * Merge into L<List::Util> or L<List::MoreUtils>

This module shouldn't really exist. The functions should instead be part of
one of the existing modules that already contain many list utility functions.
Having Yet Another List Utilty Module just worsens the problem.

I have attempted to contact the authors of both of the above modules, to no
avail; therefore I decided it best to write and release this code here anyway
so that it is at least on CPAN. Once there, we can then see how best to merge
it into an existing module.

=back

=head1 AUTHOR

Paul Evans <leonerd@leonerd.org.uk>
