# Demo Video

This folder contains the HyperFrames source plan for the public Codex Meter demo.

- `DESIGN.md` defines the visual identity.
- `index.html` is the HyperFrames composition source.
- `script/render_demo_video.sh` renders the current local MP4 demo from the same public screenshots.

The preferred production path is:

```bash
npx hyperframes lint docs/demo
npx hyperframes inspect docs/demo --samples 12
npx hyperframes render docs/demo --output ../outputs/codex-meter-demo.mp4 --quality standard
```

If the HyperFrames CLI is unavailable, use the local-safe fallback renderer:

```bash
./script/render_demo_video.sh
```

The fallback renderer uses only `ffmpeg` and the public screenshots in `docs/assets/`.
