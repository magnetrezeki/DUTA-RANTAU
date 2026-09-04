import Link from "next/link";
import { notFound } from "next/navigation";
import { ArrowLeft, Sparkles } from "lucide-react";
import { SecretaryWorkspace } from "@/components/secretary-workspace";
import { getOrganization } from "@/lib/services/organizations";

export const dynamic = "force-dynamic";

export async function generateMetadata() {
  return {
    title: "Sekretaris Digital & Publikasi",
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

  return (
    <div className="page secretary-page">
      <Link href={`/organisasi/${id}`} className="back">
        <ArrowLeft />
        Kembali ke Kantor Digital
      </Link>

      <header className="secretary-head">
        <div>
          <span className="eyebrow">STAF KOMUNIKASI VIRTUAL</span>

          <h1>Sekretaris Digital & Publikasi</h1>

          <p>
            {org.name} · Dokumen, materi komunikasi, dan ringkasan rapat
            dalam satu ruang kerja.
          </p>
        </div>

        <span className="plan-pill">
          <Sparkles />
          ORGANISASI PRO
        </span>
      </header>

      <SecretaryWorkspace
        organizationName={org.name}
        plan="PRO"
      />
    </div>
  );
}
