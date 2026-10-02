'use client';
import { useState } from 'react';
import Link from 'next/link';
import { ArrowUpRight } from 'lucide-react';

export function NotificationRow({ id, title, body, createdAt, readAt }: { id: string; title: string; body: string; createdAt: string; readAt: string | null }) {
  const [read, setRead] = useState(Boolean(readAt));
  async function markRead() {
    if (read) return;
    const response = await fetch(`/api/notifications/${id}/read`, { method: 'POST' });
    if (response.ok) setRead(true);
  }
  return <button type="button" className="vp-row" onClick={markRead}><span><strong>{title}</strong><small>{body} · {new Date(createdAt).toLocaleDateString('id-ID')}</small></span><small>{read ? 'Dibaca' : 'Belum dibaca'} <ArrowUpRight size={14}/></small></button>;
}
