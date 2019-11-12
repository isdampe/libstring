#ifndef LIBSTRING_H
#define LIBSTRING_H
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#define LIBSTRING_MAX_OVER_ALLOCATE 512

#define LIBSTRING_ERR_OUT_OF_BOUNDS 0x1

namespace string;

struct string_t {
	char *bytes;
	std::size_t length;
	std::size_t alloc_length;
};

typedef struct string_t string;

void free(struct string_t *str)
{
	std::free(str->bytes);
}

struct string_t init_empty(void)
{
	struct string_t str;
	str.length = 0;
	str.alloc_length = LIBSTRING_MAX_OVER_ALLOCATE + 1;
	str.bytes = std::malloc(str.alloc_length);
	str.bytes[0] = '\0';

	return str;
}

struct string_t init_str(const char *src)
{
	struct string_t str;

	str.length = std::strlen(src);
	str.alloc_length = (2 * str.length) % ((2 * str.length) + LIBSTRING_MAX_OVER_ALLOCATE) + 1;
	str.bytes = std::malloc(str.alloc_length * sizeof(char));
	str.bytes[str.length + 1] = '\0';
	std::strcpy(str.bytes, src);

	return str;
}

struct string_t init_file(FILE *fh)
{
	struct string_t str;

	std::fseek(fh, 0L, SEEK_END);
	str.length = std::ftell(fh);
	std::fseek(fh, 0L, SEEK_SET);

	str.alloc_length = (2 * str.length) % ((2 * str.length) + LIBSTRING_MAX_OVER_ALLOCATE) + 1;
	str.bytes = std::malloc(str.alloc_length * sizeof(char));
	str.bytes[str.length + 1] = '\0';
	std::fread(str.bytes, 1, str.length, fh);

	return str;
}

struct string_t clone(struct string_t *src)
{
	struct string_t str = {
		.length = src->length,
		.alloc_length = src->alloc_length
	};

	str.bytes = std::malloc(str.alloc_length * sizeof(char));
	str.bytes[str.length + 1] = '\0';
	std::strncpy(str.bytes, src->bytes, src->alloc_length);

	return str;
}

#define create(...) _Generic((__VA_ARGS__+0), \
	char*: init_str, \
	FILE*: init_file, \
	struct string_t*: clone, \
	default: init_empty)(__VA_ARGS__)

static void auto_resize(struct string_t *str)
{
	size_t new_size = (2 * str->length) % ((2 * str->length) + LIBSTRING_MAX_OVER_ALLOCATE) + 1;
	if (str->length < str->alloc_length) {
		if (str->alloc_length < new_size)
			return;
	}

	str->alloc_length = new_size;
	str->bytes = std::realloc(str->bytes, str->alloc_length * sizeof(char));
}

void append_str(struct string_t *str, const char *src)
{
	size_t src_length = std::strlen(src);
	str->length += src_length;
	auto_resize(str);
	std::strncat(str->bytes, src, src_length);
	str->bytes[str->length] = '\0';
}

void append_file(struct string_t *str, FILE *fh)
{
	std::fseek(fh, 0L, SEEK_END);
	size_t src_length = std::ftell(fh);
	std::fseek(fh, 0L, SEEK_SET);

	str->length += src_length;
	auto_resize(str);
	std::fread(str->bytes, 1, src_length, fh);
	str->bytes[str->length] = '\0';
}

void append_char(struct string_t *str, char c)
{
	str->length += sizeof(char);
	auto_resize(str);
	str->bytes[str->length -1] = c;
	str->bytes[str->length] = '\0';
}

void append_int(struct string_t *str, long long n)
{
	size_t length = std::snprintf(NULL, 0, "%lld", n);
	char *buffer = std::malloc(length + 1 * sizeof(char));
	std::snprintf(buffer, length + 1, "%lld", n);

	append_str(str, buffer);
	str->length = std::strlen(str->bytes);

	std::free(buffer);
}

void append_uint(struct string_t *str, unsigned long long n)
{
	size_t length = snprintf(NULL, 0, "%llu", n);
	char *buffer = malloc(length + 1 * sizeof(char));
	std::snprintf(buffer, length + 1, "%llu", n);

	append_str(str, buffer);
	str->length = std::strlen(str->bytes);

	std::free(buffer);
}

