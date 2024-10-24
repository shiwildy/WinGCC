#!/bin/bash

# Set script as eux
set -eux

# >> install requirements
apt install ca-certificates libgmp-dev zip \
libmpc-dev libmpfr-dev libisl-dev xz-utils unzip \
texinfo patch bzip2 p7zip cmake make curl m4 gcc g++ -y

mkdir -p /build-gcc
SOURCE="/build-gcc/source"
BUILD="/build-gcc/build/x86_64-w64-mingw32"
mkdir -p $SOURCE
cd $SOURCE

# >> Include
echo "Build for 1.0.0
-----------------------
ZSTD 1.5.5
GMP 6.3.0
MPFR 4.2.1
MPC 1.3.1
ISL 0.26
EXPAT 2.5.0
BINUTILS 2.41
GCC 14.2.0
MINGW 11.0.1
GDB 13.2
MAKE 4.4
"

wget -O zstd.tar.gz 'https://github.com/facebook/zstd/releases/download/v1.5.5/zstd-1.5.5.tar.gz'
tar -xvf zstd.tar.gz && rm zstd.tar.gz

wget -O gmp.tar.xz 'https://ftp.gnu.org/gnu/gmp/gmp-6.3.0.tar.xz'
tar -xvf gmp.tar.xz && rm gmp.tar.xz

wget -O mpfr.tar.xz 'https://ftp.gnu.org/gnu/mpfr/mpfr-4.2.1.tar.xz'
tar -xvf mpfr.tar.xz && rm mpfr.tar.xz

wget -O mpc.tar.gz 'https://ftp.gnu.org/gnu/mpc/mpc-1.3.1.tar.gz'
tar -xvf mpc.tar.gz && rm mpc.tar.gz

wget -O isl.tar.xz 'https://libisl.sourceforge.io/isl-0.26.tar.xz'
tar -xvf isl.tar.xz && rm isl.tar.xz

wget -O expat.tar.xz 'https://github.com/libexpat/libexpat/releases/download/R_2_5_0/expat-2.5.0.tar.xz'
tar -xvf expat.tar.xz && rm expat.tar.xz

wget -O binutils.tar.xz 'https://ftp.gnu.org/gnu/binutils/binutils-2.41.tar.xz'
tar -xvf binutils.tar.xz && rm binutils.tar.xz

wget -O gcc.tar.xz 'https://ftp.gnu.org/gnu/gcc/gcc-14.2.0/gcc-14.2.0.tar.xz'
tar -xvf gcc.tar.xz && rm gcc.tar.xz

wget -O mingw.zip 'https://onboardcloud.dl.sourceforge.net/project/mingw-w64/mingw-w64/mingw-w64-release/mingw-w64-v11.0.1.zip'
unzip -o mingw.zip && rm mingw.zip

wget -O gdb.tar.xz 'https://ftp.gnu.org/gnu/gdb/gdb-13.2.tar.xz'
tar -xvf gdb.tar.xz && rm gdb.tar.xz

wget -O make.tar.gz 'https://ftp.gnu.org/gnu/make/make-4.4.tar.gz'
tar -xvf make.tar.gz && rm make.tar.gz

# >> Build binutils
# =============================

# >> Create directory for binutils build
mkdir -p ${BUILD}/x-binutils
cd ${BUILD}/x-binutils

# >> Start build
/build-gcc/source/binutils-2.41/configure                   \
  --prefix="/build-gcc/bootstrap/x86_64-w64-mingw32"        \
  --with-sysroot="/build-gcc/bootstrap/x86_64-w64-mingw32"  \
  --target="x86_64-w64-mingw32"                             \
  --disable-plugins                                         \
  --disable-nls                                             \
  --disable-shared                                          \
  --disable-multilib                                        \
  --disable-werror
make -j 8 && make install


# >> Build mingw headers
# ====================================

# >> Create directory for building
mkdir -p ${BUILD}/x-mingw-w64-headers
cd ${BUILD}/x-mingw-w64-headers

# >> Start build
/build-gcc/source/mingw-w64-v11.0.1/mingw-w64-headers/configure   \
  --prefix="/build-gcc/bootstrap/x86_64-w64-mingw32"              \
  --host="x86_64-w64-mingw32"
