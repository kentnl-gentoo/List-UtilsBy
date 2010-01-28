#  You may distribute under the terms of either the GNU General Public License
#  or the Artistic License (the same terms as Perl itself)
#
#  (C) Paul Evans, 2009,2010 -- leonerd@leonerd.org.uk

package List::UtilsBy;

use strict;
use warnings;

our $VERSION = '0.02';

use Exporter 'import';

our @EXPORT_OK = qw(
   sortby
   nsortby

   maxby
   minby

   uniqby

   partitionby
);

=head1 NAME

C<List::UtilsBy> - higher-order list utility functions

=head1 SYNOPSIS

 use List::UtilsBy qw( nsortby minby );

 use File::stat qw( stat );
 my @files_by_age = nsortby { stat($_)->mtime } @files;

 my $shortest_name = minby { length } @names;

=head1 DESCRIPTION

This module provides a number of list utility functions, all of which take an
initial code block to control their behaviour. They are variations on similar
core perl or C<List::Util> functions of similar names, but which use the block
to control their behaviour. For example, the core Perl function C<sort> takes
a list of values and returns them, sorted into order by their string value.
The C<sortby> function sorts them according to the string value returned by
the extra function, when given each value.

 my @names_sorted = sort @names;

 my @people_sorted = sortby { $_->name } @people;

=cut

=head1 FUNCTIONS

=cut

=head2 @vals = sortby { KEYFUNC } @vals

Returns the list of values sorted according to the string values returned by
the C<KEYFUNC> block or function. A typical use of this may be to sort objects
according to the string value of some accessor, such as

 sortby { $_->name } @people

The key function is called in scalar context, being passed each value in turn
as both C<$_> and the only argument in the parameters, C<@_>. The values are
then sorted according to string comparisons on the values returned.

This is equivalent to

 sort { $a->name cmp $b->name } @people

except that it guarantees the C<name> accessor will be executed only once per
value.

=cut

sub sortby(&@)
{
   my $keygen = shift;
   my @vals = @_;

   my @keys = map { local $_ = $vals[$_]; scalar $keygen->( $_ ) } 0 .. $#vals;
   return map { $vals[$_] } sort { $keys[$a] cmp $keys[$b] } 0 .. $#vals;
}

=head2 @vals = nsortby { KEYFUNC } @vals

Equivalent to C<sortby> but compares its key values numerically.

=cut

sub nsortby(&@)
{
   my $keygen = shift;
   my @vals = @_;

   my @keys = map { local $_ = $vals[$_]; scalar $keygen->( $_ ) } 0 .. $#vals;
   return map { $vals[$_] } sort { $keys[$a] <=> $keys[$b] } 0 .. $#vals;
}

=head2 $optimal = maxby { CMPFUNC } @vals

Returns the (first) value from C<@vals> that gives the numerically largest
result from the comparison function.

 my $tallest = maxby { $_->height } @people

 use File::stat qw( stat );
 my $newest = maxby { stat($_)->mtime } @files;

In the case of a tie, the first value to give the largest result is returned.
To obtain the last, reverse the input list.

 my $longest = maxby { length $_ } reverse @strings;

If called on an empty list, C<undef> is returned.

=cut

sub maxby(&@)
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

=head2 $optimal = minby { CMPFUNC } @vals

Equivalent to C<maxby> but returns the first value which gives the numerically
smallest result from the comparison function.

=cut

sub minby(&@)
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

=head2 @vals = uniqby { KEYFUNC } @vals

Returns a list of the subset of values for which the key function block
returns unique values. The first value yielding a particular key is chosen,
subsequent values are rejected.

 my @some_fruit = uniqby { $_->colour } @fruit;

To select instead the last value per key, reverse the input list. If the order
of the results is significant, don't forget to reverse the result as well:

 my @some_fruit = reverse uniqby { $_->colour } reverse @fruit;

=cut

sub uniqby(&@)
{
   my $code = shift;

   my %present;
   return grep {
      my $key = $code->( local $_ = $_ );
      !$present{$key}++
   } @_;
}

=head2 %parts = partitionby { KEYFUNC } @vals

Returns a hash of ARRAY refs, containing all the original values distributed
according to the result of the key function block. Each ARRAY ref will contain
all the values which returned the same string from the key function, in their
original order.

 my %balls_by_colour = partitionby { $_->colour } @balls;

Because the values of the key function are used as hash keys, they ought to
either be strings, or at least well-behaved as strings (such as numbers, or
object references which overload stringification in a suitable manner).

=cut

sub partitionby(&@)
{
   my $code = shift;

   my %parts;
   push @{ $parts{ $code->( local $_ = $_ ) } }, $_ for @_;

   return %parts;
}

# Keep perl happy; keep Britain tidy
1;

=head1 TODO

=over 4

=item * XS implementations

These functions are currently all written in pure perl. Some at least, may
benefit from having XS implementations to speed up their logic.

=item * List-context C<maxby> and C<minby>

Consider whether C<maxby> and C<minby> ought to return a list of all the
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
