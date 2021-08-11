const fs = require('fs')
const path = require('path')

let modName = path.basename(process.cwd())

function Main() {
    process.chdir("System")
    let args = process.argv
    args.shift()
    args.shift()

    if(!fs.existsSync("../../Postal2Game")){
        console.error("You have not yet unpacked the POSTAL 2 UnrealScript Source\nDo it manually or use VSCode Task \"Unpack\"")
        process.exit(1)
    }

    if(args.length >= 1 && args[0] == "--clean"){
        deleteFilesFromDirectory("EditorRes")
        deleteFilesFromDirectory(".", [
            /\.exe$/,
            /\.dll$/,
            /\.ini$/,
            /\.int$/,
            /\.u$/,
            /\.log$/,
            /\.txt$/,
            /\.bmp$/
        ])
        return
    }

    copyFilesFromDirectoryToDirectory("../../System/EditorRes", "EditorRes")
    copyFilesFromDirectoryToDirectory("../../System", ".", [
        /\.exe$/,
        /\.dll$/,
        /\.ini$/,
        /\.int$/,
        /\.u$/,
        /\.log$/,
        /\.txt$/,
        /\.bmp$/
    ])
    fs.copyFileSync(modName+".default.ini", "Postal2.ini")

    let initxt = fs.readFileSync(modName+".default.ini").toString()
    initxt = initxt.replace(/\.\.\\\.\.\\/g, "..\\")
    fs.writeFileSync(modName+".ini", initxt)

}

function copyFilesFromDirectoryToDirectory(source, destination = "", includeRegexps = []) {
    if (!fs.existsSync(source)) {
        console.error("\"" + source + "\" does not exist on file system")
        process.exit(1)
    }
    if (!fs.existsSync(destination)) {
        fs.mkdirSync(destination)
    }
    files = fs.readdirSync(source)
    files.forEach((file) => {
        var fromPath = path.resolve(source, file)
        var toPath = path.resolve(destination, file)

        if (fs.existsSync(fromPath) && fs.existsSync(toPath)) {
            return
        }
        

        let stat = fs.statSync(fromPath)
        if(stat.isDirectory()){
            return
        }

        if(includeRegexps !== null && includeRegexps.length > 0){
            let matched = false
            includeRegexps.forEach((regexp) => {
                if(matched || regexp.test(file)){
                    matched = true
                }
            })
            if(!matched){
                return
            }
        }

        fs.copyFileSync(fromPath, toPath)
    });
}

function deleteFilesFromDirectory(source, includeRegexps = []) {
    if (!fs.existsSync(source)) {
        return
    }
    files = fs.readdirSync(source)
    files.forEach((file) => {
        var sourcePath = path.resolve(source, file)

        if(file.indexOf(modName) !== -1 || file == "Postal2.ini"){
            return
        }

        let stat = fs.statSync(sourcePath)
        if(stat.isDirectory()){
            return
        }

        if(includeRegexps !== null && includeRegexps.length > 0){
            let matched = false
            includeRegexps.forEach((regexp) => {
                if(matched || regexp.test(file)){
                    matched = true
                }
            })
            if(!matched){
                return
            }
        }
        fs.unlinkSync(sourcePath)
    });
    if(includeRegexps === null || includeRegexps.length == 0){
        fs.rmdirSync(source)
    }
}


Main()