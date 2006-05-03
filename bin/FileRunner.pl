#!/usr/bin/perl -w

# $Id: FileRunner.pl,v 1.5 2006/05/03 17:07:29 tonyb Exp $
#
# Copyright (c) 2002-2005 Cunningham & Cunningham, Inc.
# Released under the terms of the GNU General Public License version 2 or later.
#
# Perl translation by Dave W. Smith <dws@postcognitive.com>
# Modified by Tony Byrne <fit4perl@byrnehq.com>

$|++;

use lib qw( lib t/lib spec/fat examples/lib );
use strict;
use Test::C2FIT::FileRunner;
new Test::C2FIT::FileRunner()->run(@ARGV);
