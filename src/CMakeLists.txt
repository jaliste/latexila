file (GLOB vala_sources RELATIVE "${latexila_SOURCE_DIR}/src/" "*.vala")
file (GLOB vapi_files "${latexila_SOURCE_DIR}/vapi/*.vapi")

vala_precompile (
	VALA_C
		${vala_sources}
	PACKAGES
		gtk+-2.0
		gtksourceview-2.0
		#gee-1.0
		unique-1.0
		gdk-x11-2.0
		x11
		posix

# for debugging
#	OPTIONS
#		--debug
	CUSTOM_VAPIS
		${vapi_files}
)

add_executable (latexila ${VALA_C})
install (TARGETS latexila DESTINATION "bin")

file (GLOB UI "*.ui")
install (FILES ui.xml ${UI} DESTINATION ${DATA_DIR}/ui)
