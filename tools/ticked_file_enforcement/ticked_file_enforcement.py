import fnmatch
import functools
import glob
import sys
import json

FORBID_INCLUDE = []

schema = json.load(sys.stdin)
file_reference = schema["file"]
raw_forbid_include = schema["forbidden_includes"]

if raw_forbid_include is not None:
    for forbidable_category in raw_forbid_include:
        FORBID_INCLUDE.append(repr(forbidable_category))

reading = False
lines = []
total = 0

with open(file_reference, 'r') as file:
    for line in file:
        total += 1
        line = line.strip()

        if line == "// BEGIN_INCLUDE":
            reading = True
            continue
        elif line == "// END_INCLUDE":
            break
        elif not reading:
            continue

        lines.append(line)

if lines == []:
    print("No lines were read from the file")
    sys.exit(1)

offset = total - len(lines)
print(f"{offset} lines were ignored in output")
fail_no_include = False

for code_file in glob.glob("code/**/*.dm", recursive=True):
    dm_path = code_file.replace('/', '\\')

    included = f"#include \"{dm_path}\"" in lines
    forbid_include = False

    for forbid in FORBID_INCLUDE:
        if not fnmatch.fnmatch(code_file, forbid):
            continue

        forbid_include = True

        if included:
            print(f"{dm_path} should not be included")
            print(f"::error file={code_file},line=1,title=Ticked File Enforcement::File should not be included")
            fail_no_include = True

    if forbid_include:
        continue

    if not included:
        print(f"{dm_path} is not included")
        print(f"::error file={code_file},line=1,title=Ticked File Enforcement::File is not included")
        fail_no_include = True

if fail_no_include:
    sys.exit(1)

def compare_lines(a, b):
    # Remove initial include as well as the final quotation mark
    a = a[len("#include \""):-1].lower()
    b = b[len("#include \""):-1].lower()

    a_segments = a.split('\\')
    b_segments = b.split('\\')

    for (a_segment, b_segment) in zip(a_segments, b_segments):
        a_is_file = a_segment.endswith(".dm")
        b_is_file = b_segment.endswith(".dm")

        # code\something.dm will ALWAYS come before code\directory\something.dm
        if a_is_file and not b_is_file:
            return -1

        if b_is_file and not a_is_file:
            return 1

        # interface\something.dm will ALWAYS come after code\something.dm
        if a_segment != b_segment:
            return (a_segment > b_segment) - (a_segment < b_segment)

    print(f"Two lines were exactly the same ({a} vs. {b})")
    sys.exit(1)

sorted_lines = sorted(lines, key = functools.cmp_to_key(compare_lines))
for (index, line) in enumerate(lines):
    if sorted_lines[index] != line:
        print(f"The include at line {index + offset} is out of order ({line}, expected {sorted_lines[index]})")
        print(f"::error file={file_reference},line={index+offset},title=Ticked File Enforcement::The include at line {index + offset} is out of order ({line}, expected {sorted_lines[index]})")
        sys.exit(1)
