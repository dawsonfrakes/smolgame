#import "Compiler";

build :: () {
    set_build_options_dc(.{do_output=false, write_added_strings=false});

    options := get_build_options();
    options.output_type = .EXECUTABLE;
    options.output_executable_name = "game";
    options.output_path = ".build";
    options.runtime_support_definitions = .OMIT;
    options.additional_linker_arguments = .["-subsystem:windows", "-entry:RawEntryPoint"];

    w := compiler_create_workspace("Primary");
    set_build_options(options, w);
    add_build_file("platform/main.jai", w);
}

#run build();
