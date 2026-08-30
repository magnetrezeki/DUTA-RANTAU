import type { Metadata,Viewport } from 'next';import { AppShell } from '@/components/app-shell';import './globals.css';
export const metadata:Metadata={title:{default:'DUTA RANTAU — Rumah Digital Indonesia di Malaysia',template:'%s | DUTA RANTAU'},description:'Informasi, komunitas, kerja, pasar, organisasi dan bantuan untuk orang Indonesia di Malaysia.',manifest:'/manifest.webmanifest'};
export const viewport:Viewport={themeColor:'#071a3b',width:'device-width',initialScale:1};
export default function RootLayout({children}:{children:React.ReactNode}){return <html lang="id"><body><AppShell>{children}</AppShell></body></html>}

