# Neovim Config — Dépendances & Setup

## Dépendances système

Installe les paquets suivants via le gestionnaire de ta distro.

| Paquet | Rôle |
|--------|------|
| `lua-language-server` | LSP Lua |
| `ripgrep` | requis par Telescope live_grep |
| `lazygit` | git TUI |
| `clang` | requis pour compiler tree-sitter-cli |
| `rust` / `cargo` | requis pour tree-sitter-cli |
| `jdk21` (OpenJDK 21+) | requis pour neotest-java |

```bash
# Arch
sudo pacman -S lua-language-server ripgrep lazygit clang rust jdk21-openjdk

# Ubuntu/Debian
sudo apt install lua-language-server ripgrep lazygit clang rustup default-jdk

# Fedora
sudo dnf install lua-language-server ripgrep lazygit clang rust cargo java-21-openjdk
```

## tree-sitter-cli

La version packagée dans la plupart des distros est trop ancienne pour nvim-treesitter.
Installe via cargo :

```bash
cargo install --locked tree-sitter-cli
```

Assure-toi que `~/.cargo/bin` est dans ton `$PATH`.

## jdtls (LSP Java)

```bash
# Arch (AUR)
paru -S jdtls

# Autres distros — installation manuelle
# Télécharge depuis https://download.eclipse.org/jdtls/milestones/
mkdir -p ~/.local/share/jdtls
tar -xzf jdt-language-server-*.tar.gz -C ~/.local/share/jdtls
```

Crée un wrapper `/usr/local/bin/jdtls` :
```bash
#!/bin/bash
exec ~/.local/share/jdtls/bin/jdtls "$@"
```
```bash
chmod +x /usr/local/bin/jdtls
```

## Dépendances npm (global)

```bash
npm install -g \
  typescript-language-server \
  typescript \
  @vue/language-server
```

## Variables d'environnement

À ajouter dans `~/.bashrc` ou `~/.zshrc` :

```bash
export JAVA_HOME=/path/to/jdk21   # adapte le chemin à ta distro
export PATH="$HOME/.cargo/bin:$PATH"
```

Pour trouver ton JAVA_HOME :
```bash
readlink -f $(which java) | sed 's|/bin/java||'
```

## Treesitter — parsers à installer

Dans Neovim :

```
:TSInstall java
:TSInstall lua
:TSInstall typescript
:TSInstall vue
```

## telescope-fzf-native — compilation manuelle

```bash
cd ~/.local/share/nvim/site/pack/*/opt/telescope-fzf-native.nvim
make
```

## neotest-java — téléchargement du jar JUnit

Dans Neovim :

```
:NeotestJava setup
```

## Patch requis pour Neovim 0.12 — neotest-java

Le plugin appelle le LSP dans un contexte async incompatible avec Neovim 0.12.
Patch à appliquer après installation :

```bash
nvim ~/.local/share/nvim/site/pack/core/opt/neotest-java/lua/neotest-java/command/binaries.lua
```

Remplacer la fonction `get_java_home` par :

```lua
local get_java_home = function(cwd)
    if cached_java_homes[cwd:to_string()] then
        return cached_java_homes[cwd:to_string()]
    end
    local java_home = os.getenv('JAVA_HOME')
    if java_home and java_home ~= '' then
        cached_java_homes[cwd:to_string()] = java_home
        return java_home
    end
    local client = deps.client_provider(cwd)
    logger.debug("Resolving Java home via JDTLS for cwd: " .. cwd:to_string())
    local cmd = {
        command = "java.project.getSettings",
        arguments = { vim.uri_from_fname(cwd:to_string()), { "org.eclipse.jdt.ls.core.vm.location" } },
    }
    local result_future = nio.control.future()
    client:request("workspace/executeCommand", cmd, function(err, res)
        assert(not err, "Error while getting Java home from lsp server: " .. vim.inspect(err))
        assert(not res.err, "Error while getting Java home from lsp server: " .. vim.inspect(res.err))
        result_future.set(res)
    end)
    local res = result_future.wait()
    cached_java_homes[cwd:to_string()] = res["org.eclipse.jdt.ls.core.vm.location"]
    return cached_java_homes[cwd:to_string()]
end
```

