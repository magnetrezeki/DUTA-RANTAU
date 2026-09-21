'use client';
import { useState } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { ArrowUpRight, Mic } from 'lucide-react';
import styles from '@/app/landing-r21.module.css';
export function LandingComposer(){const [question,setQuestion]=useState('');const router=useRouter();return <form className={styles.ask} onSubmit={event=>{event.preventDefault();router.push(question.trim()?`/tanya?q=${encodeURIComponent(question.trim())}`:'/tanya')}}><label htmlFor="question">Apa yang ingin Anda cari?</label><textarea id="question" rows={2} placeholder="Contoh: saya mahu urus paspor" value={question} onChange={event=>setQuestion(event.target.value)}/><div><Link href="/tanya"><Mic size={17}/>Gunakan suara <ArrowUpRight size={15}/></Link><button className={styles.cta} type="submit">Tanya DUTA <ArrowUpRight size={17}/></button></div></form>}
