file (GLOB VALA_SOURCES RELATIVE "${latexila_SOURCE_DIR}/src/" "*.vala")
vala_precompile (
	VALA_C
		${VALA_SOURCES}
	PACKAGES
		gtk+-2.0
		gtksourceview-2.0
		gee-1.0
	CUSTOM_VAPIS
		${latexila_SOURCE_DIR}/vapi/config.vapi
)

add_executable (latexila ${VALA_C})
install (TARGETS latexila DESTINATION "bin")
install (FILES ui.xml DESTINATION ${DATA_DIR}/ui)
