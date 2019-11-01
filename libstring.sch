#ifndef LIBSTRING_H
#define LIBSTRING_H
#include <stdlib.h>
#include <string.h>

#define LIBSTRING_MAX_OVER_ALLOCATE 512

namespace string;

struct string_t {
	char *bytes;
	std::size_t length;
	std::size_t alloc_length;
};

typedef struct string_t string;

struct string_t init_empty(void)
{
	struct string_t str;
	str.length = 0;
	str.alloc_length = LIBSTRING_MAX_OVER_ALLOCATE + 1;
	str.bytes = malloc(str.alloc_length);
	str.bytes[0] = '\0';

	return str;
}

struct string_t init_str(const char *src)
{
	struct string_t str;

	str.length = strlen(src);
	str.alloc_length = (2 * str.length) % ((2 * str.length) + LIBSTRING_MAX_OVER_ALLOCATE) + 1;
	str.bytes = malloc(str.alloc_length * sizeof(char));
	str.bytes[str.length + 1] = '\0';
	strcpy(str.bytes, src);

	return str;
}

struct string_t init_file(FILE *fh)
{
	struct string_t str;

	fseek(fh, 0L, SEEK_END);
	str.length = ftell(fh);
	fseek(fh, 0L, SEEK_SET);

	str.alloc_length = (2 * str.length) % ((2 * str.length) + LIBSTRING_MAX_OVER_ALLOCATE) + 1;
	str.bytes = malloc(str.alloc_length * sizeof(char));
	str.bytes[str.length + 1] = '\0';
	fread(str.bytes, 1, str.length, fh);

	return str;
}

struct string_t clone(struct string_t *src)
{
	struct string_t str = {
		.length = src->length,
		.alloc_length = src->alloc_length
	};

	str.bytes = malloc(str.alloc_length * sizeof(char));
	str.bytes[str.length + 1] = '\0';
	strncpy(str.bytes, src->bytes, src->alloc_length);

	return str;
}

#define create(...) _Generic((__VA_ARGS__+0), \
	char*: init_str, \
	FILE*: init_file, \
	struct string_t*: clone, \
	default: init_empty)(__VA_ARGS__)

static void auto_expand(struct string_t *str)
{
	if (str->length < str->alloc_length)
		return;

	str->alloc_length = (2 * str->length) % ((2 * str->length) + LIBSTRING_MAX_OVER_ALLOCATE) + 1;
	str->bytes = realloc(str->bytes, str->alloc_length * sizeof(char));
}

void append_str(struct string_t *str, const char *src)
{
	size_t src_length = strlen(src);
	str->length += src_length;
	auto_expand(str);
	strncat(str->bytes, src, src_length);
	str->bytes[str->length] = '\0';
}

void append_file(struct string_t *str, FILE *fh)
{
	fseek(fh, 0L, SEEK_END);
	size_t src_length = ftell(fh);
	fseek(fh, 0L, SEEK_SET);

	str->length += src_length;
	auto_expand(str);
	fread(str->bytes, 1, src_length, fh);
	str->bytes[str->length] = '\0';
}

void append_char(struct string_t *str, char c)
{
	str->length++;
	auto_expand(str);
	str->bytes[str->length -1] = c;
	str->bytes[str->length] = '\0';
}

void append_int(struct string_t *str, long long n)
{
	size_t length = snprintf(NULL, 0, "%lld", n);
	char *buffer = malloc(length + 1 * sizeof(char));
	snprintf(buffer, length + 1, "%lld", n);

	append_str(str, buffer);
	free(buffer);
}

void append_uint(struct string_t *str, unsigned long long n)
{
	size_t length = snprintf(NULL, 0, "%llu", n);
	char *buffer = malloc(length + 1 * sizeof(char));
	snprintf(buffer, length + 1, "%llu", n);

	append_str(str, buffer);
	free(buffer);
}

void append_double(struct string_t *str, double n)
{
	size_t length = snprintf(NULL, 0, "%f", n);
	char *buffer = malloc(length + 1 * sizeof(char));
	snprintf(buffer, length + 1, "%f", n);

	append_str(str, buffer);
	free(buffer);
}

#define append(str, x) _Generic((str, x), \
	char*: append_str, \
	char: append_char, \
	FILE*: append_file, \
	long long: append_int, \
	long: append_int, \
	int: append_int, \
	unsigned long long: append_uint, \
	unsigned long: append_uint, \
	unsigned int: append_uint, \
	double: append_double, \
	float: append_double, \
	default: append_str)(str, x)

void string_free(struct string_t *str)
{
	free(str->bytes);
}

#endif