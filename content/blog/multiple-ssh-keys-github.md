---
title: "Multiple SSH Keys Github"
date: 2021-01-15T21:58:02+08:00
draft: false
---

## Using multiple SSH keys for Github

1. Create separate SSH keys and add them to appropriate Github account settings. Make sure they are easily distinguishable from each other.

2. Modify the ssh config file ( ~/.ssh/config) or create it if there isn't one.

```
# Personal GitHub account
Host github.com
 HostName github.com
 User git
 AddKeysToAgent yes
 UseKeychain yes
 IdentityFile ~/.ssh/id_rsa

# Work/other GitHub account 
Host workhub
 HostName github.com
 User git
 AddKeysToAgent yes
 UseKeychain yes
 IdentityFile ~/.ssh/work_rsa
```

The `host` alias defined in previous step may now be used to manage repos from both accounts. 
e.g.
git URL without the alias: `git@github.com:<organization>/<project>.git`
with it: `git@workhub:<organization>/<project>.git`
```
$ git clone git@workhub:<organization>/<project>.git
```

Extra: Git can be configured to also swap URLs so that the alias does not need to be specified when
cloning/adding new repositories.
e.g. `~/.gitconfig`
```
[user]
    name = David Ebreo
    email = david@<organization>.com
[core]
    editor = vim
[alias]
    co = checkout
[url "ssh://git@workhub/<organization>"]
    insteadOf = git@github.com/<organization>

```  

Hope that's useful and clear enough. There are more detailed (and probably clearer) instructions out [there](https://xiaolishen.medium.com/use-multiple-ssh-keys-for-different-github-accounts-on-the-same-computer-7d7103ca8693). This here is mainly to jog my memmory when I forget how to do it. 