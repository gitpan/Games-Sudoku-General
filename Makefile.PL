use 5.006002;	# For 'our', at the very least.

use strict;
use warnings;

use lib qw{ inc };

use Config;
use ExtUtils::MakeMaker qw{WriteMakefile prompt};
use FileHandle;
use Getopt::Std;
use My::Module::Meta;

my $meta = My::Module::Meta->new();

my %opt;
getopts ('ny', \%opt) or die <<eod;
The only legal options are
  -n = answer all questions 'no';
  -y = answer all questions 'yes'.
eod

my @exe_files;
my @clean_files;

print <<'EOD';

In addition to Games::Sudoku::General, you will get the following
executable:

  sudokug -- an interactive interface to Games::Sudoku::General.

Unless you are running MSWin32 or VMS (which are special-cased),
I will assume you are running some version of U*ix, and behave
accordingly.

If you do not want this executable installed, rerun this script
with the -n qualifier.

>>>> NOTICE <<<<

Beginning with the first release after July 1 2015, sudokug will be
installed by default. If you do not want it installed, provide the -n
option when you run Makefile.PL.

I also intend to get rid of the OS-specific ad-hocery at this point.

EOD

if ($opt{n}) {
    print "Because you have asserted -n, the executable will not be installed.\n\n";
    }
  elsif ( $opt{y} ) {
    push @exe_files, qw{ sudokug };
    print "Because you have asserted -y, the executable will be installed.\n";
    }
  else {
    foreach (qw{sudokug}) {
	push @exe_files, $_
	    if prompt ("Do you want to install $_?", 'n') =~ m/^y/i;
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

(my $mmv = ExtUtils::MakeMaker->VERSION) =~ s/_//g;
my %attr = (
##  (MM->can ('signature_target') ? (SIGN => 1) : ()),
    NAME => 'Games::Sudoku::General',
    VERSION_FROM => 'lib/Games/Sudoku/General.pm',
    PREREQ_PM => $meta->requires(),
    PL_FILES => {},	# Prevent old MakeMaker from running Build.PL
    EXE_FILES => \@exe_files,
#   'linkext' => {LINKTYPE => ''},
    'dist' => {COMPRESS => 'gzip', SUFFIX => 'gz'},
    realclean => {FILES => join ' ', @clean_files},
    AUTHOR => 'Tom Wyant (wyant at cpan dot org)',
    ABSTRACT => 'Solve Sudoku and related puzzles',
    BINARY_LOCATION => "$Config{archname}$vers/Games-Sudoku-General.tar.gz",
);


$mmv >= 6.31 and $attr{LICENSE} = 'perl';

if ( $mmv >= 6.4501 ) {
    $attr{META_ADD} = {
	no_index => {
	    directory => [ qw{ inc t xt } ],
	},
    };    
    $attr{META_MERGE} = {
	resources => {
	    bugtracker => 'https://rt.cpan.org/Public/Dist/Display.html?Name=Games-Sudoku-General',
	    license => 'http://dev.perl.org/licenses/',
	},
    };
}

$mmv >= 6.4701 and $attr{MIN_PERL_VERSION} = $meta->requires_perl();

$mmv >= 6.5501
    and $attr{BUILD_REQUIRES} = $meta->build_requires()
    or $mmv >= 6.4501
    and $attr{META_MERGE}{build_requires} = $meta->build_requires();

WriteMakefile(%attr);

# ex: set textwidth=72 :
