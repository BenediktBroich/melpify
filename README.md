# melpify (alpha)
Automate adding recipes to MELPA. For [emacsmirror](https://emacsmirror.net/stats/melpa.html)

List repos in repos.txt

Features:
 - Create fork
 - Commit workflow
 - Push request workflow

 - Fork MELPA
 - Add recipe
 - Push request for recipe

# Run

```gh auth refresh -h github.com -s delete_repo```

```sh melpify.sh```

## Dependencies

 - gh 
 - git
 - curl
