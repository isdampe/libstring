#include <stdio.h>
#include "../libstring.sch"

int main(void)
{
	autofree string::string name = string::create("Hello world this is Richard and this is really cool\n");
	printf("%s", name.bytes);

	string::replace(&name, "is", "IS");
	printf("%s", name.bytes);

	string::replace(&name, "Richard", "DAMPE");
	printf("%s", name.bytes);

	autofree string::string empty = string::create("this is a pointless emptyish string.\n");
	printf("%s", empty.bytes);
	string::replace(&empty, "i", "");
	printf("%s", empty.bytes);

	return 0;
}
