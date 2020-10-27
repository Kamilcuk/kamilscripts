#include <iostream>
#include <vector>
#include <type_traits>
#include "unistd.h"
/* This is sample C++ code */
#include <cstdio>
#include <complex>
#define MACRO(x) x \
	/**/
using namespace std;
static int static_variable; int variable2; const int const_variable = 0; extern volatile int extern_volatile_variable;
// This comment may span only this line \
	well not really???????/
typedef unsigned int uint;
double operator""_d(unsigned long long i) {
  return static_cast<double>(i);
}
namespace Namespace {
int static myfunc(uint parameter) {
  if (parameter == 0) fprintf(stdout, "zero\n");
  while (1) {} for (;;) {}
  cout << "hello\n";
  using std::literals::complex_literals;
  auto c = 13if; auto k = 13_d;
  return parameter - MACRO(1);
} };
void mutator(int&);
template <typename Item>
class MyClass {
public:
  enum Number { ZERO, ONE, TWO }; enum class NumberClass { ZERO, ONE, TWO };
  static char staticField; int field;
  static Number smethod() noexcept; virtual Number vmethod() const override;
  void method(Number n) {
    int local = (int)MACRO('\0');
	field = 1; this->field = 2;
label: Namespace::myfunc(local);
	   this->vmethod();
    vmethod();
    staticMethod();
    problem();  // TODO: fix
    mutator(local);
  }
  static void staticMethod();
};
/**
 * @brief doxygen documentation
 * \brief Test doxygen documentation colorscheme
 */
struct FirstClass {
private:
	int brief, member = 0, function2{0}; std::vector<int> member2;
public:
	FirstClass(int var) : member(var) { int v2ar; std::vector<int> var2{5}; }
	template<typename A>
	typename std::enable_if<std::is_same<A, int>::value, int>::type function(int arg) {
		for (int a = 0; a < arg; ++a) { return a; } return 0;
	}
protected:
};
enum EnumType {
	ENUM_A = 1,
	ENUM_B = 2,
};
#define MACRO_B(b) b
#define MACRO_A(a) MACRO_B(b)
#ifdef __GLIBC__
int main() {
	FirstClass var{5}; var.function<int>(5);
	std::vector<int> a = {1,2,3,5}; std::vector<int> b(1,2);
}
#else
int main() {
	hello_world();
}
#endif
	A
