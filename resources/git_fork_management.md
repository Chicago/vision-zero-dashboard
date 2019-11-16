
The preferred pattern for collaboration is to 

1. fork to your personal repository
2. clone your fork locally
3. do stuff
4. git add \<your files\>
5. git commit
6. git push
7. Open pull request to chicago\vision-zero-dashboard
8. We will merge your work into a branch
9. Eventually we'll pull some branches into master

However, this leads to the very confusing "how do I updated my fork?" question!

There's a very good discussion here:
https://stackoverflow.com/questions/7244321/how-do-i-update-a-github-forked-repository

Which in essence suggests that you add the chicago repository as an upstream branch.  The details:

Add the remote, call it "upstream":

`git remote add upstream https://github.com/whoever/whatever.git`

Fetch all the branches of that remote into remote-tracking branches,
such as upstream/master:

`git fetch upstream`

Make sure that you're on your master branch:

`git checkout master`

Rewrite your master branch so that any commits of yours that
aren't already in upstream/master are replayed on top of that
other branch:

`git rebase upstream/master`

Thanks you @hneaz for documenting!


