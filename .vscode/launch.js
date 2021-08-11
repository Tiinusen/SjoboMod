const fs = require('fs')

var exec = require('child_process').execFile;

let modName = "SjoboMod"

process.exit(0)

let args = process.argv
args.shift()
args.shift()
process.chdir('../../../System')
console.log("Starting Postal 2 with map \""+args[0]+"\"")
if(args.length >= 2){
    exec('Postal2',[args[0],'INI=../'+modName+'/System/'+modName+".ini",'USERINI=../'+modName+'/System/'+modName+".user.ini",'-log', '-windowed','-nosteam'], function(err, data) {                       
    })
}else if(args.length >= 1){
    exec('Postal2',[args[0],'-log','-windowed','-nosteam'], function(err, data) {                        
    })
}else{
    console.error("requires atleast one argument")
}