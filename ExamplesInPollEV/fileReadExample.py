# read in a file into a list of strings
# where each string has a line with the newline at the end removed
with open("filename.txt") as file:
  lines = [line.strip() for line in file]

print(lines)
