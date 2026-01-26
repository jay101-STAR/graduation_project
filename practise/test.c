/* demo.c */
const char msg[] = "Hello rodata!";
const int nums[] = {1, 2, 3, 4};

int main(void) {
  /* 只读数据，编译器会塞进 .rodata */
  return 0;
}
