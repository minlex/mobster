# Mobster

Tool for static analysis Andoird apk files. This tool unpack, disassemble and decompile apk. After that doing simple collecting statisticc from manifests and assemble bytecode about used android permission and api calls. Which can be used to identify potentialy vulnereable applications.

## Installation

Mobster use apktool for unpacking apk,adb for dissassembly bytecode  and dex2jar to decompile. You need to set up path  in config.yml   


## Usage

mobster -c config.yml apkfile

