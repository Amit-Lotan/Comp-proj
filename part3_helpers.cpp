#include "part3_helpers.hpp"
#include <sstream>

CodeBuffer::CodeBuffer(){
    data.clear();
}

void CodeBuffer::emit(const string& str) {
    data.push_back(str);
}

void CodeBuffer::emit_front(const string& str) {
    data.insert(data.begin(), str);
}

void CodeBuffer::backpatch(const vector<int>& lst, int line) {
    for (size_t i=0; i < lst.size(); ++i) {
        int index = lst[i] - 1;
        if(index >= 0 && index < data.size()) {
            data[index] += intToString(line) + " ";
        }
    }
}

int CodeBuffer::nextquad() {
    return data.size() + 1;
}

string CodeBuffer::printBuffer() {
    string out = "";
    for (size_t i=0; i<data.size(); ++i) {
        out += data[i] + "\n";
    }
    return out;
}

string intToString(int i) {
    stringstream ss;
    ss << i;
    return ss.str();
}
