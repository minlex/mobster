# Mobster

Tool for static analysis Android apk files, unpack, disassemble and decompile apk files. After that  mobster collecting statistics from manifests file about permission and search assemble bytecode for dangerous api calls. Which can be used to identify potentially vulnerable applications.

## Installation

Mobster use apktool for unpacking apk,adb for disassembly bytecode  and dex2jar to decompile. You need to set up path  in config.yml   


## Usage

   mobster -c config.yml apkfile

