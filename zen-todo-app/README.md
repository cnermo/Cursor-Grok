# Zen Todo (web + Android)

Local-first task list with nested subtasks. Built with **Expo Router** so the same app runs on web and Android.

v1 stores rows through a `TaskRepository` backed by Zustand persist (AsyncStorage / localStorage). The shape matches two SQLite tables so a later **Turso/libSQL** adapter can sit behind Vercel API routes without rewriting screens. Do not put a `.sqlite` file on Vercel’s filesystem.

## Run

```bash
cd zen-todo-app
npm install
npm run web
```

Expo Go: `npm start`, then scan the QR code.

Live web (Vercel): https://zen-todo-app-aot7.vercel.app

## Scripts

- `npm run web` — Metro web
- `npm run android` — Expo Android
- `npm run export:web` — static web export to `dist/` (Vercel)
- `npx eas-cli login && npx eas-cli build --platform android --profile preview` — internal APK (Expo account required; `eas.json` preview profile is already configured)

## Features (v1)

- Add / complete / edit / delete tasks
- Nested subtasks with `done/total` progress
- All / Active / Completed filters
- Dark, light, or system theme
- Offline persistence on the device

Out of scope: kanban, habits, auth, Turso wiring.
