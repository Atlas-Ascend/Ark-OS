import type { ReactNode } from 'react';
import './globals.css';

export const metadata = {
  title: 'Ghost Atlas // ARK Ω',
  description: 'Firmware-grade operator cockpit for the Ghost Atlas estate',
};

export default function RootLayout({children}:{children:ReactNode}) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
