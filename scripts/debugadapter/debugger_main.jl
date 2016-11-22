open("C:\\Users\\david\\source\\julia-vscode\\scripts\\debugadapter\\logging.txt", "w") do f
    println(f, "STARTED")
    while true
        s = readline()
        print(f, s)
    end
end
