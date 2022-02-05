#!/bin/bash

gh repo fork --clone=true "melpa/melpa"

while read p; do

    echo "$p"

    read -n 1 -r -s -p $'Start : Press enter to continue...\n'

    if ! git ls-remote "https://github.com/"$p
    then
        echo $p >> repos_error.txt
        continue
    fi

    gh repo fork "$p" --clone=true

    ghlink=(${p//\// })
    owner=${ghlink[0]}
    repo=${ghlink[1]}
    repoWithoutEL=${repo//\.el/}

    cd "$repo"

    git branch "add-melpazoid-workflow"
    git checkout "add-melpazoid-workflow"

    mkdir -p .github/workflows
    curl -o .github/workflows/melpazoid.yml \
             https://raw.githubusercontent.com/riscy/melpazoid/master/melpazoid.yml

    sed -i 's/"riscy/"'$owner'/g' .github/workflows/melpazoid.yml
    sed -i 's/shx-for-emacs/'$repo'/g' .github/workflows/melpazoid.yml
    sed -i 's/shx/'$repoWithoutEL'/g' .github/workflows/melpazoid.yml
    sed -i -e 's/EXIST_OK/# EXIST_OK/g' .github/workflows/melpazoid.yml

    git add .github/workflows
    git commit -m "Add melpazoid workflow"
    git push --set-upstream origin "add-melpazoid-workflow"

    gh pr create \
       --title "Add a workflow to do all MELPA checks" \
       --body "
Hey,

your package is listed on [emacsmirror](https://emacsmirror.net/stats/melpa.html) as package that should be added to MELPA. I would like to see your package on MELPA, so here is a workflow that will show you all the warnings that need to be fixed before it can be added.

Beep Boop!
" -R $p

    cd ../melpa

    git branch $repo
    git checkout $repo

    echo '('$repoWithoutEL' :fetcher github :repo "'$p'")' > 'recipes/'$repo

    git add "recipes/"$repo
    git commit -m "Add recipe for "$repo
    git push --set-upstream origin $repo
    git checkout master

    gh pr create \
       --title "Add recipe for "$repo \
       --body "
### Brief summary of what the package does

Beep Boop!

### Direct link to the package repository

https://github.com/"$p"

### Your association with the package

Found it on [emacsmirror](https://emacsmirror.net/stats/melpa.html). I created a pull request to add a melpazoid workflow.

### Checklist

<!-- Please confirm with `x`: -->

- [ ] The package is released under a [GPL-Compatible Free Software License](https://www.gnu.org/licenses/license-list.en.html#GPLCompatibleLicenses)
- [ ] I've read [CONTRIBUTING.org](https://github.com/melpa/melpa/blob/master/CONTRIBUTING.org)
- [ ] I've used the latest version of [package-lint](https://github.com/purcell/package-lint) to check for packaging issues, and addressed its feedback
- [ ] My elisp byte-compiles cleanly
- [ ] `M-x checkdoc` is happy with my docstrings
- [ ] I've built and installed the package using the instructions in [CONTRIBUTING.org](https://github.com/melpa/melpa/blob/master/CONTRIBUTING.org)
- [ ] I have confirmed some of these without doing them

<!-- After submitting, please fix any problems the CI reports. -->

" -R $p

    # xdg-open "https://github.com/BenediktBroich/"$repo"/tree/add-melpazoid-workflow"
    # xdg-open "https://melpa.org/#/?q="$repoWithoutEL

    gh repo delete --confirm $p

    cd ..

    rm -rf $repo

    echo $p >> repos_pr_open.txt

done <repos.txt
