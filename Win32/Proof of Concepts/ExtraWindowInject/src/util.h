#pragma once

void hex_dump(unsigned char *buf, size_t buf_size)
{
    size_t pad = 8;
    size_t col = 16;
    putchar('\n');
    for (size_t i = 0; i < buf_size; i++) {
        if (i != 0 && i % pad == 0) putchar('\t');
        if (i != 0 && i % col == 0) putchar('\n');
        printf("%02X ", buf[i]);
    }
    putchar('\n');
}
