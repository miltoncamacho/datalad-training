"""Aggregate statistics."""
from pathlib import Path
import csv
import argparse
import statistics as st


def read_case(file: Path) -> list[list]:
    """Read case data."""
    with open(file, "r", encoding="utf-8") as csvfile:
        reader = csv.reader(csvfile, delimiter=',')
        next(reader)
        return list(reader)


def read_all_cases(files: list[Path]) -> list[list[list]]:
    """Read data for all cases."""
    return [read_case(file) for file in files]


def aggregate_case_data(stats: list[list]) -> list[float]:
    """Aggregate case data."""
    aggregate = []
    for column_index in range(len(stats[0])):
        column_values = [float(row[column_index]) for row in stats]
        aggregate += [st.mean(column_values)]
    return aggregate


def aggregate_all_cases(cases: list[list[list]]) -> list[list[float]]:
    """Aggregate data from all cases"""
    return [aggregate_case_data(case) for case in cases]


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


def write_file(
    header: list[str],
    content: list,
    output_file: Path,
) -> None:
    """Write to a file."""
    with open(output_file, 'w', encoding='utf-8') as csvfile:
        writer = csv.writer(
            csvfile,
            delimiter=',',
        )
        writer.writerow(header)
        for row in content:
            writer.writerow(row)


def main():
    """Main processing."""
    args = parse_args()
    all_data = read_all_cases(args.input_files)
    aggregated_data = aggregate_all_cases(all_data)
    header = ["Mean", "Median", "Mode", "Stdev"]
    write_file(
        header=header,
        content=aggregated_data,
        output_file=args.output_file,
    )


if __name__ == "__main__":
    main()
