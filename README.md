# Reinstall Windows from Linux

**PROBLEM:** How to install Windows when no KVM or BMC is available

## ipxe

```

apt-get update
apt-get install -y build-essential syslinux mkisofs isolinux liblzma-dev

git clone https://github.com/ipxe/ipxe.git

cd ipxe/src
# Copy and modify chain.ipxe
make bin/ipxe.lkrn EMBED=chain.ipxe
make bin-x86_64-efi/ipxe.efi EMBED=chain.ipxe
```
