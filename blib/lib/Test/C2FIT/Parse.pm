# $Id: Parse.pm,v 1.14 2005/04/27 13:16:29 tonyb Exp $
#
# Copyright (c) 2002-2005 Cunningham & Cunningham, Inc.
# Released under the terms of the GNU General Public License version 2 or later.
#
# Perl translation by Dave W. Smith <dws@postcognitive.com>
# Modified by Tony Byrne <fit4perl@byrnehq.com>

package Test::C2FIT::Parse;

use strict;

use vars qw(@tags);

use Test::C2FIT::ParseException;

our @tags = qw(table tr td);
our $MAX_VALUE = 99999999999999999999999999;

sub new
{
	my $pkg = shift;
	my $class = ref $pkg || $pkg;
	my $self = bless { }, $class;
	$self->_parse(@_);
	return $self;
}

sub from
{
	my $pkg = shift;
	my($tag,$body,$parts,$more) = @_;
	bless
	{
		leader	=> "\n",
		tag		=> "<$tag>",
		body	=> $body,
		parts	=> $parts,
		end		=> "</$tag>",
		more	=> $more,
		trailer	=> ""
	}, $pkg;
}

sub _parse
{
	my $self = shift;
	my ($text, $tags, $level, $offset) = @_;
	$tags = \@tags unless $tags;
	$level = 0 unless $level;
	$offset = 0 unless $offset;

	my $lc = lc($text);

	my $startTag	= index($lc, "<" . $tags->[$level]);
	my $endTag		= index($lc, ">", $startTag) + 1;
	my $startEnd	= $self->findMatchingEndTag($lc, $endTag, $tags->[$level], $offset);
	my $endEnd		= index($lc, ">", $startEnd) + 1;
	my $startMore	= index($lc, "<" . $tags->[$level], $endEnd);

	if ($startTag < 0 or $endTag < 0 or $startEnd < 0 or $endEnd < 0)
	{
		throw Test::C2FIT::ParseException ("Can't find tag: " . $tags->[$level] . "\n", $offset);
	}

	$self->{'leader'} 	= substr($text,0,$startTag);
	$self->{'tag'}	 	= substr($text,$startTag,$endTag - $startTag);
	$self->{'body'}		= substr($text,$endTag,$startEnd - $endTag);
	$self->{'end'}		= substr($text,$startEnd,$endEnd - $startEnd);
	$self->{'trailer'}	= substr($text,$endEnd);

	if ($level + 1 < scalar @{$tags})
	{
		$self->{'parts'} = $self->new($self->{'body'}, $tags, $level + 1, $offset + $endTag);
		$self->{'body'} = undef;
	}
	else
	{ 
		#Check for nested table
		my $index = index($self->{'body'}, "<" . $tags->[0]);
		if ($index >= 0)
		{
				$self->{'parts'} = $self->new($self->{'body'}, $tags, 0, $offset + $endTag);
				$self->{'body'} = '';
		}
	}

	if ($startMore >= 0)
	{
		$self->{'more'} = $self->new($self->{'trailer'}, $tags, $level, $offset + $endEnd);
		$self->{'trailer'} = undef;
	}
}

sub findMatchingEndTag
{
	my $self = shift;
	my ($lc, $matchFromHere, $tag, $offset) = @_;
	
	my $fromHere = $matchFromHere;
	my $count = 1;
	my $startEnd = 0;

	while ($count > 0)
	{
		my $embeddedTag 	= index($lc, "<$tag", $fromHere);
		my $embeddedTagEnd	= index($lc, "</$tag", $fromHere);

		# Which one is closer?
		throw Test::C2FIT::ParseException("Can't find tag: $tag\n", $offset)
			if ($embeddedTag < 0 and $embeddedTagEnd < 0);

		$embeddedTag 	= $MAX_VALUE if ($embeddedTag < 0); 
		$embeddedTagEnd	= $MAX_VALUE if ($embeddedTagEnd < 0);

		if ($embeddedTag < $embeddedTagEnd)
		{
			$count++;
			$startEnd = $embeddedTag;
			$fromHere = index($lc, ">" , $embeddedTag) + 1;
		}
		elsif ($embeddedTagEnd < $embeddedTag)
		{
			$count--;
			$startEnd = $embeddedTagEnd;
			$fromHere = index($lc, ">", $embeddedTagEnd) + 1;
		}
	}
	return $startEnd;
}


