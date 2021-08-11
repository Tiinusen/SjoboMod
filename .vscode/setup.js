const fs = require('fs')
const path = require('path')

function Main() {
    process.chdir("../System")

    copyFilesFromDirectoryToDirectory("../../System/EditorRes", "EditorRes")




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


Main()
process.exit(1)