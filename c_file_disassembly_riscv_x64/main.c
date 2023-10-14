#include <stdio.h>
#include <stdlib.h>

int square(int val)
{
  int result;
  result = val * val;
  return result;
}

int main(void)
{
  int x = 10;
  return square(x);
}