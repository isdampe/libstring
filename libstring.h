#ifndef LIBSTRING_H
#define LIBSTRING_H
#include <stdlib.h>
#include <string.h>

#define LIBSTRING_MAX_OVER_ALLOCATE 512

struct string_t {
	char *bytes;
	size_t length;
	size_t alloc_length;
};

typedef struct string_t string;

struct string_t string_init_empty(void)
{
	struct string_t str;
	str.length = 0;
	str.alloc_length = LIBSTRING_MAX_OVER_ALLOCATE + 1;
	str.bytes = malloc(str.alloc_length);
	str.bytes[0] = '\0';

	return str;
}

struct string_t string_init_str(const char *src)
{
	struct string_t str;

	str.length = strlen(src);
	str.alloc_length = (2 * str.length) % ((2 * str.length) + LIBSTRING_MAX_OVER_ALLOCATE) + 1;
	str.bytes = malloc(str.alloc_length * sizeof(char));
	str.bytes[str.length + 1] = '\0';
	strcpy(str.bytes, src);

	return str;
}

struct string_t string_init_file(FILE *fh)
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

struct string_t string_clone(struct string_t *src)
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

#define string(...) _Generic((__VA_ARGS__+0), \
	char*: string_init_str, \
	FILE*: string_init_file, \
	struct string_t*: string_clone, \
	default: string_init_empty)(__VA_ARGS__)

static void string_auto_expand(struct string_t *str)
{
	if (str->length < str->alloc_length)
		return;

	str->alloc_length = (2 * str->length) % ((2 * str->length) + LIBSTRING_MAX_OVER_ALLOCATE) + 1;
	str->bytes = realloc(str->bytes, str->alloc_length * sizeof(char));
}

void string_append_str(struct string_t *str, const char *src)
{
	size_t src_length = strlen(src);
	str->length += src_length;
	string_auto_expand(str);
	strncat(str->bytes, src, src_length);
	str->bytes[str->length] = '\0';
}

void string_append_file(struct string_t *str, FILE *fh)
{
	fseek(fh, 0L, SEEK_END);
	size_t src_length = ftell(fh);
	fseek(fh, 0L, SEEK_SET);

	str->length += src_length;
	string_auto_expand(str);
	fread(str->bytes, 1, src_length, fh);
	str->bytes[str->length] = '\0';
}

void string_append_char(struct string_t *str, char c)
{
	str->length++;
	string_auto_expand(str);
	str->bytes[str->length -1] = c;
	str->bytes[str->length] = '\0';
}

void string_append_int(struct string_t *str, long long n)
{
	size_t length = snprintf(NULL, 0, "%lld", n);
	char *buffer = malloc(length + 1 * sizeof(char));
	snprintf(buffer, length + 1, "%lld", n);

	string_append_str(str, buffer);
	free(buffer);
}

void string_append_uint(struct string_t *str, unsigned long long n)
{
	size_t length = snprintf(NULL, 0, "%llu", n);
	char *buffer = malloc(length + 1 * sizeof(char));
	snprintf(buffer, length + 1, "%llu", n);

	string_append_str(str, buffer);
	free(buffer);
}

void string_append_double(struct string_t *str, double n)
{
	size_t length = snprintf(NULL, 0, "%f", n);
	char *buffer = malloc(length + 1 * sizeof(char));
	snprintf(buffer, length + 1, "%f", n);

	string_append_str(str, buffer);
	free(buffer);
}

#define string_append(str, x) _Generic((str, x), \
	char*: string_append_str, \
	char: string_append_char, \
	FILE*: string_append_file, \
	long long: string_append_int, \
	long: string_append_int, \
	int: string_append_int, \
	unsigned long long: string_append_uint, \
	unsigned long: string_append_uint, \
	unsigned int: string_append_uint, \
	double: string_append_double, \
	float: string_append_double, \
	default: string_append_str)(str, x)

void string_free(struct string_t *str)
{
	free(str->bytes);
}

#endif