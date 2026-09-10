# QEMU AArch64 Setup

This guide sets up QEMU on an Ubuntu x86_64 host to run and test AArch64
(ARM64) virtual machines.

## 1. Install QEMU and supporting tools

```bash
sudo apt update
sudo apt install -y \
  qemu-system-arm \
  qemu-efi-aarch64 \
  qemu-utils \
  cloud-image-utils \
  wget
```

Verify the installation:

```bash
qemu-system-aarch64 --version
qemu-img --version
command -v qemu-system-aarch64
```

## 2. Check host acceleration

KVM acceleration is normally unavailable when the host CPU is x86_64 and the
guest CPU is AArch64. Use QEMU software emulation in that case.

```bash
test -e /dev/kvm && echo "KVM available" || echo "Software emulation"
```

If the host itself is AArch64 and KVM is available, add `-accel kvm` to the
QEMU command. On an x86_64 host running an AArch64 guest, do not use it.

## 3. Download an Ubuntu AArch64 cloud image

```bash
mkdir -p "$HOME/qemu/aarch64"
cd "$HOME/qemu/aarch64"

wget -O ubuntu-arm64.img \
  https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-arm64.img

qemu-img info ubuntu-arm64.img
```

Create a writable copy-on-write VM disk:

```bash
qemu-img create -f qcow2 \
  -F qcow2 \
  -b ubuntu-arm64.img \
  vm-arm64.qcow2 \
  20G
```

## 4. Configure cloud-init

Create a test user and enable SSH:

```bash
cat > user-data <<'EOF'
#cloud-config
users:
  - name: ubuntu
    groups: [adm, sudo]
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    lock_passwd: false
    plain_text_passwd: ubuntu
ssh_pwauth: true
package_update: true
EOF

cat > meta-data <<'EOF'
instance-id: aarch64-qemu
local-hostname: aarch64-qemu
EOF

cloud-localds cloud-init.iso user-data meta-data
```

The example password is `ubuntu`; change it for anything beyond local testing.

## 5. Boot the AArch64 VM

Find the installed AArch64 UEFI firmware:

```bash
dpkg -L qemu-efi-aarch64 | grep -E 'AAVMF_CODE|QEMU_EFI|aarch64.*fd$'
```

On current Ubuntu releases, it is commonly:

```text
/usr/share/AAVMF/AAVMF_CODE.fd
```

Start the VM:

```bash
qemu-system-aarch64 \
  -machine virt \
  -cpu max \
  -m 2048 \
  -smp 2 \
  -bios /usr/share/AAVMF/AAVMF_CODE.fd \
  -drive if=virtio,format=qcow2,file=vm-arm64.qcow2 \
  -drive if=virtio,format=raw,file=cloud-init.iso \
  -netdev user,id=net0,hostfwd=tcp::2222-:22 \
  -device virtio-net-device,netdev=net0 \
  -nographic
```

Connect from another terminal:

```bash
ssh -p 2222 ubuntu@127.0.0.1
```

The first boot can take a few minutes while cloud-init initializes the image.
Shut down cleanly inside the VM with:

```bash
sudo poweroff
```

## 6. Verify the guest architecture

Inside the VM:

```bash
uname -m
lscpu | grep -E 'Architecture|Model name'
```

Expected output includes:

```text
aarch64
```

Compile and run a small program:

```bash
sudo apt install -y build-essential
printf '#include <stdio.h>\nint main(void) { puts("AArch64 works"); }\n' > test.c
cc test.c -o test
./test
```

## 7. Run one AArch64 binary with user-mode QEMU

For testing a single ARM64 executable instead of a complete VM:

```bash
sudo apt install -y qemu-user-static
qemu-aarch64-static ./your-aarch64-program
```

## Troubleshooting

### Firmware file not found

```bash
dpkg -L qemu-efi-aarch64 | grep '\.fd$'
```

Use the reported firmware path in the `-bios` argument.

### No console output

Ensure the QEMU command contains `-nographic`. If necessary, add
`console=ttyAMA0` to the guest kernel command line.

### SSH connection refused

Wait for cloud-init to finish and inspect the serial console. Confirm that the
QEMU command contains both the `hostfwd` network option and the
`virtio-net-device` option.

### Slow performance

Software emulation is expected to be slower than native execution. KVM
acceleration requires an AArch64 host with `/dev/kvm` available.
