function process(r::Request{Val{Symbol("textDocument/signatureHelp")},TextDocumentPositionParams}, server)
    (r::Request{Val{Symbol("textDocument/signatureHelp")},TextDocumentPositionParams}, server)
    tdpp = r.params
    if isempty(server.last_sig) # initializing sig helper
        word = get_word(tdpp, server,-1)
        x = get_sym(word)
        M = methods(x).ms

        sigs = map(M) do m
            tv, decls, file, line = Base.arg_decl_parts(m)
            p_sigs = [isempty(i[2]) ? i[1] : i[1]*"::"*i[2] for i in decls[2:end]]
            desc = string(string(m.name), "(",join(p_sigs, ", "),")")

            PI = map(ParameterInformation,p_sigs)
            # Extract documentation here
            doc = ""
            return SignatureInformation(desc,doc,PI)
        end
        # TODO pass in the correct argument position
        signatureHelper = SignatureHelp(sigs,0,0)
        push!(server.last_sig,signatureHelper)
        response = Response(get(r.id),signatureHelper)
    else # still handling old sig helper
        signatureHelper = server.last_sig[end]
        actP = signatureHelper.activeParameter+1
        actSigParamlength = length(signatureHelper.signatures[signatureHelper.activeSignature+1].parameters)
        response = Response(get(r.id),signatureHelper)
        line = get_line(tdpp, server)
        pos = tdpp.position.character
        if line[pos] == ',' #assume still in sig, will break if pasting of string with ',' into brackets 
            signatureHelper.activeParameter+=1
            response = Response(get(r.id),signatureHelper)
        elseif (actP>actSigParamlength) || (actP==actSigParamlength && line[pos] == ')') || (line[pos] == ')') # last comparison is to be safe
            empty!(server.last_sig)
            response = Response(get(r.id),CancelParams(Dict("id"=>get(r.id))))
        end
    end

    send(response,server)
end

function JSONRPC.parse_params(::Type{Val{Symbol("textDocument/signatureHelp")}}, params)
    return TextDocumentPositionParams(params)
end

Z(a,b) = a