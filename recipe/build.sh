#!/bin/bash

mkdir build
cd build

if [[ "$HOST" == "arm64-apple-darwin"* ]];
then
    # Assume ARM Mac
    simdflavors=(ARM_NEON_ASIMD)
else
    # Assume x86
    simdflavors=(SSE2 AVX_256 AVX2_256)
fi

for simdflavor in "${simdflavors[@]}" ; do
  cmake_args=(
    -DSHARED_LIBS_DEFAULT=ON
    -DBUILD_SHARED_LIBS=ON
    -DGMX_PREFER_STATIC_LIBS=NO
    -DGMX_BUILD_OWN_FFTW=OFF
    -DGMX_DEFAULT_SUFFIX=ON
    -DCMAKE_PREFIX_PATH="${PREFIX}"
    -DCMAKE_INSTALL_PREFIX="${PREFIX}"
    -DGMX_SIMD="${simdflavor}"
    -DCMAKE_INSTALL_BINDIR="bin.${simdflavor}"
    -DCMAKE_INSTALL_LIBDIR="lib.${simdflavor}"
    -DGMX_VERSION_STRING_OF_FORK="conda-forge"
    -DGMX_INSTALL_LEGACY_API=ON
    -DGMX_USE_RDTSCP=OFF
  )
  if [[ "$(uname)" != 'Darwin' && "${double}" == "no" ]] ; then
      cmake_args+=(-DGMX_GPU=OpenCL)
  fi
  if [[ "${mpi}" == "nompi" ]]; then
      cmake_args+=(-DGMX_MPI=OFF -DGMX_THREAD_MPI=ON)
  else
      cmake_args+=(-DGMX_MPI=ON)
  fi
  if [[ "${double}" == "yes" ]]; then
      cmake_args+=(-DGMX_DOUBLE=ON)
      cmake_args+=(-DGMX_GPU=OFF)
  else
      cmake_args+=(-DGMX_DOUBLE=OFF)
  fi
  if [[ "${cuda_compiler_version}" != "None" ]]; then
      cmake_args+=(-DGMX_GPU=CUDA)
  fi
  if [[ "$(uname)" == 'Darwin' ]] ; then
      cmake_args+=(-DCMAKE_CXX_FLAGS='-D_LIBCPP_DISABLE_AVAILABILITY')
  fi
  cmake .. "${cmake_args[@]}"
  make -j "${CPU_COUNT}"
  make install
done

if [ "${mpi}" = 'nompi' ] ; then
    if [ "${double}" = 'no' ] ; then
        gmx='gmx'
    else
        gmx='gmx_d'
    fi
else
    if [ "${double}" = 'no' ] ; then
        gmx='gmx_mpi'
    else
        gmx='gmx_mpi_d'
    fi
fi

mkdir -p "${PREFIX}/etc/conda/activate.d"
mkdir -p "${PREFIX}/etc/conda/deactivate.d"
touch "${PREFIX}/bin/${gmx}"
chmod +x "${PREFIX}/bin/${gmx}"

cp "${RECIPE_DIR}/gromacs_deactivate.sh" "${PREFIX}/etc/conda/deactivate.d/"
cp "${RECIPE_DIR}/gromacs_deactivate.csh" "${PREFIX}/etc/conda/deactivate.d/"

case "$OSTYPE" in
    darwin*)    hardware_info_command="sysctl -a | grep '^hw.optional\..*: 1$'"
                ;;
    *)          hardware_info_command="cat /proc/cpuinfo | grep -m1 '^flags'"
                ;;
esac

{ cat <<EOF
#! /bin/bash

function _gromacs_bin_dir() {
  local simdflavor
  local uname=\$(uname -m)
  if [[ "\$uname" == "arm64" ]]; then
    # Assume ARM Mac
    test -d "${PREFIX}/bin.ARM_NEON_ASIMD" && simdflavor='ARM_NEON_ASIMD'
  else
    simdflavor='SSE2'
    case \$( ${hardware_info_command} ) in
      *\ avx2\ * | *avx2_0*)
        test -d "${PREFIX}/bin.AVX2_256" && simdflavor='AVX2_256'
      ;;
      *\ avx\ * | *avx1_0*)
        test -d "${PREFIX}/bin.AVX_256" && simdflavor='AVX_256'
    esac
  fi
  printf '%s' "${PREFIX}/bin.\${simdflavor}"
}

EOF
} | tee "${PREFIX}/bin/${gmx}" > "${PREFIX}/etc/conda/activate.d/gromacs_activate.sh"

cat >> "${PREFIX}/etc/conda/activate.d/gromacs_activate.sh" <<EOF
. "\$( _gromacs_bin_dir )/GMXRC" "\${@}"
EOF

cat >> "${PREFIX}/bin/${gmx}" <<EOF
exec "\$( _gromacs_bin_dir )/${gmx}" "\${@}"
EOF

{ cat <<EOF
#! /bin/tcsh

setenv uname_m \`uname -m\`
if ( \$uname_m == "arm64" && -d "${PREFIX}/bin.ARM_NEON_ASIMD" ) then
    setenv simdflavor ARM_NEON_ASIMD
else

    setenv hwlist \`${hardware_info_command}\`

    if ( \`echo \$hwlist | grep -c 'avx512f'\` > 0 && -d "${PREFIX}/bin.AVX_512" && \`"${PREFIX}/bin.AVX_512/identifyavx512fmaunits" | grep -c 2\` > 0 ) then
        setenv simdflavor AVX_512
    else 
        if ( \`echo \$hwlist | grep -c avx2\` > 0 && -d "${PREFIX}/bin.AVX2_256" ) then
            setenv simdflavor AVX2_256
        else
            if ( \`echo \$hwlist | grep -c avx\` > 0 && -d "${PREFIX}/bin.AVX_256" ) then
                setenv simdflavor AVX_256
            else
                setenv simdflavor SSE2
            endif
        endif
    endif
endif

source "${PREFIX}/bin.\$simdflavor/GMXRC"

EOF
} > "${PREFIX}/etc/conda/activate.d/gromacs_activate.csh"
