#!/usr/bin/env python3

import io
import argparse
import yaml


def parse_args():
    yaml_context_help_string = (
        "YAML files to be merged. "
        "If multiple files contain the same variable, the last one takes precedence."
    )

    parser = argparse.ArgumentParser(description = 'Merged YAML file')
    parser.add_argument(                  dest = 'yaml_paths',  metavar = 'YAML_FILE', action = 'store', nargs = '+',     type = str,  help = yaml_context_help_string)
    parser.add_argument('-o', '--output', dest = 'output_file', metavar = 'FILE',      action = 'store', required = True, type = str, help = "Output file. Use '-' to print to standard output.")

    return parser.parse_args()


def read_yaml(yaml_path):
    with io.open(yaml_path, 'r', encoding = 'utf-8') as yaml_file:
        yaml_content = yaml.load(yaml_file.read())

    if yaml_content is None:
        # If the file is empty, parser returns None
        return {}

    return yaml_content


def load_and_combine_yaml(yaml_paths):
    combined_dict = {}
    for path in yaml_paths:
        combined_dict.update(read_yaml(path))

    return combined_dict


def save_file(output_file_name, content):
    with io.open(output_file_name, 'w', encoding = 'utf-8') as file:
        file.write(content)


def main():
    args = parse_args()

    combined_yaml_dict = load_and_combine_yaml(args.yaml_paths)
    yaml_content       = yaml.dump(combined_yaml_dict, default_flow_style = False)
    save_file(args.output_file, yaml_content)


if __name__ == "__main__":
    main()
