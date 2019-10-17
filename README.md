# libstring for >= C11
A simple, generics based string library for use with >= C11.

## Methods

### Constructors
```c
// From bytes
struct string_t name = string("Hello world");
printf("%s", name->bytes);
string_free(&name);

// From void
struct string_t v = string();
string_free(&v);

// From a file
FILE *fh = fopen("/tmp/somefile.txt", "r");
if (fh) {
	struct string_t somefile = string(fh);
	printf("%s\n", somefile->bytes);
	string_free(&somefile);
	fclose(fh);
}
```

### Append / concat
```c
// From bytes
string_append(&name, " and this will be appended");

// From char
string_append(&name, (char)'.');

// From file
string_append(&name, fh);
```