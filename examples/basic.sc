#include <stdio.h>
#include "../libstring.sch"

int main(void) {
	string::string name = string::create("Hello world.");
	std::printf("%s\n", name.bytes);

	string::append(&name, " It's time to leave.");
	string::append(&name, (char)'\n');
	string::append(&name, (24 + 32));
	std::printf("%s\n", name.bytes);

	string::string surname = string::create();
	string::append(&surname, &name);
	std::printf("Surname: %s\n", surname.bytes);

	string::free(&name);
	string::free(&surname);

	// Append from file.
	std::FILE *fh = std::fopen("/etc/hosts", "r");
	if (fh != NULL) {
		struct string::string_t hosts = string::create();
		string::append(&hosts, fh);
		std::printf("%s\n", hosts.bytes);

		string::free(&hosts);
		std::fclose(fh);
	}

	// Auto read a file.
	std::FILE *nfh = std::fopen("/etc/hosts", "r");
	if (nfh != NULL) {
		struct string::string_t host_file = string::create(nfh);
		std::printf("%s\n", host_file.bytes);

		string::free(&host_file);
		std::fclose(nfh);
	}

	struct string::string_t first_string = string::create("It's really me.");
	struct string::string_t second_string = string::create(&first_string);
	string::append(&second_string, (unsigned long)12312);
	string::append(&second_string, ". And now a decimal number. ");
	string::append(&second_string, 3.14159265);

	string::free(&first_string);
	std::printf("%s\n", second_string.bytes);
	string::free(&second_string);

	string::string label = string::create("\t\t \n\t\tRichard");
	std::printf("--Before--: '%s'\n", label.bytes);
	string::trim_left(&label);
	std::printf("--After--: '%s'\n", label.bytes);
	string::free(&label);

	string::string label_right = string::create("Richard  \t\t \t");
	std::printf("--Before--: '%s'\n", label_right.bytes);
	string::trim_right(&label_right);
	std::printf("--After--: '%s'\n", label_right.bytes);
	string::free(&label_right);

	string::string label_both = string::create("  It's a beautiful world    ");
	std::printf("--Before--: '%s'\n", label_both.bytes);
	string::trim(&label_both);
	std::printf("--After--: '%s'\n", label_both.bytes);
	string::free(&label_both);

	string::string upper = string::create("ab");
	string::uppercase(&upper);
	std::printf("%s\n", upper.bytes);
	string::free(&upper);

	string::string lower = string::create("ZXY");
	string::lowercase(&lower);
	std::printf("%s\n", lower.bytes);
	string::free(&lower);

	string::string subject = string::create("It's a small world after all.");
	int position = string::find(&subject, "small");
	std::printf("%i\n", position);

	string::string needle = string::create("world");
	position = string::find(&subject, &needle);
	std::printf("%i\n", position);
	string::free(&needle);

	string::string insensitive = string::create("Hello there Richard");
	position = string::find(&insensitive, "richard");
	std::printf("%i\n", position);
	position = string::find_insensitive(&insensitive, "richard");
	std::printf("%i\n", position);

	string::string n = string::create("There");
	position = string::find(&insensitive, &n);
	std::printf("T: %i\n", position);
	position = string::find_insensitive(&insensitive, &n);
	std::printf("Z: %i\n", position);

	string::free(&insensitive);
	string::free(&n);
	string::free(&subject);

	string::string ss = string::create("Hello world it's great");
	printf("%s\n", ss.bytes);
	string::subset(&ss, 0, 7);
	printf("%s\n", ss.bytes);

	string::free(&ss);

	return 0;
}