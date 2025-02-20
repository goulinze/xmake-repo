package("libdeflate")

    set_homepage("https://github.com/ebiggers/libdeflate")
    set_description("libdeflate is a library for fast, whole-buffer DEFLATE-based compression and decompression.")
    set_license("MIT")

    add_urls("https://github.com/ebiggers/libdeflate/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ebiggers/libdeflate.git")
    add_versions("v1.8", "50711ad4e9d3862f8dfb11b97eb53631a86ee3ce49c0e68ec2b6d059a9662f61")

    on_load("windows", function (package)
        if package:config("shared") then
            package:add("defines", "LIBDEFLATE_DLL")
        end
    end)

    on_install("windows", "macosx", "linux", "android", "mingw", function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("deflate")
                set_kind("$(kind)")
                add_files("lib/*.c")
                if is_arch("x86", "i386", "x86_64", "x64") then
                    add_files("lib/x86/*.c")
                elseif is_arch("arm.+") then
                    add_files("lib/arm/*.c")
                else
                    os.raise("unsupported architecture!")
                end
                add_includedirs(".")
                add_headerfiles("libdeflate.h")
                if is_plat("windows") and is_kind("shared") then
                    add_defines("LIBDEFLATE_DLL", "BUILDING_LIBDEFLATE")
                end
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("libdeflate_alloc_compressor", {includes = "libdeflate.h"}))
    end)
