# GLES 3.0 is supported by the GPU but freedreno support of GLES 3.0 in
# Adreno-a3xx is very buggy and crashes the device with anything more complicated
# than a cube.
# Forcing GLES 2.0 until I find what's wrong with freedreno.
# Maybe relevant: https://gitlab.freedesktop.org/mesa/mesa/-/work_items/12634#note_2792052
export MESA_GLES_VERSION_OVERRIDE=2.0
