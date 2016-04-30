package Player;

use strict;
use warnings;
use HTTP::Request;
use LWP::UserAgent;
use JSON::MaybeXS;

our $VERSION = '0.1.3';

sub new {
    my $class = shift;
    my $args  = {
        name   => 'pearl',
        winner => 'http://hidden-journey-43676.herokuapp.com/'
    };
    return bless $args, $class;
}

sub bet_request {
    my $self = shift;
    $self->{game_state} = shift;
    my $req = HTTP::Request->new( POST => $self->{winner} );
    $req->header( 'Content-Type' => 'application/json' );
    $req->content( encode_json( $self->{game_state} ) );
    my $lwp = LWP::UserAgent->new;
    my $res = $lwp->request($req);
    return $res->decoded_content;
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
        return $self->raise if $self->{game_state}->{bet_index} == 0;
        return $self->call  if $self->{game_state}->{bet_index} != 0;
    }
    elsif (
        $self->has_rank('A')
        && (   $self->has_rank('K')
            || $self->has_rank('Q')
            || $self->has_rank('J') )
      )
    {
        return $self->raise
          if $self->{game_state}->{bet_index} == 0;
        return $self->call if $self->{game_state}->{bet_index} != 0;
    }
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
