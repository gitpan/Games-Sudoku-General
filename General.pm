=head1 NAME

Games::Sudoku::General - Solve sudoku-like puzzles.

=head1 SYNOPSIS

 $su = Games::Sudoku::General->new ();
 print $su->problem(<<eod)->solution();
 3 . . . . 8 . 2 .
 . . . . . 9 . . .
 . . 2 7 . 5 . . .
 2 4 . 5 . . 8 . .
 . 8 5 . 7 4 . . 6
 . 3 . . . . 9 4 .
 1 . 4 . . . . 7 2
 . . 6 9 . . . 5 .
 . 7 . 6 1 2 . . 9
 eod

=head1 DESCRIPTION

This package solves puzzles that involve the allocation of symbols
among a number of sets, such that no set contains more than one of
any symbol. This class of problem includes the puzzles known as
'Sudoku', 'Number Place', and 'Wasabi'.

Each Sudoku puzzle is considered to be made up of a number of cells,
each of which is a member of one or more sets, and each of which may
contain exactly one symbol. The contents of some of the cells are
given, and the problem is to deduce the contents of the rest of the
cells.

Although such puzzles as Sudoku are presented on a square grid, this
package does not assume any particular geometry. Instead, the topology
of the puzzle is defined by the user in terms of a list of the sets
to which each cell belongs. Some topology generators are provided, but
the user has the option of hand-specifying an arbitrary topology.

Even on the standard 9 x 9 Sudoku topology there are variants in which
unspecified cells are constrained in various ways (odd/even, high/low).
Such variants are accomodated by defining named sets of allowed
symbols, and then giving the set name for each unoccupied cell to which
it applies. See L<allowed_symbols|/item_allowed_symbols> for more
information and an example.

This module is able not only to solve a variety of Sudoku-like
puzzles, but to 'explain' how it arrived at its solution. The
steps() method, called after a solution is generated, lists in order
what solution constraints were applied, what cell each constraint
is applied to, and what symbol the cell was constrained to.

Test script t/sudoku.t demonstrates these features. ActivePerl users
will have to download the kit from L<http://www.cpan.org/>  or
L<http://search.cpan.org/~wyant/> to get this
file.

=head2 Exported symbols

No symbols are exported by default, but the following things are
available for export:

  Status values exported by the :status tag
    SUDOKU_SUCCESS
      This means what you think it does.
    SUDOKU_NO_SOLUTION
      This means the method exhausted all possible
      soltions without finding one
    SUDOKU_TOO_HARD
      This means the iteration_limit attribute was
      set to a positive number and the solution()
      method hit the limit without finding a solution.

The :all tag is provided for convenience, but it exports the same
symbols as :status.

=head2 Attributes

Games::Sudoku::General objects have the following attributes, which may
normally be accessed by the get() method, and changed by the set()
method.

In parentheses after the name of the attribute is the word "number"
or "string", giving the data type of the attribute. The parentheses
may also contain the words "read-only" to denote a read-only attribute
or "write-only" to denote a write-only attribute.

In general, the write-only attributes exist as a convenience to the
user, and provide a shorthand way to set a cluster of attributes at
the same time. At the moment all of them are concerned with generating
problem topologies, which are a real pain to specify by hand.

=over

=item allowed_symbols (string)

This attribute names and defines sets of allowed symbols which may
appear in empty cells. The set definitions are whitespace-delimited
and each consists of a string of the form 'name=symbol,symbol...'
where the 'name' is the name of the set, and the symbols are a list
of the symbols valid in a cell to which that set applies.

For example, if you have an odd/even puzzle (i.e. you are given that
at least some of the unoccupied cells are even or odd but not both),
you might want to

 $su->set (allowed_symbols => <<eod);
 o=1,3,5,7,9
 e=2,4,6,8
 eod

and then define the problem like this:

 $su->problem (<<eod);
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

To eliminate an individual allowed symbol set, set it to an empty
string (e.g. $su->set (allowed_symbols => 'o=');). To eliminate all
symbol sets, set the entire attribute to the empty string.

Allowed symbol set names may not conflict with symbol names. If you set
the symbol attribute, all allowed symbol sets are deleted, because
that seemed to be the most expeditious way to enforce this restriction
across a symbol set change.

Because symbol set names must be parsed like symbol names when a
problem is defined, they also affect the need for whitespace on
problem input. See the L<problem()|/item_problem> documentation for
full details.

=item brick (string, write-only)

This "virtual" attribute is a convenience, which causes the object to
be configured with a topology of rows, columns, and rectangles. The
value set must be either a comma-separated list of three numbers (e.g.
'3,2,6') or a reference to a list containing three numbers (e.g. [3, 2,
6]). Either way, the numbers represent the horizontal dimension of the
rectangle (in columns), the vertical dimension of the rectangle (in
rows), and the overall size of the puzzle square. For example,

 $su->set (brick => [3, 2, 6])

generates a topology that looks like this

 +-------+-------+
 | x x x | x x x |
 | x x x | x x x |
 +-------+-------+
 | x x x | x x x |
 | x x x | x x x |
 +-------+-------+
 | x x x | x x x |
 | x x x | x x x |
 +-------+-------+

The overall size of the puzzle must be a multiple of both the
horizontal and vertical rectangle size.

Setting this modifies the following "real" attributes:

 columns is set to the size of the big square;
 symbols is set to "." and the numbers "1", "2",
   and so on, up to the size of the big square;
 topology is set to represent the rows,  columns,
   and small squares in the big square, with row
   sets named "r0", "r1", and so on, column sets
   named "c0", "c1", and so on, and small
   rectangle sets named "s0", "s1", and so on for
   historical reasons.

=item columns (number)

This attribute defines the number of columns of data to be used when
formatting the topology attribute, or the solution to a puzzle.

=item corresponding (number, write-only)

This "virtual" attribute is a convenience, which causes the object
to be configured for "corresponding-cell" Sudoku. The topology is
the same as 'set L<sudoku|/item_sudoku>', but in addition corresponding
cells in the small squares must have different values. The extra set
names are "u0", "u1", and so on.

This kind of puzzle is also called "disjoint groups."

=item cube (string, write-only)

This "virtual" attribute is a convenience, which causes the object to
be configured for cubical sudoku. The string is either a number, or
'full', or 'half'.

* a number sets the topology to a Dion cube of the given order.
That is,

 sudokug> set cube 3

generates a 9 x 9 x 9 Dion cube, with the small squares being 3 x 3.
The problem is entered in plane, row, and column order, as though you
were entering the required number of normal Sudoku puzzles
back-to-back.

* 'full' generates a topology that includes all faces of the cube. The
sets are the faces of the cube, and the rows, columns, and (for lack
of a better word) planes of cells that circle the cube.

To enter the problem, imagine the cube unfolded to make a Latin cross.
Then, enter the problem in order by faces, rows, and columns, top to
bottom and left to right. The order of entry is actually in order by
cell number, as given below.

               +-------------+
               |  0  1  2  3 |
               |  4  5  6  7 |
               |  8  9 10 11 |
               | 12 13 14 15 |
 +-------------+-------------+-------------+
 | 16 17 18 19 | 32 33 34 35 | 48 49 50 51 |
 | 20 21 22 23 | 36 37 38 39 | 52 53 54 55 |
 | 24 25 26 27 | 40 41 42 43 | 56 57 58 59 |
 | 28 29 30 31 | 44 45 46 47 | 60 61 62 63 |
 +-------------+-------------+-------------+
               | 64 65 66 67 |
               | 68 69 70 71 |
               | 72 73 74 75 |
               | 76 77 78 79 |
               +-------------+
               | 80 81 82 83 |
               | 84 85 86 87 |
               | 88 89 90 91 |
               | 92 93 94 95 |
               +-------------+

The solution will be displayed in order by cell number, with line
breaks controlled by the L<columns|/item_columns> attribute, just
like any other solution presented by this package.

I have seen such puzzles presented with the bottom square placed to the
right and rotated counterclockwise 90 degrees. You will need to perform
the opposite rotation when you enter the problem.

