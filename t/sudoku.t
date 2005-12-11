
use strict;
use warnings;

use Games::Sudoku::General;
use Test;

my $loc = tell DATA;
my $method;
my $su;
my %variable;
my $number;
my @todo;
my $pass;

new ();

for ($pass = 0; $pass < 2; $pass++) {
    $number = 0;
    %variable = ();
    @todo = ();
    seek (DATA, $loc, 0);
    while (<DATA>) {
	s/^\s+//;
	next unless $_;
	next if m/^#/;
	s/\s+$//;
	my $outside = 1;
	my @args = map {
	    $outside++ % 2 ? (map {
		m/^<<(.+)/ ? do {
		    my $t = $1 . "\n"; my $r = '';
		    while (<DATA>) {last if $_ eq $t; $r .= $_}
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

__END__

get columns
test 9 'Implicit columns'

get symbols
test '. 1 2 3 4 5 6 7 8 9' 'Implicit symbols'

get topology
test <<eod 'Implicit topology'
c0,r0,s0 c1,r0,s0 c2,r0,s0 c3,r0,s1 c4,r0,s1 c5,r0,s1 c6,r0,s2 c7,r0,s2 c8,r0,s2
c0,r1,s0 c1,r1,s0 c2,r1,s0 c3,r1,s1 c4,r1,s1 c5,r1,s1 c6,r1,s2 c7,r1,s2 c8,r1,s2
c0,r2,s0 c1,r2,s0 c2,r2,s0 c3,r2,s1 c4,r2,s1 c5,r2,s1 c6,r2,s2 c7,r2,s2 c8,r2,s2
c0,r3,s3 c1,r3,s3 c2,r3,s3 c3,r3,s4 c4,r3,s4 c5,r3,s4 c6,r3,s5 c7,r3,s5 c8,r3,s5
c0,r4,s3 c1,r4,s3 c2,r4,s3 c3,r4,s4 c4,r4,s4 c5,r4,s4 c6,r4,s5 c7,r4,s5 c8,r4,s5
c0,r5,s3 c1,r5,s3 c2,r5,s3 c3,r5,s4 c4,r5,s4 c5,r5,s4 c6,r5,s5 c7,r5,s5 c8,r5,s5
c0,r6,s6 c1,r6,s6 c2,r6,s6 c3,r6,s7 c4,r6,s7 c5,r6,s7 c6,r6,s8 c7,r6,s8 c8,r6,s8
c0,r7,s6 c1,r7,s6 c2,r7,s6 c3,r7,s7 c4,r7,s7 c5,r7,s7 c6,r7,s8 c7,r7,s8 c8,r7,s8
c0,r8,s6 c1,r8,s6 c2,r8,s6 c3,r8,s7 c4,r8,s7 c5,r8,s7 c6,r8,s8 c7,r8,s8 c8,r8,s8
eod

var gsftax http://www.research.att.com/~gsf/sudoku/taxonomy.dat
problem <<eod
...4..7894.6...1...8.....5.2.4..5....95.........9.2345.3..7.9.8.67..1...9....8..2
eod
solution
test <<eod 'Constraint Taxonomy 1 (F) - Glenn Fowler' $gsftax
1 2 3 4 5 6 7 8 9
4 5 6 7 8 9 1 2 3
7 8 9 1 2 3 4 5 6
2 1 4 3 6 5 8 9 7
3 9 5 8 4 7 2 6 1
6 7 8 9 1 2 3 4 5
5 3 2 6 7 4 9 1 8
8 6 7 2 9 1 5 3 4
9 4 1 5 3 8 6 7 2
eod

constraints_used
test F

set symbols '. A B C D E F G H I'
problem <<eod
...D..GHID.F...A...H.....E.B.D..E....IE.........I.BCDE.C..G.I.H.FG..A...I....H..B
eod
solution
test <<eod 'Constraint Taxonomy 1 (F) - Glenn Fowler' $gsftax 'but with letters.'
A B C D E F G H I
D E F G H I A B C
G H I A B C D E F
B A D C F E H I G
C I E H D G B F A
F G H I A B C D E
E C B F G D I A H
H F G B I A E C D
I D A E C H F G B
eod

set symbols '. 1 2 3 4 5 6 7 8 9'

problem <<eod
...4..7894.6...1...8.....5.2.4..5....95......6..9.2.4..3..7.9.8.67......9....8..2
eod
solution
test <<eod 'Constraint Taxonomy 2 (FN) - Glenn Fowler' $gsftax
1 2 3 4 5 6 7 8 9
4 5 6 7 8 9 1 2 3
7 8 9 1 2 3 4 5 6
2 1 4 3 6 5 8 9 7
3 9 5 8 4 7 2 6 1
6 7 8 9 1 2 3 4 5
5 3 2 6 7 4 9 1 8
8 6 7 2 9 1 5 3 4
9 4 1 5 3 8 6 7 2
eod

constraints_used
test 'F N'

problem <<eod
...4..7894.6...1...8.....5.2.4..5....95......6..9.2.4..3..7...8.67......9....8..2
eod
solution
test <<eod 'Constraint Taxonomy 3 (FN) - Glenn Fowler' $gsftax
1 2 3 4 5 6 7 8 9
4 5 6 7 8 9 1 2 3
7 8 9 1 2 3 4 5 6
2 1 4 3 6 5 8 9 7
3 9 5 8 4 7 2 6 1
6 7 8 9 1 2 3 4 5
5 3 2 6 7 4 9 1 8
8 6 7 2 9 1 5 3 4
9 4 1 5 3 8 6 7 2
eod

constraints_used
test 'F N'


problem <<eod
...4..7894.6...1...8.....5.2.4..5....9.......6..9.23...3..7.9.8.67..1...9.......2
eod
solution
test <<eod 'Constraint Taxonomy 4 (FNB) - Glenn Fowler' $gsftax
1 2 3 4 5 6 7 8 9
4 5 6 7 8 9 1 2 3
7 8 9 1 2 3 4 5 6
2 1 4 3 6 5 8 9 7
3 9 5 8 4 7 2 6 1
6 7 8 9 1 2 3 4 5
5 3 2 6 7 4 9 1 8
8 6 7 2 9 1 5 3 4
9 4 1 5 3 8 6 7 2
eod

constraints_used
test 'F N B'

problem <<eod
...4..7894.6...1...8.....5.2.4..5....9..........9.2.4..3..7.9.8.67..1...9....8..2
eod
solution
test <<eod 'Constraint Taxonomy 5 (FNBT) - Glenn Fowler' $gsftax
1 2 3 4 5 6 7 8 9
4 5 6 7 8 9 1 2 3
7 8 9 1 2 3 4 5 6
2 1 4 3 6 5 8 9 7
3 9 5 8 4 7 2 6 1
6 7 8 9 1 2 3 4 5
5 3 2 6 7 4 9 1 8
8 6 7 2 9 1 5 3 4
9 4 1 5 3 8 6 7 2
eod

constraints_used
test 'F N B T'

problem <<eod
..345...94567..1......2....2.4.....5.....8....3.....4.3.5...9128..6.1..4....3....
eod
solution
test <<eod 'Constraint Taxonomy 6 (FNT) - Glenn Fowler' $gsftax
1 2 3 4 5 6 7 8 9
4 5 6 7 8 9 1 2 3
7 8 9 1 2 3 4 5 6
2 1 4 3 6 7 8 9 5
5 9 7 2 4 8 3 6 1
6 3 8 9 1 5 2 4 7
3 6 5 8 7 4 9 1 2
8 7 2 6 9 1 5 3 4
9 4 1 5 3 2 6 7 8
eod

constraints_used
test 'F N T'

problem <<eod
. 4 5 . 3 2 1 . .
. 1 . . . . . . 3
. . . . 1 6 . 4 .
. 6 4 . . 9 7 . 8
1 . 8 7 . 3 4 . 5
5 . 3 6 . . 2 9 .
. 2 . 3 9 . . . .
4 . . . . . . 7 .
. . 6 4 7 . 3 1 .
eod
solution
test <<eod 'www.websudoku.com puzzle 3_302_280_384'
7 4 5 9 3 2 1 8 6
6 1 9 8 4 7 5 2 3
3 8 2 5 1 6 9 4 7
2 6 4 1 5 9 7 3 8
1 9 8 7 2 3 4 6 5
5 7 3 6 8 4 2 9 1
8 2 7 3 9 1 6 5 4
4 3 1 2 6 5 8 7 9
9 5 6 4 7 8 3 1 2
eod

solution
test '' 'Check for uniqueness of solution'

set allowed_symbols <<eod
o=1,3,5,7,9
e=8,6,4,2
eod
get allowed_symbols
test <<eod
e=2,4,6,8
o=1,3,5,7,9
eod

var pegg http://www.maa.org/editorial/mathgames/mathgames_09_05_05.html
problem <<eod
1 o e o e e o e 3
o o e o 6 e o o e
e e 3 o o 1 o e e
e 7 o 1 o e e o e
o e 8 e e o 5 o o
o e o o e 3 e 4 o
e o o 8 o o 6 o e
o o o e 1 e e e o
6 e e e o o o o 7
eod
solution
test <<eod 'Even/Odd - Ed Pegg Jr.' $pegg
1 5 6 9 4 8 7 2 3
7 9 4 3 6 2 1 5 8
8 2 3 5 7 1 9 6 4
2 7 9 1 5 4 8 3 6
3 4 8 6 2 9 5 7 1
5 6 1 7 8 3 2 4 9
4 1 5 8 3 7 6 9 2
9 3 7 2 1 6 4 8 5
6 8 2 4 9 5 3 1 7
eod

set allowed_symbols <<eod
o=
e=
r=1,2,3,4
b=5,6,7,8,9
y=1,3,5,7,9
g=2,4,6,8
eod
get allowed_symbols
test <<eod
b=5,6,7,8,9
g=2,4,6,8
r=1,2,3,4
y=1,3,5,7,9
eod

problem <<eod
g r y y g g y b 1
b b y g r 9 g y g
y g 6 r b b b r r
y b y b g r g 5 b
g y r b y b g y b
b 8 b y r g r b g
r b y b y y 4 g g
g g r 5 b y b y y
1 y g g b r y b y
eod
solution
test <<eod 'Colors - Ed Pegg Jr.' $pegg
4 3 9 7 6 2 5 8 1
8 5 1 4 3 9 6 7 2
7 2 6 1 5 8 9 4 3
9 6 3 8 4 1 2 5 7
2 1 4 9 7 5 8 3 6
5 8 7 3 2 6 1 9 4
3 9 5 6 1 7 4 2 8
6 4 2 5 8 3 7 1 9
1 7 8 2 9 4 3 6 5
eod

set sudokux 3
get columns
test 9 'Sudoku X columns'

get symbols
test '. 1 2 3 4 5 6 7 8 9' 'Sudoku X symbols'

get topology
test <<eod 'Sudoku X topology'
c0,d0,r0,s0 c1,r0,s0 c2,r0,s0 c3,r0,s1 c4,r0,s1 c5,r0,s1 c6,r0,s2 c7,r0,s2 c8,d1,r0,s2
c0,r1,s0 c1,d0,r1,s0 c2,r1,s0 c3,r1,s1 c4,r1,s1 c5,r1,s1 c6,r1,s2 c7,d1,r1,s2 c8,r1,s2
c0,r2,s0 c1,r2,s0 c2,d0,r2,s0 c3,r2,s1 c4,r2,s1 c5,r2,s1 c6,d1,r2,s2 c7,r2,s2 c8,r2,s2
c0,r3,s3 c1,r3,s3 c2,r3,s3 c3,d0,r3,s4 c4,r3,s4 c5,d1,r3,s4 c6,r3,s5 c7,r3,s5 c8,r3,s5
c0,r4,s3 c1,r4,s3 c2,r4,s3 c3,r4,s4 c4,d0,d1,r4,s4 c5,r4,s4 c6,r4,s5 c7,r4,s5 c8,r4,s5
c0,r5,s3 c1,r5,s3 c2,r5,s3 c3,d1,r5,s4 c4,r5,s4 c5,d0,r5,s4 c6,r5,s5 c7,r5,s5 c8,r5,s5
c0,r6,s6 c1,r6,s6 c2,d1,r6,s6 c3,r6,s7 c4,r6,s7 c5,r6,s7 c6,d0,r6,s8 c7,r6,s8 c8,r6,s8
c0,r7,s6 c1,d1,r7,s6 c2,r7,s6 c3,r7,s7 c4,r7,s7 c5,r7,s7 c6,r7,s8 c7,d0,r7,s8 c8,r7,s8
c0,d1,r8,s6 c1,r8,s6 c2,r8,s6 c3,r8,s7 c4,r8,s7 c5,r8,s7 c6,r8,s8 c7,r8,s8 c8,d0,r8,s8
eod

problem <<eod
. . . 1 . . . 6 .
2 9 . . . . 4 7 .
. 3 . . . 2 . . .
. . 7 6 . . . . 5
. . . . . . . . .
5 . . . . 8 7 . .
. . . 7 . . . 5 .
. 5 9 . . . . 1 8
. 8 . . . 9 . . .
eod
solution
test <<eod 'Sudoku X puzzle - Ed Pegg Jr.' $pegg
4 7 8 1 9 3 5 6 2
2 9 1 8 6 5 4 7 3
6 3 5 4 7 2 8 9 1
8 1 7 6 2 4 9 3 5
9 2 4 5 3 7 1 8 6
5 6 3 9 1 8 7 2 4
3 4 6 7 8 1 2 5 9
7 5 9 2 4 6 3 1 8
1 8 2 3 5 9 6 4 7
eod

set allowed_symbols <<eod
b=1,2
c=1,2,3
d=1,2,3,4
e=1,2,3,4,5
f=1,2,3,4,5,6
g=1,2,3,4,5,6,7
h=1,2,3,4,5,6,7,8
i=1,2,3,4,5,6,7,8,9
eod
problem <<eod
. . . g 7 g . 6 f
. . . g . g f f f
2 b . g g . . . f
i i i e e . . . .
i 9 i . 5 e . . .
i i i . . e 1 . .
d . 4 . . . h h h
. d d . . . h h h
. . . c c 3 8 h .
eod
set debug 0
solution
test <<eod '"Magic Sudoku" - Alexandre Owen Muniz' 'cited by Ed Pegg, Jr.' $pegg
8 4 3 2 7 5 9 6 1
5 7 9 6 8 1 3 2 4
2 1 6 4 3 9 7 8 5
7 6 5 3 1 8 4 9 2
4 9 1 7 5 2 6 3 8
3 2 8 9 6 4 1 5 7
1 8 4 5 9 6 2 7 3
9 3 2 8 4 7 5 1 6
6 5 7 1 2 3 8 4 9
eod

set topology <<eod
c0,n0,r0 c1,n0,r0 c2,n0,r0 c3,n0,r0 c4,n1,r0 c5,n1,r0 c6,n1,r0 c7,n2,r0 c8,n2,r0
c0,n0,r1 c1,n0,r1 c2,n3,r1 c3,n0,r1 c4,n1,r1 c5,n1,r1 c6,n1,r1 c7,n1,r1 c8,n2,r1
c0,n0,r2 c1,n3,r2 c2,n3,r2 c3,n0,r2 c4,n1,r2 c5,n4,r2 c6,n2,r2 c7,n2,r2 c8,n2,r2
c0,n3,r3 c1,n3,r3 c2,n4,r3 c3,n4,r3 c4,n1,r3 c5,n4,r3 c6,n2,r3 c7,n5,r3 c8,n2,r3
c0,n3,r4 c1,n3,r4 c2,n3,r4 c3,n4,r4 c4,n4,r4 c5,n4,r4 c6,n5,r4 c7,n5,r4 c8,n2,r4
c0,n3,r5 c1,n6,r5 c2,n6,r5 c3,n6,r5 c4,n8,r5 c5,n4,r5 c6,n4,r5 c7,n5,r5 c8,n5,r5
c0,n6,r6 c1,n6,r6 c2,n7,r6 c3,n7,r6 c4,n8,r6 c5,n8,r6 c6,n8,r6 c7,n8,r6 c8,n5,r6
c0,n6,r7 c1,n7,r7 c2,n7,r7 c3,n7,r7 c4,n8,r7 c5,n7,r7 c6,n8,r7 c7,n8,r7 c8,n5,r7
c0,n6,r8 c1,n6,r8 c2,n6,r8 c3,n7,r8 c4,n7,r8 c5,n7,r8 c6,n8,r8 c7,n5,r8 c8,n5,r8
eod
problem <<eod
3 . . 8 . 5 . . .
. . . 6 1 . 2 . .
4 . 5 . . 1 . 6 .
9 . . . . . . 4 .
. . . . . 6 . 7 2
8 . . . . . . . .
. . . . . . . . .
6 . . . . . . . 9
. . 4 5 . . . . 1
eod
solution
test <<eod 'Arbitrary nonomino - Ed Pegg Jr.' $pegg
3 1 2 8 6 5 4 9 7
5 9 7 6 1 3 2 8 4
4 2 5 7 9 1 3 6 8
9 6 8 3 7 2 1 4 5
1 4 3 9 5 6 8 7 2
8 3 9 1 2 4 7 5 6
2 5 6 4 8 7 9 1 3
6 7 1 2 4 8 5 3 9
7 8 4 5 3 9 6 2 1
eod

set brick 3,2,6
get topology
test <<eod 'Brick topology (3 x 2 bricks in a 6 x 6 square)'
c0,r0,s0 c1,r0,s0 c2,r0,s0 c3,r0,s1 c4,r0,s1 c5,r0,s1
c0,r1,s0 c1,r1,s0 c2,r1,s0 c3,r1,s1 c4,r1,s1 c5,r1,s1
c0,r2,s2 c1,r2,s2 c2,r2,s2 c3,r2,s3 c4,r2,s3 c5,r2,s3
c0,r3,s2 c1,r3,s2 c2,r3,s2 c3,r3,s3 c4,r3,s3 c5,r3,s3
c0,r4,s4 c1,r4,s4 c2,r4,s4 c3,r4,s5 c4,r4,s5 c5,r4,s5
c0,r5,s4 c1,r5,s4 c2,r5,s4 c3,r5,s5 c4,r5,s5 c5,r5,s5
eod

get symbols
test '. 1 2 3 4 5 6' 'Symbols generated by above "set brick"'
get columns
test 6 'Column setting generated by above "set brick"'

set allowed_symbols <<eod
s1=2,3,5
s2=4,5,6
s4=2,3,4,5,6
s5=2,6
s6=1,3,4,5,6
s7=2,3,5,6
eod
problem <<eod
 . s2 s2  . s6 s5
s5  .  . s4  .  .
s2 s7 s4 s2  . s4
 . s7  .  . s2 s2
s7  . s2 s1  . s5
 . s6 s2 s7  .  .
eod
solution
test <<eod 'Digit Place - Cihan Altay' 'cited by Ed Pegg, Jr.' $pegg
3 4 5 1 6 2
6 2 1 4 3 5
4 5 2 6 1 3
1 6 3 2 5 4
5 1 4 3 2 6
2 3 6 5 4 1
eod

set sudoku 4

get topology
test <<eod 'Topology of 4 x 4 sudoku'
c0,r0,s0 c1,r0,s0 c2,r0,s0 c3,r0,s0 c4,r0,s1 c5,r0,s1 c6,r0,s1 c7,r0,s1 c8,r0,s2 c9,r0,s2 c10,r0,s2 c11,r0,s2 c12,r0,s3 c13,r0,s3 c14,r0,s3 c15,r0,s3
c0,r1,s0 c1,r1,s0 c2,r1,s0 c3,r1,s0 c4,r1,s1 c5,r1,s1 c6,r1,s1 c7,r1,s1 c8,r1,s2 c9,r1,s2 c10,r1,s2 c11,r1,s2 c12,r1,s3 c13,r1,s3 c14,r1,s3 c15,r1,s3
c0,r2,s0 c1,r2,s0 c2,r2,s0 c3,r2,s0 c4,r2,s1 c5,r2,s1 c6,r2,s1 c7,r2,s1 c8,r2,s2 c9,r2,s2 c10,r2,s2 c11,r2,s2 c12,r2,s3 c13,r2,s3 c14,r2,s3 c15,r2,s3
c0,r3,s0 c1,r3,s0 c2,r3,s0 c3,r3,s0 c4,r3,s1 c5,r3,s1 c6,r3,s1 c7,r3,s1 c8,r3,s2 c9,r3,s2 c10,r3,s2 c11,r3,s2 c12,r3,s3 c13,r3,s3 c14,r3,s3 c15,r3,s3
c0,r4,s4 c1,r4,s4 c2,r4,s4 c3,r4,s4 c4,r4,s5 c5,r4,s5 c6,r4,s5 c7,r4,s5 c8,r4,s6 c9,r4,s6 c10,r4,s6 c11,r4,s6 c12,r4,s7 c13,r4,s7 c14,r4,s7 c15,r4,s7
c0,r5,s4 c1,r5,s4 c2,r5,s4 c3,r5,s4 c4,r5,s5 c5,r5,s5 c6,r5,s5 c7,r5,s5 c8,r5,s6 c9,r5,s6 c10,r5,s6 c11,r5,s6 c12,r5,s7 c13,r5,s7 c14,r5,s7 c15,r5,s7
c0,r6,s4 c1,r6,s4 c2,r6,s4 c3,r6,s4 c4,r6,s5 c5,r6,s5 c6,r6,s5 c7,r6,s5 c8,r6,s6 c9,r6,s6 c10,r6,s6 c11,r6,s6 c12,r6,s7 c13,r6,s7 c14,r6,s7 c15,r6,s7
c0,r7,s4 c1,r7,s4 c2,r7,s4 c3,r7,s4 c4,r7,s5 c5,r7,s5 c6,r7,s5 c7,r7,s5 c8,r7,s6 c9,r7,s6 c10,r7,s6 c11,r7,s6 c12,r7,s7 c13,r7,s7 c14,r7,s7 c15,r7,s7
c0,r8,s8 c1,r8,s8 c2,r8,s8 c3,r8,s8 c4,r8,s9 c5,r8,s9 c6,r8,s9 c7,r8,s9 c8,r8,s10 c9,r8,s10 c10,r8,s10 c11,r8,s10 c12,r8,s11 c13,r8,s11 c14,r8,s11 c15,r8,s11
c0,r9,s8 c1,r9,s8 c2,r9,s8 c3,r9,s8 c4,r9,s9 c5,r9,s9 c6,r9,s9 c7,r9,s9 c8,r9,s10 c9,r9,s10 c10,r9,s10 c11,r9,s10 c12,r9,s11 c13,r9,s11 c14,r9,s11 c15,r9,s11
c0,r10,s8 c1,r10,s8 c2,r10,s8 c3,r10,s8 c4,r10,s9 c5,r10,s9 c6,r10,s9 c7,r10,s9 c8,r10,s10 c9,r10,s10 c10,r10,s10 c11,r10,s10 c12,r10,s11 c13,r10,s11 c14,r10,s11 c15,r10,s11
c0,r11,s8 c1,r11,s8 c2,r11,s8 c3,r11,s8 c4,r11,s9 c5,r11,s9 c6,r11,s9 c7,r11,s9 c8,r11,s10 c9,r11,s10 c10,r11,s10 c11,r11,s10 c12,r11,s11 c13,r11,s11 c14,r11,s11 c15,r11,s11
c0,r12,s12 c1,r12,s12 c2,r12,s12 c3,r12,s12 c4,r12,s13 c5,r12,s13 c6,r12,s13 c7,r12,s13 c8,r12,s14 c9,r12,s14 c10,r12,s14 c11,r12,s14 c12,r12,s15 c13,r12,s15 c14,r12,s15 c15,r12,s15
c0,r13,s12 c1,r13,s12 c2,r13,s12 c3,r13,s12 c4,r13,s13 c5,r13,s13 c6,r13,s13 c7,r13,s13 c8,r13,s14 c9,r13,s14 c10,r13,s14 c11,r13,s14 c12,r13,s15 c13,r13,s15 c14,r13,s15 c15,r13,s15
c0,r14,s12 c1,r14,s12 c2,r14,s12 c3,r14,s12 c4,r14,s13 c5,r14,s13 c6,r14,s13 c7,r14,s13 c8,r14,s14 c9,r14,s14 c10,r14,s14 c11,r14,s14 c12,r14,s15 c13,r14,s15 c14,r14,s15 c15,r14,s15
c0,r15,s12 c1,r15,s12 c2,r15,s12 c3,r15,s12 c4,r15,s13 c5,r15,s13 c6,r15,s13 c7,r15,s13 c8,r15,s14 c9,r15,s14 c10,r15,s14 c11,r15,s14 c12,r15,s15 c13,r15,s15 c14,r15,s15 c15,r15,s15
eod

get symbols
test '. 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16' 'Symbols for 4 x 4 Sudoku'

get columns
test 16 'Columns for 4 x 4 Sudoku'

problem <<eod
  1 .. .. ..    8 .. ..  5   .. .. .. ..    7 14 .. .. 
 .. 11  6 ..    4 .. 10 ..   .. 16 .. ..   .. 15 .. .. 
 .. .. .. ..   .. .. .. ..   .. .. .. 13   .. .. ..  2 
  3 .. .. ..   .. 12 .. ..   .. ..  9 ..   11  8  1 .. 

 .. .. .. 14    6 .. ..  7    8 11 ..  5   .. .. .. .. 
 .. 10 .. ..   .. .. 15 16    2 .. .. ..    3  4 13 .. 
 .. ..  2  5   .. 13 .. ..   ..  3 .. ..   ..  9 .. 12 
 ..  8 .. ..    1 .. .. ..    7  4 16 ..   .. .. .. .. 

 .. .. .. ..   ..  2  3  8   .. .. .. 14   .. .. 10 .. 
 11 ..  4 ..   .. ..  9 ..   .. ..  5 ..   16  1 .. .. 
 .. 13 15  9   .. .. ..  1   12  6 .. ..   .. ..  4 .. 
 .. .. .. ..   15 ..  7 14    3 .. ..  2    6 .. .. .. 

 .. 16 12  4   ..  9 .. ..   .. .. 10 ..   .. .. .. 15 
  7 .. .. ..   11 .. .. ..   .. .. .. ..   .. .. .. .. 
 .. ..  9 ..   .. ..  2 ..   ..  1 .. 15   ..  5  8 .. 
 .. ..  3 10   .. .. .. ..   14 .. ..  6   .. .. .. 13 
eod

var act365 'from http://www.act365.com/sudoku/brain.htm'
solution <<eod 'Straightforward 4 x 4' $act365
 1  2 10 15  8 16 13  5 11 12  6  3  7 14  9  4
 9 11  6  8  4 14 10  3  1 16  2  7 13 15 12  5
 4  5 16 12  7  1 11  9 15  8 14 13 10  6  3  2
 3  7 14 13  2 12  6 15  5 10  9  4 11  8  1 16
12  9  1 14  6  3  4  7  8 11 13  5  2 16 15 10
 6 10 11  7  9  5 15 16  2 14 12  1  3  4 13  8
16  4  2  5 14 13  8 11  6  3 15 10  1  9  7 12
15  8 13  3  1 10 12  2  7  4 16  9  5 11  6 14
 5  6  7  1 16  2  3  8  4 13 11 14 15 12 10  9
11  3  4  2 13  6  9 12 10 15  5  8 16  1 14  7
14 13 15  9 10 11  5  1 12  6  7 16  8  2  4  3
10 12  8 16 15  4  7 14  3  9  1  2  6 13  5 11
 8 16 12  4  5  9  1  6 13  7 10 11 14  3  2 15
 7 15  5  6 11  8 14 13  9  2  3 12  4 10 16  1
13 14  9 11  3  7  2 10 16  1  4 15 12  5  8  6
 2  1  3 10 12 15 16  4 14  5  8  6  9  7 11 13
eod

set latin 4
get columns
test 4 'Latin square columns'

get symbols
test '. A B C D' 'Latin square symbols'

get topology
test <<eod 'Latin square topology'
c0,r0 c1,r0 c2,r0 c3,r0
c0,r1 c1,r1 c2,r1 c3,r1
c0,r2 c1,r2 c2,r2 c3,r2
c0,r3 c1,r3 c2,r3 c3,r3
eod
