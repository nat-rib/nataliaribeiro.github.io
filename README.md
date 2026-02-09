# Natalia Ribeiro - Portfolio & Blog

Personal portfolio and blog built with [Hugo](https://gohugo.io/) and [PaperMod](https://github.com/adityatelange/hugo-PaperMod) theme.

## 🚀 Quick Start

### Local Development

```bash
# Clone with submodules
git clone --recurse-submodules https://github.com/nat-rib/nataliaribeiro.github.io.git
cd nataliaribeiro.github.io

# Start local server
hugo server -D

# Build for production
hugo --minify
```

### Adding Blog Posts

Create a new post in `content/posts/`:

```bash
hugo new posts/my-new-post.md
```

Edit the file with your content in Markdown format.

## 📁 Structure

```
.
├── content/
│   ├── about/          # About page
│   ├── contact/        # Contact page
│   ├── experience/     # Work experience
│   ├── posts/          # Blog posts
│   └── projects/       # Projects showcase
├── static/
│   └── images/         # Images and assets
├── themes/
│   └── PaperMod/       # Hugo theme (submodule)
└── hugo.yaml           # Site configuration
```

## 🔧 Deployment

This site is automatically deployed to GitHub Pages via GitHub Actions when pushing to `main`.

## 📝 License

Content © Natalia Ribeiro. Theme under MIT License.