* 'half' generates a topology that looks like an isometric view of a
cube, with the puzzle on the visible faces. The faces are divided in
half, since the set size here is 8, not 16. Imagine the isometric
unfolded to make an L-shape. Then, enter the problem in order by faces,
rows, and columns, top to bottom and left to right. The order of entry
is actually in order by cell number, as given below.

 +-------------------+
 |  0    1    2    3 |
 |                   |
 |  4    5    6    7 |
 +-------------------+
 |  8    9   10   11 |
 |                   |
 | 12   13   14   15 |
 +---------+---------+-------------------+
 | 16   17 | 18   19 | 32   33   34   35 |
 |         |         |                   |
 | 20   21 | 22   23 | 36   37   38   39 |
 |         |         +-------------------+
 | 24   25 | 26   27 | 40   41   42   43 |
 |         |         |                   |
 | 28   29 | 30   31 | 44   45   46   47 |
 +---------+---------+-------------------+

The solution will be displayed in order by cell number, with line
breaks controlled by the L<columns|/item_columns> attribute, just
like any other solution presented by this package.

For all the 'cube' puzzles, the L</columns> attribute is set to 4, and
the L<symbols|/item_symbols> attribute to the numbers 1 to the size of
the largest set (16 for the full cube, 8 for the half or isometric
cube). I have seen full cube puzzles done with hex digits 0 to F; these
are handled most easily by setting the L<symbols|/item_symbols>
attribute appropriately:

 $su->set (cube => 'full', symbols => <<eod);
 . 0 1 2 3 4 5 6 7 8 9 A B C D E F
 eod

=item debug (number)

This attribute, if not 0, causes debugging information to be displayed.
Values other than 0 are not supported, in the sense that the author
makes no commitment what will happen when a non-zero value is set, and
further reserves the right to change this behaviour without notice of
any sort, and without documenting the changes.

=item iteration_limit (number)

This attribute governs how hard the solution() method tries to solve
a problem. An iteration is an attempt to use the backtrack constraint.
Since what this really counts is the number of times we place a
backtrack constraint on the stack, not the number of values generated
from that constraint, I suspect 10 to 20 is reasonable for a "normal"
sudoku problem.

The default is 0, which imposes no limit.

=item largest_set (number, read-only)

This read-only attribute returns the size of the largest set defined by
the current topology.

=item latin (number, write-only)

This "virtual" attribute is a convenience, which causes the object to
be configured to handle a Latin square. The value gives the size of
the square. Setting this modifies the following "real" attributes:

 columns is set to the size of the square;
 symbols is set to "." and the letters "A", "B",
   and so on, up to the size of the square;
 topology is set to represent the rows and columns
   of a square, with row sets named "r0", "r1",
   and so on, and the column sets named "c0",
   "c1", and so on.

=item max_tuple (number)

This attribute represents the maximum-sized tuple to consider for the
tuple constraint. It is possible that one might want to modify this
upward for large puzzles, or downward for small ones.

The default is 4, meaning that the solution considers doubles, triples,
and quads only.

=item name (string)

This attribute is for information, and is not used by the class.

=item output_delimiter (string)

This attribute specifies the delimiter to be used between cell values
on output. The default is a single space.

=item status_text (text, read-only)

This attribute is a short piece of text corresponding to the
status_value.

=item status_value (number)

The solution() method sets a status, which can be retrieved via this
attribute. The retrieved value is one of

    SUDOKU_SUCCESS
      This means what you think it does.
    SUDOKU_NO_SOLUTION
      This means the method exhausted all possible
      soltions without finding one
    SUDOKU_TOO_HARD
      This means the iteration_limit attribute was
      set to a positive number and the solution()
      method hit the limit without finding a solution.

=item sudoku (number, write-only)

This attribute is a convenience, which causes the object to be
configured to handle a standard Sudoku square. The value gives the size
of the small squares into which the big square is divided. The big
square's side is the square of the value.

For example, the customary Sudoku topology is set by

 $su->set (sudoku => 3);

This attribute is implemented in terms of 'set brick', and modifies the
same "real" attributes. See L<brick|/item_brick> for the details.

=item sudokux (number, write-only)

This attribute is a convenience. It is similar to the 'sudoku'
attribute, but the topology includes both main diagonals (set names
'd0' and 'd1') in addition to the standard sets. See
L<brick|/item_brick> for the details, since that's ultimately how this
attribute is implemented.

=item symbols (string)

This attribute defines the symbols to be used in the puzzle. Any
printing characters may be used except ",". Multi-character symbols
are supported. The value of the attribute is a whitespace-delimited
list of the symbols, though the whitespace is optional if all symbols
(and symbol constraints if any) are a single character. See the
L<problem()|/item_problem> documentation for full details.

The first symbol in the list is the one that represents an empty cell.
Except for this, the order of the symbols is immaterial.

The symbols defined here are used only for input or output. It is
perfectly legitimate to set symbols, call the problem() method, and
then change the symbols. The solution() method will return solutions
in the new symbol set. I have no idea why you would want to do this.

=item topology (string)

This attribute defines the topology of the puzzle, in terms of what
sets each cell belongs to. Each cell is defined in terms of a
comma-delimited list of the names of the sets it belongs to, and
the string is a whitespace-delimited list of cell definitions. For
example, a three-by-three grid with diagonals can be defined as
follows in terms of sets r1, r2, and r3 for the rows, c1, c2, and
c3 for the columns, and d1 and d2 for the diagonals:

 r1,c1,d1 r1,c2       r1,c3,d2
 r2,c1    r2,c2,d1,d2 r2,c3
 r3,c1,d1 r3,c2       r3,c3,d2

The parser treats line breaks as whitespace. That is to say, the
above definition would be the same if it were all on one line.

You do not need to define the sets themselves anywhere. The
package defines each set as it encounters it in the topology
definition.

Setting the topology invalidates any currently-set-up problem.

=back

=head2 Methods

This package provides the following public methods:

=over

=cut

package Games::Sudoku::General;

use strict;
use warnings;

use base qw{Exporter};

our $VERSION = '0.004';
our @EXPORT_OK = qw{
	SUDOKU_SUCCESS
	SUDOKU_NO_SOLUTION
	SUDOKU_TOO_HARD
	SUDOKU_MULTIPLE_SOLUTIONS
	};
our %EXPORT_TAGS = (
    all => \@EXPORT_OK,
    status => \@EXPORT_OK,
    );
use Carp;
use Data::Dumper;
use List::Util qw{first max reduce};
use POSIX qw{floor};
use Scalar::Util qw{dualvar looks_like_number};

use constant SUDOKU_SUCCESS => 0;
use constant SUDOKU_NO_SOLUTION => 1;
use constant SUDOKU_TOO_HARD => 2;
use constant SUDOKU_MULTIPLE_SOLUTIONS => 3;

my @status_values = (
    'Success',
    'No solution found',
    'No solution found before exceeding iteration limit',
    'Multiple solutions found',
    );

=item $su = Games::Sudoku::General->new ()

This method instantiates a new Games::Sudoku::General object. Any
arguments are passed to the set() method. If, after processing
the arguments, the object does not have a topology,

  $self->set (sudoku => 3)

is called. If there is no symbols setting (which could happen
if the user passed an explicit topology),

  $self->set (symbols => join ' ', '.',
    1 .. $self->get ('largest_set'))

is called. If, after all this, there is still no columns setting,
the number of columns is set to the number of symbols, excluding
the "empty cell" symbol.

The newly-instantiated object is returned.

=cut

sub new {
my $class = shift;
my $self = bless {debug => 0, iteration_limit => 0,
	output_delimiter => ' '}, $class;
@_ and $self->set (@_);
$self->{cell} or $self->set (sudoku => 3);
$self->{symbol_list} or $self->set (symbols => join ' ', '.', 1 .. $self->{largest_set});
defined $self->{columns} or $self->set (columns => @{$self->{symbol_list}} - 1);
defined $self->{status_value} or $self->set (status_value => SUDOKU_SUCCESS);
defined $self->{max_tuple} or $self->set (max_tuple => 4);
$self;
}

=item $su->add_set ($name => $cell ...)

This method adds to the current topology a new set with the given name,
and consisting of the given cells. The set name must not already
exist, but the cells must already exist. In other words, you can't
modify an existing set with this method, nor can you add new cells.

=cut

