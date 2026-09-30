import type { Metadata,Viewport } from 'next';import { AppShell } from '@/components/app-shell';import { publicRobots,siteUrl } from '@/lib/seo';import './globals.css';import './r21f.css';import './jaga-diri-mobile.css';import './visual-port.css';
export function generateMetadata():Metadata{return {title:{default:'DUTA RANTAU — Rumah Digital Indonesia di Malaysia',template:'%s | DUTA RANTAU'},description:'Informasi, komunitas, kerja, pasar, organisasi dan bantuan untuk orang Indonesia di Malaysia.',metadataBase:siteUrl,robots:publicRobots(),openGraph:{type:'website',locale:'id_ID',siteName:'DUTA RANTAU'},twitter:{card:'summary'},manifest:'/manifest.webmanifest',icons:{icon:'/logo.png'}}}
export const viewport:Viewport={themeColor:'#071a3b',width:'device-width',initialScale:1};
export default function RootLayout({children}:{children:React.ReactNode}){return <html lang="id"><body><AppShell>{children}</AppShell></body></html>}

