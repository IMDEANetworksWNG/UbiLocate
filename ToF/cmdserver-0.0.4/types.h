#ifndef _TYPES_H_
#define _TYPES_H_

typedef enum {
    T_COMMAND = 1,
    T_RFILE = 2,
    T_TFILE = 3,
} type_t;

typedef enum {
    C_DATA = 1,
    C_MSG = 2,
} chunk_type_t;

#define CHUNK_DATA_SIZE 128

typedef struct _chunk {
    uint16_t type;
    uint16_t len;
    char data[CHUNK_DATA_SIZE];
} chunk;

#endif // _TYPES_H_
