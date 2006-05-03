# $Id: FileRunner.pm,v 1.7 2006/05/03 09:36:34 tonyb Exp $
#
# Copyright (c) 2002-2005 Cunningham & Cunningham, Inc.
# Released under the terms of the GNU General Public License version 2 or later.
#
# Perl translation by Dave W. Smith <dws@postcognitive.com>
# Modified by Tony Byrne <fit4perl@byrnehq.com>

package Test::C2FIT::FileRunner;

use strict;
use IO::File;
use Test::C2FIT::Parse;
use Test::C2FIT::Fixture;

sub new
{
	my $pkg = shift;
    return bless { input => undef, tables => undef, output => undef,
		fixture => new Test::C2FIT::Fixture(), @_ }, $pkg;
}

sub run
{
	my $self = shift;
	my(@argv) = @_;
	$self->argv(@argv);
	$self->process();
	$self->_exit();
}

sub argv
{
	my $self = shift;
	my(@argv) = @_;

	die "usage: FileRunner.pl input-file output-file\n"
		unless 2 == @argv;

	$Test::C2FIT::Fixture::summary{'input file'} = $argv[0];
	$Test::C2FIT::Fixture::summary{'output file'} = $argv[1];
	
	my $in = new IO::File($argv[0], "r") or die "$argv[0]: $!\n";
	$self->{'input'} = join("", <$in>);
	my $out = new IO::File($argv[1], "w") or die "$argv[1]: $!\n";
	$self->{'output'} = $out;

	my @inputFileStat = stat($argv[0]);
	my $inputUpdateTime = localtime($inputFileStat[9]);
	$Test::C2FIT::Fixture::summary{'input update'} = $inputUpdateTime;

}

sub process
{
	my $self = shift;

	use Benchmark;
	eval
	{
		if ($self->{'input'} =~ /<wiki>/)
		{
			$self->{'tables'} = new Test::C2FIT::Parse($self->{'input'}, ['wiki','table','tr','td']);
			$self->{'fixture'}->doTables($self->{'tables'}->parts());
		}
		else
		{
			$self->{'tables'} = new Test::C2FIT::Parse($self->{'input'}, ['table','tr','td']);
			$self->{'fixture'}->doTables($self->{'tables'});
		}
	};
    if ( $@ )
	{
		$self->exception($@);
    }

	$self->{'output'}->print( $self->{'tables'}->asString());
}

sub exception
{
	my $self = shift;
	my($exception) = @_;

	# $self->{'tables'} = new Parse("Unable to parse input. Input ignored.", undef);
	# $self->{'fixture'}->exception($self->{'tables'}, $exception);

	print $exception;
	exit(-1);
}

sub _exit
{
	my($self) = @_;
	$self->{'output'}->close();
    my $counts = $self->{fixture}->{counts};
    print STDERR $counts->toString(),"\n";
	exit( $counts->{wrong} + $counts->{exceptions} );
}

1;
