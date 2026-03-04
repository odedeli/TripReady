# Install icons to standard freedesktop locations
# Add this block to your linux/CMakeLists.txt install section

# Desktop entry
install(FILES "${CMAKE_SOURCE_DIR}/packaging/tripready.desktop"
        DESTINATION "${CMAKE_INSTALL_PREFIX}/share/applications")

# Icons at each standard size
foreach(SIZE 16 32 48 64 128 256 512)
  install(FILES "${CMAKE_SOURCE_DIR}/packaging/icons/tripready_${SIZE}.png"
          DESTINATION "${CMAKE_INSTALL_PREFIX}/share/icons/hicolor/${SIZE}x${SIZE}/apps"
          RENAME "tripready.png")
endforeach()

# Scalable placeholder (optional — use if you add an SVG later)
# install(FILES "${CMAKE_SOURCE_DIR}/packaging/icons/tripready.svg"
#         DESTINATION "${CMAKE_INSTALL_PREFIX}/share/icons/hicolor/scalable/apps")