sub size
{
	my $self = shift;
	$self->more() ? $self->more()->size() + 1 : 1;
}

sub last
{
	my $self = shift;
	$self->more() ? $self->more()->last() : $self;
}

sub leaf
{
	my $self = shift;
	$self->parts() ? $self->parts()->leaf() : $self;
}

sub at
{
	my $self = shift;

	return $self->_at3(@_) if 3 == @_;
	return $self->_at2(@_) if 2 == @_;
	return ($_[0] == 0 || not defined($self->more()))
		? $self
		: $self->more()->at($_[0] - 1);
}

sub _at2
{			#TBD revisit this
	my $self = shift;
	return $self->at($_[0])->parts()->at($_[1]);
}

sub _at3
{			#TBD revisit this
	my $self = shift;
	return $self->_at2($_[0], $_[1])->parts()->at($_[2]);
}

sub text
{
	my $self = shift;
	return $self->htmlToText($self->body());
}

sub htmlToText
{
	my $self = shift;
	my $s = shift;
	return $s unless $s;
	$s = $self->normalizeLineBreaks($s);
	$s = $self->removeNonBreakTags($s);
	$s = $self->condenseWhitespace($s);
	$s = $self->unescape($s);
	return $s;
}

sub removeNonBreakTags
{
	my $self = shift;
	my $s = shift;
	$s =~ s/(<(?!br)[^>]+>)//g;
	return $s;
}

sub unescape
{
	my $self = shift;
	my $s = shift;

	$s =~ s|<br />|\n|g;
	$s = $self->unescapeEntities($s);
	$s = $self->unescapeSmartQuotes($s);

	return $s;
}

sub unescapeSmartQuotes
{
	my $self = shift;
	my $s = shift;

	$s =~ s/\x{91}/\'/g;
	$s =~ s/\x{92}/\'/g;
	$s =~ s/\x{93}/\"/g;
	$s =~ s/\x{94}/\"/g;

	$s =~ s/\x{201c}/\"/g;
	$s =~ s/\x{201d}/\"/g;
	$s =~ s/\x{2018}/\'/g;
	$s =~ s/\x{2019}/\'/g;

	return $s;
}

sub unescapeEntities
{
	my $self = shift;
	my $s = shift;
	$s =~ s/\&lt;/</g;
	$s =~ s/\&gt;/>/g;
	$s =~ s/\&nbsp;/ /g;
	$s =~ s/\&amp;/&/g;
	$s =~ s/\&quot;/\"/g;
	return $s;
}

sub normalizeLineBreaks
{
	my $self = shift;
	my $s = shift;
	$s =~ s|<\s*br\s*/?\s*>|<br />|g;
	$s =~ s|<\s*/\s*p\s*>\s*<\s*p( .*?)?>|<br />|g;
	return $s;
}

sub unformat
{
	my $self = shift;
	my $s = shift;
	$s =~ s/<[^>]+>//g;
	return $s;
}

sub addToTag
{
	my $self = shift;
	my($string) = @_;
	$self->{'tag'} =~ s/>$/$string>/;
}

sub addToBody
{
    my $self = shift;
    my($string) = @_;
    $self->{'body'} .= $string;
}

sub asString
{
	my $self = shift;

	my $s = $self->leader() . $self->tag();
	if ( $self->parts() )
	{
		$s .= $self->parts()->asString();
	}
	else
	{
		$s .= $self->body();
	}
	$s .= $self->end();
	if ( $self->more() )
	{
		$s .= $self->more()->asString();
	}
	else
	{
		$s .= $self->trailer();
	}
	return $s;
}


