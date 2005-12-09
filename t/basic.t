
use strict;
use warnings;

use Test;


plan tests => 2;
print <<eod;
#
# Test 1 - Load Games::Sudoku::General;
eod
eval "use Games::Sudoku::General";
my $skip = $@ ? 'Failed to load Games::Sudoku::General' : '';
print $skip ? "# $skip\n" : "# Games::Sudoku::General loaded successfully.\n";
ok (!$skip);

print <<eod;
#
# Test 2 - Instantiate a Games::Sudoku::General object.
eod
skip ($skip, $skip || Games::Sudoku::General->new ());