sub add_set {
my $self = shift;
my $name = shift;
$self->{set}{$name} and croak <<eod;
Error - Set '$name' already exists.
eod
foreach my $inx (@_) {$self->{cell}[$inx] or croak <<eod}
Error - Cell $inx does not exist.
eod
foreach my $inx (@_) {
    my $cell = $self->{cell}[$inx];
    foreach my $other (@{$cell->{membership}}) {
	my $int = join ',', sort $other, $name;
	$self->{intersection}{$int} ||= [];
	push @{$self->{intersection}{$int}}, $inx;
	}
    @{$cell->{membership}} = sort $name, @{$cell->{membership}};
    }
$self->{set}{$name} = {
    name => $name,
    membership => [sort @_],
    };
$self->{largest_set} = max ($self->{largest_set},
    scalar @{$self->{set}{$name}{membership}});
delete $self->{backtrack_stack};	# Force setting of new problem.
}


=item %constraints_used = $su->constraints_used;

This method returns a hash containing the constraints used in the most
recent call to solution(), and the number of times each was used. The
constraint codes are the same as for the steps() method. If called in
scalar context it returns a string representing the constraints used
at least once, in canonical order (i.e. in the order documented in the
steps() method).

B<Note:> As of version 0.002, the string returned by the scalar has
spaces delimiting the constraint names. They were not delimited in
version 0.001

=cut

sub constraints_used {
my $self = shift;
return unless $self->{constraints_used} && defined wantarray;
return %{$self->{constraints_used}} if wantarray;
my $rslt = join ' ', grep {$self->{constraints_used}{$_}} qw{F N B T X Y W ?};
$rslt;
}


my %accessor = (
    allowed_symbols => \&_get_allowed_symbols,
    columns => \&_get_value,
    debug => \&_get_value,
    iteration_limit => \&_get_value,
    largest_set => \&_get_value,
    name => \&_get_value,
    output_delimiter => \&_get_value,
    status_text => \&_get_value,
    status_value => \&_get_value,
    symbols => \&_get_symbols,
    topology => \&_get_topology,
    );

=item $value = $su->get ($name);

This method returns the value of the named attribute. An exception
is thrown if the given name does not correspond to an attribute that
can be read. That is, the given name must appear on the list of
attributes above, and not be marked "write-only".

If called in list context, you can pass multiple attribute names,
and get back a list of their values. If called in scalar context,
attribute names after the first are ignored.

=cut

sub get {
my $self = shift;
my @rslt;
wantarray or @_ = ($_[0]);
foreach my $name (@_) {
    exists $accessor{$name} or croak <<eod;
Error - Attribute $name does not exist, or is write-only.
eod
    push @rslt, $accessor{$name}->($self, $name);
    }
wantarray ? @rslt : $rslt[0];
}

sub _get_allowed_symbols {
my $self = shift;
my $rslt = '';
my $syms = @{$self->{symbol_list}};
foreach (sort keys %{$self->{allowed_symbols}}) {
    my @symlst;
    for (my $val = 1; $val < $syms; $val++) {
	push @symlst, $self->{symbol_list}[$val]
	    if $self->{allowed_symbols}{$_}[$val];
	}
    $rslt .= "$_=@{[join ',', @symlst]}\n";
    }
$rslt;
}

sub _get_symbols {
my $self = shift;
join ' ', @{$self->{symbol_list}};
}

sub _get_topology {
my $self = shift;
my $rslt = '';
my $col = $self->{columns};
foreach (map {join ',', @{$_->{membership}}} @{$self->{cell}}) {
    $rslt .= $_;
    if (--$col > 0) {$rslt .= ' '}
      else {$rslt .= "\n"; $col = $self->{columns};}
    }
$rslt;
}

sub _get_value {$_[0]->{$_[1]}}


=item $su->problem ($string);

This method specifies the problem to be solved, and sets the object
up to solve the problem.

The problem is specified by a whitespace-delimited list of the symbols
contained by each cell. You can format the puzzle definition into a
square grid (e.g. the SYNOPSIS section), but to the parser a  line
break is no different than spaces. If you pass an empty string, an
empty problem will be set up - that is, one in which all cells are
empty.

An exception will be thrown if:

 * The puzzle definition uses an unknown symbol;
 * The puzzle definition has a different number
   of cells from the topology definition;
 * There exists a set with more members than the
   number of symbols, excluding the "empty"
   symbol.

The whitespace delimiter is optional, provided that all symbol names
are exactly one character long, B<and> that you have not defined any
symbol constraint names more than one character long since the last
time you set the symbol names.

=cut

sub problem {
my $self = shift;
my $val = shift || '';
$val =~ m/\S/ or
    $val = "$self->{symbol_list}[0] " x
    scalar @{$self->{cell}};
$val =~ s/\s+//g unless $self->{biggest_spec} > 1;
$val =~ s/^\s+//;
$val =~ s/\s+$//;
$self->{debug} and print <<eod;
Debug problem - Called with $val
eod

local $Data::Dumper::Terse = 1;
$self->{largest_set} >= @{$self->{symbol_list}} and croak <<eod;
Error - The largest set has $self->{largest_set} cells, but there are only @{[
		@{$self->{symbol_list}} - 1]} symbols.
        Either the set definition is in error or the list of symbols is
        incomplete.
eod

my $syms = @{$self->{symbol_list}};
foreach (@{$self->{cell}}) {
    $_->{content} = $_->{chosen} = 0;
    $_->{possible} = {map {$_ => 0} (1 .. $syms - 1)};
    }
foreach (values %{$self->{set}}) {
    $_->{free} = @{$_->{membership}};
    $_->{content} = [$_->{free}];
    }
$self->{cells_unassigned} = scalar @{$self->{cell}};

my $hash = $self->{symbol_hash};
my $inx = 0;
my $max = @{$self->{cell}};
foreach (split (($self->{biggest_spec} > 1 ? '\s+' : ''), $val)) {
    $inx >= $max and croak <<eod;
Error - Too many cell specifications. The topology allows only $max.
eod
    next unless defined $_;
    $self->{allowed_symbols}{$_} and do {
    $self->{debug} > 1 and print <<eod;
Debug problem - Cell $inx allows symbol set $_
eod
	my $cell = $self->{cell}[$inx];
	for (my $val = 1; $val < $syms; $val++) {
	    next if $self->{allowed_symbols}{$_}[$val];
	    $cell->{possible}{$val} = 1;
	    }
	};
    defined $hash->{$_} or $_ = $self->{symbol_list}[0];
    $self->{debug} > 1 and print <<eod;
Debug problem - Cell $inx specifies symbol $_
eod
    $self->_try ($inx, $hash->{$_}) and croak <<eod;
Error - Symbol '$_' appears more than once in a set.
        The problem loaded thus far is:
@{[$self->_unload ('        ')]}
eod
    $self->{cell}[$inx]{chosen} = $hash->{$_} ? 1 : 0;
    }
  continue {
    $inx++;
    }

$inx == @{$self->{cell}} or croak <<eod;
Error - Not enough cell specifications. you gave $inx but the topology
        defined $max.
eod

$self->{constraints_used} = {};

$self->{debug} and print <<eod;
Debug problem - problem loaded.
eod

$self->{backtrack_stack} = [];
$self->{cell_order} = [];
delete $self->{no_more_solutions};

$self->{debug} > 1 and print "         object = ", Dumper ($self);

$self;
}



my %mutator = (
    allowed_symbols => \&_set_allowed_symbols,
    brick => \&_set_brick,
    columns => \&_set_number,
    debug => \&_set_number,
    corresponding => \&_set_corresponding,
    cube => \&_set_cube,
    iteration_limit => \&_set_number,
    latin => \&_set_latin,
    max_tuple => \&_set_number,
    name => \&_set_value,
    output_delimiter => \&_set_value,
    status_value => \&_set_status_value,
    sudoku => \&_set_sudoku,
    sudokux => \&_set_sudokux,
    symbols => \&_set_symbols,
    topology => \&_set_topology,
    );

=item $su->set ($name => $value);

This method sets the value of the named attribute. An exception
is thrown if the given name does not correspond to an attribute that
can be written. That is, the given name must appear on the list of
attributes above, and not be marked "read-only". An exception is
also thrown if the value is invalid, e.g. a non-numeric value for
an attribute marked "number".

You can pass multiple name-value pairs. If an exception is thrown,
all settings before the exception will be made, and all settings
after the exception will not be made.

