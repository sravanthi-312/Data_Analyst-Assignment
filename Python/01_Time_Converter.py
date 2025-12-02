# 01_Time_Converter.py
# Given an integer number of minutes, convert to "X hrs Y minutes" format.

def minutes_to_human(minutes: int) -> str:
    if minutes < 0:
        raise ValueError("Minutes cannot be negative")
    hours = minutes // 60
    mins = minutes % 60
    parts = []
    if hours == 1:
        parts.append(f"{hours} hr")
    elif hours > 1:
        parts.append(f"{hours} hrs")
    if mins == 1:
        parts.append(f"{mins} minute")
    elif mins > 1 or mins == 0:
        parts.append(f"{mins} minutes")
    return " ".join(parts)

# Simple CLI for testing
if __name__ == "__main__":
    test_values = [130, 110, 60, 1, 0]
    for t in test_values:
        print(f"{t} -> {minutes_to_human(t)}")
