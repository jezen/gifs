# gifs.jezenthomas.com

My collection of reaction gifs, served as a single page at
[gifs.jezenthomas.com](https://gifs.jezenthomas.com). Click a gif to
copy its direct link, which unfurls inline in Slack and GitHub.

## Adding a gif

Drop a `.gif` file in the repo root (lowercase, `[a-z0-9._-]` only),
commit, and push. CI regenerates the page and deploys it.

## Local preview

```sh
./build.sh && open _site/index.html
```
