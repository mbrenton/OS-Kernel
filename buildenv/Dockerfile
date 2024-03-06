FROM randomdude/gcc-cross-x86_64-elf

RUN apt-get update 
RUN apt-get upgrade -y

#Compile assembly
RUN apt-get install -y nasm

#Xorriso for grub
RUN apt-get install -y xorriso

#Grub for building iso
RUN apt-get install -y grub-pc-bin
RUN apt-get install -y grub-common

#Access to files
VOLUME /root/env

#Start folder
WORKDIR /root/env
