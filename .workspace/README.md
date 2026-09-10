# Useful GCC and G++ Commands

These commands are useful when checking C and C++ code for warnings, syntax
errors, formatting issues, generated output, and runtime problems.

Replace `main.c`, `main.cpp`, and `app` with the names used by your project.

## Basic compilation

```bash
# Compile C source to an object file
gcc -c main.c -o main.o

# Compile C++ source to an object file
g++ -c main.cpp -o main.o

# Compile and link a C program
gcc main.c -o app

# Compile and link a C++ program
g++ main.cpp -o app

# Compile several source files
gcc main.c io.c -o app
g++ main.cpp io.cpp -o app
```

## Check syntax without linking

Use `-fsyntax-only` when you want to validate source code without creating an
object file or executable.

```bash
gcc -std=c11 -fsyntax-only main.c
g++ -std=c++17 -fsyntax-only main.cpp

# Check a header as C
gcc -std=c11 -fsyntax-only -x c include/my_header.h

# Check a header as C++
g++ -std=c++17 -fsyntax-only -x c++ include/my_header.h
```

## Enable useful warnings

```bash
# Strong general-purpose warnings
gcc -std=c11 -Wall -Wextra -Wpedantic -Wconversion -Wshadow \
    -fsyntax-only main.c

g++ -std=c++17 -Wall -Wextra -Wpedantic -Wconversion -Wshadow \
    -fsyntax-only main.cpp

# Treat warnings as errors
gcc -std=c11 -Wall -Wextra -Werror -fsyntax-only main.c
g++ -std=c++17 -Wall -Wextra -Werror -fsyntax-only main.cpp

# Show warnings for a particular category
gcc -Wformat=2 -Wnull-dereference -Wdouble-promotion \
    -fsyntax-only main.c
```

Useful warning options include:

- `-Wall` and `-Wextra`: common and additional warnings.
- `-Wpedantic`: warnings for non-standard language extensions.
- `-Werror`: treat warnings as errors.
- `-Wconversion`: identify potentially lossy implicit conversions.
- `-Wshadow`: warn when declarations hide another declaration.
- `-Wformat=2`: stricter `printf`/`scanf` format checking.
- `-Wnull-dereference`: warn about possible null pointer dereferences.
- `-Wundef`: warn when an undefined macro is used in `#if`.
- `-Wwrite-strings`: warn about assigning string literals to non-const data.

## Debug builds

```bash
# Include debug symbols and disable optimization
gcc -std=c11 -Wall -Wextra -g -O0 main.c -o app
g++ -std=c++17 -Wall -Wextra -g -O0 main.cpp -o app

# Debug symbols with moderate optimization
gcc -g -O1 main.c -o app
g++ -g -O1 main.cpp -o app
```

Run a program in GDB:

```bash
gdb ./app

# Useful commands inside GDB:
# break main
# run
# next
# step
# print variable_name
# backtrace
# continue
# quit
```

## Sanitizers

Sanitizers detect many runtime memory, undefined-behavior, and threading
problems. Use them with debug symbols and low optimization.

```bash
# AddressSanitizer and UndefinedBehaviorSanitizer
gcc -g -O1 -fsanitize=address,undefined \
    -fno-omit-frame-pointer main.c -o app

g++ -g -O1 -fsanitize=address,undefined \
    -fno-omit-frame-pointer main.cpp -o app

./app

# ThreadSanitizer for data races
g++ -g -O1 -fsanitize=thread \
    -fno-omit-frame-pointer main.cpp -o app
```

## Preprocessor output

Use these commands to inspect includes, macros, and conditional compilation.

```bash
# Write preprocessed output to a file
gcc -E main.c -o main.i
g++ -E main.cpp -o main.ii

# Keep comments in the preprocessed output
gcc -E -C main.c -o main.i

# List defined macros
gcc -E -dM main.c

# Inspect include nesting
gcc -H -fsyntax-only main.c
```

## Assembly and compiler output

```bash
# Generate assembly
gcc -S -O2 main.c -o main.s
g++ -S -O2 main.cpp -o main.s

# Generate readable assembly with source interleaved
gcc -S -O2 -fverbose-asm main.c -o main.s

# Show compilation commands and keep temporary files
gcc -v -save-temps main.c -o app
```

## Include paths, macros, libraries, and standards

```bash
# Add a project include directory
gcc -Iinclude -fsyntax-only src/main.c
g++ -Iinclude -fsyntax-only src/main.cpp

# Define a preprocessor macro
gcc -DDEBUG=1 -fsyntax-only main.c
g++ -DDEBUG=1 -fsyntax-only main.cpp

# Link with a library
gcc main.c -lm -o app
g++ main.cpp -pthread -o app

# Select a language standard
gcc -std=c11 main.c -o app
g++ -std=c++17 main.cpp -o app
g++ -std=c++20 main.cpp -o app
```

Put libraries after the source or object files on the command line:

```bash
gcc main.o math_helpers.o -lm -o app
```

## Separate compile and link steps

```bash
gcc -std=c11 -Wall -Wextra -g -c main.c -o main.o
gcc -std=c11 -Wall -Wextra -g -c io.c -o io.o
gcc main.o io.o -o app
```

For C++:

```bash
g++ -std=c++17 -Wall -Wextra -g -c main.cpp -o main.o
g++ -std=c++17 -Wall -Wextra -g -c io.cpp -o io.o
g++ main.o io.o -o app
```

## Inspect symbols and dependencies

```bash
# List symbols in an object file or executable
nm -C app

# Show dynamic libraries required by an executable
ldd ./app

# Inspect ELF headers and sections
readelf -h -S ./app

# Disassemble an executable
objdump -dC ./app
```

## Recommended strict checks

For a C project:

```bash
gcc -std=c11 -Wall -Wextra -Wpedantic -Werror \
    -fstack-protector-strong -fsyntax-only src/*.c
```

For a C++ project:

```bash
g++ -std=c++17 -Wall -Wextra -Wpedantic -Werror \
    -fstack-protector-strong -fsyntax-only src/*.cpp
```

For a single header:

```bash
gcc -std=c11 -Wall -Wextra -Werror -fsyntax-only -x c include/header.h
g++ -std=c++17 -Wall -Wextra -Werror -fsyntax-only -x c++ include/header.h
```
