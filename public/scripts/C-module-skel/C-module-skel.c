#include <stdint.h>
#include <errno.h>
#include <stdio.h>
#include <stddef.h>
#include <stdlib.h>

typedef struct {
	int val;
} SKEL_t;

int SKEL_Init(SKEL_t *hskel, int val)
{
	if ( !hskel ) return -EINVAL;
	hskel->val = val;
	return 0;
}

int SKEL_Add(SKEL_t *hskel, int val)
{
	if ( !hskel ) return -EINVAL;
	hskel->val += val;
	return 0;
}

int SKEL_Snprintf(SKEL_t *hskel, char *buffer, size_t size)
{
	return snprintf(buffer, size, "%d", hskel->val);
}

int SKEL_Get(SKEL_t *hskel, int *val)
{
	if ( !hskel || !val ) return -EINVAL;
	*val = hskel->val;
	return 0;
}

int SKEL_DeInit(SKEL_t *hskel)
{
	return 0;
}

int main() { 
	SKEL_t skel;
	int ret;
	if ( (ret = SKEL_Init(&skel, 8)) != 0 ) { 
		printf("Handle skel init error\n");
		return -1;
	}
	if ( (ret = SKEL_Add(&skel, 5)) != 0 ) {
		printf("Handle skel add error\n");
		return -1;
	}

	int val;
	if ( (ret = SKEL_Get(&skel, &val)) != 0 ) {
		printf("Handle skel get error \n");
		return -1;
	}
	if ( (ret = SKEL_DeInit(&skel)) != 0 ) { 
		printf("Handle skel de init error \n");
		return -1;
	}
	return 0;
}


