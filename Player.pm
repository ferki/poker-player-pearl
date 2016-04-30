package Player;

use strict;
use warnings;
use List::Util qw(max);

our $VERSION = '0.0.9';

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
        return max( int( $self->{big_blind} * 3.5 ),
            int( $self->{pot} / 0.66 ), );
    }
    else {
        return 0;
    }
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
