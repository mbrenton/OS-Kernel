# OS-Kernel

Building environment (in terminal)
Linux:          sudo docker build buildenv -t myos-buildenv
Windows:        docker build buildenv -t myos-buildenv

Running container
Linux or Mac:  sudo docker run --rm -it -v $PWD:/root/env myos-buildenv
Windows:       docker run --rm -it -v %cd%:/root/env myos-buildrnv

Making it
make build-x86_64

*Have to exit out of container before testing in qemu

Running it in qemu
qemu-system-x86_64 -cdrom dist/x86_64/kernel.iso