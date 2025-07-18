#!/usr/bin/perl

#----------------------------------------------------------------------------
# Script Name: NDR_rule.pl
#
# Description:
# This script is designed to help define **Nondefault Routing Rules (NDRs)** 
# automatically in Synopsys **IC Compiler II (ICC2)**.
#
# In ICC2, nondefault routing rules define special constraints such as increased 
# width and spacing for clock nets or other critical nets. Normally, these rules 
# are defined manually for each metal layer, which can be tedious and error-prone.
#
# This script reads a Synopsys technology file (.tf), extracts the default 
# `defaultWidth` and `minSpacing` for each metal layer (M1, M2, ..., M9), and applies 
# user-specified multipliers to generate NDR-compliant values.
#
# It outputs two Tcl variables: WIDTH and SPACE, which can then be used inside ICC2
# to define routing rules automatically.
#
#----------------------------------------------------------------------------
# Example ICC2 Usage:
#
# icc2_shell> set NDR [sh ./NDR_rule.pl TECH_FILE 2 2]
# icc2_shell> eval $NDR
# icc2_shell> create_routing_rule 2Wx2S -default -widths $WIDTH -spacings $SPACE
#
#----------------------------------------------------------------------------
# Example Command Line Usage:
#
#   perl NDR_rule.pl technology_file spacing_multiplier width_multiplier
#
#   e.g. perl NDR_rule.pl saed32nm.tf 2 2
#
#----------------------------------------------------------------------------
# Output:
#
#   set WIDTH {M9 0.84 M8 0.84 ... M1 0.24};
#   set SPACE {M9 0.84 M8 0.84 ... M1 0.24};
#
# You can then use these Tcl variables directly in ICC2 to define a routing rule:
#
#   create_routing_rule 2Wx2S -default -widths $WIDTH -spacings $SPACE
#
#----------------------------------------------------------------------------

use strict;
use warnings;

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
print "set WIDTH \{$W\};\n";
print "set SPACE \{$S\};\n";