The object itself is returned.

=cut

sub set {
my $self = shift;
while (@_) {
    my $name = shift;
    exists $mutator{$name} or croak <<eod;
Error - Attribute $name does not exist, or is read-only.
eod
    $mutator{$name}->($self, $name, shift);
    }
$self;
}

sub _set_allowed_symbols {
my $self = shift;
my $name = shift;
my $value = shift || '';
my $maxlen = 0;
$self->{debug} and print <<eod;
Debug allowed_symbols being set to '$value'
eod
if ($value) {
    foreach (split '\s+', $value) {
	my ($name, $value) = split '=', $_, 2;
	croak <<eod if $self->{symbol_hash}{$name};
Error - You can not use '$name' as a symbol constraint name, because
        it is a valid symbol name.
eod
	$value or do {delete $self->{allowed_symbols}{$name}; next};
	$maxlen = max ($maxlen, length ($name));
	$self->{debug} > 1 and print <<eod;
Debug allowed_symbols - $_
        set name '$name' has length @{[length ($name)]}. Maxlen now $maxlen.
eod
	my $const = $self->{allowed_symbols}{$name} = [];
	foreach (split ',', $value) {
	    $self->{debug} > 1 and print <<eod;
Debug allowed_symbols - Adding symbol '$_' to set '$name'.
eod
	    $self->{symbol_hash}{$_} or croak <<eod;
Error - '$_' is not a valid symbol.
eod
	    $const->[$self->{symbol_hash}{$_}] = 1;
	    }
	}
    }
  else {
    $self->{allowed_symbols} = {};
    }
$self->{biggest_spec} = $maxlen if $maxlen > $self->{biggest_spec};
}

sub _set_brick {
my $self = shift;
my $name = shift;
my ($horiz, $vert, $size) = ref $_[0] ? @{$_[0]} : split ',', $_[0];
$size % $horiz || $size % $vert and croak <<eod;
Error - The puzzle size $size must be a multiple of both the horizontal
        brick size $horiz and the vertical brick size $vert.
eod
my $rowmul = floor ($size / $horiz);
my $syms = '.';
my $topo = '';
for (my $row = 0; $row < $size; $row++) {
    $syms .= " @{[$row + 1]}";
    for (my $col = 0; $col < $size; $col++) {
	$topo .= sprintf ' r%d,c%d,s%d', $row, $col,
		floor ($row / $vert) * $rowmul + floor ($col / $horiz);
	}
    }
substr ($topo, 0, 1, '');
$self->set (columns => $size, symbols => $syms, topology => $topo);
}

sub _set_corresponding {
my $self = shift;
my $name = shift;
my $order = shift;
my $size = $order * $order;
my $size_minus_1 = $size - 1;
$self->set (sudoku => $order);
for (my $inx = 0; $inx < $size; $inx++) {
    $self->add_set ("u$inx", map {$_ * $size + $inx} 0 .. $size_minus_1);
    }
}

my %cube = (
    full => <<eod,
c0,r0,s0 c1,r0,s0 c2,r0,s0 c3,r0,s0
c0,r1,s0 c1,r1,s0 c2,r1,s0 c3,r1,s0
c0,r2,s0 c1,r2,s0 c2,r2,s0 c3,r2,s0
c0,r3,s0 c1,r3,s0 c2,r3,s0 c3,r3,s0
p0,r0,s1 p0,r1,s1 p0,r2,s1 p0,r3,s1
p1,r0,s1 p1,r1,s1 p1,r2,s1 p1,r3,s1
p2,r0,s1 p2,r1,s1 p2,r2,s1 p2,r3,s1
p3,r0,s1 p3,r1,s1 p3,r2,s1 p3,r3,s1
c0,p0,s2 c1,p0,s2 c2,p0,s2 c3,p0,s2
c0,p1,s2 c1,p1,s2 c2,p1,s2 c3,p1,s2
c0,p2,s2 c1,p2,s2 c2,p2,s2 c3,p2,s2
c0,p3,s2 c1,p3,s2 c2,p3,s2 c3,p3,s2
p0,r3,s3 p0,r2,s3 p0,r1,s3 p0,r0,s3
p1,r3,s3 p1,r2,s3 p1,r1,s3 p1,r0,s3
p2,r3,s3 p2,r2,s3 p2,r1,s3 p2,r0,s3
p3,r3,s3 p3,r2,s3 p3,r1,s3 p3,r0,s3
c0,r3,s4 c1,r3,s4 c2,r3,s4 c3,r3,s4
c0,r2,s4 c1,r2,s4 c2,r2,s4 c3,r2,s4
c0,r1,s4 c1,r1,s4 c2,r1,s4 c3,r1,s4
c0,r0,s4 c1,r0,s4 c2,r0,s4 c3,r0,s4
c0,p3,s5 c1,p3,s5 c2,p3,s5 c3,p3,s5
c0,p2,s5 c1,p2,s5 c2,p2,s5 c3,p2,s5
c0,p1,s5 c1,p1,s5 c2,p1,s5 c3,p1,s5
c0,p0,s5 c1,p0,s5 c2,p0,s5 c3,p0,s5
eod
    half => <<eod,
r0,c0,s0 r0,c1,s0 r0,c2,s0 r0,c3,s0
r1,c0,s0 r1,c1,s0 r1,c2,s0 r1,c3,s0
r2,c0,s1 r2,c1,s1 r2,c2,s1 r2,c3,s1
r3,c0,s1 r3,c1,s1 r3,c2,s1 r3,c3,s1
p0,c0,s2 p0,c1,s2 p0,c2,s3 p0,c3,s3
p1,c0,s2 p1,c1,s2 p1,c2,s3 p1,c3,s3
p2,c0,s2 p2,c1,s2 p2,c2,s3 p2,c3,s3
p3,c0,s2 p3,c1,s2 p3,c2,s3 p3,c3,s3
p0,r3,s4 p0,r2,s4 p0,r1,s4 p0,r0,s4
p1,r3,s4 p1,r2,s4 p1,r1,s4 p1,r0,s4
p2,r3,s5 p2,r2,s5 p2,r1,s5 p2,r0,s5
p3,r3,s5 p3,r2,s5 p3,r1,s5 p3,r0,s5
eod
    );

sub _set_cube {
my $self = shift;
my $name = shift;
my $type = shift;
if ($type =~ m/\D/) {
    $cube{$type} or croak <<eod;
Error - Cube type '$type' is not defined. Legal values are numeric (for
        Dion cube), or one of @{[join ', ', map {"'$_'"} sort keys %cube]}
eod
    $self->set (topology => $cube{$type}, columns => 4);
    }
  else {
    my $size = $type * $type;
    my $topo = '';
    for (my $x = 0; $x < $size; $x++) {
	for (my $y = 0; $y < $size; $y++) {
	    for (my $z = 0; $z < $size; $z++) {
		$topo .= join (',',
			_cube_set_names ($type, x => $x, $y, $z),
			_cube_set_names ($type, y => $y, $z, $x),
			_cube_set_names ($type, z => $z, $x, $y)) . ' ';
		}
	    }
	}
    $self->set (topology => $topo, columns => $size);
    }
$self->set (symbols => join ' ', '.', 1 .. $self->{largest_set});
}

sub _cube_set_names {
my ($order, $name, $x, $y, $z) = @_;
my $tplt = sprintf '%s%d%%s%%d', $name, $x;
map {sprintf $tplt, @$_} [r => $y], [c => $z],
    [s => floor ($y / $order) * $order + floor ($z / $order)]
}

sub _set_latin {
my $self = shift;
my $name = shift;
my $size = shift;
my $syms = '.';
my $topo = '';
my $letter = 'A';
for (my $row = 0; $row < $size; $row++) {
    $syms .= " @{[$letter++]}";
    for (my $col = 0; $col < $size; $col++) {
	$topo .= sprintf ' r%d,c%d', $row, $col;
	}
    }
substr ($topo, 0, 1, '');
$self->set (columns => $size, symbols => $syms, topology => $topo);
}

sub _set_number {
my $self = shift;
my $name = shift;
my $value = shift;
looks_like_number ($value) or croak <<eod;
Error - Attribute $name must be numeric.
eod
$self->{$name} = $value;
}

