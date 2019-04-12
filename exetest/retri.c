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

int main (int argc, char* argv[])
{
    char *name;
    char ch;
    int i,j,n;
    //解析命令可选项，循环执行，可将argv中的全部option解析出来
    //':'表示该选项带一个参数
    while((ch = getopt(argc, argv, "n:")) != -1) {
        switch(ch) {
            case 'n':
                printf("option n (modified process name): %s\n", optarg);
                name = optarg;
                break;
            case '?': //  ?
                printf("unknown option \n");
                break;
            default:
                printf("default \n");
        }
    }
    char argv_buf[MAXLINE] = {0}; // save argv paramters
    for(i = 1; i < argc; i++)
    {
        strcat(argv_buf, argv[i]);
        strcat(argv_buf, " ");
    }
    setproctitle_init(argc, argv, environ);
    setproctitle("retri%s %s", name, argv_buf);

	//printf("请输入要打印尖朝下等腰三角形的行数:");
	//scanf("%d",&n);
	n = 20;
	for(i=1;i<=n;i++)
	{
		for(j=1;j<=i-1;j++)
		{
			printf(" ");
		}
		for(j=1;j<=2*n-2*i+1;j++)
		{
			printf("*");
		}
		printf("\n");
	}

	for (int i = 0; environ[i] != NULL; i++)
        free(environ[i]);
    getchar();
	return 0;
 
}

//编译  gcc retri.c -std=c99 -o retri
//执行例程   ./retri -n pppppp