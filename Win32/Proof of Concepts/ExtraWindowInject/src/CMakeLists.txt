cmake_minimum_required (VERSION 2.8)
project (Injections)

add_definitions(-DUNICODE -D_UNICODE)

set (srcs
	main.cpp
	window_long_inject.cpp
	sysutil.cpp
	pe_hdrs_helper.cpp
)

set (hdrs
	main.h
	ntddk.h
	ntdll_undoc.h
	kernel32_undoc.h
	map_buffer_into_process.h
	target_util.h
	payload.h
	createproc.h
	add_thread.h
	add_apc.h
	patch_ep.h
	patch_context.h
	window_long_inject.h
	enumproc.h
	sysutil.h
	pe_hdrs_helper.h
)

add_executable (Injections ${hdrs} ${srcs})

INSTALL( TARGETS ${PROJECT_NAME} DESTINATION ${CMAKE_INSTALL_PREFIX} COMPONENT ${PROJECT_NAME} )
