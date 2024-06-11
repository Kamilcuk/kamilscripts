from math import sin
import contextlib
from typing import IO, Optional, Union

GLOBAL: int = 1

@contextlib.contextmanager
def main(a: Optional[Union[IO, int]] = None):
    yield 123
    return None

if __name__ == "__main__":
    main()
