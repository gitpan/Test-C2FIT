# Copyright (c) 2002-2005 Cunningham & Cunningham, Inc.
# Released under the terms of the GNU General Public License version 2 or later.
#
# Perl translation by Tony Byrne <fit4perl@byrnehq.com>

package Test::C2FIT::fat::ReferenceFixture;
use base 'Test::C2FIT::ColumnFixture';

use strict;

use Error qw( :try );
#use Test::C2FIT::Parse;
use Test::C2FIT::Fixture;
use Test::C2FIT::FileRunner;

sub Result
{
	my $self = shift;
	my $inputFileName  = "spec/input/" . $self->{'Location'};
	my $outputFileName = "spec/output/" . $self->{'Location'};
	my $result;
	try
	{
		my $runner = new Test::C2FIT::FileRunner();
		$runner->argv($inputFileName, $outputFileName);
		$runner->process();
		$runner->{'output'}->close();

		my $counts = $runner->{'fixture'}->counts();
		if ($counts->{'exceptions'} == 0 and $counts->{'wrong'} == 0)
		{
			$result = "pass";
		}
		else
		{
			$result = "fail: " . $counts->{'right'} . " right, " . $counts->{'wrong'} 
					. " wrong, " . $counts->{'exceptions'} . " exceptions";

		}

	}
	otherwise
	{
		my $e = shift;
		$result = "file not found: $e\n";
	};
	
	return $result;
}

1;

__END__

package fat;

import fit.*;
import java.io.*;

/** A fixture that processes other Fit documents. */
public class ReferenceFixture extends ColumnFixture {
	public String Description;
	public String Location;
	public String Note;

	public String Result() {
		String inputFileName = "../../spec/" + Location;
		String outputFileName = "output/spec/" + Location;
		try {
			FileRunner runner = new FileRunner();
			runner.args(new String[]{inputFileName, outputFileName});
			runner.process();
			runner.output.close();

			Counts counts = runner.fixture.counts;
			if ((counts.exceptions == 0) && (counts.wrong == 0)) {
				return "pass";
			}
			else {
				return "fail: " + counts.right + " right, " + counts.wrong + " wrong, " + counts.exceptions + " exceptions";
			}
		}
		catch (IOException e) {
			File inputFile = new File(inputFileName);
			String fileDescription;
			try {
				fileDescription = inputFile.getCanonicalPath();
			}
			catch (IOException e2) {
				fileDescription = inputFile.getAbsolutePath();
			}
			return "file not found: " + fileDescription;
		}
	}
}
