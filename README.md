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
curl -OL# https://raw.githubusercontent.com/rjsocha/windows-install-from-linux/refs/heads/master/ipxe/embed/chain.ipxe
make bin/ipxe.lkrn EMBED=chain.ipxe
make bin-x86_64-efi/ipxe.efi EMBED=chain.ipxe
```

Copy bin/ipxe.lkrn and bin-x86_64-efi/ipxe.efi:
```
cp bin/ipxe.lkrn /boot/ipxe-chain.bios
cp bin-x86_64-efi/ipxe.efi /boot/ipxe-chain.efi
```

## Prepare HTTP server

Download Windows Server 2025 Evaluation ISO:

```
  curl -OL# https://software-static.download.prss.microsoft.com/dbazure/888969d5-f34g-4e03-ac9d-1f9786c66749/26100.1742.240906-0331.ge_release_svc_refresh_SERVER_EVAL_x64FRE_en-us.iso
```


Download Windows Server 2022 Evaluation ISO:

```
  curl -OL# https://software-static.download.prss.microsoft.com/sg/download/888969d5-f34g-4e03-ac9d-1f9786c66749/SERVER_EVAL_x64FRE_en-us.iso
```

Extract **bcd** and **boot.sdi** from ISO:

```
mkdir extract boot
sudo mount -o loop SERVER_EVAL_x64FRE_en-us.iso extract/
cp extract/boot/bcd boot/
cp extract/boot/boot.sdi boot/
sudo umount extract && rm -rf -- extract
```

Download **wimboot**:
```
curl -OL# https://github.com/ipxe/wimboot/releases/latest/download/wimboot
```

## Prepare boot.wim (Under Windows OS)

Download or copy Windows Server 2022 Evaluation ISO and extrat boot.wim from **sources/boot.wim**

Mount boot.wim and copy files from **dism** directory. Modify **auto.cmd** and set INSTALL variable:

```
mkdir boot
dism /mount-wim /wimfile:boot.wim /index:2 /mountdir:boot
xcopy /s dism\ boot\
dism /unmount-wim /mountdir:boot /commit
```

Copy modified **boot.wim** to HTTP server (to the same place where **bcd** and **boot.sdi** files were copied)


# Boot

## Modify grub.cfg (add as first entry)

```
menuentry 'windows-install' {
  insmod part_gpt
  insmod part_msdos
  insmod ext2
  if [ "$grub_platform" = "efi" ]; then
    chainloader /ipxe-chain.efi
  else
    linux16 /ipxe-chain.bios
  fi
}
```
