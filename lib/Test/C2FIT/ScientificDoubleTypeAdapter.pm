#
# Martin Busik <martin.busik@busik.de>

package Test::C2FIT::ScientificDoubleTypeAdapter;
use base 'Test::C2FIT::TypeAdapter';
use Test::C2FIT::ScientificDouble;

sub parse {
    my $self = shift;
    my $value = shift;
    return Test::C2FIT::ScientificDouble->new($value);
}

sub toString {
    my ($self,$value) = @_;
    return $value->toString;
}

sub equals {
    my ($self,$a,$b) = @_;
    return $a->equals($b);
}

1;
