#include <stdio.h>
int main(int argc, char* argv[])
{
	int i,j,m,n;
	//printf("请输入要打印尖朝上等腰三角形的行数：");
	//scanf("%d",&n);
	n = atoi(argv[1]);
	printf("%d\n",n);
	//n = atoi(argv[2]);
	//printf("%d\n",n);
	for(i=1;i<=n;i++)
	{
		for(j=1;j<=n-i;j++)
		{
			printf(" ");
		}
		for(j=1;j<=2*i-1;j++)
		{
			printf("*");
		}
		printf("\n");
	}
	return 0;
}
