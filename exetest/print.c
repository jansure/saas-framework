#include<stdio.h>
int main() 
{
   int i,j,m,n;
   char ch[27];
   //printf("请你输入行数和列数 ： ");
   //scanf("%d%d",&n,&m);
   m = 26;
   n = 26;
   for(i=0;i<m;i++)
	  ch[i]=65+i;
  for(i=0;i<n;i++)	
  {
	  for(j=0;j<m;j++)
		  printf("%c ",ch[(j+i)%m]);
      printf("\n");
  }
	return 0;
}

