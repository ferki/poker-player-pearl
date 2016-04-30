package Player;

use strict;
use warnings;

our $VERSION = '0.0.4';

sub new {
    my $class = shift;
    my $args  = {};
    return bless $args, $class;
}

sub bet_request {
    my $self = shift;
    $self->{game_state} = shift;
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
        return 1000;
    }
    else {
        return 1;
    }
}

sub has_pair {
    my $self = shift;
    $self->get_my_hand;
    return $self->{hand}->[0]->{rank} eq $self->{hand}->[1]->{rank};
}

sub get_my_hand {
    my $self    = shift;
    my $players = $self->{game_state}->{players};
    for my $player ( @{$players} ) {
        next unless defined $player->{hole_cards};
        $self->{hand} = $player->{hole_cards};
    }
}

1;