make -j 8 && make install
ln -sTf /build-gcc/bootstrap/x86_64-w64-mingw32 /build-gcc/bootstrap/x86_64-w64-mingw32/mingw


# >> Build gcc
# ==================================

# >> Create directory for gcc building
mkdir -p ${BUILD}/x-gcc
cd ${BUILD}/x-gcc

# >> Start build
/build-gcc/source/gcc-14.2.0/configure                       \
  --prefix="/build-gcc/bootstrap/x86_64-w64-mingw32"         \
  --with-sysroot="/build-gcc/bootstrap/x86_64-w64-mingw32"   \
  --target="x86_64-w64-mingw32"                              \
  --enable-static                                            \
  --disable-shared                                           \
  --disable-lto                                              \
  --disable-nls                                              \
  --disable-multilib                                         \
  --disable-werror                                           \
  --disable-libgomp                                          \
  --enable-languages=c,c++                                   \
  --enable-threads=posix                                     \
  --enable-checking=release                                  \
  --enable-large-address-aware                               \
  --disable-libstdcxx-pch                                    \
  --disable-libstdcxx-verbose                                \
  --with-pkgversion="WinGCC | 1.0.0"
make all-gcc -j 8 && make install-gcc

# >> adding path environment
export PATH=/build-gcc/bootstrap/x86_64-w64-mingw32/bin:$PATH


# >> Build mingw crt
# ===================================

# >> Create directory for building
mkdir -p ${BUILD}/x-mingw-w64-crt
cd ${BUILD}/x-mingw-w64-crt

# >> Start build
/build-gcc/source/mingw-w64-v11.0.1/mingw-w64-crt/configure   \
  --prefix="/build-gcc/bootstrap/x86_64-w64-mingw32"          \
  --with-sysroot="/build-gcc/bootstrap/x86_64-w64-mingw32"    \
  --host="x86_64-w64-mingw32"                                 \
  --disable-dependency-tracking                               \
  --enable-warnings=0                                         \
  --disable-lib32
make -j 8 && make install


# >> Build mingw winpthreads
# ================================

# >> Create directory for building
mkdir -p ${BUILD}/x-mingw-w64-winpthreads
cd ${BUILD}/x-mingw-w64-winpthreads

# >> Start build
/build-gcc/source/mingw-w64-v11.0.1/mingw-w64-libraries/winpthreads/configure   \
  --prefix="/build-gcc/bootstrap/x86_64-w64-mingw32"                            \
  --with-sysroot="/build-gcc/bootstrap/x86_64-w64-mingw32"                      \
  --host="x86_64-w64-mingw32"                                                   \
  --disable-dependency-tracking                                                 \
  --enable-static                                                               \
  --disable-shared
make -j 8 && make install


# >> Rebuilding gcc
# =======================================
cd ${BUILD}/x-gcc
make -j 8 && make install


# >> Build zstd
# ===============================

# >> Create directory for building
mkdir -p ${BUILD}/zstd
cd ${BUILD}/zstd

# >> Start build
cmake /build-gcc/source/zstd-1.5.5/build/cmake                   \
  -DCMAKE_BUILD_TYPE=Release                                     \
  -DCMAKE_SYSTEM_NAME=Windows                                    \
  -DCMAKE_INSTALL_PREFIX="/build-gcc/prefix/x86_64-w64-mingw32"  \
  -DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM=NEVER                      \
  -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY                       \
  -DCMAKE_C_COMPILER="x86_64-w64-mingw32-gcc"                    \
  -DCMAKE_CXX_COMPILER="x86_64-w64-mingw32-g++"                  \
  -DZSTD_BUILD_STATIC=ON                                         \
  -DZSTD_BUILD_SHARED=OFF                                        \
  -DZSTD_BUILD_PROGRAMS=OFF                                      \
  -DZSTD_BUILD_CONTRIB=OFF                                       \
  -DZSTD_BUILD_TESTS=OFF
make -j 8 && make install


# >> Build gmp
# =================================

# >> Create directory for building
mkdir -p ${BUILD}/gmp
cd ${BUILD}/gmp

