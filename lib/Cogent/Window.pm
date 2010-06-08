package Cogent::Window;

# Moose stuff
use Moose;

# SDL stuff
use SDL;
use SDL::Surface;
use SDL::Rect;
use SDL::Constants;

# Cogent stuff


has 'surface' => {
    is => 'rw',
    isa => 'SDL::Surface'
};

has 'draw_queue' => {
    is => 'rw',
    isa => 'ArrayRef',
    default => ()
};

sub new {
    my ($self, $config) = @_;
    $self = $self->prototype() unless ref $self;
    $self->{config} = $config;
    $self->surface( SDL::Video::set_video_mode($config->{w},
                                                  $config->{h},
                                                  $config->{bpp},
                                                  $config->{flags}));

}

sub draw {
    my $self = shift;
    
    my @items = sort {$a->z_pos <=> $b->z_pos} @$self->get_draw_queue;
    foreach my $item (@items) {
        $item->draw;
    }
    
    # clear the queue to prepare for the next round of drawing
    $self->{draw_queue} = [];
}

sub add_drawable {
    my ($self, $item) = @_;
    push @{$self->{draw_queue}}, $item;
}

sub surface {
    my $self = shift;
    return $self->{surface};
}

1;