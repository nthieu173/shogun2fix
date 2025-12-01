#  Running Total War Shogun 2

## Create the patch

There's a few methods, just pick one:

### Building on Podman

Install [Podman](https://podman.io/docs/installation). Then, in this repository folder, run:
```bash
podman build --output type=local,dest=. .
```

This should create the file `libc_mprotect.so` in this folder.

### Building on Docker

Install [Docker](https://docs.docker.com/engine/install/). Then, in this repository folder, run:
```bash
docker build --output type=local,dest=. .
```

This should create the file `libc_mprotect.so` in this folder.

### Building on Fedora

Install 32-bit libaries:
```bash
sudo dnf install gcc libgcc.i686 glibc-devel.i686
```

Then, in this repository's folder, run the command:
```bash
gcc -m32 libc_mprotect.c -shared -o libc_mprotect.so
```

This should create the file `libc_mprotect.so` in this folder.

#### Ubuntu

Install 32-bit libaries:
```bash
sudo apt install gcc gcc-multilib
```

Then, in this repository's folder, run the command:
```bash
gcc -m32 libc_mprotect.c -shared -o libc_mprotect.so
```

This should create the file `libc_mprotect.so` in this folder.

## Copy the file to the game folder

After building `libc_mprotect.so` in the previous step, you find the game's folder in Steam:

1. Right click the game in the sidebar.
2. Select "Manage > Browse Local Files".
3. Copy `libc_mprotect.so` from the previous step to the `lib` folder which should exists in the game's folder.

## Create sim-links of all `.so` files in the `lib/i686` folder

The game is looking for its own folder in the wrong place, so we have to help it.

1. Go to the `lib` folder mentioned in the previous step.
2. Open a terminal there and run the command:
```bash
for f in $(find i686 -maxdepth 1 -type f -name '*.so' -printf '%f\n'); do ln -s $f $f; done
```

## Add the launch option

This tells the game to actually load the patch:

1. Right click the game in the sidebar.
2. Select "Properties".
3. Paste the folowing to the "Launch Options" input box:
```bash
LD_PRELOAD="\$ORIGIN/../lib/libc_mprotect.so" %command%`
```

## Done
Just launch the game normally!

Also, you can check out [Shogun2-Linux-Fix](https://github.com/GitoMat/Shogun2-Linux-Fix) which also fixes this, though from my observation, the `libc_dlopen_mode.so` fix doesn't seems to be neccessary.

## Original Post
Copied from original Reddit post for archival purpose. Thanks for not letting a game die r/zargex.
https://www.reddit.com/r/linux_gaming/comments/1844dfd/running_total_war_shogun_2/

Tonight I was able to run Shogun 2 natively on Linux for first time. I got the game a couple of years ago but it never worked, and I tried with Proton too and it was very slow (and it crashed too).

Today I was decided to make it work and I want to share the steps I took:
Note: I am using the flatpak version of Steam.

1. Use the Steam Linux Runtime 1.0 (scout ): Compatibility -> Click on "Force a the use of a specific Steam Play compatibility tool" -> Choose The Linux Runtime

2. Make sure the binary can find its own libs: For some reason the game is looking in the wrong folder, so I went to game's base folder (`~/.var/app/com.valvesoftware.Steam/.local/share/Steam/steamapps/common/Total War SHOGUN 2/lib`) and created a bunch of symlinks with `for f in $(ls i686); do ln -s i686/$f $f; done`

3. After that the game crashed with segmentation fault (this was my original problem), to solve this you need to compile and very small library and add it to the game launch options:

Create a game.c file with this content:

    #include <sys/mman.h>
    #include <unistd.h>
    #include <sys/syscall.h>

    int mprotect(void *addr, size_t len, int prot) { if (prot == PROT_EXEC) { prot |= PROT_READ; } return syscall(__NR_mprotect, addr, len, prot); }

4. The game is 32bit so you need to compile with `gcc -m32 game.c -shared -o game.so`

5. move the game.so to the game's lib folder and add this to launch options: `LD_PRELOAD="\$ORIGIN/../lib/game.so" %command%`

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
