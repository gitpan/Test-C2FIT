# $Id: PrimitiveFixture.pm,v 1.2 2005/04/27 13:16:29 tonyb Exp $
#
# Copyright (c) 2002-2005 Cunningham & Cunningham, Inc.
# Released under the terms of the GNU General Public License version 2 or later.
#
# Perl translation by Dave W. Smith <dws@postcognitive.com>
# Modified by Tony Byrne <fit4perl@byrnehq.com>

package Test::C2FIT::PrimitiveFixture;

use base 'Test::C2FIT::Fixture';
use strict;
use Test::C2FIT::TypeAdapter;

sub checkValue
{
	my $self = shift;
	my($cell, $value) = @_;

	if ( Test::C2FIT::TypeAdapter::equals(undef, $cell->text(), $value) )
	{
		$self->right($cell);
	} 
	else
	{
		$self->wrong($cell, $value);
	}
}

1;
