#include <string>
#include <algorithm>
#include <cassert>
#include <iostream>
#include <ranges>

void reverse_words_inplace(std::string& sentence) {
    for (const auto& word : std::views::split(sentence, ' '))
        std::ranges::reverse(word);
}

// Test functions
void test_basic_sentence() {
    std::string s = "Rust is fun";
    reverse_words_inplace(s);
    assert(s == "tsuR si nuf");
}

void test_leading_trailing_spaces() {
    std::string s = "  hello   world  ";
    reverse_words_inplace(s);
    assert(s == "  olleh   dlrow  ");
}

void test_empty_string() {
    std::string s = "";
    reverse_words_inplace(s);
    assert(s == "");
}

void test_single_char() {
    std::string s = "a";
    reverse_words_inplace(s);
    assert(s == "a");
}

void test_only_spaces() {
    std::string s = "  ";
    reverse_words_inplace(s);
    assert(s == "  ");
}

void test_single_word() {
    std::string s = "hello";
    reverse_words_inplace(s);
    assert(s == "olleh");
}

void test_multiple_spaces_between_words() {
    std::string s = "hi    there";
    reverse_words_inplace(s);
    assert(s == "ih    ereht");
}

void test_in_place_no_reallocation() {
    std::string s;
    s.reserve(20); // Pre-allocate extra space
    s = "Rust is fun";

    const char* ptr_before = s.data();
    size_t capacity_before = s.capacity();

    reverse_words_inplace(s);

    const char* ptr_after = s.data();
    size_t capacity_after = s.capacity();

    assert(s == "tsuR si nuf");
    assert(ptr_before == ptr_after && "Buffer pointer should not change");
    assert(capacity_before == capacity_after && "Capacity should not increase");
}

void test_tight_capacity_no_reallocation() {
    std::string s = "hi there"; // Capacity matches length

    const char* ptr_before = s.data();
    size_t capacity_before = s.capacity();

    reverse_words_inplace(s);

    const char* ptr_after = s.data();
    size_t capacity_after = s.capacity();

    assert(s == "ih ereht");
    assert(ptr_before == ptr_after && "Buffer pointer should not change");
    assert(capacity_before == capacity_after && "Capacity should not increase");
}

int main() {
    test_basic_sentence();
    test_leading_trailing_spaces();
    test_empty_string();
    test_single_char();
    test_only_spaces();
    test_single_word();
    test_multiple_spaces_between_words();
    test_in_place_no_reallocation();
    test_tight_capacity_no_reallocation();

    std::cout << "All tests passed!" << std::endl;
    return 0;
}