## Setup projet Maven multi-module

Toujours lancer Neovim depuis la **racine du projet** :

```bash
cd /chemin/vers/mon-projet
nvim
```

Chaque module doit avoir son propre `pom.xml` avec un parent pointant vers la racine.

Compiler le projet avant de lancer les tests (neotest utilise les classes compilées) :

```bash
mvn compile test-compile
```

---

## Raccourcis clavier

### Leader key
`<Space>` (Espace) est configuré comme touche leader.

### Navigation & Fichiers

| Raccourci | Action |
|-----------|--------|
| `-` | Ouvrir Oil (file explorer) |
| `<leader>sf` | Search Files (Telescope) |
| `<leader>sg` | Search Grep (Telescope) |
| `<leader>sr` | Search Recent files (Telescope) |
| `<leader>st` | Search TODOs (Telescope) |

### LSP (Language Server Protocol)

| Raccourci | Action |
|-----------|--------|
| `gd` | Go to Definition |
| `gD` | Go to Declaration |
| `gr` | Find References |
| `gI` | Go to Implementation |
| `gt` | Go to Type Definition |
| `K` | Hover Documentation |
| `<C-k>` | Signature Help (mode insertion) |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code Action |
| `<leader>ds` | Document Symbols |
| `<leader>ws` | Workspace Symbols |
| `<leader>f` | Format buffer |

### Diagnostics

| Raccourci | Action |
|-----------|--------|
| `<leader>e` | Show diagnostic (flottant) |
| `[d` | Previous diagnostic |
| `]d` | Next diagnostic |

### Tests (Neotest)

| Raccourci | Action |
|-----------|--------|
| `<leader>tt` | Test sous le curseur |
| `<leader>tf` | Tous les tests du fichier |
| `<leader>to` | Ouvrir le panneau de résultats |
| `<leader>mo` | Message output (test détaillé) |

### Git

| Raccourci | Action |
|-----------|--------|
| `<leader>lg` | Ouvrir LazyGit |
| `]h` | Next hunk (changement git) |
| `[h` | Previous hunk (changement git) |
| `<leader>hs` | Stage hunk |
| `<leader>hr` | Reset hunk |
| `<leader>hp` | Preview hunk |
| `<leader>hb` | Blame line |

### Autocomplétion (nvim-cmp)

| Raccourci | Action |
|-----------|--------|
| `<Tab>` | Sélectionner item suivant / expand snippet |
| `<S-Tab>` | Sélectionner item précédent |
| `<CR>` | Confirmer la sélection |
| `<C-Space>` | Ouvrir le menu manuellement |
| `<C-e>` | Fermer le menu |

### Text Objects & Surround (mini.nvim)

| Raccourci | Action |
|-----------|--------|
| `vaf` / `vif` | Visual autour/dans function |
| `vac` / `vic` | Visual autour/dans class |
| `sa"` | Add surround (guillemets) |
| `sd"` | Delete surround |
| `sr"'` | Replace surround (" par ') |

---

## Plugins inclus

- **Mason** — Gestionnaire de paquets LSP/formatters/linters
- **nvim-cmp** — Autocomplétion avec sources LSP, snippets, buffer
- **Telescope** — Fuzzy finder avec fzf-native
- **Oil** — File explorer éditable
- **Treesitter** — Syntax highlighting et parsing
- **Conform** — Formatting avancé
- **Gitsigns** — Indicateurs git dans la gouttière
- **Which-key** — Affichage des keymaps disponibles
- **mini.nvim** — Text objects, surround, autopairs
- **todo-comments** — Highlight TODO/FIXME/NOTE
- **neotest + neotest-java** — Framework de testing pour Java
- **LazyGit** — Interface git TUI
- **catppuccin** — Thème de couleurs

---

## Structure du projet

```
~/.config/nvim/
├── init.lua          -- Configuration principale
└── README.md         -- Ce fichier
```

La configuration utilise l'API native Neovim 0.12+ (`vim.lsp.config`, `vim.pack`) sans dépendance à nvim-lspconfig pour la configuration LSP.