# >> Start build
/build-gcc/source/gmp-6.3.0/configure             \
  --prefix="/build-gcc/prefix/x86_64-w64-mingw32" \
  --host="x86_64-w64-mingw32"                     \
  --disable-shared                                \
  --enable-static                                 \
  --enable-fat
make -j 8 && make install


# >> Build mpfr
# =================================

# >> Create directory for building
mkdir -p ${BUILD}/mpfr
cd ${BUILD}/mpfr

# >> Start build
/build-gcc/source/mpfr-4.2.1/configure                         \
  --prefix="/build-gcc/prefix/x86_64-w64-mingw32"              \
  --host="x86_64-w64-mingw32"                                  \
  --disable-shared                                             \
  --enable-static                                              \
  --with-gmp-build="/build-gcc/build/x86_64-w64-mingw32/gmp"
make -j 8 && make install


# >> Build mpc
# =========================

# >> Create directory for building
mkdir -p ${BUILD}/mpc
cd ${BUILD}/mpc

/build-gcc/source/mpc-1.3.1/configure                      \
  --prefix="/build-gcc/prefix/x86_64-w64-mingw32"          \
  --host="x86_64-w64-mingw32"                              \
  --disable-shared                                         \
  --enable-static                                          \
  --with-{gmp,mpfr}="/build-gcc/prefix/x86_64-w64-mingw32"
make -j 8 && make install


# >> Build isl
# =========================

# >> Create directory for building
mkdir -p ${BUILD}/isl
cd ${BUILD}/isl

# >> Start build
/build-gcc/source/isl-0.26/configure                       \
  --prefix="/build-gcc/prefix/x86_64-w64-mingw32"          \
  --host="x86_64-w64-mingw32"                              \
  --disable-shared                                         \
  --enable-static                                          \
  --with-gmp-prefix="/build-gcc/prefix/x86_64-w64-mingw32"
make -j 8 && make install


# >> Building expat
# =============================

# >> Create folder for building
mkdir -p ${BUILD}/expat
cd ${BUILD}/expat

# >> Start build
/build-gcc/source/expat-2.5.0/configure                    \
  --prefix="/build-gcc/prefix/x86_64-w64-mingw32"          \
  --host="x86_64-w64-mingw32"                              \
  --disable-shared                                         \
  --enable-static                                          \
  --without-examples                                       \
  --without-tests
make -j 8 && make install


# >> Build binutils
# ===========================

# >> Create folder for building
mkdir -p ${BUILD}/binutils
cd ${BUILD}/binutils

# >> Start build
/build-gcc/source/binutils-2.41/configure                              \
  --prefix="/build-gcc/final-result"                                   \
  --with-sysroot="/build-gcc/final-result"                             \
  --host="x86_64-w64-mingw32"                                          \
  --target="x86_64-w64-mingw32"                                        \
  --enable-lto                                                         \
  --enable-plugins                                                     \
  --enable-64-bit-bfd                                                  \
  --disable-nls                                                        \
  --disable-multilib                                                   \
  --disable-werror                                                     \
  --with-{gmp,mpfr,mpc,isl}="/build-gcc/prefix/x86_64-w64-mingw32"
make -j 8 && make install


# >> Build mingw headers
# =============================

# >> Create directory for building
mkdir -p ${BUILD}/mingw-w64-headers
cd ${BUILD}/mingw-w64-headers

# >> Start build
/build-gcc/source/mingw-w64-v11.0.1/mingw-w64-headers/configure   \
  --prefix="/build-gcc/final-result/x86_64-w64-mingw32"           \
  --host="x86_64-w64-mingw32"
make -j 8 && make install
ln -sTf /build-gcc/final-result/x86_64-w64-mingw32 /build-gcc/final-result/mingw


# >> Build mingw crt
# =============================

# >> Create directory for building
mkdir -p ${BUILD}/mingw-w64-crt
cd ${BUILD}/mingw-w64-crt

# >> Start build
/build-gcc/source/mingw-w64-v11.0.1/mingw-w64-crt/configure     \
  --prefix="/build-gcc/final-result/x86_64-w64-mingw32"         \
  --with-sysroot="/build-gcc/final-result/x86_64-w64-mingw32"   \
  --host="x86_64-w64-mingw32"                                   \
  --disable-dependency-tracking                                 \
  --enable-warnings=0                                           \
  --disable-lib32
