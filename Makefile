

capture.so: capture.c
	$(CC) -shared -o $@ $^ -liio -lm -Wall -Wextra -fPIC -std=gnu99 -pedantic -O3

clean:
	rm -f capture.so
