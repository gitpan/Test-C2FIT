package Test::C2FIT;

#use 5.008006;
use Test::C2FIT::FileRunner;
use Test::C2FIT::WikiRunner;
use Exporter();
@ISA = qw(Exporter);
@EXPORT = qw(file_runner wiki_runner);
use strict;
use warnings;

our $VERSION = '0.03';

sub file_runner {
    unshift(@INC,'.') unless grep { /^\.$/ } @INC;
    new Test::C2FIT::FileRunner()->run(@ARGV);
}

sub wiki_runner {
    unshift(@INC,'.') unless grep { /^\.$/ } @INC;
    new Test::C2FIT::WikiRunner()->run(@ARGV);
}

1;

__END__
=head1 Test::C2FIT

Test::C2FIT - A direct Perl port of Ward Cunningham's FIT 
acceptance test framework for Java.

=head1 SYNOPSIS

    FileRunner.pl input_containing_fit_tests.html test_results.html

    perl -MTest::C2FIT -e file_runner input_containing_fit_tests.html test_results.html

=head1 DESCRIPTION

Great software requires collaboration and communication. Fit is a tool for
enhancing collaboration in software development. It's an invaluable way
to collaborate on complicated problems - and get them right - early
in development.

Fit allows customers, testers, and programmers to learn what their 
software should do and what it does do. It automatically compares
customers' expectations to actual results.

This port of FIT has a featureset equivalent to v1.1 of FIT.  
Dave W. Smith's original port was based on fit-b021021j and I've updated 
most of the core to match the 1.1 version.

This port passes the current FIT spec and also implements a all of the
examples.

=head1 GOTCHAS AND LIMITATIONS

1) Java is a strongly typed language; Perl is not. The Java version of FIT
cares a lot about types, but Perl takes a more relaxed view of things and
this port reflects that.

2) Perl supports limited introspection. Because there are no method signatures,
it isn't possible to determine method return types. If you want to use
TypeAdapters you have to supply hints. (see examples)

3) Some of the tests from the 'examples' directory expect Java behaviour for
arithmetic (e.g. integer overflow).  Perl doesn't have this type of overflow
so these tests will "fail".

4) The MusicExample uses a clock that doesn't have millisecond accuracy. This
throws off the clock by a second during one of the tests.

5) Perl supports a limited set of primitive types. Dave has used a
GenericTypeAdapter that knows about strings and numbers (and pretends
to know about booleans).


=head1 SEE ALSO

Extensive and up-to-date documentation on FIT can be found at:
http://fit.c2.com/

The 'examples' directory of this distribution contains some sample FIT
tests and sample applications that they test.  Invoke FileRunner.pl on
any of the test input files from examples/input and view the output in
a browser. To invoke the tests use gmake (if you have :) or 
do_tests.bat / do_tests.sh

The directory examples-perl contains examples written for this perl-port
only.

You should also examine and run the tests in the 'spec' directory.
These are FIT's own acceptance tests.

=head1 AUTHOR

Original port from the Java version by Dave W. Smith.

Updates and modifications by Tony Byrne E<lt>fit4perl@byrnehq.comE<gt>.
Further modifications by Martin Busik E<lt>martin.busik@busik.deE<gt>.

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2002-2006 Cunningham & Cunningham, Inc.
Released under the terms of the GNU General Public License version 2 or later.


=cut
