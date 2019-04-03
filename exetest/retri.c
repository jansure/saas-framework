
#include <stdio.h>
int main ()
{
	int i,j,n;
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
	return 0;
 
}

