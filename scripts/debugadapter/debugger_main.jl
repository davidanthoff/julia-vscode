using JSON
include("../languageserver/julia_pkgdir/v0.5/LanguageServer/src/transport.jl")

open("C:\\Users\\david\\source\\julia-vscode\\scripts\\debugadapter\\logging.txt", "w") do f
    println(f, "STARTED")
    msg = read_transport_layer(STDIN)
    msg_json = JSON.parse(msg)
    println(f, msg)
    rsp = Dict()
    rsp["seq"] = msg_json["seq"]
    rsp["request_seq"] = msg_json["seq"]
    rsp["success"] = true
    rsp["command"] = msg_json["command"]
    rsp["type"] = "response"
    rsp["body"] = Dict()
    rsp["body"]["supportsConfigurationDoneRequest"] = "false"
    println(f, JSON.json(rsp))
    write_transport_layer(STDOUT, JSON.json(rsp))

    println(f, "NOW MOVING ON")
    msg = read_transport_layer(STDIN)
    println(f, msg)
    msg_json = JSON.parse(msg)
    msg_json["command"] == "launch" || error()
    if msg_json["arguments"]["noDebug"]==true
        rsp = Dict()
        rsp["seq"] = msg_json["seq"]
        rsp["request_seq"] = msg_json["seq"]
        rsp["success"] = true
        rsp["command"] = msg_json["command"]
        rsp["type"] = "response"
        rsp["body"] = Dict()
        println(f, JSON.json(rsp))
        write_transport_layer(STDOUT, JSON.json(rsp))
    else
        rsp = Dict()
        rsp["seq"] = msg_json["seq"]
        rsp["request_seq"] = msg_json["seq"]
        rsp["success"] = false
        rsp["command"] = msg_json["command"]
        rsp["type"] = "response"
        rsp["message"] = "We don't support debugging yet."
        println(f, JSON.json(rsp))
        write_transport_layer(STDOUT, JSON.json(rsp))
    end

    msg = Dict()
    msg["command"] = "runInTerminal"
    msg["type"] = "request"
    msg["seq"] = 3
    msg["arguments"] = Dict()
    msg["arguments"]["kind"] = "external"
    msg["arguments"]["title"] = "something cool"
    msg["arguments"]["cwd"] = "c:\\"
    msg["arguments"]["args"] = ["C:\\Users\\david\\AppData\\Local\\julia-0.5\\bin\\julia.exe"]
    write_transport_layer(STDOUT, JSON.json(msg))
    
    msg = read_transport_layer(STDIN)
    println(f, msg)

    msg = read_transport_layer(STDIN)
    println(f, msg)
    
    println(f, "DONE")

end
