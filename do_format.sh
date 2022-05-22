#!/bin/zsh

find . \( -name "*.c" -o -name "*.h" -o -name "*.cpp" -o -name "*.hpp" \) -exec /Volumes/silo/Projects/open-source/llvm-project/build/bin/clang-format -i {} \;
