# Cursor Settings

My Cursor editor configuration.

## Contents

- `settings.json` — editor settings (vim bindings, theme, language configs)
- `keybindings.json` — custom keybindings
- `extensions.txt` — installed extensions list

## Restore

```bash
# Clone
git clone https://github.com/tomvonheill/cursor-settings.git
cd cursor-settings

# Copy settings
cp settings.json ~/Library/Application\ Support/Cursor/User/settings.json
cp keybindings.json ~/Library/Application\ Support/Cursor/User/keybindings.json

# Install extensions
cat extensions.txt | xargs -L 1 cursor --install-extension
```

## Update

```bash
# From this repo directory
cp ~/Library/Application\ Support/Cursor/User/settings.json settings.json
cp ~/Library/Application\ Support/Cursor/User/keybindings.json keybindings.json
cursor --list-extensions > extensions.txt
git add -A && git commit -m "Update settings" && git push
```
