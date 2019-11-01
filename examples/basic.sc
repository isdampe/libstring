#include <stdio.h>
#include "../libstring.sch"

int main(void) {
	string::string name = string::create("Hello world.");
	std::printf("%s\n", name.bytes);

	string::append(&name, " It's time to leave.");
	string::append(&name, (char)'\n');
	string::append(&name, (24 + 32));
	std::printf("%s\n", name.bytes);

	string::string_free(&name);

	// Append from file.
	std::FILE *fh = std::fopen("/etc/hosts", "r");
	if (fh != NULL) {
		struct string::string_t hosts = string::create();
		string::append(&hosts, fh);
		std::printf("%s\n", hosts.bytes);

		string::string_free(&hosts);
		std::fclose(fh);
	}

	// Auto read a file.
	std::FILE *nfh = std::fopen("/etc/hosts", "r");
	if (nfh != NULL) {
		struct string::string_t host_file = string::create(nfh);
		std::printf("%s\n", host_file.bytes);

		string::string_free(&host_file);
		std::fclose(nfh);
	}

	struct string::string_t first_string = string::create("It's really me.");
	struct string::string_t second_string = string::create(&first_string);
	string::append(&second_string, (unsigned long)12312);
	string::append(&second_string, ". And now a decimal number. ");
	string::append(&second_string, 3.14159265);

	string::string_free(&first_string);
	std::printf("%s\n", second_string.bytes);
	string::string_free(&second_string);

	return 0;
}