"""
VHDL Linting Script

This script automates the process of linting VHDL files in a project directory. It supports
debugging mode for linting files individually, output customization for syntastic format,
and allows configurable paths for the search directory, configuration file, and output report.

Usage:
    python script.py [--debug] [--syntastic] [--directory DIR] [--config CONFIG] [--output OUTPUT]

Arguments:
    --debug         Lint files one by one, stopping at the first error encountered.
    --syntastic     Output linting results in syntastic format.
    --directory     Directory to search for VHDL files (default is '../../').
    --config        Path to the VSG configuration file (default is '../config/vsg_config.yml').
    --output        Path to the JUnit-compatible report output (default is '../report/vsg_vhdl.xml').

Note:
    - Files containing "tb" in their names, those within 'test/tb' directories, non-VHDL files,
      and files listed in NOT_LINTED will be excluded from linting.
    - The script changes the current directory to the directory containing the script itself,
      ensuring relative paths work as expected.
"""

import os
import argparse
import sys

# Set the script directory as the working directory
os.chdir(os.path.dirname(os.path.realpath(__file__)))

# Argument parsing
parser = argparse.ArgumentParser(description='Lint all VHDL files in the project')
parser.add_argument('--debug', action='store_true', help='Lint files one by one and stop on any errors')
parser.add_argument('--syntastic', action='store_true', help='Output in syntastic format')
parser.add_argument('--directory', default='../../', help='Directory to search for VHDL files')
parser.add_argument('--config', default='../config/vsg_config.yml', help='Path to the vsg configuration file')
parser.add_argument('--output', default='../report/vsg_vhdl.xml', help='Path for the JUnit-compatible report output')

args = parser.parse_args()

# Define non-lintable files
NOT_LINTED = ["RbExample.vhd"]  # Documentation example, incomplete VHDL

def find_vhd_files(directory):
    """Recursively find VHDL files in the specified directory, excluding testbenches and specific directories."""
    vhd_files = []
    for root, _, files in os.walk(directory):
        for file in files:
            # Skip testbench files or non-VHDL files, and files in NOT_LINTED
            if "tb" in file or root.endswith('test/tb') or not file.endswith('.vhdl') or file in NOT_LINTED:
                continue
            # Append the absolute path of the file
            vhd_files.append(os.path.abspath(os.path.join(root, file)))
    return vhd_files

# Configure output format
output_format = "-of syntastic" if args.syntastic else "-of vsg"

# Get the list of .vhdl files
vhd_files_list = find_vhd_files(args.directory)

# Check if any VHDL files were found
if not vhd_files_list:
    print("No VHDL files found to lint.")
    sys.exit(0)

print(f"Linting {len(vhd_files_list)} VHDL files: {vhd_files_list}")

error_occurred = False

# Linting process
try:
    if args.debug:
        for file in vhd_files_list:
            print(f"Linting {file}")
            result = os.system(f'vsg -c {args.config} -f {file} {output_format}')
            if result != 0:
                raise RuntimeError(f"Error: Linting of {file} failed - check report")
    else:
        all_files = " ".join(vhd_files_list)
        result = os.system(f'vsg -c {args.config} -f {all_files} --junit {args.output} --all_phases {output_format}')
        if result != 0:
            error_occurred = True
except Exception as e:
    print(e)
    sys.exit(1)

# Check for errors
if error_occurred:
    print("Error: Linting of VHDL files failed - check report.")
    sys.exit(1)
else:
    print("All VHDL files linted successfully.")
