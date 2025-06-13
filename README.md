# Reinstall Windows from Linux

**PROBLEM:** How to install Windows when no KVM or BMC is available

## ipxe

```
apt-get update
apt-get install -y build-essential syslinux mkisofs isolinux liblzma-dev
```

```
git clone https://github.com/ipxe/ipxe.git
cd ipxe/src
make
```

```
# Copy and modify chain.ipxe
curl -OL# https://raw.githubusercontent.com/rjsocha/windows-install-from-linux/refs/heads/master/ipxe/chain.ipxe
make bin/ipxe.lkrn EMBED=chain.ipxe
make bin-x86_64-efi/ipxe.efi EMBED=chain.ipxe
```

Copy bin/ipxe.lkrn and bin-x86_64-efi/ipxe.efi:
```
cp bin/ipxe.lkrn /boot/ipxe-chain.bios
cp bin-x86_64-efi/ipxe.efi /boot/ipxe-chain.efi
```
