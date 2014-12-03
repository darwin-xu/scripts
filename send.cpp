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
		if (connect(sk, (sockaddr *)&addr, sizeof(addr)) == -1)
		{
			printf("%s\n", strerror(errno));
			return errno;
		}

		char buf[2048];

		while (send(sk, buf, 2048, 0) >= 0);
	}
	return 0;
}