sub leader
{
	$_[0]->{'leader'}
}

sub tag
{
	$_[0]->{'tag'}
}

sub body
{
	$_[0]->{'body'}
}

sub parts
{
	$_[0]->{'parts'}
}

sub end
{
	$_[0]->{'end'}
}

sub trailer 
{
	$_[0]->{'trailer'}
}

sub more
{
	my $self = shift;
	$self->{'more'} = $_[0] if @_;
	return $self->{'more'};
}

# TBD print() is required by the tests. TJB
sub print
{
	my $self = shift;
	return $self->asString();
}

sub condenseWhitespace
{
	my $self = shift;
	my $s = shift;

	my $NON_BREAKING_SPACE = chr(160);

	$s =~ s/\s+/ /g;
	$s =~ s/&nbsp;/ /g;
	$s =~ s/$NON_BREAKING_SPACE/ /g;
	$s =~ s/^\s+//g;
	$s =~ s/\s+$//g;

	return $s;
}

1;

__END__

package fit;

// Copyright (c) 2002 Cunningham & Cunningham, Inc.
// Released under the terms of the GNU General Public License version 2 or later.

import java.io.*;
import java.text.ParseException;

public class Parse {

    public String leader;
    public String tag;
    public String body;
    public String end;
    public String trailer;

    public Parse more;
    public Parse parts;

    public Parse (String tag, String body, Parse parts, Parse more) {
        this.leader = "\n";
        this.tag = "<"+tag+">";
        this.body = body;
        this.end = "</"+tag+">";
        this.trailer = "";
        this.parts = parts;
        this.more = more;
    }

    public static String tags[] = {"table", "tr", "td"};

    public Parse (String text) throws ParseException {
        this (text, tags, 0, 0);
    }

    public Parse (String text, String tags[]) throws ParseException {
        this (text, tags, 0, 0);
    }

    public Parse (String text, String tags[], int level, int offset) throws ParseException {
        String lc = text.toLowerCase();
        int startTag = lc.indexOf("<"+tags[level]);
        int endTag = lc.indexOf(">", startTag) + 1;
//        int startEnd = lc.indexOf("</"+tags[level], endTag);
		int startEnd = findMatchingEndTag(lc, endTag, tags[level], offset);
        int endEnd = lc.indexOf(">", startEnd) + 1;
        int startMore = lc.indexOf("<"+tags[level], endEnd);
        if (startTag<0 || endTag<0 || startEnd<0 || endEnd<0) {
            throw new ParseException ("Can't find tag: "+tags[level], offset);
        }

        leader = text.substring(0,startTag);
        tag = text.substring(startTag, endTag);
        body = text.substring(endTag, startEnd);
        end = text.substring(startEnd,endEnd);
        trailer = text.substring(endEnd);

        if (level+1 < tags.length) {
            parts = new Parse (body, tags, level+1, offset+endTag);
            body = null;
        }
		else { // Check for nested table
			int index = body.indexOf("<" + tags[0]);
			if (index >= 0) {
				parts = new Parse(body, tags, 0, offset + endTag);
				body = "";
			}
		}

        if (startMore>=0) {
            more = new Parse (trailer, tags, level, offset+endEnd);
            trailer = null;
        }
    }

	/* Added by Rick Mugridge, Feb 2005 */
	protected static int findMatchingEndTag(String lc, int matchFromHere, String tag, int offset) throws ParseException {
		int fromHere = matchFromHere;
		int count = 1;
		int startEnd = 0;
		while (count > 0) {
			int embeddedTag = lc.indexOf("<" + tag, fromHere);
			int embeddedTagEnd = lc.indexOf("</" + tag, fromHere);
			// Which one is closer?
			if (embeddedTag < 0 && embeddedTagEnd < 0)
				throw new ParseException("Can't find tag: " + tag, offset);
			if (embeddedTag < 0)
				embeddedTag = Integer.MAX_VALUE;
			if (embeddedTagEnd < 0)
				embeddedTagEnd = Integer.MAX_VALUE;
			if (embeddedTag < embeddedTagEnd) {
				count++;
				startEnd = embeddedTag;
				fromHere = lc.indexOf(">", embeddedTag) + 1;
			}
			else if (embeddedTagEnd < embeddedTag) {
				count--;
				startEnd = embeddedTagEnd;
				fromHere = lc.indexOf(">", embeddedTagEnd) + 1;
			}
		}
		return startEnd;
	}

