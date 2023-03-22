

local struct = {
    command = "",
    isSucceed = true,
    msg = ""
}


function handleCommandCallback(args)
    if args == nil or args.command == nil then
        return
    end

    doSystemHint(args.msg, args.isSucceed)

end