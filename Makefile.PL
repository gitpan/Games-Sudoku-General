use Config;
use ExtUtils::MakeMaker qw{WriteMakefile prompt};
use FileHandle;
use Getopt::Std;

our $VERSION = '0.002';

my %opt;
getopts ('n', \%opt) or die <<eod;
The only legal option is
  -n = answer all questions 'no'.
eod

my @exe_files;
my @clean_files;

print <<eod;

In addition to Games::Sudoku::General, you will get the following
executable:

  sudokug -- an interactive interface to Games::Sudoku::General.

Unless you are running MSWin32 or VMS (which are special-cased),
I will assume you are running some version of U*ix, and behave
accordingly.

If you do not want this executable installed, rerun this script
with the -n qualifier.

eod

if ($opt{n}) {
    print "Because you have asserted -n, the executable will not be installed.\n\n";
    }
  else {
    foreach (qw{sudokug}) {
	push @exe_files, $_
##	    if prompt ("Do you want to install $_?", 'n') =~ m/^y/i;
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

WriteMakefile (
##	(MM->can ('signature_target') ? (SIGN => 1) : ()),
	NAME => 'Games::Sudoku::General',
	VERSION_FROM => 'lib/Games/Sudoku/General.pm',
	PREREQ_PM => {
			},
	PL_FILES => {},	# Prevent old MakeMaker from running Build.PL
	EXE_FILES => \@exe_files,
#	'linkext' => {LINKTYPE => ''},
	'dist' => {COMPRESS => 'gzip', SUFFIX => 'gz'},
	realclean => {FILES => join ' ', @clean_files},
	$] >= 5.005 ? (
		AUTHOR => 'Tom Wyant (wyant at cpan dot org)',
		ABSTRACT => 'Solve Sudoku and related puzzles',
		BINARY_LOCATION => "$Config{archname}$vers/Games-Sudoku-General.tar.gz",
		) : (),
	);
