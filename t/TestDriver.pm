
use strict;
use warnings;

package t::TestDriver;

use Games::Sudoku::General;
use Test;

our $VERSION = '0.001';

my $method;
my $number;
my $pass;
my $su;
my @todo;
my %variable;

sub execute {
my $self = shift;
my $handle = shift;

my $loc = tell $handle;

new ();

for ($pass = 0; $pass < 2; $pass++) {
    $number = 0;
    %variable = ();
    @todo = ();
    seek ($handle, $loc, 0);
    while (<$handle>) {
	s/^\s+//;
	next unless $_;
	next if m/^#/;
	s/\s+$//;
	my $outside = 1;
	my @args = map {
	    $outside++ % 2 ? (map {
		m/^<<(.+)/ ? do {
		    my $t = $1 . "\n"; my $r = '';
		    while (<$handle>) {last if $_ eq $t; $r .= $_}
		    $r } :
		m/^\$(.+)/ ? $variable{$1} || $1 :
		$_
		} split ('\s+', $_)) :
	    $_} split "'", $_;
	$variable{trace} and
	    print "#> ", join (' ', map {m/\s/ ? "'$_'" : $_} @args), "\n";
	my $verb = shift @args;
	if ($verb =~ m/\W/ || $verb =~ m/^_/) {
	    warn <<eod;
Error - Verb '$verb' is illegal.
eod
	    }
	  elsif (__PACKAGE__->can ($verb)) {
	    __PACKAGE__->$verb (@args);
	    }
	  elsif ($su->can ($verb)) {
	    next unless $pass;
	    $method = $verb;
	    $variable{result} = eval {$su->$verb (@args)} || $@ || '';
	    warn $@ if $@;
	    }
	  else {
	    warn <<eod;
Error - Verb '$verb' is unknown.
eod
	    }
	}


    unless ($pass) {plan tests => $number, todo => \@todo; }

    }
}

#	echo prints its arguments.

sub echo {
return unless $pass;
shift;
foreach (@_) {
    chomp;
    foreach (split '\n', $_) {
	s/^\.//;
	print "#         ", ' ' x length ($number), "$_\n" if $_
	}
    }
}

#	fowler translates Glenn Fowler's cell numbers into mine.

sub fowler {
$variable{result} = $_[1];
$variable{result} =~
    s/\[(\d+),(\d+)\]/'[' . (($1 - 1) * 9 + $2 - 1) . ']'/gem;
}

#	new instantiates a new Games::Sudoku::General object.

sub new {shift; $su = Games::Sudoku::General->new (@_)}

#	test compares the previous result to its first argument. It
#	also prints some front matter for the test, with the second
#	argument being the title (defaulting to the name of the
#	previous method), and subsequent arguments being echoed.

sub test {
shift;
$number++;
return unless $pass;
my $expect = shift;
chomp $expect;
my $title = shift || $method;
chomp $title;
print <<eod;
#
# Test $number - $title
eod
__PACKAGE__->echo (@_) if @_;
my $result = $variable{result};
chomp $result;
if ($result =~ m/\n/ || $expect =~ m/\n/) {
    foreach ([Expect => $expect], [Got => $result]) {
	printf "# %9s:\n", $_->[0];
	foreach (split '\n', $_->[1]) {print "#          $_\n"}
	}
    }
  else {
    print <<eod;
#    Expect: $expect
#       Got: $result
eod
    }
ok ($expect eq $result);
}

#	todo marks the previous test as a 'todo' item.

sub todo {push @todo, $number}

sub unload {$variable{result} = $su->_unload () if $pass}

#	var defines a pseudo-lexical variable, which can be substituted
#	into the command by prefixing the variable name with a '$'.
#	Note that $result is implicitly set by any
#	Games::Sudoku::General method.

sub var {shift; my $name = shift; $variable{$name} = "@_"}

1;
