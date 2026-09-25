# Work around rendering artifacts and crashes in Plasma Mobile and QML apps by
# enabling a debug flag in the Freedreno driver.

export FD_MESA_DEBUG=inorder # Disable reordering for draws/blits

