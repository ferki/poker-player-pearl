package Player;

use strict;
use warnings;
use List::Util qw(max);

our $VERSION = '0.2.3';

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
        if ( $self->has_rank('A') || $self->has_rank('K') ) {
            return $self->allin;
        }

        if ( $self->has_rank('Q') || $self->has_rank('J') ) {
            return $self->raise;
        }

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
        if ( $self->has_suited ) {
            return $self->raise;
        }

        return $self->raise if $self->preflop;
        return $self->call  if $self->postflop;
    }
    elsif ( $self->connector && $self->has_suited ) {
        return 0;
    }
    else {
        return 0;
    }
}

sub connector {
    my $self = shift;
    return $self->rank_diff == 1;
}

sub preflop {
    my $self = shift;
    return scalar @{ $self->{game_state}->{community_cards} } == 0;
}

sub postflop {
    my $self = shift;
    return !$self->preflop;
}

sub raise {
    my $self = shift;
    if ( $self->preflop ) {
        return max( $self->call + $self->{game_state}->{minimum_raise},
            int( 3.5 * $self->{big_blind} ) );
    }

    return int( $self->{pot} * 0.67 );
}

sub rank_diff {
    my $self = shift;
    my %map  = (
        2  => 2,
        3  => 3,
        4  => 4,
        5  => 5,
        6  => 6,
        7  => 7,
        8  => 8,
        9  => 9,
        10 => 10,
        J  => 11,
        Q  => 12,
        K  => 13,
        A  => 14,
    );

    my $rank1 = $map{ $self->{hand}->[0]->{rank} };
    my $rank2 = $map{ $self->{hand}->[1]->{rank} };

    my $diff = abs( $rank1 - $rank2 );
    $diff = $diff == 12 ? 1 : $diff;
    return $diff;
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
    return $self->{hand}->[0]->{suit} eq $self->{hand}->[1]->{suit};
}

sub has_pair {
    my $self = shift;
    return $self->rank_diff == 0;
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
