#include <stdio.h>
#include "../libstring.h"

int main(void) {
	string name = string("Hello world.");
	printf("%s\n", name.bytes);
	string_append(&name, " It's time to leave.");
	string_append(&name, (char)'\n');
	string_append(&name, (24 + 32));
	printf("%s\n", name.bytes);

	string_free(&name);

	// Append from file.
	FILE *fh = fopen("/etc/hosts", "r");
	if (fh != NULL) {
		struct string_t hosts = string();
		string_append(&hosts, fh);
		printf("%s\n", hosts.bytes);

		string_free(&hosts);
		fclose(fh);
	}

	// Auto read a file.
	FILE *nfh = fopen("/etc/hosts", "r");
	if (nfh != NULL) {
		struct string_t host_file = string(nfh);
		printf("%s\n", host_file.bytes);

		string_free(&host_file);
		fclose(nfh);
	}

	struct string_t first_string = string("It's really me.");
	struct string_t second_string = string(&first_string);
	string_append(&second_string, (unsigned long)12312);
	string_append(&second_string, ". And now a decimal number. ");
	string_append(&second_string, 3.14159265);

	string_free(&first_string);
	printf("%s\n", second_string.bytes);
	string_free(&second_string);

	return 0;
}