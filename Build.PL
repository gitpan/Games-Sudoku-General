use 5.006;	# For 'our', at the very least.

use strict;
use warnings;

use Config;
use FileHandle;
use Module::Build;

#	Generate a builder object.

my $bldr = Module::Build->new (
	dist_author => 'Tom Wyant (wyant at cpan dot org)',
	dist_abstract => 'Solve Sudoku and related puzzles',
	module_name => 'Games::Sudoku::General',
	requires => {},
##	dist_name => 'Games-Sudoku-General',
##	dist_version_from => 'lib/Games/Sudoku/General.pm',
	get_options => {y => {}, n => {}},
	dynamic_config => 1,
	license => 'perl',
	);

#	Find out what the user wants to do.

my %opt => $bldr->args ();

my @exe_files;
my @clean_files;

my @possible_exes = ('sudokug');
print <<eod;

In addition to Games::Sudoku::General, you will get the following
executable:

  sudokug -- an interactive interface to Games::Sudoku::General.

If you do not want this, run Build.PL with the -n option.

Unless you are running MSWin32 or VMS (which are special-cased),
I will assume you're running some version of U*ix, and behave
accordingly.

eod


if ($opt{n}) {
    print "Because you have asserted -n, the executables will not be installed.\n\n";
    }
  elsif ($opt{y}) {
    print "Because you have asserted -y, the executables will be installed.\n\n";
    @exe_files = @possible_exes;
    }
  else {
    foreach (@possible_exes) {
	push @exe_files, $_
	if $bldr->prompt ("Do you want to install $_?", 'n') =~ m/^y/i
	    ;
	}
    }

if (@exe_files) {
    if ($^O eq 'MSWin32') {
	@exe_files = map {"bin/$_"} @exe_files;
	foreach (@exe_files) {`pl2bat $_`}
	@clean_files = @exe_files =
	    grep {-e $_} map {"$_.bat"} @exe_files;
	}
      elsif ($^O eq 'VMS') {
	foreach my $fni (map {"[.bin]$_"} @exe_files) {
	    my $fno = "$fni.com";
	    my $fhi = FileHandle->new ("<$fni") or die <<eod;
Error - Unable to open $fni
        $!
eod
	    my $fho = FileHandle->new (">$fno") or die <<eod;
Error - Unable to open $fno
        $!
eod
	    print $fho "$Config{startperl}\n";
	    while (<$fhi>) {print $fho $_}
	    }
	@clean_files = @exe_files = map {"[.bin]$_.com"} @exe_files;
	}
      else {
	@exe_files = map {"bin/$_"} @exe_files;
	}
    }

##my $vers = $] >= 5.008 ? '-5.8' : '';
my $vers = '';

#	Tell Module::Build what we want to do.

$bldr->add_to_cleanup (\@clean_files);
$bldr->script_files (\@exe_files);

#	Generate the build script, at long last.

$bldr->create_build_script ();

