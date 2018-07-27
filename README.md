# Return Stack Support for Linux ELF Executables

This organization of repositories provides support for return stacks---a
leak-resilient dual stack scheme---in Linux ELF executables. For further
details see the ASIA CCS '18 paper:

> Philipp Zieris and Julian Horsch. 2018. A Leak-Resilient Dual Stack Scheme
> for Backward-Edge Control-Flow Integrity. In *ASIA CCS ’18: 2018 ACM Asia
> Conference on Computer and Communications Security, June 4–8, 2018, Incheon,
> Republic of Korea*. ACM, New York, NY, USA, 12 pages.
> https://doi.org/10.1145/3196494.3196531

The paper is also available on [arxiv.org](https://arxiv.org/abs/1806.09496).

Note that these repositories present a **prototype** implementation for return
stack support on Linux and should **not** be used in a productive environment.

## Introduction

The basic design principle of return stacks is the *separation* of potentially
unsafe stack objects, such as local stack variables storing user-supplied data,
from sensitive stack objects, i.e. return addresses. This separation thwarts
runtime attacks that aim at maliciously diverting the control-flow by
overwriting return addresses on the regular stack. As return stacks only
contain return addresses, they are not exploitable through unsafe stack objects
and are virtually impossible to locate using state-of-the-art information
disclosure attacks.

Executables and libraries compiled with return stacks still maintain their
regular stacks addressed through the architecture's stack pointer, but save
return addresses on the new, second stack. The return stack is addressed
through a dedicated register, called the Return Stack Pointer (RSP) register
(see [Supported Architectures](#supported-architectures)). The RSP register
*must not* be used for any other purpose when return stacks are present.

## Compatibility

In general, return stacks can be fully integrated into programs, static
libraries, and dynamic shared objects. Return stack support does not restrict
any compiler and linker features, such as tail call optimization or
position-independent code, and is interoperable with language features, such as
shortened return sequences (e.g., setjmp/longjmp), multi-threading, or C++
exceptions.

Return stack-enabled executables can be linked and executed against unprotected
legacy libraries. However, unprotected libraries might leak the RSP to unsafe
memory.

### Limitations

User-level multi-threading (e.g.,
[ucontext.h](http://man7.org/linux/man-pages/man3/getcontext.3.html) on Linux)
is not supported for return stack-enabled binaries. User-level threads store
register contexts within the program's address space, implicitly leaking the
RSP to memory. Therefore, only kernel-level threads, which store their register
contexts in kernel space and out of the attacker's reach, are supported.

### Supported Languages

C and C++ are supported.

### Supported Platforms

Only Linux is supported.

### Supported Architectures

The following architectures are supported. On each architecture, the
general-purpose register shown below is used as the dedicated RSP register.

* AArch64 (RSP register: X28)
* x86-64 (RSP register: R15)

## Usage

The repositories of this organization provide the following tools and libraries.

* Meta repository containing scripts for building and testing:
  * https://github.com/llvm-return-stack/return-stack
* LLVM compiler framework with return stack support:
  * LLVM: https://github.com/llvm-return-stack/llvm
  * Clang: https://github.com/llvm-return-stack/clang
  * Compiler-RT: https://github.com/llvm-return-stack/compiler-rt
* GNU C library with return stack-safe versions of setjmp/longjmp:
  * https://github.com/llvm-return-stack/glibc
* GCC runtime library with support for return stack unwinding (e.g., for C++
  exception handling and multi-threading):
  * https://github.com/llvm-return-stack/gcc
* Small collection of C/C++ files as a test suite:
  * https://github.com/llvm-return-stack/test

### Building LLVM and the Runtime Libraries

To compile and execute return stack-enabled executables, a modified version of
the LLVM compiler framework, the GNU C library, and the GCC runtime library are
required.

#### Requirements

Building LLVM and the runtime libraries requires several software packages to
be installed. Those packages are listed in the table below.

| Package       | Version    | Note |
|---------------|------------|------|
| binutils      | &nbsp;     | Binary utilities |
| Bison         | &nbsp;     | Parser generator |
| CMake         | >= 3.4.3   | Build process manager (used for building LLVM) |
| Flex          | >= 2.5.4   | Lexical analyzer generator |
| GCC/G++       | &nbsp;     | GNU C/C++ compiler |
| gawk          | &nbsp;     | Pattern scanning and processing language |
| gettext       | >= 0.14.5  | Internationalization and localization tool |
| Git           | &nbsp;     | Version control system |
| glibc         | >= 2.25    | GNU C library **and** headers |
| GMP library   | >= 4.3.2   | GNU multiple precision library |
| Make          | >= 3.80    | Build processor |
| MPC library   | >= 0.8.1   | Multiple precision complex floating-point library |
| MPFR library  | >= 2.4.2   | Multiple precision floating-point reliably library |
| Ninja         | &nbsp;     | Build processor (used for building LLVM) |
| Python        | >= 2.7.6   | Python programming language interpreter |
| zlib          | >= 1.2.3.4 | Compression library and headers |

#### Building and Testing Using Provided Scripts

1. Checkout the meta and test suite repositories:  
   `cd <workspace>`  
   `git clone https://github.com/llvm-return-stack/return-stack.git`  
   `git clone https://github.com/llvm-return-stack/test.git`
2. Checkout the LLVM compiler framework:  
   1. Checkout LLVM:  
      `cd <workspace>`  
      `git clone https://github.com/llvm-return-stack/llvm.git`
   2. Checkout Clang:  
      `cd <workspace>/llvm/tools`  
      `git clone https://github.com/llvm-return-stack/clang.git`
   3. Checkout the Compiler-RT:  
      `cd <workspace>/llvm/projects`  
      `git clone https://github.com/llvm-return-stack/compiler-rt.git`
3. Checkout the GNU C library:  
   `cd <workspace>`  
   `git clone https://github.com/llvm-return-stack/glibc.git`
4. Checkout GCC:  
   `cd <workspace>`  
   `git clone https://github.com/llvm-return-stack/gcc.git`
5. Build using provided build scripts:  
   `cd <workspace>/return-stack/buildscripts`  
   `./build-llvm-x86_64-linux-gnu.sh`  
   `./build-glibc-x86_64-linux-gnu.sh`  
   `./build-gcc-x86_64-linux-gnu.sh`
6. Test using a provided test script:  
   `cd <workspace>/return-stack/testscripts`  
   `./run-x86_64-linux-gnu.sh`

**Note** that it is recommended to build the same version of the GNU C library
as running on your system. Otherwise the tests may fail due to runtime errors.

#### Building Manually

1. Build the LLVM compiler framework:

   1. Checkout LLVM:  
      `cd <workspace>`  
      `git clone https://github.com/llvm-return-stack/llvm.git`
   2. Checkout Clang:  
      `cd <workspace>/llvm/tools`  
      `git clone https://github.com/llvm-return-stack/clang.git`
   3. Checkout the Compiler-RT:  
      `cd <workspace>/llvm/projects`  
      `git clone https://github.com/llvm-return-stack/compiler-rt.git`
   4. Build LLVM according to the
      [documentation](https://llvm.org/docs/CMake.html).

2. Build the GNU C library:

   1. Checkout:  
      `cd <workspace>`  
      `git clone https://github.com/llvm-return-stack/glibc.git`
   2. Build the library according to the
      [documentation](https://www.gnu.org/software/libc/manual/html_node/Configuring-and-compiling.html),
      using the compiler option `--ffixed-<RSP>` (see [Supported
      Architectures](#supported-architectures)). Be sure to build the same
      version as running on your system to avoid runtime errors.
   3. Optionally install the library to a `sysroot` directory
      (see [Runtime Environment Options](#runtime-environment-options)).

3. Build the GCC runtime library:

   1. Checkout:  
      `cd <workspace>`  
      `git clone https://github.com/llvm-return-stack/gcc.git`
   2. Build GCC according to the
      [documentation](https://gcc.gnu.org/install/configure.html), using the
      compiler option `--ffixed-<RSP>` (see [Supported
      Architectures](#supported-architectures)).
   3. Optionally install GCC to a `sysroot` directory
      (see [Runtime Environment Options](#runtime-environment-options)).

### Building and Executing Protected Binaries

**Note** that executing return-stack enabled programs requires a Linux kernel
version of 3.17 or later. This is because the return stack runtime (which is
part of LLVM’s Compiler-RT) depends on the glibc wrapper `getrandom()`. The
runtime can be made compatible with older kernels by removing this dependency
(at getting random bits another way).

To build return stack-enabled executables and libraries, simply use the
previously built Clang with the compiler option `-fsanitize=return-stack`.

Further, be sure to link binaries either using the gold or lld linker (e.g., by
compiling with the option `-fuse-ld=gold`). This is necessary, as the ld linker
will fail at creating the `.eh_frame_hdr` section due to non-standard DWARF2
CFI instructions emitted by our modified compiler (although binaries linked
with ld should still work).

For executables, also pass the previously built `ld-<version>.so` from the GNU
C library as the default dynamic linker by compiling with the option
`-Wl,--dynamic-linker=<path to ld.so>`. This step is needed, as the standard
dynamic linker does not preserve the RSP register while loading return
stack-enabled executables.

For example:

```
cd <workspace>/test
<path to clang> basic.c -O0 -fsanitize=return-stack -fuse-ld=gold -Wl,--dynamic-linker=<path to ld.so> -o basic
./basic
```

### Runtime Environment Options

Besides requiring a custom dynamic linker, return stack-enabled programs that
use setjmp/longjmp or require stack unwinding (e.g., for C++ exception handling
and multi-threading) must be executed against the previously built runtime
libraries. Support for return stack-safe setjmp/longjmp is provided by the GNU
C library `libc.so.6`, while support for return stack unwinding is provided by
the GCC runtime library `libgcc_s.so`.

In the following, different options of runtime environments are presented. The
test suite is written to support all options.

#### Native Execution

To execute return stack-enabled programs on a native Linux system, it is
easiest to install the GNU C library and GCC into a `sysroot` directory and
provide this directory during compilation and at runtime.

Programs that utilize setjmp/longjmp functionalities (e.g., `setjmp.c` from the
test suite) can be built and executed like this:

```
cd <workspace>/test
export SYSROOT=<path to sysroot>
export LD_PATH=$SYSROOT/<path to ld.so>
export LD_LIBRARY_PATH=$SYSROOT/<path to lib directory>
<path to clang> setjmp.c -O1 -fsanitize=return-stack -fuse-ld=gold -Wl,--dynamic-linker=$LD_PATH --sysroot=$SYSROOT -o setjmp
./setjmp
```

Programs that utilize stack unwinding (e.g., `exception.cpp` and `thread.c`
from the test suite) can be built and executed like this:

```
cd <workspace>/test
export SYSROOT=<path to sysroot>
export LD_PATH=$SYSROOT/<path to ld.so>
export LD_LIBRARY_PATH=$SYSROOT/<path to lib directory>
<path to clang++> exception.cpp -O1 -fsanitize=return-stack -fuse-ld=gold -Wl,--dynamic-linker=$LD_PATH -o exception
./exception
```

**Note** that only `setjmp.c` requires linking against our custom `libc.so.6`
library (hence the `--sysroot` option while compiling) and only `setjmp.c`,
`exception.cpp`, and `thread.c` require the `LD_LIBRARY_PATH` being set
correctly. All other files from the test suite can be built and executed only
specifying the custom dynamic linker.

Further, note that installing the custom libraries on your native Linux system
is **not** recommended.

#### Chroot

Alternatively, the required libraries can be installed into a chroot,
eliminating the need to specify the custom dynamic linker, the sysroot
directory, and the `LD_LIBRARY_PATH` variable to build and execute return
stack-enabled programs.

#### Yocto Linux

For ARM64 embedded devices, it is possible to create fully return stack-aware
Linux environments using the [Yocto Project](https://www.yoctoproject.org/) by
setting `TARGET_CFLAGS += "-ffixed-x28"` in the `local.conf` configuration file
and building with the modified versions of the GNU C library and the GCC
runtime library. Return stack-enabled programs can then be built and executed
without the need to specify the custom dynamic linker, the sysroot directory,
or the `LD_LIBRARY_PATH` variable. Note that this custom Linux environment is
still compatible with legacy programs that do not support return stacks.

## Security

See Section 5 of our [ASIA CCS '18
paper](https://doi.org/10.1145/3196494.3196531).

## Performance

The performance overhead induced by enabling return stacks is negligible, with
an average overhead of **2.72%** on x86-64 and an average gain in performance
of **0.03%** on ARM64.

The performance was evaluated using the [SPEC
CPU2017](https://www.spec.org/cpu2017/) benchmark suite on x86-64 and the
[EEMBC CoreMark](https://www.eembc.org/coremark/) benchmark on ARM64 in
combination with measurements of real world programs, i.e., the
[Apache](https://httpd.apache.org/download.cgi) and
[Nginx](https://nginx.org/en/download.html) web servers.

* Configuration of the SPEC CPU2017 benchmark suite:
  * Iterations: 2
  * C optimization flags: `-Ofast -mavx`
  * CXX optimization flags: `-O3 -mavx`
  * Benchmark set: All C/C++ benchmarks of `intrate`
  * Workload: `refrate`

* Configuration of the EEMBC CoreMark benchmark:
  * Iterations: 25,000
  * C optimization flags: `-O2`

* Configuration of the Apache benchmark:
  * Apache version: 2.4.33
  * APR version: 1.6.3
  * APR-Util version: 1.6.1
  * Compiled with APR `--with-included-apr` and the pre-fork multi-processing
    module `--with-mpm=prefork`
  * C optimization flags: `-O2`
  * Access logging turned off in `httpd.conf`

* Configuration of the Nginx benchmark:
  * Nginx version: 1.13.10
  * Compiled without the Gzip module `--without-http_gzip_module`
  * C optimization flags: `-O2`
  * Access logging turned off in `nginx.conf`
  * Number of worker processes set to `1` in `nginx.conf`

* Web server benchmarking with Apachebench:
  * Requests sent from a remote LAN host
  * Per request transferred a file of 128 bytes (created beforehand from
    `/dev/urandom`)
  * Command line used: `ab -k -n1000000 -c10 http://<IP>/<FILE>`

### x86-64

On x86-64, all evaluations were carried out on an Intel Core i5-7440HQ machine
clocked at a static 2.2 GHz and running Debian Buster with a 4.14.0-3-amd64
Linux kernel.

* Machine-specific configuration of the SPEC CPU2017 benchmark suite:
  * Cores: 4
  * Threads: 1
  * NUMA nodes: 1

| &nbsp;              | Baseline | Return Stack |
|---------------------|:--------:|:------------:|
| **500.perlbench_r** |    570 s |        4.21% |
| **502.gcc_r**       |    411 s |        5.60% |
| **505.mcf_r**       |    623 s |        1.44% |
| **520.omnetpp_r**   |    687 s |        2.04% |
| **523.xalancbmk_r** |    570 s |        0.18% |
| **525.x264_r**      |    393 s |        3.82% |
| **531.deepsjeng_r** |    437 s |        4.35% |
| **541.leela_r**     |    761 s |        7.10% |
| **557.xz_r**        |    562 s |        0.89% |
| **Apache**          | 130.70 s |        0.11% |
| **Nginx**           | 178.54 s |        0.15% |
| **Mean**            | &nbsp;   |    **2.72%** |

### ARM64

On ARM64, all evaluations were carried out on a Raspberry Pi 3 clocked at a
static 600 MHz and running a Yocto Poky Linux distribution.

| &nbsp;       | Baseline | Return Stack |
|--------------|:--------:|:------------:|
| **Coremark** |  16.43 s |       -0.43% |
| **Apache**   | 196.36 s |        0.85% |
| **Nginx**    | 215.98 s |       -0.50% |
| **Mean**     | &nbsp;   |   **-0.03%** |