sub _set_status_value {
my $self = shift;
my $name = shift;
my $value = shift;
looks_like_number ($value) or croak <<eod;
Error - Attribute $name must be numeric.
eod
$value < 0 || $value >= @status_values and croak <<eod;
Error - Attribute $name must be greater than or equal to 0 and
        less than @{[scalar @status_values]}
eod
$self->{status_value} = $value;
$self->{status_text} = $status_values[$value];
}

sub _set_sudoku {
my $self = shift;
my $name = shift;
my $order = shift;
$self->set (brick => [$order, $order, $order * $order]);
}

=begin comment

sub _set_sudokux {
my $self = shift;
my $name = shift;
my $order = shift;
my $size = $order * $order;
my $syms = '.';
my $topo = '';
for (my $row = 0; $row < $size; $row++) {
    $syms .= " @{[$row + 1]}";
    for (my $col = 0; $col < $size; $col++) {
	my $cell = sprintf ' r%d,c%d,s%d', $row, $col,
		floor ($row / $order) * 3 + floor ($col / $order);
	$cell .= ',d0' if $row == $col;
	$cell .= ',d1' if $row == $size - $col - 1;
	$topo .= $cell;
	}
    }
substr ($topo, 0, 1, '');
$self->set (columns => $size, symbols => $syms, topology => $topo);
}

=end comment

=cut

sub _set_sudokux {
my $self = shift;
my $name = shift;
my $order = shift;
$self->set (sudoku => $order);
my $size = $order * $order;
my $size_minus_1 = $size - 1;
my $size_plus_1 = $size + 1;
$self->add_set (d0 => map {$_ * $size_plus_1} 0 .. $size_minus_1);
$self->add_set (d1 => map {$_ * $size_minus_1} 1 .. $size);
}

sub _set_symbols {
my $self = shift;
my $name = shift;
my $value = shift;
my @lst = split '\s+', $value;
my %hsh;
my $inx = 0;
my $maxlen = 0;
foreach (@lst) {
    defined $_ or next;
    m/,/ and croak <<eod;
Error - Symbols may not contain commas.
eod
    exists $hsh{$_} and croak <<eod;
Error - Symbol '$_' specified more than once.
eod
    $hsh{$_} = $inx++;
    $maxlen = max ($maxlen, length ($_));
    }
$self->{symbol_list} = \@lst;
$self->{symbol_hash} = \%hsh;
$self->{symbol_number} = scalar @lst;
$self->{biggest_spec} = $self->{biggest_symbol} = $maxlen;
$self->{allowed_symbols} = {};
}

sub _set_topology {
my $self = shift;
my $name = shift;
$self->{cell} = [];		# The cells themselves.
$self->{set} = {};		# The sets themselves.
$self->{largest_set} = 0;
$self->{intersection} = {};
my $cell_inx = 0;
foreach my $cell_def (map {split '\s+', $_} @_) {
    my $cell = {membership => [], index => $cell_inx};
    push @{$self->{cell}}, $cell;
    foreach my $name (sort split ',', $cell_def) {
	foreach my $other (@{$cell->{membership}}) {
	    my $int = "$other,$name";
	    $self->{intersection}{$int} ||= [];
	    push @{$self->{intersection}{$int}}, $cell_inx;
	    }
	push @{$cell->{membership}}, $name;
	my $set = $self->{set}{$name} ||=
		{name => $name, membership => []};
	push @{$set->{membership}}, $cell_inx;
	$self->{largest_set} = max ($self->{largest_set},
	    scalar @{$set->{membership}});
	}
    $cell_inx++;
    }
delete $self->{backtrack_stack};	# Force setting of new problem.
}

sub _set_value {$_[0]->{$_[1]} = $_[2]}


=item $string = $su->solution ();

This method returns the next solution to the problem, or undef if there
are no further solutions. The solution is a blank-delimited list of the
symbols each cell contains, with line breaks as specified by the
'columns' attribute. If the problem() method has not been called,
an exception is thrown.

Status values set:

  SUDOKU_SUCCESS
  SUDOKU_NO_SOLUTION
  SUDOKU_TOO_HARD

=cut

sub solution {
my $self = shift;

$self->{backtrack_stack} or croak <<eod;
Error - You cannot call the solution() method unless you have specified
        the problem via the problem() method.
eod

$self->{debug} and print <<eod;
Debug solution - entering method. Stack depth = @{[
	scalar @{$self->{backtrack_stack}}]}
eod

$self->_constrain ();
}


=item $string = $su->steps ();

This method returns the steps taken to solve the problem. If no
solution was found, it returns the steps taken to determine this. If
called in list context, you get an actual copy of the list. The first
element is the name of the constraint applied:

 F = forced: only one value works in this cell;
 N = numeration or necessary: this is the only cell
     that can supply the given value;
 B = box claim: if a candidate number appears in only
     one row or column of a given box, it can be
     eliminated as a candidate in that row or column
     but outside that box;
 T = tuple, which is a generalization of the concept
     pair, triple, and so on. These come in two
     varieties for a given size of the tuple N:
   naked: N cells contain among them N values, so
     no cells outside the tuple can supply those
     values.
   hidden: N cells contain N values which do not
     occur outside those cells, so any other values
     in the tuple are supressed.
 ? = no constraint: generated in backtrack mode.

See L<http://www.research.att.com/~gsf/sudoku/> and
L<http://www.angusj.com/sudoku/hints.php> for fuller
definitions of the constraints and how they are applied.

The second value is the cell number, as defined by the topology
setting. For the 'sudoku' and 'latin' settings, the cells are
numbered from zero, row-by-row. If you did your own topology, the
first cell you defined is 0, the second is 1, and so on.

The third value is the value assigned to the cell. If returned in
list context, it is the number assigned to the cell's symbol. If
in scalar context, it is the symbol itself.

=cut

sub steps {
my $self = shift;
wantarray ? (@{$self->{backtrack_stack}}) :
    defined wantarray ?
	$self->_format_constraint (@{$self->{backtrack_stack}}) :
    undef;
}


########################################################################

#	Private methods and subroutines.


#	$status_value = $su->_constrain ();

#	This method applies all possible constraints to the current
#	problem, placing them on the backtrack stack. The backtrack
#	algorithm needs to remove these when backtracking. The return
#	is false if we ran out of constraints, or true if we found
#	a constraint that could not be satisfied.

