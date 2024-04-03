#!/bin/bash
# this script is used to test Aseprite-Zig

# run a test for a single .zig file
run_test() {
    local zigfile="$1"

    # skip if it's import.zig
    if [ "$(basename "$zigfile")" = "import.zig" ]; then
        return
    fi

    # copy import.zig & src/ from cwd to where the test file is located
    cp import.zig "$(dirname "$zigfile")"
    cp -r src "$(dirname "$zigfile")"

    # run zig test
    zig test "$zigfile"

    # change directory to where the test file is located
    cd "$(dirname "$zigfile")" || exit

    # this check is added as to prevent deleting core files if our cwd is
    # not where it should be
    if [ -f README.md ] || [ -f build.zig ]; then
        echo "Something has gone wrong..."
        exit 1
    else
        # delete import.zig & src/ after test is done
        rm -f import.zig
        rm -rf src/
    fi

    # go back to the original directory
    cd - >/dev/null || exit
}

# recursively search for .zig files then run the test
search_and_run_tests() {
    local directory="$1"

    # find all .zig files recursively
    while IFS= read -r -d '' zigfile; do
        # run test for each .zig file found
        run_test "$zigfile"
    done < <(find "$directory" -type f -name "*.zig" -print0)
}

# check if directory is provided as an argument
if [ $# -eq 0 ]; then
    echo "Usage: $0 TEST FILE DIRECTORY"
    exit 1
fi

# check if the provided directory exists
if [ ! -d "$1" ]; then
    echo "Error: Directory '$1' not found"
    exit 1
fi

search_and_run_tests "$1"
