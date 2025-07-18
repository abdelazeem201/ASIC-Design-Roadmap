#!/usr/bin/perl

use strict;
use warnings;

#---------------------------------------------------------------------
# USAGE: NDR_rule.pl <techfile> <spacing_multiplier> <width_multiplier>
#---------------------------------------------------------------------

# Check for minimum number of arguments
die "Usage: NDR_rule.pl <techfile> <spacing_multiplier> <width_multiplier>\n" 
    if (@ARGV < 3);

# Read command-line arguments
my ($techfile, $SM, $WM) = @ARGV;

# Variables to store final WIDTH and SPACE strings
my ($W, $S) = ("", "");

# Open techfile for reading
open(my $TECH, "<", $techfile) or die "Cannot open file $techfile: $!";

# Layer processing
my ($found, $name, $width, $space);

while (my $line = <$TECH>) {
    chomp $line;

    # End of a layer definition
    $found = 0 if $line =~ /\}/;

    # Start of a new layer
    if ($line =~ /^Layer\s+(\S+)/) {
        $name = $1;
        $name =~ s/[\"\s]//g;
        $found = ($name =~ /^M\d+$/) ? 0 : -1;  # Only process metal layers like M1, M2, etc.
    }

    # Extract defaultWidth
    if ($line =~ /defaultWidth\s+([\d.]+)/) {
        $width = $1;
        $found++ if ($width > 0 && $width < 1);
    }

    # Extract minSpacing
    if ($line =~ /minSpacing\s+([\d.]+)/) {
        $space = $1;
        $found++ if ($space > 0 && $space < 1);
    }

    # When all conditions are met
    if ($found == 2) {
        my $scaled_width  = $width * $WM;
        my $scaled_space  = $space * $SM;
        $W = "$name $scaled_width $W";
        $S = "$name $scaled_space $S";
        $found = 0;
    }
}

close $TECH;

# Print out the TCL-style formatted outputs
print "set WIDTH \{$W\}\;\n";
print "set SPACE \{$S\}\;\n";
