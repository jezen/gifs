#!/bin/sh

# Generates the gifs.jezenthomas.com site into _site/ from the *.gif
# files at the repo root.

set -eu

out=_site

rm -rf "$out"
mkdir -p "$out"

# The page's HTML assumes filenames need no escaping; refuse anything
# outside a conservative character set rather than escape it.
for f in *.gif; do
  case $f in
    *[!a-z0-9._-]*)
      echo "error: filename needs to match [a-z0-9._-]: $f" >&2
      exit 1
      ;;
  esac
done

cp ./*.gif "$out"/
printf 'gifs.jezenthomas.com\n' > "$out/CNAME"

set -- *.gif
n=$#

{
  cat <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>gifs.jezenthomas.com</title>
<meta name="description" content="A collection of $n reaction gifs. Click one to copy its link.">
<meta property="og:title" content="gifs.jezenthomas.com">
<meta property="og:description" content="A collection of $n reaction gifs. Click one to copy its link.">
<style>
:root {
  color-scheme: light dark;
  --bg: #ffffff;
  --fg: #1a1a1a;
  --muted: #6a6a6a;
}
@media (prefers-color-scheme: dark) {
  :root {
    --bg: #16161a;
    --fg: #e8e8e8;
    --muted: #9a9a9a;
  }
}
* { box-sizing: border-box; }
body {
  background: var(--bg);
  color: var(--fg);
  font-family: system-ui, -apple-system, sans-serif;
  max-width: 72rem;
  margin: 0 auto;
  padding: 1.5rem 1rem;
}
header { margin-bottom: 1.5rem; }
h1 { font-size: 1.4rem; margin: 0 0 0.25rem; }
header p { margin: 0; color: var(--muted); }
.grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
  gap: 1rem;
}
.gif {
  margin: 0;
  cursor: pointer;
}
.gif img {
  width: 100%;
  height: 180px;
  object-fit: cover;
  border-radius: 6px;
  display: block;
  background: rgba(128, 128, 128, 0.15);
}
.gif figcaption {
  font-size: 0.85rem;
  color: var(--muted);
  text-align: center;
  padding-top: 0.35rem;
}
.gif.copied figcaption { color: var(--fg); }
footer {
  margin-top: 2rem;
  font-size: 0.85rem;
  color: var(--muted);
}
footer a { color: inherit; }
</style>
</head>
<body>
<header>
<h1>gifs.jezenthomas.com</h1>
<p>$n reaction gifs. Click one to copy its link.</p>
</header>
<main class="grid">
EOF

  for f in *.gif; do
    name=${f%.gif}
    printf '<figure class="gif" data-name="%s" tabindex="0" role="button" aria-label="Copy link to %s"><img src="%s" alt="%s" loading="lazy"><figcaption>%s</figcaption></figure>\n' \
      "$f" "$f" "$f" "$name" "$f"
  done

  cat <<'EOF'
</main>
<footer>
<a href="https://jezenthomas.com">jezenthomas.com</a>
</footer>
<script>
(function () {
  var grid = document.querySelector('.grid');

  function fallbackCopy(text) {
    var ta = document.createElement('textarea');
    ta.value = text;
    ta.style.position = 'fixed';
    ta.style.opacity = '0';
    document.body.appendChild(ta);
    ta.select();
    try { document.execCommand('copy'); } catch (e) {}
    document.body.removeChild(ta);
  }

  function copy(fig) {
    var url = 'https://gifs.jezenthomas.com/' + fig.dataset.name;
    if (navigator.clipboard && navigator.clipboard.writeText) {
      navigator.clipboard.writeText(url).catch(function () { fallbackCopy(url); });
    } else {
      fallbackCopy(url);
    }
    var caption = fig.querySelector('figcaption');
    var original = fig.dataset.name;
    caption.textContent = 'Copied!';
    fig.classList.add('copied');
    clearTimeout(fig._timer);
    fig._timer = setTimeout(function () {
      caption.textContent = original;
      fig.classList.remove('copied');
    }, 1200);
  }

  grid.addEventListener('click', function (e) {
    var fig = e.target.closest('.gif');
    if (fig) copy(fig);
  });

  grid.addEventListener('keydown', function (e) {
    if (e.key !== 'Enter' && e.key !== ' ') return;
    var fig = e.target.closest('.gif');
    if (fig) {
      e.preventDefault();
      copy(fig);
    }
  });
})();
</script>
</body>
</html>
EOF
} > "$out/index.html"

echo "Built $out/index.html with $n gifs."
