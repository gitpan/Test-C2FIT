package NullFkWrapper;

#
#   TypeAdapter for columns/fields/method-Params/method-Results
#   which shall contain undef (null) too.
#
#   This is necessary especially when you want to "enter" a null,
#   e.g. in a Column- or ActionFixture.
#

use strict;
use base 'Test::C2FIT::TypeAdapter';

sub parse {
    my $self = shift;
    my($s) = @_;

    return undef unless defined($s);
    return undef if $s eq "NULL";
    return $s;
}

#
# need to be implemented, since we store a scalar value,
# not a reference to an object...
#

=pod
sub equals {
    my ($self,$a,$b) = @_;
    if(!defined($a)) {
        return !defined($b);
    }
    warn "EQ: $a $b\n";
    return $a eq $b;
}
=cut

1;
