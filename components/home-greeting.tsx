'use client'

import { useEffect, useState } from 'react'

type MalaysiaNow = {
  greeting: string
  date: string
}

function getMalaysiaNow(): MalaysiaNow {
  const parts = new Intl.DateTimeFormat('id-ID', {
    timeZone: 'Asia/Kuala_Lumpur',
    weekday: 'long',
    day: '2-digit',
    month: 'long',
    hour: '2-digit',
    minute: '2-digit',
    hour12: false,
  }).formatToParts(new Date())

  const get = (type: string) =>
    parts.find((part) => part.type === type)?.value ?? ''

  const hour = Number(get('hour'))
  const minute = Number(get('minute'))
  const totalMinutes = hour * 60 + minute

  let greeting = 'Selamat malam'

  if (totalMinutes >= 5 * 60 && totalMinutes < 11 * 60) {
    greeting = 'Selamat pagi'
  } else if (totalMinutes >= 11 * 60 && totalMinutes < 15 * 60) {
    greeting = 'Selamat siang'
  } else if (totalMinutes >= 15 * 60 && totalMinutes < 19 * 60 + 30) {
    greeting = 'Selamat sore'
  }

  return {
    greeting,
    date: `${get('weekday')}, ${get('day')} ${get('month')}`,
  }
}

export function HomeGreeting() {
  const [now, setNow] = useState<MalaysiaNow | null>(null)

  useEffect(() => {
    const update = () => {
      setNow(getMalaysiaNow())
    }

    update()

    const timer = window.setInterval(update, 60_000)

    return () => {
      window.clearInterval(timer)
    }
  }, [])

  if (!now) {
    return (
      <>
        <span className="eyebrow">-</span>
        <h1>Selamat datang, <em>Kawan Rantau</em> ??</h1>
      </>
    )
  }

  return (
    <>
      <span className="eyebrow">{now.date}</span>
      <h1>{now.greeting}, <em>Kawan Rantau</em> ??</h1>
    </>
  )
}
