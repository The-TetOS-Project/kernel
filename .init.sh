# SPDX-License-Identifier: GPL-3.0-or-later
# SPDX-FileCopyrightText: 2026 Wakana Kisarazu <wakanakisarazu.work@gmail.com>
#!/bin/sh


read -p "Git username? " USERNAME
read -p "Git remote? " REMOTE

echo "Setting git remotes..."
git remote set-url origin git@github.com:"$USERNAME"/"$REMOTE".git
git remote set-url --add --push origin git@github.com:"$USERNAME"/"$REMOTE".git
git remote set-url --add --push origin git@gitlab.com:"$USERNAME"/"$REMOTE".git
git remote set-url --add --push origin git@codeberg.org:"$USERNAME"/"$REMOTE".git

echo "Removing .gitkeep files..."
find . -name ".gitkeep" -delete

echo "Removing this script..."
rm -v -- "$0"
