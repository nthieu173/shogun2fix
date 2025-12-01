FROM ubuntu:noble AS build

RUN apt-get update && apt-get install -y \
    gcc \
    gcc-multilib \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /shogun

COPY libc_mprotect.c .

RUN gcc -m32 -shared -o libc_mprotect.so \
    libc_mprotect.c

FROM scratch AS export
COPY --from=build /shogun/libc_mprotect.so /libc_mprotect.so
