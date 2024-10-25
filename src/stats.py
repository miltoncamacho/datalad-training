"""Calculate statistics."""
import os
from pathlib import Path
import csv
import argparse
import statistics as st
from typing import Callable

RawData = list[list[int]]


def find_files_in_directory(directory: Path) -> list[Path]:
    """Return files in directory."""
    all_directory_contents = os.listdir(directory)
    file_list = [
        Path(item) for item in all_directory_contents
        if Path.is_file(directory / item)
    ]
    return sorted(file_list)


def read_csv(file: Path) -> list[int]:
    """Read a csv file.

    The file must be a single column and only contain integers."""
    with open(file, 'r', newline='', encoding='utf-8') as csvfile:
        return [int(row[0]) for row in csv.reader(csvfile)]


def create_array(files: list[Path]) -> RawData:
    return [read_csv(file) for file in files]


def calculate_quantity(data: RawData, call_function: Callable) -> list:
    return [call_function(array) for array in data]


def calculate_mean(data: RawData) -> list[float]:
    return calculate_quantity(data, st.mean)


def calculate_median(data: RawData) -> list[float]:
    return calculate_quantity(data, st.median)


def calculate_mode(data: RawData) -> list[int]:
    return calculate_quantity(data, st.mode)


def calculate_stdev(data: RawData) -> list[float]:
    return calculate_quantity(data, st.stdev)


def create_file_content(data: RawData) -> list[list]:
    """Create the body of the statistics file."""
    means = calculate_mean(data)
    medians = calculate_median(data)
    modes = calculate_mode(data)
    stdevs = calculate_stdev(data)
    content = []
    for mean, median, mode, stdev in zip(means, medians, modes, stdevs):
        content += [[mean, median, mode, stdev]]
    return content


def write_stats_file(
    header: list[str],
    content: list,
    output_file: Path,
) -> None:
    """Write to the statistics file."""
    with open(output_file, 'w', encoding='utf-8') as csvfile:
        writer = csv.writer(
            csvfile,
            delimiter=',',
        )
        writer.writerow(header)
        for row in content:
            writer.writerow(row)


def parse_args() -> argparse.Namespace:
    """Command line argument parsing."""
    parser = argparse.ArgumentParser(
        description='Calculate statistics of files'
    )
    required = parser.add_argument_group('required arguments')
    required.add_argument(
        "-i", "--input-files",
        nargs='+',
        type=Path,
        help="Input files",
        required=True,
    )
    required.add_argument(
        "-o", "--output-file",
        type=Path,
        help="Output file",
        required=True,
    )
    return parser.parse_args()


def main():
    """Main processing."""
    args = parse_args()
    data = create_array(args.input_files)
    header = ["Mean", "Median", "Mode", "Stdev"]
    file_contents = create_file_content(data)
    write_stats_file(
        header=header,
        content=file_contents,
        output_file=args.output_file,
    )


if __name__ == "__main__":
    main()
