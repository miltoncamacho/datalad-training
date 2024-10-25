import argparse

def multiply_numbers(input_file, output_file):
    with open(input_file, 'r') as file:
        lines = file.readlines()

    with open(output_file, 'w') as file:
        for line in lines:
            numbers = map(int, line.split())
            multiplied_numbers = [str(num * 2) for num in numbers]
            file.write(' '.join(multiplied_numbers) + '\n')

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Multiply numbers in a file by 2.")
    parser.add_argument('input_file', type=str, help="Path to the input file.")
    parser.add_argument('output_file', type=str, help="Path to the output file.")
    args = parser.parse_args()

    multiply_numbers(args.input_file, args.output_file)
