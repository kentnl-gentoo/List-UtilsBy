package t::TestRand;

use strict;
use warnings;

use Exporter 'import';
our @EXPORT = qw( randomly );

my $randhook;
*CORE::GLOBAL::rand = sub { $randhook ? $randhook->( $_[0] ) : rand $_[0] };

sub randomly(&)
{
   my $code = shift;

   my @rands;
   my $randidx;
   $randhook = sub {
      my ( $below ) = @_;
      if( $randidx > $#rands ) {
         push @rands, [ 0, $below ];
         $randidx++;
         return 0;
      }

      if( $below != $rands[$randidx][1] ) {
         die "ARGH! The function under test is nondeterministic!\n";
      }

      if( $randidx < $#rands and $rands[$randidx+1][0] == $rands[$randidx+1][1]-1 ) {
         die "Fell off the edge" if $rands[$randidx][0] == $rands[$randidx][1]-1;
         splice @rands, $randidx+1, @rands-$randidx, ();
         $rands[$randidx][0]++;
         return $rands[$randidx++][0];
      } 
      elsif( $randidx == $#rands ) {
         $rands[$randidx][0]++;
         return $rands[$randidx++][0];
      }
      else {
         return $rands[$randidx++][0];
      }
   };

   while(1) {
      my $more = 0;
      $_->[0] < $_->[1]-1 and $more = 1 for @rands;
      last if @rands and !$more;

      $randidx = 0;
      $code->();
   }
}

1;
