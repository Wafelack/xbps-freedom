#!/usr/bin/env perl
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <https://www.gnu.org/licenses/>.

use strict;
use warnings;
use Getopt::Long qw(GetOptions);

my @copyleft = ("GPL-2.0-only", "GPL-2.0-or-later", "GPL-3.0-only", "GPL-3.0-or-later", 
    "AGPL-1.0-only", "AGPL-1.0-or-later", "AGPL-3.0-only", "AGPL-3.0-or-later",
    "GFDL-1.1-only", "GFDL-1.1-or-later", "GFDL-1.2-only", "GFDL-1.2-or-later",
    "GFDL-1.3-only", "GFDL-1.3-or-later");
my @free = ("AFL-1.1", "AFL-1.2", "AFL-2.0", "AFL-2.1", "AFL-3.0", "Apache-1.0", 
    "Apache-1.1", "Apache-2.0", "APSL-2.0", "Artistic-2.0", "BitTorrent-1.1",
    "BSD-3-Clause", "BSD-3-Clause-Clear", "BSD-4-Clause", "BSL-1.0", "CC-BY-4.0",
    "CC-BY-SA-4.0", "CC0-1.0", "CDDL-1.0", "CECILL-2.0", "CECILL-B", "CECILL-C",
    "ClArtistic", "Condor-1.1", "CPAL-1.0", "CPL-1.0", "ECL-2.0", "EFL-2.0",
    "EPL-1.0", "EPL-2.0", "EUDatagrid", "EUPL-1.1", "FTL", "gnuplot", "HPND",
    "IJG", "iMatix", "Imlib2", "Intel", "IPA", "IPL-1.0", "ISC",
    "LGPL-2.0-only", "LGPL-2.0-or-later", "LGPL-2.1-only", "LGPL-2.1-or-later",
    "LGPL-3.0-only", "LGPL-3.0-or-later", "LPPL-1.2", "LPPL-1.3a", "LPL-1.02",
    "MIT", "MPL-1.1", "MPL-2.0", "MS-PL", "MS-RL", "NCSA", "Nokia", "NOSL",
    "NPL-1.0", "NPL-1.1", "ODbL-1.0", "OFL-1.1", "OLDAP-2.3", "OLDAP-2.7",
    "OpenSSL", "OSL-1.0", "OSL-1.1", "OSL-2.0", "OSL-2.1", "OSL-3.0", "PHP-3.01",
    "Python-2.0", "QPL-1.0", "RPSL-1.0", "Ruby", "SGI-B-2.0", "SISSL", "Sleepycat",
    "SMLNJ", "SPL-1.0", "Unlicense", "UPL-1.0", "Vim", "W3C", "WTFPL", "X11",
    "XFree86-1.1", "xinetd", "YPL-1.1", "Zend-2.0", "Zimbra-1.3", "Zlib",
    "ZPL-2.0", "ZPL-2.1", "Public Domain");

# Make licenses searchable.
my %copyleft = map { $_ => 1 } @copyleft;
my %free = map { $_ => 1 } @free;

my $verbose = 0;

GetOptions(
    'v' => \$verbose,
    'V' => sub { $verbose = 2 },
);

my $copylefts = 0;
my $frees = 0;
my $nonfrees = 0;

# Check if a license is either nonfree, free or copyleft.
# 0 stands for nonfree
# 1   "     "  free
# 2   "     "  copyleft
sub check_license {
    my ($raw_license) = @_;
    my @licenses = split /,/, $raw_license;
    $_ =~ s/^\s+|\s+$//g foreach (@licenses);
    if ($verbose > 1) {
        print "  (licenses . (";
        print ' "', $_, '"' foreach (@licenses);
        print " ))\n";
    }
    foreach (@licenses) {
        return 2 if exists($copyleft{$_});
        return 1 if exists($free{$_});
    }
    return 0;
}

open(my $package_list, '-|', "xbps-query -l | grep ^ii | awk -F' ' '{ print \$2 }'") 
    or die "Failed to list packages: $!.\n";

while (<$package_list>) {
    chomp $_;
    my $license = `xbps-query $_ | grep license: | awk -F'license: ' '{ print \$2 }'`;
    print "($_ .\n" if ($verbose);
    my $freedom = check_license $license;
    print "  (freedom . \x1b[0;" if ($verbose);
    if ($freedom == 0) {
        $nonfrees++;
        print "31mnonfree" if ($verbose);
    } elsif ($freedom == 1) {
        $frees++;
        print "33mfree" if ($verbose);
    } else {
        $copylefts++;
        print "32mcopyleft" if ($verbose);
    }
    print "\x1b[0;m))\n" if ($verbose);
}

print "\nYou have $copylefts copyleft packages, $frees free packages and $nonfrees non-free packages out of ", $copylefts + $frees + $nonfrees, " total.\n";

close $package_list;
