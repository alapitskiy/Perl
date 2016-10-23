package ALAP::Fitech::Biotech::Html::Tags;

package SuperTag;

use Moose;

with qw(Attributable Printable);

sub add_attribute {
  my $self = shift;
  my $name = shift;

  if (my $att = $self->get_attr($name)) {
    $att->push_val(+shift);
  }
  else {
    my $values = shift;

    my $att_new = Attribute->new(name => $name);

    $att_new->push_val(ref $values ? @$values : $values);

    $self->push_att($att_new);
  }
}

sub to_string {
  my $self = shift;

  my $att_str = join(' ', map {$_->to_string} @{$self->attributes});

  my $inner = inner() // q"";
  $inner =~ s/^(.)/  $1/mg;

  return q"<div" . ( $att_str ? " $att_str" : q"" ) . ">\n" . $inner . "\n</div>";
}

package Tag;
use Moose;

extends 'SuperTag';

has tags => (
  is => 'ro',
  isa => 'ArrayRef[SuperTag]',
  default => sub {[]},

  traits => ['Array'],
  handles => {
    push_tag => 'push',
  }
);

augment to_string => sub {
  my $self = shift;

  return (join "\n", map {$_->to_string} @{$self->tags}) . (inner() // q"");
};

package LeafTag;
use Moose;

extends 'SuperTag';

has content => (
  is => 'ro',
  isa => 'Value',
  required => 1,
  default => q"",
);

around BUILDARGS => sub {
  my ($orig, $class) = (shift, shift);

  if (@_ == 1 and ! ref $_[0]) {
    return $class->$orig(content => $_[0]);
  }
  else {
    return $class->$orig(@_);
  }
};

augment to_string => sub {
  return $_[0]->content . (inner() // q"");
};

1;

BEGIN {
#  package ALAP::Fitech::Biotech::Html::Printable;
  package Printable;

  use Moose::Role;

  requires 'to_string';

#  package ALAP::Fitech::Biotech::Html::Attribute;
  package Attribute;

  use Moose;

  with qw(Printable);

  has name => (
    is => 'ro',
    isa => 'Str',
    required => 1,
  );

  has values => (
    traits => ['Array'],
    is => 'ro',
    isa => 'ArrayRef[Str]',
    default => sub {[]},
    handles => {
      push_val => 'push',
    },
  );

  sub to_string {
    my $self = shift;

    $self->name() . '="' . join(' ', @{$self->values}) . '"';
  }

  package Attributable;

  use Moose::Role;

  use List::Util 'first';

  has 'attributes' => (
    traits => ['Array'],
    is => 'ro',
#    isa => 'ArrayRef[ALAP::Fitech::Biotech::Html::Attribute]',
    isa => 'ArrayRef[Attribute]',
    default => sub {[]},
    handles => {
      push_att => 'push',
    }
  );

  sub get_attr {
    my ($self, $name) = @_;

    return first {$_->name eq $name} @{$self->attributes};
  }
}

