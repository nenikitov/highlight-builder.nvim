#!/usr/bin/env python

# The following is tweaked code from
# https://xyne.dev/projects/python3-colorsysplus/src/

from sys import stdout, stdin
import re
import select
import termios

class ConfiguredTerminal():
    def __init__(self) -> None:
        self.state_previous = None

    def __enter__(self) -> select.poll:
        return self.__configure()

    def __exit__(self, *_) -> None:
        self.__reset()
 
    def __configure(self) -> select.poll:
        fileno = stdin.fileno()
        poll = select.poll()
        poll.register(fileno, select.POLLIN)
        try:
            # Save state
            self.state_previous = termios.tcgetattr(fileno)
            # Copy to modify
            state_current = termios.tcgetattr(fileno)
            # Configure
            state_current[3] &= ~termios.ECHO
            state_current[3] &= ~termios.ICANON
            state_current[6][termios.VMIN] = 0
            state_current[6][termios.VTIME] = 0
            # Set state
            termios.tcsetattr(fileno, termios.TCSANOW, state_current)
            return poll

        except Exception as e:
            self.__reset()
            raise e

    def __reset(self) -> None:
        if self.state_previous:
            fileno = stdin.fileno()
            termios.tcsetattr(fileno, termios.TCSANOW, self.state_previous)
            self.state_previous = None



def query_color(ansi: list[int] | int, poll: select.poll, timeout=500, retries=5) -> str | None:
    ansi = [ansi] if isinstance(ansi, int) else ansi
    ansi_str = ';'.join([str(a) for a in ansi])

    QUERY = f'\033]{ansi_str};?\007'
    REGEX = re.compile(
        r'[\d;]*;'            # ID of the color
        r'(rgba?):'           # RGB or RGBA format
        r'([\da-fA-F]+)\/'    # R
        r'([\da-fA-F]+)\/'    # G
        r'([\da-fA-F]+)'      # B
        r'(\/([\da-fA-F]+))?' # A (optional)
    )
    def format_color(col: str, max: int) -> str:
        num = int(col, 16)
        num_256 = int(num / max * 256)
        return '{:02x}'.format(num_256)

    # Discard stdin
    while poll.poll(0):
        stdin.read()

    # Query
    stdout.write(QUERY)
    stdout.flush()

    # Find a match
    match = None
    output = ''
    while not match:
        if retries < 1 or not poll.poll(timeout):
            return None
        else:
            retries -= 1
            output += stdin.read()
            match = REGEX.search(output)

    # Get only RGB values (apparently if there is alpha the format is ARGB)
    rgb_indices = [2, 3, 4] if match.group(1) == 'rgb' else [3, 4, 6]

    # Format color
    max = 16 ** len(match.group(2))

    return (
        '#' +
        ''.join([
            format_color(match.group(i), max)
            for i in rgb_indices
        ])
    )

class ColorQuery():
    def __init__(self, name: str, query: list[int] | int) -> None:
        self.name = name
        self.query = query

COLORS = [
    'black',
    'red',
    'green',
    'yellow',
    'blue',
    'magenta',
    'cyan',
    'white'
]

QUERIES = [
    ColorQuery('primary.background', 11),
    ColorQuery('primary.foreground', 10),
    *[ ColorQuery(f'normal.{c}', [4, i]) for i, c in enumerate(COLORS) ],
    *[ ColorQuery(f'bright.{c}', [4, i + 8]) for i, c in enumerate(COLORS) ],
    *[ ColorQuery(f'indexed.{i}', [4, i]) for i in range(0, 256) ],
]

if __name__ == '__main__':
    with ConfiguredTerminal() as poll:
        try:
            for q in QUERIES:
                rgb = query_color(q.query, poll)
                if rgb:
                    print(f'{q.name} - {rgb}')
                else:
                    break
        except KeyboardInterrupt:
            pass

