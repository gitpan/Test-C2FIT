# $Id: ColumnFixture.pm,v 1.5 2006/05/03 09:36:34 tonyb Exp $
#
# Copyright (c) 2002-2005 Cunningham & Cunningham, Inc.
# Released under the terms of the GNU General Public License version 2 or later.
#
# Perl translation by Dave W. Smith <dws@postcognitive.com>
# Modified by Tony Byrne <fit4perl@byrnehq.com>

package Test::C2FIT::ColumnFixture;

use base 'Test::C2FIT::Fixture';
use strict;
use Test::C2FIT::TypeAdapter;

sub new
{
	my $pkg = shift;
	return $pkg->SUPER::new(columnBindings => [], hasExecuted => 0, @_);
}

sub doRows
{
	my $self = shift;
	my($rows) = @_;
	$self->bind($rows->parts());
	$self->SUPER::doRows($rows->more());
}

sub doRow
{
	my $self = shift;
	my($row) = @_;

	$self->{'hasExecuted'} = 0;
	eval
	{
		$self->reset();
		$self->SUPER::doRow($row);
		$self->execute unless $self->{'hasExecuted'};
	};
	if ( $@ ) {
		$self->exception($row->leaf(), $@);
	}
}

sub doCell
{
	my $self = shift;
	my($cell, $column) = @_;

	my $adapter = $self->{'columnBindings'}->[$column];
	eval
	{
		my $string = $cell->text();
		if ( $string eq "" )
		{
	    	$self->check($cell, $adapter);
		}
		elsif ( not defined($adapter) )
		{
			$self->ignore($cell);
		}
		elsif ( $adapter->field() )
		{
			$adapter->set($adapter->parse($string));
		}
		elsif ( $adapter->method() )
		{
			$self->check($cell, $adapter);
		}
	};
	if ( $@ )
	{
		$self->exception($cell, $@);
	}
}

sub check
{
	my $self = shift;
	my($cell, $adapter) = @_;

	if ($self->{'hasExecuted'}) {
    	$self->SUPER::check(@_);
    } 
    elsif ( ! $self->{'hasExecuted'} )
	{
  		$self->{'hasExecuted'} = 1;
		eval
		{
			$self->execute();
        	$self->SUPER::check(@_);
		};
		if ( $@ )
		{
			$self->exception($cell, $@);
		}
	}
}

sub reset
{
	my($self) = @_;
	# about to process first cell of row
}

sub execute
{
	my($self) = @_;
	# about to process first method call of row
}

sub bind
{
	my($self, $heads) = @_;
	my $column = 0;

	$self->{'columnBindings'} = [];
	while ( $heads )
	{
		my $name = $heads->text();
		eval
		{
			if ( $name eq "" )
			{
				$self->{'columnBindings'}->[$column] = undef;
	    		}
			elsif ( $name =~ /^(.*)\(\)$/ )
			{
				$self->{'columnBindings'}->[$column] = $self->bindMethod($1);
			}
			else
			{
				$self->{'columnBindings'}->[$column] = $self->bindField($name);
			}
		};
		if ( $@ )
		{
			$self->exception($heads, $@);
		}
		$heads = $heads->more();
		++$column;
	}
}

sub bindMethod
{
	my $self = shift;
	my($name) = @_;
	return Test::C2FIT::TypeAdapter::onMethod($self, $name);
}

sub bindField
{
	my $self = shift;
	my($name) = @_;
	return Test::C2FIT::TypeAdapter::onField($self, $name);
}

sub getTargetClass
{
	my $self = shift;
	ref($self);
}

1;

__END__

package fit;

// Copyright (c) 2002 Cunningham & Cunningham, Inc.
// Released under the terms of the GNU General Public License version 2 or later.

public class ColumnFixture extends Fixture {

    protected TypeAdapter columnBindings[];
    protected boolean hasExecuted = false;

    // Traversal ////////////////////////////////

    public void doRows(Parse rows) {
        bind(rows.parts);
        super.doRows(rows.more);
    }

    public void doRow(Parse row) {
        hasExecuted = false;
        try {
            reset();
            super.doRow(row);
            if (!hasExecuted) {
                execute();
            }
        } catch (Exception e) {
            exception (row.leaf(), e);
        }
    }

    public void doCell(Parse cell, int column) {
        TypeAdapter a = columnBindings[column];
        try {
            String text = cell.text();
            if (text.equals("")) {
                check(cell, a);
            } else if (a == null) {
                ignore(cell);
            } else if (a.field != null) {
                a.set(a.parse(text));
            } else if (a.method != null) {
                check(cell, a);
            }
        } catch(Exception e) {
            exception(cell, e);
        }
    }

    public void check(Parse cell, TypeAdapter a) {
        if (!hasExecuted) {
            try {
                execute();
            } catch (Exception e) {
                exception (cell, e);
            }
            hasExecuted = true;
        }
        super.check(cell, a);
    }

    public void reset() throws Exception {
        // about to process first cell of row
    }

    public void execute() throws Exception {
        // about to process first method call of row
    }

    // Utility //////////////////////////////////

    protected void bind (Parse heads) {
        columnBindings = new TypeAdapter[heads.size()];
        for (int i=0; heads!=null; i++, heads=heads.more) {
            String name = heads.text();
            String suffix = "()";
            try {
                if (name.equals("")) {
                    columnBindings[i] = null;
                } else if (name.endsWith(suffix)) {
                    columnBindings[i] = bindMethod(name.substring(0,name.length()-suffix.length()));
                } else {
                    columnBindings[i] = bindField(name);
                }
            }
            catch (Exception e) {
                exception (heads, e);
            }
        }

    }

    protected TypeAdapter bindMethod (String name) throws Exception {
        return TypeAdapter.on(this, getTargetClass().getMethod(camel(name), new Class[]{}));
    }

    protected TypeAdapter bindField (String name) throws Exception {
        return TypeAdapter.on(this, getTargetClass().getField(camel(name)));
    }

    protected Class getTargetClass() {
        return getClass();
    }
}
