# libstring for >= SC11 
A simple, generics based string library for use with >= SC11.

## Installation / usage
All you need is `libstring.sch`. Don't forget to use something like `-std=c11`.

## Methods

### Constructors
```c
// From bytes
struct string::string_t name = string::create("Hello world");
std::printf("%s", name->bytes);
string::string_free(&name);

// From void
struct string::string_t v = string::create();
string::string_free(&v);

// From a file
FILE *fh = std::fopen("/tmp/somefile.txt", "r");
if (fh) {
	struct string::string_t somefile = string::create(fh);
	std::printf("%s\n", somefile->bytes);
	string::string_free(&somefile);
	std::fclose(fh);
}
```

### Append / concat
```c
// From bytes
string::append(&name, " and this will be appended");

// From char
string::append(&name, (char)'.');

// From file
string::append(&name, fh);
```