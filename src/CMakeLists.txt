project(simpler)

set(LEX_FILE      ${CMAKE_CURRENT_SOURCE_DIR}/scanner.l)
set(LEX_C_SOURCE  ${CMAKE_CURRENT_SOURCE_DIR}/scanner.c)
set(YACC_FILE     ${CMAKE_CURRENT_SOURCE_DIR}/parser.y)
set(YACC_C_SOURCE ${CMAKE_CURRENT_SOURCE_DIR}/parser.c)
set(YACC_H        ${PROJECT_INCLUDE_DIRECTORY}/parser.h)

add_custom_command(OUTPUT ${LEX_C_SOURCE}
        DEPENDS ${LEX_FILE}
        PRE_BUILD
        COMMAND flex -o ${LEX_C_SOURCE} ${LEX_FILE}
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})

add_custom_command(OUTPUT ${YACC_C_SOURCE}
        DEPENDS ${YACC_FILE}
        PRE_BUILD
        COMMAND bison --report=lookahead -tvdo ${YACC_C_SOURCE} ${YACC_FILE}
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})

add_executable(${PROJECT_NAME}
    configure.c
    scanner.c
    parser.c
    errors.c
    hash_table.c
    lists.c
    simpler.c
    stacks.c
)

set_property(DIRECTORY PROPERTY ADDITIONAL_MAKE_CLEAN_FILES
    "${CMAKE_CURRENT_SOURCE_DIR}/parser.h"
    "${CMAKE_CURRENT_SOURCE_DIR}/parser.output"
)

target_compile_options(${PROJECT_NAME} PRIVATE "-Wall" "-Wextra" "-g" "-D_DEBUGGING" )
