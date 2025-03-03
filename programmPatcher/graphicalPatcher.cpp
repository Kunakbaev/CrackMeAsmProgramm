#include <stdio.h>
#include <inttypes.h>
#include <sys/stat.h>
#include <assert.h>

const int MAX_FILE_NAME_LEN = 100;
const int MAX_FILE_BUFF_LEN = 1024;

size_t getFileSize(FILE* file) {
    assert(file != NULL);

    int fd = fileno(file);
    struct stat buff;
    fstat(fd, &buff);
    return buff.st_size;
}

int main() {
    char fileNameBuffer[MAX_FILE_NAME_LEN] = {};
    printf("Print file name: ");
    scanf("%s", fileNameBuffer); // read file name

    FILE* file = fopen(fileNameBuffer, "rb");
    if (file == NULL) {
        printf("Error: couldn't open file\n");
        return 1;
    }

    size_t fileSize = getFileSize(file);
    printf("fileSize : %zu\n", fileSize);


    if (fileSize > MAX_FILE_BUFF_LEN) {
        printf("Error: file size is bigger than buffer size\n");
        return 3;
    }



    char fileBuffer[MAX_FILE_BUFF_LEN] = {};
    fread(fileBuffer, fileSize, sizeof(uint8_t), file);

    // printf("first 10 bytes of file: ");
    // for (int i = 0; i < 10; ++i) {
    //     printf("%d ", fileBuffer[i]);
    // }
    // printf("\n");


    printf("Index of byte to change (in zero indexation): ");
    size_t indexOfByte2Change = -1;
    scanf("%zu", &indexOfByte2Change);

    printf("Print new byte value: ");
    uint8_t newByteValue = 0; // how to read uint8_t
    scanf("%hhu", &newByteValue);

    if (indexOfByte2Change >= MAX_FILE_BUFF_LEN) {
        printf("Error: index of byte is too big\n");
        return 2;
    }

    fileBuffer[indexOfByte2Change] = newByteValue;



    fclose(file);
    file = fopen(fileNameBuffer, "wb");
    assert(file != NULL); // ASK: how to open binary file for read and write simultaneously

    // printf("first 10 bytes of file: ");
    // for (int i = 0; i < 10; ++i) {
    //     printf("%d ", fileBuffer[i]);
    // }
    // printf("\n");

    printf("patching byte...\n");
    fwrite(fileBuffer, fileSize, sizeof(uint8_t), file);

    printf("Closing file...\n");
    fclose(file);

    return 0;
}

/*

file path:
../../DOS_world/crackMe/CRACK_edited_copy_JE2JNE.COM
byte index: 210
byte val:   75 in hex = 117 in decimal (code of needed jne command)

*/