sub _constrain {
my $self = shift;
my $stack = $self->{backtrack_stack} ||= [];	# May hit this when initializing.
my $used = $self->{constraints_used} ||= {};
my $syms = @{$self->{symbol_list}};
my $iterations = $self->{iteration_limit}
    if $self->{iteration_limit} > 0;

$self->{no_more_solutions} and
    return $self->_unload (undef, SUDOKU_NO_SOLUTION);

@{$self->{backtrack_stack}} and do {
    $self->_constraint_remove and
	return $self->_unload (undef, SUDOKU_NO_SOLUTION);
   };

$self->{cells_unassigned} or do {
    $self->{no_more_solutions} = 1;
    return $self->_unload ('', SUDOKU_SUCCESS);
    };

my $number_of_cells = @{$self->{cell}};

constraint_loop:
{	# Begin outer constraint loop.

# F constraint - only one value possible.

die <<eod if @{$self->{cell}} != $number_of_cells;
Programming error - Before trying F constraint.
        We started with $number_of_cells cells, but now have @{[
	scalar @{$self->{cell}}]}.
eod

my $done = 1;				# Jump-start loop.
while ($done) {				# for as long as it works.
    $done = 0;
    foreach my $cell (@{$self->{cell}}) {
	next if $cell->{content};		# Skip already-assigned cells.
	my $pos = 0;
	foreach (values %{$cell->{possible}}) {$_ or $pos++};
	if ($pos > 1) {			# > 1 possibility. Can't apply.
	    }
	  elsif ($pos == 1) {		# Exactly 1 possibility. Apply.
	    my $val;
	    foreach (keys %{$cell->{possible}}) {
		next if $cell->{possible}{$_};
		$val = $_;
		last;
		}
	    $self->_try ($cell, $val) and die <<eod;
Programming error - Passed 'F' constraint but _try failed.
eod
	    my $constraint = [F => [$cell->{index}, $val]];
	    $self->{debug} and
		print '#    ', $self->_format_constraint ($constraint);
	    push @$stack, $constraint;
	    $used->{F}++;
	    $done++;
	    $self->{cells_unassigned} or
		return $self->_unload ('', SUDOKU_SUCCESS);
	    }
	  else {				# No possibilities. Backtrack.
	    my $rslt = $self->_constraint_remove;
	    redo constraint_loop unless $rslt;
	    $self->{debug} and
		print "#    No valid value for cell $cell->{index}. Backtracking.\n";
use Data::Dumper;
local $Data::Dumper::Terse = 1;
	    $self->{debug} > 1 and print "#    Cell is ", Dumper ($cell);
	    $self->{debug} > 2 and print "#    Self is ", Dumper ($self);
	    return $self->_unload ('', $rslt);
	    }
	}
    }

# N constraint - the only cell which supplies a necessary value.

die <<eod if @{$self->{cell}} != $number_of_cells;
Programming error - Before trying N constraint.
        We started with $number_of_cells cells, but now have @{[
	scalar @{$self->{cell}}]}.
eod

while (my ($name, $set) = each %{$self->{set}}) {
    my @suppliers;
    foreach my $inx (@{$set->{membership}}) {
	my $cell  = $self->{cell}[$inx];
	next if $cell->{content};
	while (my ($val, $count) = each %{$cell->{possible}}) {
	    next if $count;
	    $suppliers[$val] ||= [];
	    push @{$suppliers[$val]}, $inx;
	    }
	}
    my $limit = @suppliers;
    for (my $val = 1; $val < $limit; $val++) {
	next unless $suppliers[$val] && @{$suppliers[$val]} == 1;
	my $inx = $suppliers[$val][0];
	$self->_try ($inx, $val) and die <<eod, $self->{debug} ? <<eod : ();
Programming error - Cell $inx passed 'N' constraint but try of
        $self->{symbol_list}[$val] failed.
eod
@{[$self->_unload
]}         set: $name
        cell: @{[Dumper ($self->{cell}[$inx])]}
eod
	my $constraint = [N => [$inx, $val]];
	$self->{debug} and
	    print '#    ', $self->_format_constraint ($constraint);
	push @$stack, $constraint;
	$used->{N}++;
	$done++;
	$self->{cells_unassigned} or
	    return $self->_unload ('', SUDOKU_SUCCESS);
	keys %{$self->{set}};	# Reset iterator.
	redo constraint_loop;
	}
    }

# B constraint - "box claim". Given two sets whose intersection
#	contains more than one cell, if all cells which can contribute
#	a given value to one set are in the intersection, no cell in
#	the second set can contribute that value. Note that this
#	constraint does NOT actually assign a value to a cell, it just
#	eliminates possible values. The name is because on the
#	"standard" sudoku layout one of the sets is always a box; the
#	other can be a row or a column.

die <<eod if @{$self->{cell}} != $number_of_cells;
Programming error - Before trying B constraint.
        We started with $number_of_cells cells, but now have @{[
	scalar @{$self->{cell}}]}.
eod

while (my ($int, $cells) = each %{$self->{intersection}}) {
    next unless @$cells > 1;
    my @int_supplies;	# Values supplied by the intersection
    my %int_cells;	# Cells in the intersection
    foreach my $inx (@$cells) {
	next if $self->{cell}[$inx]{content};
	$int_cells{$inx} = 1;
	while (my ($val, $imposs) = each %{$self->{cell}[$inx]{possible}}) {
	    $int_supplies[$val] = 1 unless $imposs;
	    }
	}
    my %ext_supplies;	# Intersection values also supplied outside.
    my %ext_cells;	# Cells not in the intersection.
    my @set_names = split ',', $int;
    foreach my $set (@set_names) {
	$ext_supplies{$set} = [];
	$ext_cells{$set} = [];
	foreach my $inx (@{$self->{set}{$set}{membership}}) {
	    next if $int_cells{$inx};	# Skip cells in intersection.
	    next if $self->{cell}[$inx]{content};
	    push @{$ext_cells{$set}}, $inx;
	    while (my ($val, $imposs) = each %{$self->{cell}[$inx]{possible}}) {
		$ext_supplies{$set}[$val] = 1 if !$imposs && $int_supplies[$val];
		}
	    }
	}
    for (my $val = 1; $val < @int_supplies; $val++) {
	next unless $int_supplies[$val];
	my @occurs_in = grep {$ext_supplies{$_}[$val]} @set_names;
	next unless @occurs_in && @occurs_in < @set_names;
	my %cells_claimed;
	foreach my $set (@occurs_in) {
	    foreach my $inx (@{$ext_cells{$set}}) {
		next if $self->{cell}[$inx]{possible}{$val};
		$cells_claimed{$inx} = 1;
		$self->{cell}[$inx]{possible}{$val} = 1;
		$done++;
		}
	    }
	next unless $done;
	my $constraint = [B => [[sort keys %cells_claimed], $val]];
	$self->{debug} and
	    print '#    ', $self->_format_constraint ($constraint);
	push @$stack, $constraint;
	$used->{B}++;
	$done++;
	keys %{$self->{intersection}};	# Reset iterator.
	redo constraint_loop;
	}
    }

# T constraint - "tuple" (double, triple, quad). These come in two
#	flavors, "naked" and "hidden". Considering only pairs for the
#	moment:
#   A "naked pair" is two cells in the same set which contain the same
#	pair of possibilities, and only those possibilities. These
#	possibilities are then excluded from other cells in the set.
#   A "hidden pair" is when there is a pair of values which can only
#	be contributed to the set by one or the other of a pair of
#	cells. These cells then must supply these values, and any other
#	values supplied by cells in the pair can be eliminated.
#    For higher groups (triples, quads ...) the rules generalize, except
#	that all of the candidate values need not be present in all of
#	the cells under consideration; it is only necessary that none
#	of the candidate values appears outside the cells under
#	consideration.
#
#	Glenn Fowler of AT&T (http://www.research.att.com/~gsf/sudoku/)
#	lumps all these together. But he refers to Angus Johnson
#	(http://www.angusj.com/sudoku/hints.php) for the details, and
#	Angus separates naked and hidden tuples.

die <<eod if @{$self->{cell}} != $number_of_cells;
Programming error - Before trying B constraint.
        We started with $number_of_cells cells, but now have @{[
	scalar @{$self->{cell}}]}.
eod

{	# Begin local symbol block
    my @tuple;		# Tuple indices
    my %vacant;		# Empty cells by set. $vacant{$set} = [$cell ...]
    my %contributors;	# Number of cells which can contrib value, by set.
    my $syms = @{$self->{symbol_list}};
    while (my ($name, $set) = each %{$self->{set}}) {
	my @open = grep {!$_->{content}}
	    map {$self->{cell}[$_]} @{$set->{membership}}
	    or next;
	foreach my $cell (@open) {
	    for (my $val = 1; $val < $syms; $val++) {
		$cell->{possible}{$val} and next;
		$contributors{$name} ||= [];
		$contributors{$name}[$val]++;
		}
	    }
	@{$contributors{$name}} = map {$_ || 0} @{$contributors{$name}};
	$vacant{$name} = \@open;
	$tuple[scalar @open] ||= [map {[$_]} 0 .. $#open];
	}
    for (my $order = 2; $order <= $self->{max_tuple}; $order++) {
	for (my $inx = 1; $inx < @tuple; $inx++) {
	    next unless $tuple[$inx];
	    my $max = $inx - 1;
	    $tuple[$inx] = [map {my @tpl = @$_;
		map {[@tpl, $_]} $tpl[$#tpl] + 1 .. $max}
		grep {$_->[@$_ - 1] < $max} @{$tuple[$inx]}];
	    $tuple[$inx] = undef unless @{$tuple[$inx]};
	    }

#	Okay, I have generated the blasted tuples. Now I need to take
#	the union of all values provided by the tuple of cells. If the
#	number of values in this union is equal to the current order, I
#	have potentially found a naked tuple, and if this lets me
#	eliminate any values outside the tuple I can apply the
#	constraint. If the number of values inside the union is greater
#	than the current order, I need to consider whether any tuple of
#	supplied values is not represented outside the cell tuple; if
#	so, I have a hidden tuple and can eliminate the superfluous
#	values.

	foreach my $name (keys %vacant) {
	    my $open = $vacant{$name};
	    next unless $tuple[@$open];
	    my $contributed = $contributors{$name};
	    foreach my $tuple (@{$tuple[@$open]}) {
		my @tcontr;	# number of times each value contributed by the tuple.
		foreach my $inx (@$tuple) {
		    my $cell = $open->[$inx];
		    for (my $val = 1; $val < $syms; $val++) {
			next if $cell->{possible}{$val};
			$tcontr[$val]++;
			}
		    }
		@tcontr = map {$_ || 0} @tcontr;


#	At this point, @tcontr contains how many cells in the tuple
#	contribute each value. Calculate the number of discrete values
#	the tuple can contribute.

#	If the number of discrete values contributed by the tuple is
#	equal to the current order, we have a naked tuple. We have an
#	"effective" naked tuple if at least one of the values
#	contributed by the tuple occurs outside the tuple. We can
#	determine this by subtracting the values in @tcontr from the
#	corresponding values in @$contributed; if we get a positive
#	result for any cell, we have an "effective" naked tuple.

		my $discrete = grep {$_} @tcontr;
		my $constraint;
		my @tuple_member;
		if ($discrete == $order) {
		    for (my $val = 1; $val < @tcontr; $val++) {
			next unless $tcontr[$val] &&
			    $contributed->[$val] > $tcontr[$val];

#	At this point we know we have an "effective" naked tuple.

			$constraint ||= ['T', 'naked', $order];
			@tuple_member or map {$tuple_member[$_] = 1} @$tuple;
			my @ccl;
			for (my $inx = 0; $inx < @$open; $inx++) {
			    next if $tuple_member[$inx] ||
				$open->[$inx]{possible}{$val};
			    $open->[$inx]{possible}{$val} = 1;
			    --$contributed->[$val];
			    push @ccl, $open->[$inx]{index};
			    }
			push @$constraint, [\@ccl, $val] if @ccl;
			}
		    }

#	If the number of discrete values is greater than the current
#	order, we may have a hidden tuple. The test for an "effective"
#	hidden tuple involves massaging @tcontr against @$contributed in
#	some way to find a tuple of values within the tuple of cells
#	which do not occur outside it.

		  elsif ($discrete > $order) {
		    my $within = 0;	# Number of values occuring only within tuple.
		    for (my $val = 1; $val < @tcontr; $val++) {
			$within++ if $tcontr[$val] &&
			    $contributed->[$val] == $tcontr[$val];
			}
		    next unless $within >= $order;
		    $constraint = ['T', 'hidden', $order];
		    map {$tuple_member[$_] = 1} @$tuple;
		    for (my $val = 1; $val < @tcontr; $val++) {
			next unless $tcontr[$val] &&
			    $contributed->[$val] > $tcontr[$val];
			my @ccl;
			for (my $inx = 0; $inx < @$open; $inx++) {
			    next unless $tuple_member[$inx]
				&& !$open->[$inx]{possible}{$val}
				;
			    $open->[$inx]{possible}{$val} = 1;
			    --$contributed->[$val];
			    --$tcontr[$val];
			    push @ccl, $open->[$inx]{index};
			    }

			push @$constraint, [\@ccl, $val] if @ccl;
			}
		    }

		next unless $constraint;
		$self->{debug} and
		    print '#    ', $self->_format_constraint ($constraint);
		push @$stack, $constraint;
		$used->{T}++;
		$done++;
		redo constraint_loop;
		}	# Next tuple
	    }	# Next set containing vacant cells
	}	# Next order
    }	# End local symbol block.

redo if $done;

# ? constraint - initiate backtracking.

die <<eod if @{$self->{cell}} != $number_of_cells;
Programming error - Before trying ? constraint.
        We started with $number_of_cells cells, but now have @{[
	scalar @{$self->{cell}}]}.
eod

--$iterations >= 0 or return $self->_unload ('', SUDOKU_TOO_HARD)
    if defined $iterations;
my @try;
my $syms = @{$self->{symbol_list}};
foreach my $cell (@{$self->{cell}}) {
    next if $cell->{content};
    my $possible = 0;
    for (my $val = 1; $val < $syms; $val++) {
	$possible++ unless $cell->{possible}{$val};
	}
    $possible or do {
	$self->_constraint_remove and
	    return $self->_unload (undef, SUDOKU_NO_SOLUTION);
	redo constraint_loop;
	};
    push @try, [$cell, $possible];
    }
@try = map {$_->[0]} sort {$a->[1] <=> $b->[1] || $a->[0]{index} <=> $b->[0]{index}} @try;
my $cell = $try[0];
for (my $val = 1; $val < $syms; $val++) {
    next if $cell->{possible}{$val};
    $self->_try ($cell, $val) and die <<eod;
Programming error - Value $val illegal in cell $cell->{index}, but
        \$self->{possible}{$val} = $self->{possible}{$val}
eod
    my $constraint = ['?' => [$cell->{index}, $val]];
    $self->{debug} and
	print '#    ', $self->_format_constraint ($constraint);
    push @$stack, $constraint;
    $used->{'?'}++;
    $done++;
    redo constraint_loop;
    }
}	# end outer constraint loop.

$self->set (status_value => SUDOKU_TOO_HARD);
return undef;
}


#	$status_value = $su->_constraint_remove ();

#	This method removes the topmost constraints from the backtrack
#	stack. It continues until the next item is a backtrack item or
#	the stack is empty. It returns true (SUDOKU_NO_SOLUTION,
#	actually) if the stack is emptied, or false (SUDOKU_SUCCESS,
#	actually) if it stops because it found a backtrack item.

sub _constraint_remove {
my $self = shift;
$self->{no_more_solutions} and return SUDOKU_NO_SOLUTION;
my $stack = $self->{backtrack_stack} or return SUDOKU_NO_SOLUTION;
my $used = $self->{constraints_used} ||= {};
my $inx = @$stack;
my $syms = @{$self->{symbol_list}};
$self->{debug} && $inx and print <<eod;
# Debug - Backtracking
eod
my $old = $inx;
while (--$inx >= 0) {
    my $constraint = $stack->[$inx][0];
    --$used->{$constraint};
    if ($constraint eq 'F' || $constraint eq 'N') {
	foreach my $ref (reverse @{$stack->[$inx]}) {
	    $self->_try ($ref->[0], 0) if ref $ref;
	    }
	}
      elsif ($constraint eq 'B' || $constraint eq 'T') {
	foreach my $ref (reverse @{$stack->[$inx]}) {
	    next unless ref $ref;
	    my $val = $ref->[1];
	    foreach my $inx (@{$ref->[0]}) {
		$self->{cell}[$inx]{possible}{$val} = 0;
		}
	    }
	}
      elsif ($constraint eq '?') {
	my $start = $stack->[$inx][1][1] + 1;
	my $cell = $self->{cell}[$stack->[$inx][1][0]];
	$self->_try ($cell, 0);
	for (my $val = $start; $val < $syms; $val++) {
	    next if $cell->{possible}{$val};
		$self->_try ($cell, $val) and die <<eod;
Programming error - Try of $val in cell $cell->{index} failed, but
        \$cell->{possible}[$inx] = $cell->{possible}[$inx]
eod
	    $used->{$constraint}++;
	    $stack->[$inx][1][0] = $cell->{index};
	    $stack->[$inx][1][1] = $val;
	    $self->{debug} and do {
		my $x = $self->_format_constraint ($stack->[$inx]);
		chomp $x;
		print <<eod;
# Debug - Backtrack complete. @{[$old - @$stack]} constraints removed.
#         Resuming puzzle at stack depth @{[$inx + 1]} with
#         $self->{cells_unassigned} unassigned cells, guessing
#         $x
eod
		};
	    return SUDOKU_SUCCESS;
	    }
	}
      else {die <<eod}
Programming Error - No code provided to remove constraint '$constraint' from stack.
eod
    pop @$stack;
    }
$self->{debug} and print <<eod;
# Debug - Backtrack complete. @{[$old - @$stack]} constraints removed.
#         No more solutions to the puzzle exist.
eod
$self->{no_more_solutions} = 1;
return SUDOKU_NO_SOLUTION;
}

#	_format_constraint formats the given constraint for output.

sub _format_constraint {
my $self = shift;
my @steps;
foreach (@_) {
    my @stuff;
    foreach (@$_) {
	last unless $_;
	push @stuff, ref $_ ?
	    '[' . join (' ',
		ref $_->[0] ? '[' . join (', ', @{$_->[0]}) . ']' : $_->[0],
		ref $_->[1] ? '[' . join (', ',
		    map {$self->{symbol_list}[$_]} @{$_->[1]}) . ']' :
		    $self->{symbol_list}[$_->[1]],
		    ) . ']' :
	    $_;
	}
    push @steps, join (' ', @stuff) . "\n";
    }
join '', @steps;
}

#	_get_* subroutines are found right after the get() method.


#	_set_* subroutines are found right after the set() method.


#	$su->_try ($cell, $value)

#	This method inserts the given value in the given cell,
#	replacing the previous value if any, and doing all the
#	bookkeeping. If the given value is legal (meaning, if
#	it is zero or if it is unique in all sets the cell
#	belongs to), it returns 0. If not, it returns 1, but
#	does not undo the trial.

sub _try {
my $self = shift;
my $cell = shift;
$cell = $self->{cell}[$cell] unless ref $cell;
my $new = shift;
defined (my $old = $cell->{content}) or die <<eod;
Programming error - Old cell $cell->{index} content not defined.
eod
my $rslt = eval {
    return 0 if $old == $new;
    if ($new) {
	foreach my $set (@{$cell->{membership}}) {
	    return 1 if $self->{set}{$set}{content}[$new];
	    }
	}
    $cell->{content} = $new;
    $old and $self->{cells_unassigned}++;
    $new and --$self->{cells_unassigned};
    foreach my $name (@{$cell->{membership}}) {
	my $set = $self->{set}{$name};
	--$set->{content}[$old];
	$old and do {
	    $set->{free}++;
	    foreach (@{$set->{membership}}) {
		--$self->{cell}[$_]{possible}{$old};
		}
	    };
	$set->{content}[$new]++;
	$new and do {
	    --$set->{free};
	    foreach (@{$set->{membership}}) {
		$self->{cell}[$_]{possible}{$new}++;
		}
	    };
	}
    return 0;
    };
$@ and croak <<eod;
Programming Error - eval failed in _try.
$@
eod
$rslt;
}


#	$string = $self->_unload (prefix, status_value)

#	This method unloads the current cell contents into a string.
#	The prefix is prefixed to the string, and defaults to ''.
#	If status_value is specified, it is set. If status_value is
#	specified and it is a failure status, undef is returned, and
#	the current cell contents are ignored.

sub _unload {
my $self = shift;
my $prefix = shift || '';
@_ and do {$self->set (status_value => $_[0]); $_[0] and return undef};
my $rslt = '';
my $col = $self->{columns};
my $fmt = "%$self->{biggest_symbol}s";
foreach (@{$self->{cell}}) {
    $col == $self->{columns} and $rslt .= $prefix;
    $rslt .= sprintf $fmt, $self->{symbol_list}[$_->{content} || 0];
    if (--$col > 0) {$rslt .= $self->{output_delimiter}}
      else {$rslt .= "\n"; $col = $self->{columns};}
    }
return $rslt;
}

1;

__END__

=back

=head1 EXECUTABLES

The distribution for this module also contains the script 'sudokug',
which is a command-driven interface to this module.

=head1 BUGS

The X, Y, and W constraints (to use Glenn Fowler's terminology) are
not yet handled. The package can solve puzzles that need these
constraints, but it does so by backtracking.

Please report bugs either through L<http://rt.cpan.org/> or by
mail to the author.

=head1 ACKNOWLEDGMENTS

The authow would like to acknowledge the following, without whom this
module would not exist:

Glenn Fowler of AT&T, whose L<http://www.research.att.com/~gsf/sudoku/>
provided the methodological starting point and basic terminology, whose
'sudoku' executable provided a reference implementation for checking
the solutions of standard Sudoku puzzles, and whose constraint taxonomy
data set provided invaluable test data.

Angus Johnson, whose fulsome explanation at
L<http://www.angusj.com/sudoku/hints.php> was a great help
in understanding the mechanics of solving Sudoku puzzles.

Ed Pegg, Jr, whose Mathematical Association of America C<Math Games>
column for September 5 2005
(L<http://www.maa.org/editorial/mathgames/mathgames_09_05_05.html>)
provided a treasure trove of 'non-standard' Sudoku puzzles.

=head1 MODIFICATIONS

 0.001 T. R. Wyant
   Initial release to CPAN.
 0.002 T. R. Wyant
   Format solution nicely for multi-character symbols.
   Fixed error in values eliminated by a hidden tuple.
   Recoded 'set sudokug' in terms of 'set brick', thus
     fixing an error in generating the small squares.
   Added method add_set(), and recoded 'set sudokux' in
     terms of this and 'set sudokug', thus fixing the
     same error that 'set sudoku' had.
   Put spaces in the result of scalar constraints_used.
   Spiffed up the POD.
 0.003 T. R. Wyant
   Added 'set corresponding' and 'set max_tuple'.
   Added cubic sudoku (via 'set cube').
   Fixed horrendous inefficiency in backtrack logic.
 0.004 T. R. Wyant
   Added Dion cube (via 'set cube number').

=head1 SEE ALSO

The Games-Sudoku package by Eugene Kulesha (see
L<http://search.cpan.org/~jset/>) solves the standard 9x9 version
of the puzzle.

The Games-Sudoku-OO package by Michael Cope (see
L<http://search.cpan.org/~cope/>) also solves the standard
9x9 version of the puzzle, with an option to solve (to the extent
possible) a single row, column, or square. The implementation may
be extensable to other topologies than the standard one.

The Games-YASudoku package by Andrew Wyllie (see
L<http://search.cpan.org/~wyllie/>) also solves the standard
9x9 version of the puzzle. In contrast to the other packages, this one
represents the board as a list of cell/value pairs.

=head1 AUTHOR

Thomas R. Wyant, III (F<wyant at cpan dot org>)

=head1 COPYRIGHT

Copyright 2005 by Thomas R. Wyant, III
(F<wyant at cpan dot org>). All rights reserved.

This module is free software; you can use it, redistribute it
and/or modify it under the same terms as Perl itself.

=cut

#	Guide to attributes:
#  The following indicators say how each attribute is used:
#    T - The attribute is used to define the topology. It is set by
#        set (topology => string).
#    A - The attribute is set by some setting other than topology.
#    P - The attribute is used to define the problem. It is set by
#        problem();
#    S - The attribute is used to solve the problem.
#
#  T {cell} = []		# A list of the cell definitions.
#  P {cell}[$inx]{content}	# The symbol the cell contains.
#  T {cell}[$inx]{index} = $inx	# The index number of the cell.
#  T {cell}[$inx]{membership} = [] # A list of the names of the sets
#				   # the cell is a member of.
#  P {cell}[$inx]{possible} = {}   # A list of the possible values of
#				   # the cell. Each element is false if
#				   # the value is possible.
#  P {cells_unassigned}		# Number of empty cells remaining
#  S {constraints_used} = {}	# The number of times each constraint
#				# was applied.
#  T {intersection}{$name} = []	# The indices of the cells in the named
#				# intersection. The name is the alpha-
#				# betized set names, comma-separated.
#  T {largest_set}		# The size of the largest set.
#  S {no_more_solutions}	# Cleared when problem set up, set when
#				# we run out of backtrack.
#  T {set} = {}			# A hash of all the set definitions.
#  T {set}{$set}{content} = []	# The contents of the set.
#  T {set}{$set}{membership} = []  # A list of the numbers of the cells
#				   # that are members of the set.
#  T {set}{$set}{name} = $set	# The name of the set.
#  A {allowed_symbols}{$name} = [] # The list contains a 1 if the
#				# symbol's value is allowed under the
#				# named symbol set.
#  A {biggest_spec}		# Number of characters in biggest
#				# symbol or allowed value set name.
#  A {biggest_symbol}		# Number of characters in biggest
#				# symbol.
#  A {symbol_hash} = {}		# A hash of symbols, giving the internal
#				# value for each.
#  A {symbol_list} = []		# A list of the symbols used, in order
#				# by the values used internally.
#  A {symbol_number}		# Number of symbols defined.
