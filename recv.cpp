#include <string>
#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>
#include <stdlib.h>
#include <arpa/inet.h>
#include <errno.h>

using namespace std;

int main(int argc, char *argv[])
{
	if (argc == 3)
	{
		string s = argv[1];
		string p = argv[2];

		sockaddr_in addr;
		addr.sin_family = AF_INET;
		addr.sin_port = htons(atoi(p.c_str()));
		addr.sin_addr.s_addr = inet_addr(s.c_str());

		int sk = socket(AF_INET, SOCK_STREAM, 0);
		if (bind(sk, (sockaddr *)&addr, sizeof(addr)) != 0)
		{
			printf("%s\n", strerror(errno));
			return errno;
		}

		if (listen(sk, 10) != 0)
		{
			printf("%s\n", strerror(errno));
			return errno;
		}

		int sk1;
		if ((sk1 = accept()) == -1)
		{
			printf("%s\n", strerror(errno));
			return errno;
		}

		
	}

	return 0;
}