LEF Layer to Technology File Layer Mapper
This Perl script processes a technology file (.tf) and a Library Exchange Format (LEF) file to generate a mapping between the layers defined in these files.

# Overview

The script reads through the specified technology and LEF files, extracts layer information, and generates two output files:

A log file documenting the processing steps and any issues encountered.
A mapping file that correlates the layers in the LEF file with their corresponding layers in the technology file.

# Features

Automatic Layer Mapping: The script identifies and maps layers between the LEF and technology files based on predefined rules.
Logging: Detailed logging of the processing steps, aiding in troubleshooting and validation.
Configurable via Command Line Arguments: The input files are specified via command line arguments, allowing flexibility in usage.

# Usage

Command Line

````````````````````````````````````````````````
perl lef_layer_tf_number_map.pl Tech_file_name.tf Lef_file_name.lef
````````````````````````````````````````````````

* Tech_file_name.tf: The technology file containing layer definitions.
* Lef_file_name.lef: The LEF file containing layer definitions.

Output Files

* Lef_file_name_lef_Tech_file_name_tf.map: A file containing the mapping between LEF layers and technology file layers.
* Lef_file_name_lef_Tech_file_name_tf.log: A log file containing detailed logs of the processing steps.

# Script Explanation
## Argument Handling

The script expects two arguments: the technology file and the LEF file. If the correct number of arguments is not provided, it displays a usage message and exits.

## File Opening
The script opens the technology file, LEF file, and two output files: one for logging and one for the mapping.

## Processing the Technology File
The script processes the technology file to extract layer information:

Identifies layers, their numbers, and mask names.
Stores the extracted information in hashes for later use.
Processing the LEF File
The script processes the LEF file to extract layer information and derive mask names based on the layer types:

Uses predefined rules to derive mask names for various layer types.
Maps these derived mask names to the corresponding layer numbers from the technology file.
Generating the Mapping File
The script generates the mapping file by printing the layer names and their corresponding numbers from both the LEF and technology files.

## Logging and Helper Subroutines
The script includes helper subroutines for logging and printing the map file.

## Example
To run the script with example files:
``````````````````````````````````````````````
perl lef_layer_tf_number_map.pl example_tech.tf example_lef.lef
``````````````````````````````````````````````
This will generate example_lef_lef_example_tech_tf.map and example_lef_lef_example_tech_tf.log.

