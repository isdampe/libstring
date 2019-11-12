#include <stdio.h>
#include "../libstring.sch"

#define TEST_MESSAGE "Hello world.\n"

int main(void)
{
	string::string a = string::create(TEST_MESSAGE);
	string::string b = string::create(&a);
	string::string c = string::create(&a);
	string::string d = string::create(&a);
	string::string e = string::create(&a);
	string::string f = string::create(&a);
	string::string g = string::create(&a);

	// Test a.
	std::printf("Test A:\n");
	std::printf("Pre: '%s'", a.bytes);
	string::subset(&a, 0, 5);
	std::printf("Post: '%s'", a.bytes);

	// Test b.
	std::printf("\n\nTest B:\n");
	std::printf("Pre: '%s'", b.bytes);
	string::subset(&b, 0, 1);
	std::printf("Post: '%s'", b.bytes);


	// Test c.
	std::printf("\n\nTest C:\n");
	std::printf("Pre: '%s'", c.bytes);
	string::subset(&c, 0, 0);
	std::printf("Post: '%s'", c.bytes);

	// Test d.
	std::printf("\n\nTest D:\n");
	std::printf("Pre: '%s'", d.bytes);
	string::subset(&d, 0, 999999999);
	std::printf("Post: '%s'", d.bytes);

	// Test e.
	std::printf("\n\nTest E:\n");
	std::printf("Pre: '%s'", e.bytes);
	string::subset(&e, strlen(e.bytes) -1, 1);
	std::printf("Post: '%s'", e.bytes);

	// Test f.
	std::printf("\n\nTest F:\n");
	std::printf("Pre: '%s'", f.bytes);
	string::subset(&f, -1, -1);
	std::printf("Post: '%s'", f.bytes);

	// Test g.
	std::printf("\n\nTest G:\n");
	std::printf("Pre: '%s'", g.bytes);
	string::subset(&g, -1, 5);
	std::printf("Post: '%s'", g.bytes);

	string::free(&a);
	string::free(&b);
	string::free(&c);
	string::free(&d);
	string::free(&e);
	string::free(&f);
	string::free(&g);
	return 0;
}