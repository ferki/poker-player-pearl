package Player;

use strict;
use warnings;
use List::Util qw(max);

our $VERSION = '0.1.5';

sub new {
    my $class = shift;
    my $args = { name => 'pearl' };
    return bless $args, $class;
}

sub bet_request {
    my $self = shift;
    $self->{game_state} = shift;
    $self->parse();
    return $self->get_bet();
}

sub check { }

sub showdown { }

sub version {
    my $self = shift;
    return $self->VERSION;
}

sub get_bet {
    my $self = shift;
    if ( $self->has_pair ) {
        return $self->raise if $self->preflop;
        return $self->call  if $self->postflop;
    }
    elsif (
        $self->has_rank('A')
        && (   $self->has_rank('K')
            || $self->has_rank('Q')
            || $self->has_rank('J') )
      )
    {
        return $self->raise if $self->preflop;
        return $self->call  if $self->postflop;
    }
    else {
        return 0;
    }
}

sub preflop {
    my $self = shift;
    return $self->{game_state}->{bet_index} == 0;
}

sub postflop {
    my $self = shift;
    return !$self->preflop;
}

sub raise {
    my $self = shift;
    if ( $self->{game_state}->{bet_index} == 0 ) {
        return max( $self->call + $self->{game_state}->{minimum_raise},
            int( 3.5 * $self->{big_blind} ) );
    }
    return int( $self->{pot} * 0.67 );
}

sub fold {
    my $self = shift;
    return $self->call - 1;
}

sub call {
    my $self = shift;
    return $self->{game_state}->{current_buy_in} - $self->{player}->{bet};
}

sub allin {
    my $self = shift;
    return $self->{player}->{stack};
}

sub has_rank {
    my $self = shift;
    my $rank = shift;
    return ( $self->{hand}->[0]->{rank} eq $rank
          || $self->{hand}->[1]->{rank} eq $rank );
}

sub has_suited {
    my $self = shift;
    return $self->{hand}->[0]->{suite} eq $self->{hand}->[1]->{suite};
}

sub has_pair {
    my $self = shift;
    return $self->{hand}->[0]->{rank} eq $self->{hand}->[1]->{rank};
}

sub parse {
    my $self = shift;
    $self->{pot}         = $self->{game_state}->{pot};
    $self->{small_blind} = $self->{game_state}->{small_blind};
    $self->{big_blind}   = $self->{game_state}->{small_blind} * 2;
    $self->{players}     = $self->{game_state}->{players};

    for my $player ( @{ $self->{players} } ) {
        next unless $player->{name} eq $self->{name};
        $self->{player} = $player;
        $self->{hand}   = $self->{player}->{hole_cards};
    }
}

1;
