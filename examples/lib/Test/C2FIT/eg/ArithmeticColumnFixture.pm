# ArithmeticColumnFixture.pm
#
# Copyright (c) 2002-2005 Cunningham & Cunningham, Inc.
# Released under the terms of the GNU General Public License version 2 or later.
#
# Perl translation by Dave W. Smith <dws@postcognitive.com>
# Modified by Tony Byrne <fit4perl@byrnehq.com>

package Test::C2FIT::eg::ArithmeticColumnFixture;

use base 'Test::C2FIT::ColumnFixture';
use strict;

sub new
{
	my $pkg = shift;
	return $pkg->SUPER::new(x => 0, y => 0, @_);
}

sub plus
{
	my $self = shift;
	return $self->{'x'} + $self->{'y'};
}

sub minus
{
	my $self = shift;
	return $self->{'x'} - $self->{'y'};
}

sub times
{
	my $self = shift;
	return $self->{'x'} * $self->{'y'};
}

sub divide
{
	my $self = shift;
	return $self->{'x'} / $self->{'y'};
}

sub floating
{
	my $self = shift;
	return $self->{'x'} / $self->{'y'};
}

1;
