#!/bin/bash
#
# Uses yasha to embed variable values into a jinja2 template.
# The rendered file is printed to the standard output.
#
# Example usage:
#
#     render-jinja-template.sh vars.yml template.txt.j2 output.txt

vars_file="$1"
template_file="$2"
output_file="$3"

pass_count=5

mkdir --parents "$(dirname "$output_file")"

yasha --no-extension-file --variables "$vars_file" --output "$output_file" "$template_file"
for pass in $(seq 1 $pass_count); do
    # Rerun the rendering using the output from the previous step as a template.
    # This resolves nested variables.
    yasha --no-extension-file --variables "$vars_file" --output "$output_file" "$output_file"
done

# Copy file permissions from the source file
chown --reference="$template_file" "$output_file"
chmod --reference="$template_file" "$output_file"
