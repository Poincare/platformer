# this package implements the main game loop and state machine

package platformer;
use Moose;

use SDL;
use SDL::Video;
use SDL::Surface;
use SDL::Audio;
use SDL::Event;
use SDL::Events;
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
    
has 'window' => (
    is => 'rw',
    isa => 'Cogent::Window',
    default => sub { Cogent::Window->new('x' => 800,
                                          'y' => 600,
                                          'bpp' => 32,
                                          'flags' => SDL_DOUBLEBUF | SDL_SWSURFACE)}
);

has 'clock' => (
    is => 'rw',
    isa => 'SDLx::Clock',
    default => sub { SDLx::Clock->new }
);

has 'states' => (
    is => 'rw',
    isa => 'HashRef',
    default => { menu   => platformer::level->new( filename => 'data/levels/menu.dat'   ),
                 level1 => platformer::level->new( filename => 'data/levels/level1.dat' ) }
);

has 'current_state' => (
    is => 'rw',
    isa => 'platformer::level',
    default => $self->states->{menu};
);

has 'event_filter' => (
    is => 'rw',
    isa => 'CodeRef',
    default => sub {
        my $event = shift;
        if ($event->type == SDL_QUIT) {
            exit;
        }
        else if ($event->type == SDL_VIDEORESIZE) {
            # TODO: handle this later
        }
    }
);

sub new {
    my ($self) = @_;
    SDL::init( SDL_INIT_VIDEO | SDL_INIT_AUDIO);
    
    SDL::Events::set_event_filter($self->{event_filter});
    
}

# main loop of the game
sub run {
    my $self = shift;
    $self->set_state('menu');
    
    $self->{clock}->start;
    my $prev_time_delta = $self->clock->get_ticks();
    while (1) {
        my $time_delta = $self->clock->get_ticks() - $prev_time_delta;
        $self->handle_events();
        $self->update($time_delta);
        $self->{window}->draw();
        $prev_time_delta += $time_delta;
    }
}

# allows the engine to handle common events (e.g. window resizes, quitting the game), and pass off unhandled events to the current state
sub handle_events() {
    my $self = shift;
    my $events = SDL::Event->new();
    $self->current_state->handle_events($events); 
}

# runs the main engine logic and the current state's logic with the same update interval, keeping everything in sync
sub update {
    my ($self, $time_delta) = @_;
    $self->{current_state}->update($time_delta);
}

sub window {
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