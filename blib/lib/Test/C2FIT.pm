package Test::C2FIT;

#use 5.008006;
use strict;
use warnings;

our $VERSION = '0.01';

1;

__END__
=head1 Test::C2FIT

Test::C2FIT - A direct Perl port of Ward Cunningham's FIT 
acceptance test framework for Java.

=head1 SYNOPSIS

    FileRunner.pl input_containing_fit_tests.html test_results.html

=head1 DESCRIPTION

Great software requires collaboration and communication. Fit is a tool for
enhancing collaboration in software development. It's an invaluable way
to collaborate on complicated problems - and get them right - early
in development.

Fit allows customers, testers, and programmers to learn what their 
software should do and what it does do. It automatically compares
customers' expectations to actual results.

This port of FIT has a featureset that lies somewhere between
Java versions b021021j and v1.1 of FIT.  Dave W. Smith's original port
was based on fit-b021021j and I've updated most of the core to match the
1.1 version.

This port passes the current FIT spec and also implements a subset of the
examples, including the complex MusicExample.

=head1 GOTCHAS AND LIMITATIONS

1) Java is a strongly typed language; Perl is not. The Java version of FIT
cares a lot about types, but Perl takes a more relaxed view of things and
this port reflects that.

2) Perl supports limited introspection. Because there are no method signatures,
it isn't possible to determine method return types. Without known return
types, the "right" TypeAdapters can't be set up. This can cause problems
with RowFixtures and ActionFixtures.

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
a browser.

You should also examine and run the tests in the 'spec' directory.
These are FIT's own acceptance tests.

=head1 AUTHOR

Original port from the Java version by Dave W. Smith.

Updates and modifications by Tony Byrne E<lt>fit4perl@byrnehq.comE<gt>.

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2002-2005 Cunningham & Cunningham, Inc.
Released under the terms of the GNU General Public License version 2 or later.


=cut
