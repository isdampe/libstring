#include <stdio.h>
#include "../libstring.h"

int main(void) {
	struct string_t name = string("Hello world.");
	printf("%s\n", name.bytes);

	string_append(&name, " It's time to leave");
	string_append(&name, (char)'.');
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
		struct string_t host_file = string(fopen("/etc/hosts", "r"));
		printf("%s\n", host_file.bytes);

		string_free(&host_file);
		fclose(nfh);
	}

	return 0;
}