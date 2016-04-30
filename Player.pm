package Player;

use strict;
use warnings;

our $VERSION = '0.0.5';

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
    my $self = shift;
    $self->{hand} = $self->{player}->{hole_cards};
}

sub parse {
    my $self = shift;
    $self->{players} = $self->{game_state}->{players};
    for my $player ( @{ $self->{players} } ) {
        next unless $player->{name} eq $self->{name};
        $self->{player} = $player;
    }
}

1;
