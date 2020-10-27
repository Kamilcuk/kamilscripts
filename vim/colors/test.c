#include <stdio.h>
#include <assert.h>
#include <stdint.h>
#include <string.h>
#include <stdlib.h>
#include "unistd.h"
#include "test.h"
/* This is sample C code */
#define MACRO(x) x \
	/**/
static int static_variable; int variable2; const int const_variable = 0; extern volatile int extern_volatile_variable;
// This comment may span only this line \
	well not really???????/
typedef unsigned int uint;
typedef struct Struct { int a; const char *b; volatile int c; } Struct_t;
enum StructRets { RET_A, RET_B, RET_C = 0b00000, RET_D = 0x01, RET_F = 00111uLL };
enum StructRets struct_new(struct Struct *variable) {
	static_variable += 1; variable2 %= 10;
	variable->a = 5; variable->b = malloc(500); strcpy((char*)variable->b, "aaaa"); return RET_A;
}
int struct_do_something(Struct_t *variable) {
	variable->c += 100; return RET_B;
};
#define MACRO_B(b) b
#define MACRO_A(a) MACRO_B(b)
#ifndef __GLIBC__
int main() {
	FirstClass var{5}; var.function<int>(5);
	std::vector<int> a = {1,2,3,5}; std::vector<int> b(1,2);
}
#else
int main() {
	static const char *variable_static = "string";
	struct Struct variable = {};
	struct_new(&variable);
	assert(500);
}
#endif
