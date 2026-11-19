import type { Metadata } from 'next';
import './globals.css';
export const metadata: Metadata = { title: 'UX Studio — Pilotage UX & clients', description: 'Espace de travail pour agences digitales et consultants UX.' };
export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) { return <html lang="fr"><body>{children}</body></html>; }
