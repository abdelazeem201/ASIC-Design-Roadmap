#!/depot/perl-5.003/bin/perl5.003 -w

# Written by Ahmed Abdelazeem
# March 11, 2024
# Updated to cover more LEF cases
# July 1, 2024
# A Perl script processes a technology file (.tf) and an LEF (Library Exchange Format) file to generate a mapping between layers defined in these files.
#
#

$EXPECTED_COMMAND_ARGS = 2;

if ($#ARGV < $EXPECTED_COMMAND_ARGS -1 )
        {
        die "Usage: lef_layer_tf_number_map.pl Tech_file_name.tf Lef_file_name.lef\n";
        }
        else
                {
                $tech_file = $ARGV[0];
                $lef_file = $ARGV[1];
		$tmp_s1 = $ARGV[0];
		$tmp_s1 =~ s/\.tf/_tf/;
		$tmp_s2 = $ARGV[1];
		$tmp_s2 =~ s/\.lef/_lef/;
                $lef_tf_map_file = $tmp_s2."_".$tmp_s1.".map";
                $lef_tf_log_file = $tmp_s2."_".$tmp_s1.".log";
                }

open tech_file or die "Can't open $tech_file\n";
open lef_file or die "Can't open $lef_file\n";
open lef_tf_log_file, ">$lef_tf_log_file" or die "Can't open $lef_tf_log_file\n";
open lef_tf_map_file, ">$lef_tf_map_file" or die "Can't open $lef_tf_map_file\n";

print_log( "\n*** Beginning to process $tech_file tech file***\n");
$i=0;

%tf_layerMaskNames = ();
%tf_layerMaskLayerNumber = ();
%tf_layerName = ();

$processing_tf_layer = 0;
$found_maskName = 0;
$tf_masks = 0;
while ($line = <tech_file>) 
{
	chop $line;
	if ( $line =~ /^[lL][aA][yY][eE][rR][\s]+\"([\w\W]+)\"[\s]+\{.*$/ )
	{
	if ($processing_tf_layer ==0)
		{
		$processing_tf_layer = 1;
		$tf_layer_name = $1;
		print_log( "\nBeginning to process $tf_layer_name layer...\n");
		}
	}	
	elsif ( $line =~ /^[\s]*\}.*$/) 
		{
		if ($processing_tf_layer ==1) 
			{
			if ($found_maskName == 1)
				{
				$tf_layerMaskNames{$tf_masks} = $tf_maskName;
				$tf_layerMaskLayerNumber{$tf_maskName} = $tf_layerNumber;
				$tf_layerName{$tf_maskName} = $tf_layer_name;

				$tf_masks++;
				$found_maskName =0;
				}
			print_log( "Completed the processing of $tf_layer_name layer.\n");
			$processing_tf_layer = 0;
			}
		}
	elsif ( $line =~ /^[\s]*layerNumber[\s]*\=[\s]*([\d]+).*$/) 
		{
		$tf_layerNumber = $1;
		print_log( "Found the layerNumber $tf_layerNumber for the $tf_layer_name!\n");
		}
	elsif ( $line =~ /^[\s]*maskName[\s]*\=[\s]*\"([\w]+)\".*$/) 
		{
		$tf_maskName = $1;
		$found_maskName = 1;
		print_log( "Found the maskName $tf_maskName for the $tf_layer_name!\n");
		}
$i++;
}

#foreach $key (keys %tf_layerMaskNames)
#	{
#	print "tf_layerName=$tf_layerName{$tf_layerMaskNames{$key}}		";
#	print "tf_mask_layerName=$tf_layerMaskNames{$key}		";
#	print "tf_mask_layerNumber=$tf_layerMaskLayerNumber{$tf_layerMaskNames{$key}}\n";
#	}

print_log( "\n*** Beginning to process $lef_file LEF file***\n");

%lef_layerDerivedMaskNames = ();
%lef_layerDerivedMaskLayerNumber = ();
%lef_layerName = ();

$i=0;
$lef_masks = 0;
$processing_lef_layer = 0;
$lef_prev_layerTYPE = "";
$metal_index = 0;
while ($line = <lef_file>) 
{
	chop $line;
#	print "$line\n";
#	print "$i th line:$line\n";      
	if ( $line =~ /^LAYER[\s]+([\w]+)[\s]*$/ )
	{
	if ($processing_lef_layer ==0)
		{
		$processing_lef_layer = 1;
		$lef_layer_name = $1;
		print_log( "\nBeginning to process $lef_layer_name layer...\n");
		}
	}	
	elsif ( $line =~ /^END[\s]+[\w]+[\s]*$/) 
		{
		if ($processing_lef_layer ==1) 
			{
			$lef_derivedmaskName = "";
			if ( ($lef_layerTYPE eq "MASTERSLICE") && ($lef_masks == 0) )
				{
				$lef_derivedmaskName = "poly";
				}
			elsif ( ($lef_layerTYPE eq "CUT") && ($lef_prev_layerTYPE eq "MASTERSLICE") )
				{
				$lef_derivedmaskName = "polyCont";
				}
			elsif ( ($lef_layerTYPE eq "ROUTING") )
				{
				if ( $metal_index == 0) { $metal_index = 1; }
				else { $metal_index++; }
				$lef_derivedmaskName = "metal".$metal_index;
				}
			elsif ( ($lef_layerTYPE eq "CUT") && ($lef_prev_layerTYPE ne "MASTERSLICE"))
				{
#				print "lef_layerTYPE=$lef_layerTYPE;lef_masks=$lef_masks;lef_prev_layerTYPE=$lef_prev_layerTYPE\n";
				$lef_derivedmaskName = "via".$metal_index;
				}
			elsif ( ($lef_layerTYPE eq "OVERLAP") )
				{
				print_log( "Skipping the OVERLAP Layer...\n");
				}
			else    { 
#				print "lef_layerTYPE=$lef_layerTYPE;lef_masks=$lef_masks;lef_prev_layerTYPE=$lef_prev_layerTYPE\n";
				die "Can not process due to issue...\n";
				}

			if ($lef_derivedmaskName ne "" )
				{
				$lef_derivedlayerNumber = $tf_layerMaskLayerNumber{$lef_derivedmaskName};

				$lef_layerDerivedMaskNames{$lef_masks} = $lef_derivedmaskName;
				$lef_layerDerivedMaskLayerNumber{$lef_derivedmaskName} = $lef_derivedlayerNumber;
				$lef_layerName{$lef_derivedmaskName} = $lef_layer_name;
				$lef_masks++;
				}
			print_log( "Completed the processing of $lef_layer_name layer.\n");
			$processing_lef_layer = 0;
			$lef_prev_layerTYPE = $lef_layerTYPE;
			}
		}
	elsif ( $line =~ /^[\s]*TYPE[\s]+([\w]+)[\s]*\;.*$/) 
		{
		$lef_layerTYPE = $1;
		print_log( "Found the TYPE $lef_layerTYPE for the $lef_layer_name!\n");
		}
$i++;
}

#foreach $key (keys %lef_layerDerivedMaskNames)
#	{
#	print "lef_layerName=$lef_layerName{$lef_layerDerivedMaskNames{$key}}		";
#	print "lef_mask_layerName=$lef_layerDerivedMaskNames{$key}		";
#	print "lef_mask_layerNumber=$lef_layerDerivedMaskLayerNumber{$lef_layerDerivedMaskNames{$key}}\n";
#	}

print_log( "\n*** Printing the map file between $lef_file and $tech_file ***\n");
for ($j=0; $j < $lef_masks; $j++)
	{
	print_map("$lef_layerName{$lef_layerDerivedMaskNames{$j}}");
	print_map(" $lef_layerDerivedMaskLayerNumber{$lef_layerDerivedMaskNames{$j}}\n");
	}

close lef_tf_map_file;

sub print_log {
	print "$_[0]";
	print lef_tf_log_file "$_[0]";
}

sub print_map {
	print "$_[0]";
	print lef_tf_map_file "$_[0]";
}
