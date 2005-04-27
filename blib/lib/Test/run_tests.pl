#!/usr/bin/perl -w

# $Id: run_tests.pl,v 1.4 2005/04/27 13:16:29 tonyb Exp $
#
# Copyright (c) 2002-2005 Cunningham & Cunningham, Inc.
# Released under the terms of the GNU General Public License version 2 or later.
#
# Written by Tony Byrne <fit4perl@byrnehq.com>

use strict;
use lib qw( lib t/lib examples/lib );
use Test::Unit::TestRunner;

my @tests = @ARGV ? @ARGV : 'Test::C2FIT::test::AllTests';
my $testrunner = Test::Unit::TestRunner->new();

while (my $test = shift @tests)
{
	my $package = &pathToPackageName($test);
	$testrunner->start($test);
}

sub pathToPackageName
{
	my $path = shift;
	my $package = $path;
	$package =~ s/^t\/lib\///;
	$package =~ s/\.pm$//g;
	$package =~ s/\//::/g;
	return $package;
}