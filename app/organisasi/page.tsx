import Link from "next/link";
import { PageHeader } from "@/components/ui";
import { ArrowRight, Building2, FileText, Landmark, Users, Wallet } from "lucide-react";
import { getOrganizations } from "@/lib/services/organizations";

export const metadata = {
  title: "Organisasi",
};

export const dynamic = "force-dynamic";

export default async function Page() {
  const organizations = await getOrganizations().catch(() => []);

  return (
    <div className="page">
      <PageHeader
        eyebrow="KANTOR DIGITAL"
        title="Organisasi Anda"
        description="Jelajahi organisasi yang tersedia. Pendaftaran dan pengelolaan organisasi belum dibuka untuk beta publik awal."
      />

      <div className="notice"><Building2/><div><b>Ruang organisasi sedang dibatasi kepada penemuan.</b><p>DUTA tidak memaparkan pakej, pembayaran atau tindakan pendaftaran yang belum tersedia.</p></div></div>

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

