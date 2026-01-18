#include "part3_helpers.hpp"

int CodeBuffer::nextQuad() const {
    return static_cast<int>(m_lines.size()) + 1;
}

void CodeBuffer::emit(const std::string& line) {
    m_lines.push_back(line);
}

void CodeBuffer::backpatch(const std::vector<int>& lst, int label) {
    const std::string lab = std::to_string(label);
    for (int lineNo : lst) {
        if (lineNo <= 0) {
            continue;
        }
        const size_t idx = static_cast<size_t>(lineNo - 1);
        if (idx >= m_lines.size()) {
            continue;
        }
        m_lines[idx] += lab;
    }
}

const std::vector<std::string>& CodeBuffer::getLines() const {
    return m_lines;
}

void CodeBuffer::patchLine(int lineNo, const std::string& newLine) {
    if (lineNo <= 0) {
        return;
    }
    const size_t idx = static_cast<size_t>(lineNo - 1);
    if (idx >= m_lines.size()) {
        return;
    }
    m_lines[idx] = newLine;
}

std::string CodeBuffer::str() const {
    std::string out;
    out.reserve(m_lines.size() * 16);
    for (size_t i = 0; i < m_lines.size(); ++i) {
        out += m_lines[i];
        out.push_back('\n');
    }
    return out;
}
