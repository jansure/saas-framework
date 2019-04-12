#include <unistd.h>
#include <getopt.h>
#include <stdarg.h>
#include <string.h>
#include <stdlib.h>
#include <sys/prctl.h>
#include <stdio.h>

# define MAXLINE 2048
//environ是一个全局的外部变量，存储着系统的环境变量
extern char **environ;
static char **g_main_Argv = NULL; /* pointer to argument vector */
static char *g_main_LastArgv = NULL; /* end of argv */

void setproctitle_init(int argc, char **argv, char **envp)
{
    int i;
    for (i = 0; envp[i] != NULL; i++) // calc envp num
        continue;
    environ = (char **) malloc(sizeof (char *) * (i + 1)); // malloc envp pointer

    for (i = 0; envp[i] != NULL; i++)
    {
        environ[i] = malloc(sizeof(char) * strlen(envp[i]));
        strcpy(environ[i], envp[i]);
    }
    environ[i] = NULL;
    g_main_Argv = argv;
    if (i > 0)
        g_main_LastArgv = envp[i - 1] + strlen(envp[i - 1]);
    else
        g_main_LastArgv = argv[argc - 1] + strlen(argv[argc - 1]);
}
void setproctitle(const char *fmt, ...)
{
    char *p;
    int i;
    char buf[MAXLINE];
    extern char **g_main_Argv;
    extern char *g_main_LastArgv;
    va_list ap;
    p = buf;
    va_start(ap, fmt);
    vsprintf(p, fmt, ap);
    va_end(ap);
    i = strlen(buf);
    if (i > g_main_LastArgv - g_main_Argv[0] - 2)
    {
        i = g_main_LastArgv - g_main_Argv[0] - 2;
        buf[i] = '\0';
    }
    (void) strcpy(g_main_Argv[0], buf);
    p = &g_main_Argv[0][i];
    while (p < g_main_LastArgv)
        *p++ = '\0';
    g_main_Argv[1] = NULL;
    prctl(PR_SET_NAME,buf);
}

int main(int argc, char* argv[])
{
    char *name;
    //char *code;
    char ch;
    // 三角形的行数
    int t;

    //解析命令可选项，循环执行，可将argv中的全部option解析出来
    //':'表示该选项带一个参数
    while((ch = getopt(argc, argv, "n:t:")) != -1) {
        switch(ch) {
//            case 'c':
//                printf("option c: %s\n", optarg);
//                code = optarg;
//                break;
            case 'n':
                printf("option n: %s\n", optarg);
                name = optarg;
                break;
            case 't':
                t = atoi(optarg);
                printf("option t: %d\n",t);
                break;
            case '?': //  ?
                printf("unknown option \n");
                break;
            default:
                printf("default \n");
        }
    }
    char argv_buf[MAXLINE] = {0}; // save argv paramters
    for(int i = 1; i < argc; i++)
    {
        strcat(argv_buf, argv[i]);
        strcat(argv_buf, " ");
    }
    setproctitle_init(argc, argv, environ);
//    setproctitle("%s@%s %s", name, code, argv_buf);
    setproctitle("tri-%s %s", name, argv_buf);

	for(int i=1;i<=t;i++)
	{
		for(int j=1;j<=t-i;j++)
		{
			printf(" ");
		}
		for(int j=1;j<=2*i-1;j++)
		{
			printf("*");
		}
		printf("\n");
	}

	for (int i = 0; environ[i] != NULL; i++)
        free(environ[i]);
    getchar();

    // 进程挂起5分钟，用于模拟计算时间长的进程
    sleep(300);
	return 0;
}

//编译  gcc tri.c -std=c99 -o tri
//执行例程   ./tri -t 5 -c 12345 -n pppppp
//执行例程   ./tri -t 5 -n pppppp