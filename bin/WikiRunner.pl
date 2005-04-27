#!/usr/bin/perl -w

# $Id: WikiRunner.pl,v 1.4 2005/04/27 14:54:16 tonyb Exp $
#
# Copyright (c) 2002-2005 Cunningham & Cunningham, Inc.
# Released under the terms of the GNU General Public License version 2 or later.
#
# Perl translation by Dave W. Smith <dws@postcognitive.com>
# Modified by Tony Byrne <fit4perl@byrnehq.com>

$|++;

use strict;
use lib qw( lib t/lib spec/fat examples/lib );
use Test::C2FIT::WikiRunner;
new Test::C2FIT::WikiRunner()->run(@ARGV);