make -j 8 && make install


# >> Build gcc
# =======================

# >> Create directory for building
mkdir -p ${BUILD}/gcc
cd ${BUILD}/gcc

# >> Start build
/build-gcc/source/gcc-14.2.0/configure                                   \
  --prefix="/build-gcc/final-result"                                     \
  --with-sysroot="/build-gcc/final-result"                               \
  --target="x86_64-w64-mingw32"                                          \
  --host="x86_64-w64-mingw32"                                            \
  --disable-dependency-tracking                                          \
  --disable-nls                                                          \
  --disable-multilib                                                     \
  --disable-werror                                                       \
  --disable-shared                                                       \
  --enable-static                                                        \
  --enable-lto                                                           \
  --enable-languages=c,c++,lto                                           \
  --enable-libgomp                                                       \
  --enable-threads=posix                                                 \
  --enable-checking=release                                              \
  --enable-mingw-wildcard                                                \
  --enable-large-address-aware                                           \
  --disable-libstdcxx-pch                                                \
  --disable-libstdcxx-verbose                                            \
  --disable-win32-registry                                               \
  --with-tune=intel                                                      \
  --with-pkgversion="WinGCC | 1.0.0"                                     \
  --with-{gmp,mpfr,mpc,isl,zstd}="/build-gcc/prefix/x86_64-w64-mingw32"
make -j 8 && make install


# >> Build mingw winpthreads
# ================================

# >> Create directory for building
mkdir -p ${BUILD}/mingw-w64-winpthreads
cd ${BUILD}/mingw-w64-winpthreads

# >> Start build
/build-gcc/source/mingw-w64-v11.0.1/mingw-w64-libraries/winpthreads/configure   \
  --prefix="/build-gcc/final-result/x86_64-w64-mingw32"                         \
  --with-sysroot="/build-gcc/final-result/x86_64-w64-mingw32"                   \
  --host="x86_64-w64-mingw32"                                                   \
  --disable-dependency-tracking                                                 \
  --disable-shared                                                              \
  --enable-static
make -j 8 && make install


# >> Build gdb
# =====================================

# >> Create directory for building
mkdir -p ${BUILD}/gdb
cd ${BUILD}/gdb

# >> Start build
/build-gcc/source/gdb-13.2/configure                              \
  --prefix="/build-gcc/final-result"                              \
  --host="x86_64-w64-mingw32"                                     \
  --enable-64-bit-bfd                                             \
  --disable-werror                                                \
  --with-mpfr                                                     \
  --with-expat                                                    \
  --with-libgmp-prefix="/build-gcc/prefix/x86_64-w64-mingw32"     \
  --with-libmpfr-prefix="/build-gcc/prefix/x86_64-w64-mingw32"    \
  --with-libexpat-prefix="/build-gcc/prefix/x86_64-w64-mingw32"
make -j 8
cp gdb/.libs/gdb.exe gdbserver/gdbserver.exe /build-gcc/final-result/bin/


# >> Build make
# =======================================

# >> Create directory for building
mkdir -p ${BUILD}/make
cd ${BUILD}/make

# >> Start build
/build-gcc/source/make-4.4/configure              \
  --prefix="/build-gcc/final-result"              \
  --host="x86_64-w64-mingw32"                     \
  --disable-nls                                   \
  --disable-rpath                                 \
  --enable-case-insensitive-file-system
make -j 8 && make install

# >> Remove used files
rm -rf /build-gcc/final-result/bin/x86_64-w64-mingw32-*
rm -rf /build-gcc/final-result/bin/ld.bfd.exe /build-gcc/final-result/x86_64-w64-mingw32/bin/ld.bfd.exe
rm -rf /build-gcc/final-result/lib/bfd-plugins/libdep.dll.a
rm -rf /build-gcc/final-result/share
rm -rf /build-gcc/final-result/mingw

# >> Triming files output
for ext in "exe" "dll" "o" "a"; do
  find /build-gcc/final-result -name "*.${ext}" -print0 | xargs -0 -n 8 -P 2 x86_64-w64-mingw32-strip --strip-unneeded
done

# >> Done success
sleep 2
cd /build-gcc/final-result
zip -r result.zip *
cp result.zip /root/
