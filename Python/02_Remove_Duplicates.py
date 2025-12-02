# 02_Remove_Duplicates.py
# Remove duplicate characters from a string using a loop, preserving first occurrence order.

def remove_duplicates(s: str) -> str:
    result = []
    seen = set()
    for ch in s:
        if ch not in seen:
            seen.add(ch)
            result.append(ch)
    return "".join(result)

# Simple CLI for testing
if __name__ == "__main__":
    tests = [
        "banana",
        "aabbcc",
        "hello world",
        "",
        "AaAa"  # case-sensitive example
    ]
    for t in tests:
        print(f"Input: {t} -> Output: {remove_duplicates(t)}")
