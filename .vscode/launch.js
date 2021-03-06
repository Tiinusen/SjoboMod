const fs = require('fs')
const path = require('path')
const exec = require('child_process').execFile

let args = process.argv
args.shift()
args.shift()

let modName = path.basename(process.cwd())

if(args.length == 0){
    console.error("Argument required")
    process.exit(1)
}

if(args[0] === "POSTed"){6
    process.chdir('System')
    exec('UnrealED.exe')
}else if(args[0] === "Postal2"){
    process.chdir('../System')
    if(args.length >= 2){
        exec('Postal2',[args[1],'INI=../'+modName+'/System/'+modName+".ini",'USERINI=../'+modName+'/System/'+modName+".user.ini",'-log', '-windowed','-nosteam'])
    }else{
        exec('Postal2',['INI=../'+modName+'/System/'+modName+".ini",'USERINI=../'+modName+'/System/'+modName+".user.ini",'-log', '-windowed','-nosteam'])
    }

}