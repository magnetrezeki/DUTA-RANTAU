import {
  PageHeader,
  SourceMeta,
  TrustBadge,
} from "@/components/ui";
import { SearchFilter } from "@/components/search-filter";
import {
  Building2,
  FileText,
  ShieldAlert,
  GraduationCap,
  BriefcaseBusiness,
  Plane,
} from "lucide-react";
import { getSources } from "@/lib/services/sources";

export const metadata = {
  title: "Layanan RI",
};

export const dynamic = "force-dynamic";

const cats = [
  [FileText, "Paspor & dokumen"],
  [ShieldAlert, "Perlindungan WNI"],
  [BriefcaseBusiness, "Ketenagakerjaan"],
  [GraduationCap, "Pendidikan"],
  [Plane, "Perjalanan"],
  [Building2, "Kantor perwakilan"],
] as const;

export default async function Page() {
  const sources = await getSources();

  const institutions: string[] = [
    ...new Set(
      sources
        .filter((s) => ["Situs resmi", "Instagram"].includes(s.channel))
        .map((s) => s.institution),
    ),
  ];

  return (
    <div className="page">
      <PageHeader
        eyebrow="SUMBER RESMI"
        title="Layanan Republik Indonesia"
        description="Temukan kanal resmi perwakilan RI. DUTA tidak menebak alamat, kontak, jam layanan, biaya, atau persyaratan."
      />

      <div className="notice official">
        <ShieldAlert />
        <div>
          <b>Informasi sumber terverifikasi, bukan detail prosedur</b>
          <p>
            Dokumen sumber yang diberikan memverifikasi identitas kanal.
            Detail operasional wajib diperiksa langsung pada sumber.
          </p>
        </div>
      </div>

      <div className="category-row">
        {cats.map(([Icon, label]) => (
          <button key={label}>
            <Icon />
            {label}
          </button>
        ))}
      </div>

      <SearchFilter placeholder="Cari institusi atau layanan…" />

      <div className="cards-list">
        {institutions.map((name: string) => {
          const src =
            sources.find(
              (s) =>
                s.institution === name &&
                s.channel === "Situs resmi",
            ) ??
            sources.find((s) => s.institution === name);

          if (!src) return null;

          return (
            <article className="source-card" key={name}>
              <div className="source-icon">
                <Building2 />
              </div>

              <div className="source-content">
                <TrustBadge />
                <h2>{name}</h2>
                <p>{src.category}</p>

                <SourceMeta
                  name={`${name} — ${src.channel}`}
                  date={src.lastChecked.toISOString().slice(0, 10)}
                  url={src.url}
                />
              </div>
            </article>
          );
        })}
      </div>
    </div>
  );
}

