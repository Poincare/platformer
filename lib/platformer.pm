# this package provides the main engine functionality

package platformer;
use base 'Badger::Base';


use Badger::Class
#    mutators => 'config window clock';

use SDL;
use SDL::Video;
use SDL::Surface;
use SDL::Audio;
use SDL::Event;
use SDL::Image;

use Cogent::Window;
use platformer::Level;

#my %config = {
#    window => {800, 600, 32, '*initflags*'},
#    levels => {
#        'menu'    => 'menu.dat',
#        'level 1' => 'level1.dat',
#        'level 2' => 'level2.dat',
#    },
#};
    
sub new {
    my ($self) = @_;
    SDL::init( SDL_INIT_VIDEO | SDL_INIT_AUDIO);
    $self->{window} = Cogent::Window->new(800, 600, 32, SDL_DOUBLEBUF | SDL_SWSURFACE);
    $self->{clock} = SDLx::Clock->new();
    
    $self->{states} = { menu => platformer::Level->new( filename => 'data/levels/menu.dat' ),
                        level1 => platformer::Level->new(filename => 'data/levels/level1.dat') };
    
    
    
}

sub run {
    my $self = shift;
    $self->set_state('menu');
    
    $self->{clock}->start;
    my $prev_time_delta = $self->{clock}->get_ticks();
    while (1) {
        my $time_delta = $self->{clock}->get_ticks() - $prev_time_delta;
        $self->handle_events();
        $self->update($time_delta);
        $self->{window}->draw();
        $prev_time_delta += $time_delta;
    }
}

# allows the engine to handle common events (e.g. window resizes, quitting the game), and pass off unhandled events to the current state
sub handle_events() {
    my $self = shift;
    my $event = SDL::Event->new();
    
}

# runs the main engine logic and the current state's logic with the same update interval, keeping everything in sync
sub update {
    my ($self, $time_delta) = @_;
    $self->{current_state}->update($time_delta);
}

sub set_window {
    # TODO: Find out how to reinitialize SDL window    
}

sub get_window {
    my $self = shift;
    return $self->{window};
}

sub set_state {
    my ($self, $state_name) = @_;
    $self->{current_state} = $self->{states}->{$state_name};
}

# Hash-based resource management. Allows for initialization and lookup of resources based on resource type and specific name.
sub set_resource {
    my ($self, $rsrc_type, $rsrc_name, $rsrc) = @_;
    $self->{resources}->{$rsrc_type}->{$rsrc_name} = \$rsrc;
}

sub get_resource {
    my ($self, $rsrc_type, $rsrc_name) = @_;
    return $self->{resources}->{$rsrc_type}->{$rsrc_name};
}

sub clear_resources {
    my $self = shift;
    $self->{resources} = {};
}

1;