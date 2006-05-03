# $Id: GenericArrayAdapter.pm,v 1.3 2006/05/03 09:36:34 tonyb Exp $
#
# Copyright (c) 2002-2005 Cunningham & Cunningham, Inc.
# Released under the terms of the GNU General Public License version 2 or later.
#
# Perl translation by Dave W. Smith <dws@postcognitive.com>
# Modified by Tony Byrne <fit4perl@byrnehq.com>


package Test::C2FIT::GenericArrayAdapter;

use strict;
use vars qw(@ISA);
@ISA = qw(Test::C2FIT::TypeAdapter);

sub parse {
    my $self = shift;
    my($s) = @_;

    return [ split(/,/, $s) ];
}

sub toString {
    my $self = shift;
    my($o) = @_;

    return join(',', @$o);
}

sub equals {
    my $self = shift;
    my($a, $b) = @_;

    return 0 unless ref($a) eq "ARRAY";
    return 0 unless ref($b) eq "ARRAY";

#DEBUG print "ArrayArrayAdapter::equals ", ref($a), ", ", ref($b), "\n";
    return 0 if scalar @$a != scalar @$b;
    for ( my $i = 0; $i < scalar @$a ; ++$i ) {
	return 0 if $$a[$i] ne $$b[$i]
    }
    return 1;
}

1;
