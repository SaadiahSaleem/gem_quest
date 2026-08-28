# Gem Quest

Gem Quest is a polished match-3 puzzle game built with Flutter. It is playable in the browser and can be deployed to GitHub Pages with one workflow.

## Play locally

```bash
flutter pub get
flutter run -d chrome
```

## Build for web

```bash
flutter build web --release --base-href "/gem_quest/"
```

If your GitHub repository has a different name, replace `gem_quest` with your repo name.

## Deploy to GitHub Pages

1. Push this repo to GitHub.
2. In the repository settings, open Pages.
3. Set Source to "GitHub Actions".
4. The workflow in `.github/workflows/deploy-pages.yml` will build the web app and publish it automatically on every push to `main`.

The live URL will look like:

```text
https://<your-username>.github.io/gem_quest/
```

## Gameplay

- Match 3 or more gems to score points.
- Build combos for bigger rewards.
- Trigger special gems and clear more of the board.
- Reach the target before your moves run out.
