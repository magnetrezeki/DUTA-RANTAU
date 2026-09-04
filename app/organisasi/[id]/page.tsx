import Link from "next/link";
import { notFound } from "next/navigation";
import {
  ArrowLeft,
  CalendarDays,
  ChevronRight,
  FileText,
  Landmark,
  Lock,
  Mail,
  MessageSquareText,
  Palette,
  Sparkles,
  Users,
  Wallet,
} from "lucide-react";
import { getOrganization } from "@/lib/services/organizations";

export const dynamic = "force-dynamic";

const modules = [
  [Users, "Anggota", "Kelola anggota organisasi", "member.manage"],
  [CalendarDays, "Agenda & Event", "Kelola agenda dan event", "event.manage"],
  [MessageSquareText, "Rapat", "Rapat dan notulen organisasi", "meeting.manage"],
  [Mail, "Surat", "Surat masuk dan keluar", "letter.manage"],
  [FileText, "Dokumen & Arsip", "Dokumen organisasi", "document.manage"],
  [Wallet, "Keuangan", "Akses berdasarkan permission", "finance.view"],
] as const;

export async function generateMetadata({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = await params;
  const org = await getOrganization(id);

  return {
    title: org?.name ?? "Organisasi",
  };
}

export default async function Page({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = await params;
  const org = await getOrganization(id);

  if (!org || org.recordStatus !== "ACTIVE") {
    notFound();
  }

  const location = [org.city, org.state].filter(Boolean).join(", ");

  return (
    <div className="page org-office">
      <Link href="/organisasi" className="back">
        <ArrowLeft />
        Kembali ke organisasi
      </Link>

      <header className="office-head">
        <div className="org-logo large">
          <Landmark />
        </div>

        <div>
          <span className="eyebrow">
            {org.verification.replaceAll("_", " ")}
          </span>

          <h1>{org.name}</h1>

          <p>
            {org.type}
            {location ? ` · ${location}` : ""}
          </p>
        </div>

        <Link href="/organisasi/paket" className="office-plan">
          Lihat paket
        </Link>
      </header>

      <div className="office-stats">
        <div>
          <b>—</b>
          <span>Anggota</span>
        </div>

        <div>
          <b>—</b>
          <span>Agenda</span>
        </div>

        <div>
          <b>—</b>
          <span>Dokumen</span>
        </div>

        <div>
          <b>—</b>
          <span>Izin aktif</span>
        </div>
      </div>

      <Link
        href={`/organisasi/${id}/sekretaris`}
        className="org-ai org-ai-link"
      >
        <Sparkles />

        <div>
          <span>SEKRETARIS DIGITAL + PUBLIKASI</span>
          <h2>Staf komunikasi virtual organisasi</h2>
          <p>
            Buat surat, proposal, laporan, flyer, poster, kartu ucapan,
            undangan digital, dan ringkasan audio rapat.
          </p>

          <div className="ai-capabilities">
            <i>
              <FileText />
              Administrasi
            </i>
            <i>
              <Palette />
              Publikasi visual
            </i>
            <i>
              <MessageSquareText />
              Ringkasan rapat
            </i>
          </div>
        </div>

        <ChevronRight />
      </Link>

      <div className="office-modules">
        {modules.map(([Icon, title, meta, permission]) => (
          <article key={title}>
            <Icon />

            <div>
              <h2>{title}</h2>
              <p>{meta}</p>
              <code>{permission}</code>
            </div>

            <ChevronRight />
          </article>
        ))}
      </div>

      <div className="permission-panel">
        <div>
          <Lock />
          <h3>Isolasi data organisasi</h3>
          <p>
            Dokumen, publikasi, audio, dan keuangan hanya dapat diakses sesuai
            role dan paket organisasi.
          </p>
        </div>

        <code>organization_id = {org.id}</code>
      </div>
    </div>
  );
}
