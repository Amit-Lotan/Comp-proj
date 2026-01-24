#include "part3_helpers.hpp"

/*
 * nextQuad():
 *  Riski instruction addresses are line numbers, starting at 1.
 *  Since m_lines holds already-emitted lines, the next quad is size()+1.
 */
int CodeBuffer::nextQuad() const {
    return static_cast<int>(m_lines.size()) + 1;
}

/* Append one instruction line (without a trailing newline). */
void CodeBuffer::emit(const std::string& line) {
    m_lines.push_back(line);
}

/*
 * backpatch():
 *  For each line number in lst, append the numeric label to the end of that line.
 *  This assumes the emitted line ends with a space (e.g., "UJUMP ").
 */
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

/*
 * patchLine():
 *  Utility function to replace a specific instruction (most patching is done by
 *  backpatch()). No-op if lineNo is out of range.
 */
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

/*
 * str():
 *  Join all instruction lines with '\n'. The caller is responsible for any extra header
 *  lines that must precede the assembly (the parser prints the linker header separately).
 */
std::string CodeBuffer::str() const {
    std::string out;
    out.reserve(m_lines.size() * 16);
    for (size_t i = 0; i < m_lines.size(); ++i) {
        out += m_lines[i];
        out.push_back('\n');
    }
    return out;
}
