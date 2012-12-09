# build tools/mrbcc executable

file(GLOB MRBCC_SRC_C "*.c")
add_executable(mrbcc ${MRBCC_SRC_C})
target_link_libraries(mrbcc libmruby_static ${MRUBY_LIBS})

install(TARGETS mrbcc RUNTIME DESTINATION bin)

# vim: ts=2 sts=2 sw=2 et
