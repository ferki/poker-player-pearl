package Player;

use strict;
use warnings;

our $VERSION = '0.0.3';

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
    return 1000;
}

1;
