#  Running Total War Shogun 2 

https://www.reddit.com/r/linux_gaming/comments/1844dfd/running_total_war_shogun_2/

Tonight I was able to run Shogun 2 natively on Linux for first time. I got the game a couple of years ago but it never worked, and I tried with Proton too and it was very slow (and it crashed too).

Today I was decided to make it work and I want to share the steps I took:
Note: I am using the flatpak version of Steam.

1. Use the Steam Linux Runtime 1.0 (scout ): Compatibility -> Click on "Force a the use of a specific Steam Play compatibility tool" -> Choose The Linux Runtime

2. Make sure the binary can find its own libs: For some reason the game is looking in the wrong folder, so I went to game's base folder (~/.var/app/com.valvesoftware.Steam/.local/share/Steam/steamapps/common/Total War SHOGUN 2/lib) and created a bunch of symlinks with for f in $(ls i686); do ln -s i686/$f $f; done

3. After that the game crashed with segmentation fault (this was my original problem), to solve this you need to compile and very small library and add it to the game launch options:

Create a game.c file with this content:

    ```
    #include <sys/mman.h>
    #include <unistd.h>
    #include <sys/syscall.h>

    int mprotect(void *addr, size_t len, int prot) { if (prot == PROT_EXEC) { prot |= PROT_READ; } return syscall(__NR_mprotect, addr, len, prot); }
    ```

4. The game is 32bit so you need to compile with gcc -m32 game.c -shared -o game.so

5. move the game.so to the game's lib folder and add this to launch options: LD_PRELOAD="\$ORIGIN/../lib/game.so" %command%

6. It should be working now.

To compilation step was failing because I didn't have the required header files, so I installed some packages until the compiler stopped complaining.
```
libc6-dev-i386-cross:amd64
libc6-i386-cross:amd64
linux-libc-dev-i386-cross:amd64 
libc6-amd64-cross:amd64
linux-libc-dev-amd64-cross:amd64
libc6-dev-amd64-cross:amd64
libc6-dev-i386-amd64-cross:amd64
libc6-i386-amd64-cross:amd64
build-essential
binutils
gcc-multilib
```

I think the last 3 were the ones who did the trick. Anyways I think you can uninstall those packages after the compilation is done.

I found the code above here

Well that's all, so far I have played 3 tutorials, installed a mod and open and close the game a bunch of times. Not errors.

Edit: typos
