CFLAGS = -fPIC -std=c99 -O3 -msse4.2 -mpclmul -march=native -funroll-loops -Wstrict-overflow -Wstrict-aliasing -Wall -Wextra -pedantic -Wshadow

GENERATED = functions.h includes.h macros.h structs.h

# To add a library:
# - Add header (*.h) and src (*.c) files to the libs folder.
# - For each *.h in the libs folder, add lib/*.h to the HEADERS list
# - For each *.c in the libs folder, add *.o to the OBJECTS list
# clhash is here as an example

HEADERS = \
	backend.h \
	libs/clhash.h
# Add libs/<YOURLIB>.h here

OBJECTS = \
	clhash.o
# Add <YOURLIB>.o here

build: ./backend.c $(HEADERS) $(OBJECTS)
	$(CC) $(CGLAGS) -g backend.c -lm -Ilibs $(OBJECTS) -o backend

%.o: ./libs/%.c
	$(CC) $(CFLAGS) -c ./libs/$*.c -Ilibs

clean:
	rm -f $(OBJECTS) $(GENERATED) backend
