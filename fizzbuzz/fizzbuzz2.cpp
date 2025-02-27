#include <iostream>

void fizzbuzz(unsigned int count) {
    for (unsigned int i = 1; i <= count; ++i) {
        const bool div3 = i % 3 == 0;
        const bool div5 = i % 5 == 0;
        switch ((div5 << 1) | div3) {
            case 0b01:
                std::cout << "fizz\n";
                break;
            case 0b10:
                std::cout << "buzz\n";
                break;
            case 0b11:
                std::cout << "fizzbuzz\n";
                break;
            default:
                std::cout << i << "\n";
                break;
        }
    }
}

int main() {
    fizzbuzz(100);
    return 0;
}
