#include "part3_helper.hpp"

// C'tor of Buffer class
Buffer::Buffer(){
	data.clear();
}

void Buffer::emit(const string& str) {
	data.push_back(str);
}

void Buffer::emit_front(const string& str) {
	data.insert(data.begin(), str);
}

void Buffer::backpatch(vector<int> lst, int line) {
	for (unsigned i=0; i < lst.size(); ++i) {
		data[lst[i] - 1] += intToString(line) +" ";
	}
}

int Buffer::nextquad() {
	return data.size() + 1;
}

string Buffer::printBuffer() {
	string out = "";
	for (int i=0; i<data.size(); ++i) {
		out += data[i] + "\n";
	}
	return out;
}
