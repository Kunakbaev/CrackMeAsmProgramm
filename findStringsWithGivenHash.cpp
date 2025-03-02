#include <bits/stdc++.h>

constexpr int hashModule = 0xfa91;
constexpr int hashBase   = 857;

int countStringHash(const std::string& s) {
    int hash = 0;
    for (char ch : s) {
        hash *= hashBase;
        hash += ch;
        ++hash;
        hash %= hashModule;
    }

    return hash;
}

signed main() {
    const int maxStringLen = 7;
    const int neededStringHash = 56637;

    int cntCorrectPasswords = 0;
    for (int len = 1; len <= maxStringLen; ++len) {
        int maxHeh = 1;
        for (int i = 0; i < len; ++i)
            maxHeh *= 10;

        std::string s(len, '0');
        for (int heh = 0; heh < maxHeh; ++heh) {
            for (int i = 0, cop = heh; i < len; ++i, cop /= 10) {
                s[len - i - 1] = '0' + (cop % 10);
            }

            int stringHash = countStringHash(s);
            if (stringHash == neededStringHash) {
                std::cout << "len : " << len << " string : " << s << "\n";
                ++cntCorrectPasswords;
            }
        }
    }
}

/*



 */

