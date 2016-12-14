using JSON
include("../languageserver/julia_pkgdir/v0.5/LanguageServer/src/transport.jl")


open("C:\\Users\\anthoff\\source\\julia-vscode\\scripts\\debugadapter\\logging.txt", "w") do f
    println(f, "TIS WORKS")
    seqno = 1

    msg = read_transport_layer(STDIN)
    msg_json = JSON.parse(msg)
    println(f, msg)
    rsp = Dict()
    rsp["seq"] = seqno; seqno+=1
    rsp["request_seq"] = msg_json["seq"]
    rsp["success"] = true
    rsp["command"] = msg_json["command"]
    rsp["type"] = "response"
    rsp["body"] = Dict()
    rsp["body"]["supportsConfigurationDoneRequest"] = "false"
    println(f, JSON.json(rsp))
    write_transport_layer(STDOUT, JSON.json(rsp))

    msg = read_transport_layer(STDIN)
    println(f, msg)
    msg_json = JSON.parse(msg)
    msg_json["command"] == "launch" || error()
    script_path = msg_json["arguments"]["script"]

    if isfile(script_path)    
        rsp = Dict()
        rsp["seq"] = seqno; seqno+=1
        rsp["request_seq"] = msg_json["seq"]
        rsp["success"] = true
        rsp["command"] = msg_json["command"]
        rsp["type"] = "response"
        rsp["body"] = Dict()
        println(f, JSON.json(rsp))
        write_transport_layer(STDOUT, JSON.json(rsp))

        msg = Dict()
        msg["command"] = "runInTerminal"
        msg["type"] = "request"
        msg["seq"] = seqno; seqno+=1
        msg["arguments"] = Dict()
        msg["arguments"]["kind"] = "external" #"external"
        msg["arguments"]["title"] = "something cool"
        msg["arguments"]["cwd"] = dirname(script_path)
        msg["arguments"]["args"] = [joinpath(JULIA_HOME,Base.julia_exename()), script_path]
        write_transport_layer(STDOUT, JSON.json(msg))
    
        msg = read_transport_layer(STDIN)
        println(f, msg)

        msg = Dict()
        msg["event"] = "terminated"
        msg["type"] = "event"
        msg["seq"] = seqno; seqno+=1
        write_transport_layer(STDOUT, JSON.json(msg))
    else
        rsp = Dict()
        rsp["seq"] = seqno; seqno+=1
        rsp["request_seq"] = msg_json["seq"]
        rsp["success"] = false
        rsp["command"] = msg_json["command"]
        rsp["type"] = "response"
        rsp["message"] = "File not found"
        rsp["body"] = Dict()
        rsp["body"]["error"] = Dict()
        rsp["body"]["error"]["id"] = 1
        rsp["body"]["error"]["format"] = "File not found."
        rsp["body"]["error"]["showUser"] = true
        println(f, JSON.json(rsp))
        write_transport_layer(STDOUT, JSON.json(rsp)) 
    end    

    msg = read_transport_layer(STDIN)
    msg_json = JSON.parse(msg)
    println(f, msg)

    if msg_json["command"]=="disconnect"
        rsp = Dict()
        rsp["seq"] = seqno; seqno+=1
        rsp["request_seq"] = msg_json["seq"]
        rsp["success"] = true
        rsp["command"] = msg_json["command"]
        rsp["type"] = "response"
        println(f, JSON.json(rsp))
        write_transport_layer(STDOUT, JSON.json(rsp))
    else
        println(f, "PROBLEMO")
    end        
end
