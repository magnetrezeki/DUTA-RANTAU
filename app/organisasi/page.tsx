import Link from "next/link";
import { PageHeader } from "@/components/ui";
import {
  ArrowRight,
  Building2,
  FileText,
  Landmark,
  Plus,
  Sparkles,
  Users,
  Wallet,
} from "lucide-react";
import { getOrganizations } from "@/lib/services/organizations";

export const metadata = {
  title: "Organisasi",
};

export const dynamic = "force-dynamic";

export default async function Page() {
  const organizations = await getOrganizations();

  return (
    <div className="page">
      <PageHeader
        eyebrow="KANTOR DIGITAL"
        title="Organisasi Anda"
        description="Kelola anggota, kegiatan, administrasi, publikasi, rapat, surat, dan kas sesuai paket serta izin organisasi."
        action={
          <button className="primary">
            <Plus />
            Buat organisasi
          </button>
        }
      />

      <Link href="/organisasi/paket" className="package-banner">
        <div>
          <span>PAKET DUTA ORGANISASI</span>
          <h2>Dari halaman organisasi gratis hingga staf virtual PRO</h2>
          <p>Gratis · Organisasi+ RM49.90/bulan · PRO RM99.90/bulan</p>
        </div>
        <b>
          Lihat paket <ArrowRight />
        </b>
      </Link>

      <div className="org-summary">
        <div>
          <Building2 />
          <span>
            <b>{organizations.length}</b> organisasi
          </span>
        </div>

        <div>
          <Users />
          <span>
            <b>—</b> anggota
          </span>
        </div>

        <div>
          <FileText />
          <span>
            <b>—</b> dokumen
          </span>
        </div>
      </div>

      <div className="cards-list">
        {organizations.map((org: Awaited<ReturnType<typeof getOrganizations>>[number]) => (
          <article className="org-card" key={org.id}>
            <div className="org-logo">
              <Landmark />
            </div>

            <div>
              <span className="eyebrow">
                {org.verification.replaceAll("_", " ")}
              </span>

              <h2>{org.name}</h2>

              <p>
                {org.type}
                {org.city || org.state
                  ? ` · ${[org.city, org.state].filter(Boolean).join(", ")}`
                  : ""}
              </p>

              {org.description && <span>{org.description}</span>}
            </div>

            <Link
              className="open-org"
              href={`/organisasi/${org.id}`}
            >
              Buka kantor <ArrowRight />
            </Link>
          </article>
        ))}
      </div>

      <section className="secretary-promo">
        <Sparkles />

        <div>
          <span>ORGANISASI+ & PRO</span>
          <h2>Sekretaris Digital + Publikasi</h2>
          <p>
            Staf komunikasi virtual untuk dokumen, proposal, laporan, poster,
            flyer, kartu ucapan, dan undangan digital.
          </p>
        </div>

        {organizations[0] ? (
          <Link href={`/organisasi/${organizations[0].id}/sekretaris`}>
            Buka ruang kerja <ArrowRight />
          </Link>
        ) : (
          <Link href="/organisasi/paket">
            Lihat paket <ArrowRight />
          </Link>
        )}
      </section>

      <section className="permission-panel">
        <div>
          <Wallet />
          <h3>Data organisasi terlindungi</h3>
          <p>
            Keuangan, dokumen, anggota, publikasi, dan aksi AI hanya dapat
            diakses berdasarkan peran dan permission organisasi.
          </p>
        </div>

        <code>finance.view · publication.approve · ai.use</code>
      </section>
    </div>
  );
}

