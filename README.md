# Dev Settings

My development environment configuration.

## Quick Setup

```bash
git clone https://github.com/tomvonheill/dev-settings.git
cd dev-settings
chmod +x setup.sh
./setup.sh
```

The setup script will:
- Install brew dependencies (zsh-vi-mode, nvm, gh, tmux, vim)
- Install Oh My Zsh if missing
- Back up existing configs (as `.bak`) and install new ones
- Install Cursor extensions
- Install NVM

## What's Included

```
cursor/
  settings.json        # Editor settings (vim bindings, theme, formatters)
  keybindings.json     # Custom keybindings
  extensions.txt       # Installed extensions (28 total)
shell/
  zshrc                # Portable .zshrc (oh-my-zsh, vi-mode, nvm)
  vimrc                # Vim config (clipboard integration)
git/
  gitconfig            # Git user, aliases, credential helpers
terminal/
  tmux.conf            # tmux config (mouse, vi-keys, Claude hook)
claude/
  settings.json        # Permissions, hooks, plugins, voice settings
  hooks/
    open-worktree-in-cursor.sh  # Opens worktree in Cursor after creation
  skills/
    check-cdk-deployment/      # Check AWS CodePipeline deploy status
```

Most Claude skills (jira, drupal-query, codex, email-inbox, etc.) live in
[RealtyMogul/claude-skills](https://github.com/RealtyMogul/claude-skills) and are
symlinked into `~/.claude/skills/`. To set those up:

```bash
git clone https://github.com/RealtyMogul/claude-skills.git ~/claude-skills
cd ~/claude-skills && ./setup.sh   # or manually symlink:
# ln -s ~/claude-skills/skills/* ~/.claude/skills/
```

## Key Preferences

- **Vi everywhere**: Cursor vim plugin, zsh-vi-mode (`jk` to escape), tmux vi-keys
- **Theme**: robbyrussell (zsh), Default Dark Modern (Cursor)
- **Editor**: relative line numbers, no auto-close brackets/quotes

## Updating

```bash
cd dev-settings

# Pull latest settings from this machine
cp ~/Library/Application\ Support/Cursor/User/settings.json cursor/
cp ~/Library/Application\ Support/Cursor/User/keybindings.json cursor/
cursor --list-extensions > cursor/extensions.txt
cp ~/.zshrc shell/zshrc        # review for secrets first!
cp ~/.vimrc shell/vimrc
cp ~/.gitconfig git/gitconfig
cp ~/.tmux.conf terminal/tmux.conf
cp ~/.claude/settings.json claude/settings.json
cp ~/.claude/hooks/* claude/hooks/
cp -R ~/.claude/skills/* claude/skills/

git add -A && git commit -m "Update settings" && git push
```

## Notes

- The `shell/zshrc` is sanitized — work-specific API keys, repo paths, and AWS config have been removed
- Cursor `settings.json` may reference work-specific paths (plpgsql, PHP) — review after install
- `git/gitconfig` excludes the work `hooksPath` and `promote-all` alias
