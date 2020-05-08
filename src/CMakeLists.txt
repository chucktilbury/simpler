project(simpler)

set(LEX_FILE      ${CMAKE_CURRENT_SOURCE_DIR}/scanner.l)
set(LEX_C_SOURCE  ${CMAKE_CURRENT_SOURCE_DIR}/scanner.c)
set(CMD_FILE      ${CMAKE_CURRENT_SOURCE_DIR}/cmdline.l)
set(CMD_C_SOURCE  ${CMAKE_CURRENT_SOURCE_DIR}/cmdline.c)

add_custom_command(OUTPUT ${LEX_C_SOURCE}
        DEPENDS ${LEX_FILE}
        PRE_BUILD
        COMMAND flex -o ${LEX_C_SOURCE} ${LEX_FILE}
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})

add_custom_command(OUTPUT ${CMD_C_SOURCE}
        DEPENDS ${CMD_FILE}
        PRE_BUILD
        COMMAND flex -Pcmd_ -o ${CMD_C_SOURCE} ${CMD_FILE}
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})

add_executable(${PROJECT_NAME}
    errors.c
    hash_table.c
    lists.c
    parser.c
    simpler.c
    stacks.c
    cmdline.c
    scanner.c
)


target_compile_options(${PROJECT_NAME} PRIVATE "-Wall" "-g" "-DTRACE" "-lfl")
