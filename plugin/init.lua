require "io"

--receive part
function parseCroc(where)
    print(where)
    vim.cmd('au! croc')
    vim.cmd('tabp')
    vim.cmd("'<,'>!cat "..where) --todo check if selection or whole file
end
function startPasterReceive(args)
    where = args.args
    local cmd = "rm "..where..";croc --yes --overwrite "..where
    vim.cmd('augroup croc | exe "au TermClose * lua parseCroc(\''..where..'\')" | augroup END')
    vim.cmd('tabnew | term '..cmd)
end

vim.api.nvim_create_user_command('PasterReceive', function(args)
	startPasterReceive(args)
end, { nargs=1, range=true })

--send part
function send(content,where)
    file = io.open(where, "w")
    io.output(file)
    for k,v in ipairs(content) do
        io.write(v,'\n')
    end
    io.close(file)
    local cmd = "croc send --code "..where.." "..where
    vim.cmd('tabnew | term '..cmd)
    -- vim.cmd('tabp')
end
function startPaster(args)
    if args.range == 0 then
        send(vim.api.nvim_buf_get_lines(0, 0, -1, false), args.args)
    else
        send(vim.api.nvim_buf_get_lines(0, args.line1-1, args.line2, false), args.args)
    end
end

vim.api.nvim_create_user_command('Paster', function(args)
	startPaster(args)
end, { nargs=1, range=true })