    public int size() {
        return more==null ? 1 : more.size()+1;
    }

    public Parse last() {
        return more==null ? this : more.last();
    }

    public Parse leaf() {
        return parts==null ? this : parts.leaf();
    }

    public Parse at(int i) {
        return i==0 || more==null ? this : more.at(i-1);
    }

    public Parse at(int i, int j) {
        return at(i).parts.at(j);
    }

    public Parse at(int i, int j, int k) {
        return at(i,j).parts.at(k);
    }

    public String text() {
    	return htmlToText(body);
    }

    public static String htmlToText(String s)
    {
		s = normalizeLineBreaks(s);
    	s = removeNonBreakTags(s);
		s = condenseWhitespace(s);
		s = unescape(s);
    	return s;
    }

    private static String removeNonBreakTags(String s) {
        int i=0, j;
        while ((i=s.indexOf('<',i))>=0) {
            if ((j=s.indexOf('>',i+1))>0) {
                if (!(s.substring(i, j+1).equals("<br />"))) {
                	s = s.substring(0,i) + s.substring(j+1);
                } else i++;
            } else break;
        }
        return s;
    }

    public static String unescape(String s) {
    	s = s.replaceAll("<br />", "\n");
		s = unescapeEntities(s);
		s = unescapeSmartQuotes(s);
        return s;
    }

	private static String unescapeSmartQuotes(String s) {
		s = s.replace('\u201c', '"');
		s = s.replace('\u201d', '"');
		s = s.replace('\u2018', '\'');
		s = s.replace('\u2019', '\'');
		return s;
	}

	private static String unescapeEntities(String s) {
		s = s.replaceAll("&lt;", "<");
		s = s.replaceAll("&gt;", ">");
		s = s.replaceAll("&nbsp;", " ");
		s = s.replaceAll("&quot;", "\"");
		s = s.replaceAll("&amp;", "&");
		return s;
	}

	private static String normalizeLineBreaks(String s) {
		s = s.replaceAll("<\\s*br\\s*/?\\s*>", "<br />");
		s = s.replaceAll("<\\s*/\\s*p\\s*>\\s*<\\s*p( .*?)?>", "<br />");
		return s;
	}

    public static String condenseWhitespace(String s) {
    	final char NON_BREAKING_SPACE = (char)160;

    	s = s.replaceAll("\\s+", " ");
		s = s.replace(NON_BREAKING_SPACE, ' ');
		s = s.replaceAll("&nbsp;", " ");
		s = s.trim();
    	return s;
    }

    public void addToTag(String text) {
        int last = tag.length()-1;
        tag = tag.substring(0,last) + text + ">";
    }

    public void addToBody(String text) {
        body = body + text;
    }

    public void print(PrintWriter out) {
        out.print(leader);
        out.print(tag);
        if (parts != null) {
            parts.print(out);
        } else {
            out.print(body);
        }
        out.print(end);
        if (more != null) {
            more.print(out);
        } else {
            out.print(trailer);
        }
    }

    public static int footnoteFiles=0;
    public String footnote () {
        if (footnoteFiles>=25) {
            return "[-]";
        } else {
            try {
                int thisFootnote = ++footnoteFiles;
                String html = "footnotes/" + thisFootnote + ".html";
                File file = new File("Reports/" + html);
                file.delete();
                PrintWriter output = new PrintWriter(new BufferedWriter(new FileWriter(file)));
                print(output);
                output.close();
                return "<a href=/fit/Release/Reports/" + html + "> [" + thisFootnote + "]</a>";
            } catch (IOException e) {
                return "[!]";
            }
        }
    }
}