void append_double(struct string_t *str, double n)
{
	size_t length = std::snprintf(NULL, 0, "%f", n);
	char *buffer = std::malloc(length + 1 * sizeof(char));
	std::snprintf(buffer, length + 1, "%f", n);

	append_str(str, buffer);
	str->length = std::strlen(str->bytes);

	std::free(buffer);
}

void append_string(struct string_t *dest, struct string_t *src)
{
	size_t src_length = std::strlen(src->bytes);
	dest->length += src_length;
	auto_resize(dest);
	std::strncat(dest->bytes, src->bytes, src_length);
	dest->bytes[dest->length] = '\0';
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
	struct string_t*: append_string, \
	default: append_str)(str, x)

void trim_left(struct string_t *str)
{
	size_t str_len = std::strlen(str->bytes);
	if (str_len < 1)
		return;

	size_t idx = 0;
	for (size_t i=0; i<str_len; ++i) {
		if (! isspace(str->bytes[i])) {
			idx = i;
			break;
		}
	}

	if (idx > 0) {
		for (size_t i=0; i < (str_len - idx); ++i)
			str->bytes[i] = str->bytes[i + idx];
		str->bytes[str_len - idx] = '\0';
		str->length = std::strlen(str->bytes);
		auto_resize(str);
	}
}

void trim_right(struct string_t *str)
{
	size_t str_len = std::strlen(str->bytes);
	if (str_len < 1)
		return;

	size_t idx = str_len -1;
	for (size_t i=str_len -1; i>= 0; --i) {
		if (! isspace(str->bytes[i])) {
			idx = i;
			break;
		}
	}

	if (idx < (str_len -1)) {
		str->bytes[idx +1] = '\0';
		str->length = std::strlen(str->bytes);
		auto_resize(str);
	}
}

void trim(struct string_t *str)
{
	trim_left(str);
	trim_right(str);
}

void uppercase(struct string_t *str)
{
	char *s = str->bytes;
	while (*s) {
		*s = toupper(*s);
		s++;
	}
}

void lowercase(struct string_t *str)
{
	char *s = str->bytes;
	while (*s) {
		*s = tolower(*s);
		s++;
	}
}

int find_bytes(struct string_t *str, const char *needle)
{
	size_t subject_length = std::strlen(str->bytes);
	size_t needle_length = std::strlen(needle);
	int match_idx = 0;

	for (size_t i=0; i<subject_length; ++i) {
		if (str->bytes[i] == needle[match_idx]) {
			match_idx++;
			if (match_idx == (needle_length -1))
				return i - (match_idx -1);
		} else {
			match_idx = 0;
		}
	}

	return -1;
}

int find_string(struct string_t *str, struct string_t *needle)
{
	return find_bytes(str, needle->bytes);
}

#define find(str, x) _Generic((str, x), \
	char*: find_bytes, \
	struct string_t*: find_string)(str, x)

int find_bytes_insensitive(struct string_t *str, const char *needle)
{
	struct string_t src_buffer = clone(str);
	uppercase(&src_buffer);

	struct string_t needle_buffer = init_str(needle);
	uppercase(&needle_buffer);

	int result = find_string(&src_buffer, &needle_buffer);

	free(&src_buffer);
	free(&needle_buffer);

	return result;
}

int find_string_insensitive(struct string_t *str, struct string_t *needle)
{
	struct string_t src_buffer = clone(str);
	uppercase(&src_buffer);

	struct string_t needle_buffer = clone(needle);
	uppercase(&needle_buffer);

	int result = find_string(&src_buffer, &needle_buffer);

	free(&src_buffer);
	free(&needle_buffer);

	return result;
}

#define find_insensitive(str, x) _Generic((str, x), \
	char*: find_bytes_insensitive, \
	struct string_t*: find_string_insensitive)(str, x)

/**
 * Reduces the given string to a substring.
 * @param  str    The subject string.
 * @param  start  The starting position for the reduced subset.
 * @param  length The length of the new subset (forwards from the starting position)
 * @return int    The relevant error code, or 0.
 **/
int subset(struct string_t *str, const long start, long length)
{
	int str_len = strlen(str->bytes);
	if (start < 0 || length < 0 || start > (str_len -1))
		return LIBSTRING_ERR_OUT_OF_BOUNDS;

	if (length > (str_len - start))
		length = str_len - start;

	for (int i=0; i<length; ++i) {
		str->bytes[i] = str->bytes[i + start];
	}

	str->bytes[length] = '\0';
	str->length = strlen(str->bytes);
	auto_resize(str);
}

#endif