package Player;

use strict;
use warnings;

our $VERSION = '0.1.0';

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
    if ( $self->has_pair ) { return $self->raise }
    else {
        return 0;
    }
}

sub raise {
    my $self = shift;
    return $self->call + $self->{game_state}->{minimum_raise};
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
